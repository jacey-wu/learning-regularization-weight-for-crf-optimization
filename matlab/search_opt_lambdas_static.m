%% -------------------- Configuration --------------------
config = config_experiment(1);

% Get inputs
% -- all images
data_path = fullfile(config.path.datasets, config.expr.dataset);
all_ims = dir(fullfile(data_path, 'im', '*.jpg'));

% -- pre-defined lambda space
lamb_list = config.expr.lambda_list;

% Set outputs
out_dir = ['optL_static_', config.expr.dataset, '_', datestr(now, 'yyyy-mm-dd-HHMMSS')];
mkdir(fullfile(config.path.output, out_dir));
% fileId = fopen(fullfile('tmp_results', outDir, 'f-measure-opt.txt'), 'w');

% Get meta data
num_ims   = numel(all_ims);
num_lambs = numel(lamb_list);
F = zeros(num_ims, num_lambs);

%% -------------------- Experiment --------------------
%  Run graph cut with each lambda value in a pre-defined list
%  'lamb-spectrum' and obtain binary salient segmentation. Compute and 
%  store F-measure(with \beta = 0.3) for each segmentation
tic;
for im_idx = 1:10 %num_ims
    
    try
    input_file = all_ims(im_idx).name;
    [~, f_name] = fileparts(input_file);

    in_im = imread(fullfile(data_path, 'im', input_file));
    gt_im = imread(fullfile(data_path, 'gt', sprintf('%s.png', f_name)));
    cm_im = imread(fullfile(data_path, 'cm', input_file));
    cm_im = im2double(cm_im);

    for lamb_idx = 1:num_lambs

        % Get segmentation
        lambda = lamb_list(lamb_idx);
        seg_map = get_salient_sgmt(in_im, cm_im, lambda);

        % Compute F-measure
        F(im_idx, lamb_idx) = compute_f_measure(seg_map, gt_im);
        
%         % Write to .jpg image
%         outputFile = fullfile('./tmp_results', outDir, sprintf('%s-%s.jpg', ...
%             fName, num2str(lambda)));
%         segMap(segMap == 1) = 255;   % Rescale sgmt to viewable image
%         imwrite(segMap, outputFile, 'jpg');
    end
    
    % Report execution error
    catch
        fprintf('Failed to process image %s, with imIdx = %d\n', ...
            inputFile, imIdx);
    end
    
    % Print progress status
    if (mod(im_idx, 1) == 0)
        fprintf('Finished calculation for image with im_idx = %d\n', im_idx);
    end

    % Deallocate memory
    clear in_im gt_im cm_im segMap;
end

% Save computed variables:
% -- lambda list: L
% -- the max F measure for each image: maxF
% -- the index of lamdba that gives the maxF in L: maxI
% -- the value of the optimal lambda

L = lamb_list;
[maxF, maxI] = max(F, [], 2);
optL = L(maxI)';
save(fullfile('tmp_results', out_dir, 'f_measure.mat'), 'F', 'L', 'maxF', 'maxI', 'optL', '-mat');
toc;

%% -------------------- Visualization --------------------
%  Plot the histograms of 1). the optimal lambda distribution; 2). the
%  average F-measure for each fixed lambda.

valset = 1:num_lambs;
catnames = cellstr(num2str(lamb_list'))';

% 1). Histogram of the optimal lambda distribution
catdata = categorical(maxI, valset, catnames);
figure; h_optL = histogram(catdata);
title(sprintf('\lambda_{opt} distribution (%s)', config.expr.dataset));

fprintf('Values in the lambda_opt distribution (%s)', config.expr.dataset);
for lamb_idx = 1:num_lambs
    fprintf('Lambda = %10s \t image count = %d\n', ...
        char(h_optL.Categories(lamb_idx)), h_optL.Values(lamb_idx));
end

% 2). Histogram of the average F-measure for each fixed lambda.
avgF = sum(F, 1)./num_ims;
figure; h_avgF = histogram('Categories', catnames, 'BinCounts', avgF);
title(sprintf('Average F-measure for each \lambda_{fixed} (%s)', ... 
    config.expr.dataset))

fprintf('Values in the average F-measure for each fixed lambda (%s)', ...
     config.expr.dataset);
for lamb_idx = 1:num_lambs
    fprintf('Lambda = %10s \t image count = %d\n', ...
        char(h_optL.Categories(lamb_idx)), h_optL.Values(lamb_idx));
end


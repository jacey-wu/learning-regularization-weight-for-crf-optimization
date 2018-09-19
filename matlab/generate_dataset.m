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

% Get meta data
num_ims   = numel(all_ims);
num_lambs = numel(lamb_list);
F = zeros(num_ims, num_lambs);

lamb_path = './tmp_results/DUT-OMRON_256';
im_path   = './tmp_results/DUT-OMRON_256';
imdb = dir(fullfile(im_path, 'im/*.jpg'));

expr2  = load(fullfile(lamb_path, 'optL_static_pow2_DUT-OMRON' ,'f_measure.mat'));
% expr10 = load(fullfile(lamb_path, 'cm_orig_optL_static_pow10', 'f_measure.mat'));
numImgs = numel(imdb);

% Set output directory
convDataDir = fullfile('tmp_results', [datestr(now, 'mm-dd-HHMMSS'), '_ECSSD_eval']);
mkdir(convDataDir);
subdirs = {'im', 'gt', 'cm', 'sgmt', 'lb_pow2'};
for sdirIdx = 1:numel(subdirs)
    mkdir(fullfile(convDataDir, subdirs{sdirIdx}));
end

%% Construct dataset (current)

% Partition data
for imIdx = 1:numImgs
    inputFile = imdb(imIdx).name;
    [~, fName] = fileparts(inputFile);

    in_im = imread(fullfile(im_path, 'im', inputFile));
    sgmt_im = imread(fullfile(im_path, 'gt', sprintf('%s.png', fName)));
    cm_im = imread(fullfile(im_path, 'cm', inputFile));

    % Compute sgmt using cm_im and threashold = 0.5
    sgmt = cm_im;
    sgmt(sgmt > 255/2) = 255;
    sgmt(sgmt <= 255/2) = 0;
    
    lamb_2 = expr2.optL(imIdx);
    
    imwrite(in_im, fullfile(convDataDir, 'im', sprintf('%s.jpg', fName)), 'jpg');
    imwrite(sgmt_im, fullfile(convDataDir, 'gt', sprintf('%s.png', fName)), 'png');
    imwrite(cm_im, fullfile(convDataDir, 'cm', sprintf('%s.jpg', fName)), 'jpg');
    imwrite(sgmt, fullfile(convDataDir, 'sgmt', sprintf('%s.png', fName)), 'png');
    
    fileId = fopen(fullfile(convDataDir, 'lb_pow2', sprintf('%s.txt', fName)), 'w');
    fprintf(fileId, '%.4f\n', lamb_2);
    fclose(fileId);

    % Deallocate memory
    clear in_im gt_im cm_im sgmt;
end


%% -------------------- Configuration --------------------
config = config_experiment(1);

% Get inputs
% -- all images
data_path = fullfile(config.path.datasets, config.expr.dataset);
imdb = dir(fullfile(data_path, 'im', '*.jpg'));

% -- pre-defined lambda space
lamb_list = config.expr.lambda_list;

% Set outputs
opt_lamb_search_dir = ['optL_static_', config.expr.dataset, '_', datestr(now, 'yyyy-mm-dd-HHMMSS')];
mkdir(fullfile(config.path.output, out_dir));
opt_lamb_search_res = fullfile('tmp_results', opt_lamb_search_dir, 'f_measure.mat');

% Get meta data
num_ims   = numel(imdb);
num_lambs = numel(lamb_list);
F = zeros(num_ims, num_lambs);

%%
search_opt_lambdas_static();
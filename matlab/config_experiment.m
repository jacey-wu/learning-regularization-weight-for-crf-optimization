% The config file for lambda selection experiment
function config = config_experiment(is_lib_built)

% Config paths
config = [];
config.path.root = '.';
config.path.datasets     = fullfile(config.path.root, 'datasets');
config.path.output       = fullfile(config.path.root, 'tmp_results');
config.path.graphcut_lib = fullfile(config.path.root, 'libs', 'Bk_matlab');
config.path.util_lib     = fullfile(config.path.root, 'utils');
addpath(config.path.graphcut_lib);
addpath(config.path.util_lib);

% Config expr params
% config.Expr.lambdaList = power(10, -2:1:5);
config.expr.lambda_list = pow2(-2:1:17);
config.expr.dataset = 'PASCAL';

% Build GraphCut_lib
if (~is_lib_built)
    BK_BuildLib; disp('Built GraphCut_lib');
    BK_LoadLib;  disp('Loaded Graphcut_lib');
end

end
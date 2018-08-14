% Gets labeling of salient segmentation using graph cut
%
% @param in_im    A RGB input image
% @param cm_im    Confident measure map of in_im
% @param lambda   The scale factor for pairwise potential
%
% @return sgmt    A 0/1 binary segmentation of salient object
% @return eTotal  The energy sum of data term and pair-wise term

function [sgmt, eTotal] = ...
get_salient_sgmt(in_im, cm_im, lambda)

[row, col, ~] = size(in_im);

% Compute costs
D = [cm_im(:), 1 - cm_im(:)]';
D = -log(D + eps);              % Data term: obj, bkg

metaW = compute_n_link_weights(in_im, lambda);
N1 = metaW(:, 1);   % [NR;  NT]
N2 = metaW(:, 2);   % [NRR; NTT]
NW = metaW(:, 3);   % [WR;  WT]
NZ = zeros(size(NW, 1), 1);
W = [N1 N2 NZ NW NW NZ]; 

% Construct graph
hdl = BK_Create(row * col);
BK_SetUnary(hdl, D);
BK_SetPairwise(hdl, W);

% Optimization
eTotal = BK_Minimize(hdl);
map = BK_GetLabeling(hdl);
BK_Delete(hdl);

% Compute segmentation
% map(map == 1) = 1; % obj
map(map == 2) = 0;   % bkg
sgmt = reshape(map, [row, col]);


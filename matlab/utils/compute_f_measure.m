function f_measure = compute_f_measure(eval_im, gt_im, beta)
% Calculate the F-measure of labeled image w.r.t. ground truth image.
% Define F-meaure as:
%   F_{beta} = 
%       (1 + beta^2) * Precision * Recall / (beta^2 * Precision + Recall)
% where beta = 0.3

if nargin < 3
    beta = 0.3;
end

% if pixel intensities in [0, 255], regulate to binary label
if max(eval_im(:)) > 1
    eval_im(eval_im < 128) = 0;
    eval_im(eval_im >= 128) = 1;
else
    eval_im(eval_im < 0.5) = 0;
    eval_im(eval_im >= 0.5) = 1;
end
% if pixel intensities in [0, 255], regulate to binary label
if max(gt_im(:)) > 1
    gt_im(gt_im < 128) = 0;
    gt_im(gt_im >= 128) = 1;
end

precision = sum(sum(eval_im & gt_im, 1), 2) / ...
    max(sum(sum(eval_im, 1), 2), eps);
recall    = sum(sum(eval_im & gt_im, 1), 2) / ...
    sum(sum(gt_im, 1), 2);

f_measure = (1 + beta^2) * precision * recall / ...
    max((beta^2 * precision + recall), eps);
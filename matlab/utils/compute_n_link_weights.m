% Computes the weights of n-links in a 4-connected neighboring system using
% Guassian weighting.
%
%                   Wpq = exp{ -(Ip - Iq)^2 / 2*sigma },
% 
% where sigma is the average squared difference between neighboring pixel
% intensities.

function W = compute_n_link_weights(im, lambda)

[row, col, ~] = size(im);

im = double(sum(im, 3)) / 3;

sigma = compute_sigma(im);

I = 1:row*col;
I = reshape(I,row,col);

NR = I(:,1:col-1);
NR = NR(:);
NRR = I(:,2:col);
NRR = NRR(:);

NT = I(2:row,:);
NT = NT(:);
NTT = I(1:row-1,:);
NTT = NTT(:);

epsilon = eps;

WR = epsilon + lambda * exp(-((im(NR)-im(NRR)).^2)   ./(2*sigma)  );
WT = epsilon + lambda * exp(-((im(NT)-im(NTT)).^2)   ./(2*sigma)  );

W = [NR NRR WR; NT NTT WT];


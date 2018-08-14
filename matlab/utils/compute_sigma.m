% assumes grayscale image im
% Computes the average squared difference between neighboring pixel
% intensities.
%     sigma = sum_{i=1}^{r-1}( sum_{j=1}^{c-1}( 
%               (I[i,j]-I[i+1,j])^2 + (I[i,j]-I[i,j+c])^2 ))
%
% @param im    a greyscale image
% @return sigma    the average squared intensity differences

function sigma = compute_sigma(im)

[row, col] = size(im);

S = sum(sum((im(:,1:end-1,:) - im(:,2:end,:)) .^ 2, 1), 2) ...
    + sum(sum((im(1:end-1,:,:) - im(2:end,:,:)) .^ 2, 1), 2);

S = S / (row*(col-1)+col*(row-1));
sigma = sum(S);

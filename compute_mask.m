function mask = compute_mask (difference, threshold)
% compute_mask generates a binary mask from a difference image using a fixed threshold.
%
% input:
%    difference - The absolute difference image (assumed to be of type double)
%    threshold  - A scalar value; pixels with intensity > threshold are marked as 1
%    
% output: 
%    mask  - A logical binary mask (same size as input image), where 1 indicates significant change and 0 indicates no change
%
%

% Threshold the difference image
    mask = difference > threshold;
% Convert to logical type (optional, but useful for visualization and further processing)
    mask = logical(mask);



end
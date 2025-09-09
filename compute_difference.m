function difference = compute_difference(gray_image1, gray_image2)
% compute_difference : computes the absolute difference between two grayscale images.
%
% input :
%     gray_image1 - the first grayscale image 
%     gray_image2 - the second grayscale image (already preprocessed and aligned to gray_image1)
%
%% output :
%     difference  - Absolute difference image showing pixel-wise intensity changes
%
% Note:
%   Both input images must be pre-aligned (e.g., through rotation and translation)
%
%


% Convert input images to double for accurate subtraction
    gray_image1 = double(gray_image1);
    gray_image2 = double(gray_image2);

% Compute the absolute difference image
    difference = abs(gray_image1 - gray_image2);



end
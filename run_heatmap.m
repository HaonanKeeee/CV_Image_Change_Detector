function run_heatmap(img1, img2, ax, idx1, idx2, image_timestamps)
%RUN_HEATMAP Display heatmap of pixel differences between two images
%
% Inputs:
%   img1             - Baseline RGB image
%   img2             - Comparison RGB image
%   ax               - Axes handle for display
%   idx1             - Index of baseline image
%   idx2             - Index of comparison image
%   image_timestamps - Cell array of timestamps

gray1 = im2gray(img1);
gray2 = im2gray(img2);

diff = compute_difference(gray1, gray2);

imagesc(ax, diff);
axis(ax,'image'); 
axis(ax,'off');
colormap(ax,'hot');
cb = colorbar(ax);
cb.Label.String = 'Pixel Difference';

title(ax, sprintf('Difference Heatmap (%s vs %s)', ...
    image_timestamps{idx1}, image_timestamps{idx2}));
end

function run_overlay(ax, img1, img2, threshold, timestamp1, timestamp2, type_str)
%RUN_OVERLAY Show overlay difference between two images
%
% Inputs:
%   ax         - Axes handle for display
%   img1       - Baseline RGB image
%   img2       - Comparison RGB image
%   threshold  - Threshold value
%   timestamp1 - String, timestamp for img1
%   timestamp2 - String, timestamp for img2
%   type_str   - 'All' | 'Major' | 'Minor'

gray1 = rgb2gray(img1);
gray2 = rgb2gray(img2);

diff = compute_difference(gray1, gray2);
mask = compute_mask(diff, threshold);

% Additional filtering based on Change Type
switch lower(type_str)
    case 'major'
        CC = bwconncomp(mask);
        sizes = cellfun(@numel, CC.PixelIdxList);
        area_thresh = 500;
        keep_idx = find(sizes >= area_thresh);
        mask = false(size(mask));
        for k = keep_idx
            mask(CC.PixelIdxList{k}) = true;
        end

    case 'minor'
        CC = bwconncomp(mask);
        sizes = cellfun(@numel, CC.PixelIdxList);
        area_thresh = 500;
        keep_idx = find(sizes < area_thresh);
        mask = false(size(mask));
        for k = keep_idx
            mask(CC.PixelIdxList{k}) = true;
        end

    case 'all'

    otherwise
        error('Unknown Change Type: %s', type_str);
end

% Build overlay
overlay = im2double(img2);
ch1 = overlay(:,:,1);
ch2 = overlay(:,:,2);
ch3 = overlay(:,:,3);
ch1(mask) = 1;
ch2(mask) = 0;
ch3(mask) = 1;
overlay(:,:,1) = ch1;
overlay(:,:,2) = ch2;
overlay(:,:,3) = ch3;

combined = [im2double(img1), overlay];

imshow(combined, 'Parent', ax);
axis(ax, 'off');
axis(ax, 'image');

width1 = size(img1,2);
hold(ax,'on');
line(ax, [width1 width1], [1 size(img1,1)], 'Color',[0 1 1], 'LineWidth',2);
hold(ax,'off');

title(ax, sprintf('Left: Original (%s) | Right: Difference Highlight (%s vs %s)', ...
    timestamp1, timestamp1, timestamp2));
end

function infoText = analysis_selected_category(img1, img2, selectedLabel, ax)
% ANALYSIS_SELECTED_CATEGORY
% Classify both images and compare the selected category.
% Highlights the category area in the comparison image.
%
% INPUTS:
%   img1 - RGB baseline image
%   img2 - RGB comparison image
%   selectedLabel - string, category name (e.g., 'Vegetation')
%   ax - axes handle to display overlay
%
% OUTPUT:
%   infoText - string summarizing the result

% Convert images to HSV
hsv1 = rgb2hsv(img1);
hsv2 = rgb2hsv(img2);

% Get classification labels and masks
[labels, cat1] = classify_image(hsv1);
[~, cat2] = classify_image(hsv2);

% Find index of selected category
idx = find(strcmp(labels, selectedLabel));
if isempty(idx)
    error('Selected category not found.');
end

% Count pixels
count1 = nnz(cat1 == idx);
count2 = nnz(cat2 == idx);

% Compute percentage change
if count1 == 0
    pctChange = NaN;
    pctText = 'undefined (no pixels in reference image)';
    trend = 'N/A';
else
    delta = count2 - count1;
    pctChange = abs((delta / count1) * 100);
    pctText = sprintf('%.2f%%', pctChange);

    if delta > 0
        trend = 'increased';
    elseif delta < 0
        trend = 'decreased';
    else
        trend = 'No change';
    end
end


infoText = sprintf('Category "%s": reference image has %d pixels, comparison image has %d pixels. Compared to the reference image, %s %s by %s.', ...
    selectedLabel, count1, count2, selectedLabel, trend, pctText);

% Define colors consistent with preclassification_overview
colors = {
    [0.6 0.7 0.85], % Snow/Ice
    [1 1 0],        % Sand
    [0 1 0],        % Vegetation
    [0.7 0 1],      % Urban
    [0 0 1],        % Water
    [1 0.5 0],      % BareSoil
    [1 0 0]         % Others
};
c = colors{idx};

% Create colored overlay for the selected category
mask = (cat2 == idx);
overlay = zeros(size(img2));
for ch = 1:3
    overlay(:,:,ch) = mask * c(ch);
end

% Display overlay
cla(ax);
imshow(img2, 'Parent', ax);
hold(ax, 'on');
h = imshow(overlay, 'Parent', ax);
set(h, 'AlphaData', (sum(overlay,3) > 0) * 0.7);
title(ax, sprintf('Highlighted "%s" in Comparison Image', selectedLabel));
hold(ax, 'off');

end

function [labels, cat] = classify_image(hsv)
% CLASSIFY_IMAGE
% Helper function: HSV-based classification of an image.
%
% INPUT:
%   hsv - HSV image
% OUTPUT:
%   labels - category names
%   cat - classification mask

H = hsv(:,:,1) * 360;
S = hsv(:,:,2);
V = hsv(:,:,3);
[Hn, W] = size(H);
cat = zeros(Hn, W);

% 1: Snow/Ice
idx = V > 0.85 & S < 0.2;
cat(idx) = 1;

% 2: Sand
idx = cat==0 & H>=25 & H<=60 & S<0.5 & V>0.3;
cat(idx) = 2;

% 3: Vegetation
idx = cat == 0 & H >= 60 & H <= 150 & S > 0.2;
cat(idx) = 3;

% 4: Urban
idx = cat == 0 & H >= 30 & H <= 60 & S < 0.4 & V >= 0.3 & V <= 0.6;
cat(idx) = 4;

% 5: Water
idx = cat == 0 & H >= 170 & H <= 270 & S > 0.15 & V <= 0.85;
cat(idx) = 5;

% 6: Bare Soil
idx = cat == 0 & ...
      (H>=0 & H<=60) & ...
      S >0.10 & ...
      V >=0.05 & V <=0.70;
cat(idx)=6;

% 7: Others
idx = cat == 0;
cat(idx) = 7;

labels = {'White:Snow/Ice/Rooftop','Light YellowGrey:Sand/Urban','Green:Vegetation','Grey:Urban/Shadow','Blue:Water/Shadow','Brown:BareSoil/Rooftop','Others'};
end

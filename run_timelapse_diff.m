function timelapse_images = run_timelapse_diff(imgs, image_timestamps, threshold, ax, slider, timestampLabel)
%RUN_TIMELAPSE_DIFF Generate and display time-lapse difference overlays.
%
% Inputs:
%   imgs             - Cell array of RGB images
%   image_timestamps - Cell array of timestamps
%   threshold        - Threshold value
%   ax               - Axes handle for display
%   slider           - Slider handle
%   timestampLabel   - Label handle
%
% Output:
%   timelapse_images - Cell array of overlay images

n = length(imgs);
base_gray = im2gray(imgs{1});
timelapse_images = cell(1, n-1);

for i = 2:n
    curr_gray = im2gray(imgs{i});
    diff = compute_difference(base_gray, curr_gray);
    mask = compute_mask(diff, threshold);

    overlay = im2double(imgs{i});
    ch1 = overlay(:,:,1);
    ch2 = overlay(:,:,2);
    ch3 = overlay(:,:,3);
    ch1(mask) = 1;
    ch2(mask) = 0;
    ch3(mask) = 1;
    overlay(:,:,1) = ch1;
    overlay(:,:,2) = ch2;
    overlay(:,:,3) = ch3;

    timelapse_images{i-1} = overlay;
end

% Setup slider
set(slider,'Visible','on');
set(slider,'Min',1,'Max',n-1,'Value',1);
set(slider,'SliderStep',[1/(n-2),1/(n-2)]);
slider.UserData='timelapse_diff';

% Display first image
imshow(timelapse_images{1},'Parent',ax);
axis(ax,'off'); axis(ax,'image');
title(ax, sprintf('Difference: %s vs %s', image_timestamps{1}, image_timestamps{2}));

% Show timestamps
all_dates_str = strjoin(image_timestamps(2:end), '  |  ');
set(timestampLabel,'String', all_dates_str);

end

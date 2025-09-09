function run_timelapse(ax, faded_images, image_timestamps, slider, timestampLabel)
%RUN_TIMELAPSE Display the time-lapse images in slider mode.
%
% Inputs:
%   ax               - Axes handle for display
%   faded_images     - Cell array of images to show
%   image_timestamps - Cell array of timestamps (same length as images)
%   slider           - Handle to the slider UIControl
%   timestampLabel   - Handle to the label showing timestamps

% Clear axes and UI
cla(ax);
set(slider, 'Visible', 'off');
set(timestampLabel, 'String', '');

% Setup slider
nImgs = length(faded_images);
set(slider, 'Visible', 'on');
set(slider, 'Min', 1, 'Max', nImgs, 'Value', 1);
set(slider, 'SliderStep', [1/(nImgs-1), 1/(nImgs-1)]);
slider.UserData = 'timelapse';

% Display first image
imshow(faded_images{1}, 'Parent', ax);
axis(ax, 'off');
axis(ax, 'image');
title(ax, ['Date: ', image_timestamps{1}]);

% Show all timestamps
all_dates_str = strjoin(image_timestamps, '  |  ');
set(timestampLabel, 'String', all_dates_str);
end

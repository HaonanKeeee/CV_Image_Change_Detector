function [curtainImg1, curtainImg2, curtainIdx1, curtainIdx2] = run_curtain(faded, idx1, idx2, ax, slider, image_timestamps)
%RUN_CURTAIN Set up curtain comparison between two images
%
% Inputs:
%   faded            - Cell array of faded images
%   idx1             - Index of baseline image
%   idx2             - Index of comparison image
%   ax               - Axes handle for display
%   slider           - Slider handle
%   image_timestamps - Cell array of timestamps
%
% Outputs:
%   curtainImg1      - Left image data
%   curtainImg2      - Right image data
%   curtainIdx1      - Index 1
%   curtainIdx2      - Index 2

curtainImg1 = faded{idx1};
curtainImg2 = faded{idx2};
curtainIdx1 = idx1;
curtainIdx2 = idx2;

% Initialize slider
set(slider, 'Visible', 'on');
set(slider, 'Min', 0, 'Max', 1, 'Value', 0.5);
slider.UserData = 'curtain';

% Show initial curtain view
width = size(curtainImg1,2);
cut = round(width*0.5);
curtain = curtainImg1;
curtain(:,cut+1:end,:) = curtainImg2(:,cut+1:end,:);
imshow(curtain, 'Parent', ax);
hold(ax, 'on');
line(ax, [cut cut], [1 size(curtain,1)], 'Color', [0 1 1], 'LineWidth', 2);
hold(ax, 'off');
title(ax, sprintf('Curtain Compare (%s vs %s)', image_timestamps{idx1}, image_timestamps{idx2}));
end

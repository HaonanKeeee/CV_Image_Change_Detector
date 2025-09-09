% TUM CV Challenge 2025
% Group 11
% Preprocessing and Registration
% Haonan Ke
% last modified 10. July 2025

function [aligned_imgs, faded_imgs, warped_imgs, aligned_imgs_grey, image_timestamps, image_filenames] = prepro_and_regi(folder)
% Preprocess + Sort by date + Feature-based Registration
% Input:
%   folder - string, path to the folder containing images
% Output:
%   aligned_imgs       - cell array of registered images (original)
%   faded_imgs         - cell array of dimmed images (for visualization)
%   warped_imgs        - cell array of warped images (not filled)
%   aligned_imgs_grey  - cell array of registered grayscale images
%   image_timestamps   - formatted timestamps 'YYYY/MM'
%   image_filenames    - sorted filenames

    % ========== Step 1: Load and sort images ==========
    files = dir(fullfile(folder, '*.jpg'));
    if isempty(files)
        files = dir(fullfile(folder, '*.png'));
    end

    n = length(files);
    if n < 2
        error('At least two images are required.');
    end

    timestamps = zeros(1, n);
    image_timestamps = cell(1, n);
    for i = 1:n
        [~, name, ext] = fileparts(files(i).name);
        parts = split(name, '_');
        if length(parts) ~= 2
            error('Filename "%s" does not match format "YYYY_MM" or "MM_YYYY".', name);
        end
        num1 = str2double(parts{1});
        num2 = str2double(parts{2});
        if num1 > 1000
            year = num1;
            month = num2;
        else
            month = num1;
            year = num2;
        end
        % Format as "YYYY/MM"
        monthStr = sprintf('%02d', month);
        yearStr = sprintf('%04d', year);
        image_timestamps{i} = [yearStr, '/', monthStr];

        timestamps(i) = year*100 + month;
    end

    % Sort by timestamps
    [~, idx] = sort(timestamps);
    files = files(idx);
    image_timestamps = image_timestamps(idx);

    % Collect sorted filenames
    image_filenames = cell(1, n);
    for i = 1:n
        [~, name, ext] = fileparts(files(i).name);
        image_filenames{i} = [name, ext];
    end

    % Load images
    imgs = cell(1, n);
    for i = 1:n
        imgs{i} = imread(fullfile(files(i).folder, files(i).name));
    end

    % ========== Step 2: Sequential registration ==========
    aligned_imgs = cell(size(imgs));
    aligned_imgs_grey = cell(size(imgs));
    warped_imgs_raw = cell(size(imgs));

    % Initialize first image
    aligned_imgs{1} = imgs{1};
    warped_imgs_raw{1} = imgs{1};
    if size(imgs{1},3)==3
        aligned_imgs_grey{1} = rgb2gray(imgs{1});
    else
        aligned_imgs_grey{1} = imgs{1};
    end

    % Grayscale + adaptive histogram equalization (first image)
    if size(imgs{1},3)==3
        prev_gray = rgb2gray(imgs{1});
    else
        prev_gray = imgs{1};
    end
    prev_gray = adapthisteq(prev_gray);

    for i = 2:n
        curr_img = imgs{i};
        if size(curr_img,3)==3
            curr_gray = rgb2gray(curr_img);
        else
            curr_gray = curr_img;
        end
        curr_gray = adapthisteq(curr_gray);

        % Feature detection
        pts1 = detectKAZEFeatures(prev_gray,...
            'Threshold',0.001,...
            'NumOctaves',3,...
            'NumScaleLevels',3);
        
        pts2 = detectKAZEFeatures(curr_gray,...
            'Threshold',0.001,...
            'NumOctaves',3,...
            'NumScaleLevels',3);
        [f1,vpts1] = extractFeatures(prev_gray, pts1);
        [f2,vpts2] = extractFeatures(curr_gray, pts2);
        indexPairs = matchFeatures(f1,f2,'Unique',true,'MatchThreshold',50);

        % Skip if too few matches
        if size(indexPairs,1)<10
            fprintf('Image %d: too few matches, skipping alignment.\n', i);
            aligned_imgs{i} = curr_img;
            warped_imgs_raw{i} = curr_img;
            if size(curr_img,3)==3
                aligned_imgs_grey{i} = rgb2gray(curr_img);
            else
                aligned_imgs_grey{i} = curr_img;
            end
            prev_gray = curr_gray;
            continue;
        end

        matched1 = vpts1(indexPairs(:,1));
        matched2 = vpts2(indexPairs(:,2));

        tform = [];
        models = {'similarity','affine'};
        for m = 1:length(models)
            try
                tform_try = estimateGeometricTransform2D(matched2,matched1,...
                    models{m},'MaxNumTrials',80000,'Confidence',90,'MaxDistance',15);
                tform = tform_try;
                break;
            catch
                continue;
            end
        end

        if isempty(tform)
            fprintf('Image %d: all models failed, skipping.\n', i);
            aligned_imgs{i} = curr_img;
            warped_imgs_raw{i} = curr_img;
            if size(curr_img,3)==3
                aligned_imgs_grey{i} = rgb2gray(curr_img);
            else
                aligned_imgs_grey{i} = curr_img;
            end
            prev_gray = curr_gray;
            continue;
        end

        M = tform.T;
        if abs(det(M(1:2,1:2)))<1e-4 || cond(M(1:2,1:2))>1e4 || any(isnan(M(:)))
            fprintf('Image %d: transformation matrix invalid, skipping.\n', i);
            aligned_imgs{i} = curr_img;
            warped_imgs_raw{i} = curr_img;
            if size(curr_img,3)==3
                aligned_imgs_grey{i} = rgb2gray(curr_img);
            else
                aligned_imgs_grey{i} = curr_img;
            end
            prev_gray = curr_gray;
            continue;
        end

        % Apply transformation
        outputView = imref2d(size(aligned_imgs{i-1}));
        aligned_raw = imwarp(curr_img, tform, 'OutputView', outputView, 'FillValues',0);
        warped_imgs_raw{i} = aligned_raw;

        % Fill black borders with the previous image
        ref_img = aligned_imgs{i-1};
        if size(aligned_raw,3)==1
            mask = (aligned_raw==0);
            filled = aligned_raw;
            filled(mask) = ref_img(mask);
        else
            mask = all(aligned_raw==0,3);
            filled = aligned_raw;
            for c = 1:3
                channel = filled(:,:,c);
                ref_channel = ref_img(:,:,c);
                channel(mask) = ref_channel(mask);
                filled(:,:,c) = channel;
            end
        end
        aligned_imgs{i} = filled;

        % Generate grayscale version
        if size(filled,3)==3
            aligned_imgs_grey{i} = rgb2gray(filled);
        else
            aligned_imgs_grey{i} = filled;
        end

        prev_gray = adapthisteq(rgb2gray(filled));
    end

    % ========== Step 3: Generate faded images ==========
    faded_imgs = cell(1, n);
    for i = 1:n
        curr = im2double(aligned_imgs{i});
        if i==1
            mask = true(size(curr,1), size(curr,2));
        else
            warped = im2double(warped_imgs_raw{i});
            mask = any(warped > 0.01,3);
        end

        % Create dimmed color background
        background = curr * 0.6;

        % Combine
        combined = background;
        for c = 1:3
            channel = combined(:,:,c);
            temp = curr(:,:,c);
            channel(mask) = temp(mask);
            combined(:,:,c) = channel;
        end

        faded_imgs{i} = combined;
    end

    % assign warped_imgs output
    warped_imgs = warped_imgs_raw;
end
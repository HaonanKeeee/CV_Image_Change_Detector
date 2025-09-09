function [infoText, categoryStrings, counts] = preclassification_overview(img1, img2, threshold, ax, mode)
% HSV-based fine classification for remote sensing imagery
% Returns: info text, category strings, pixel counts per category

% Select which image to classify
switch lower(mode)
    case 'increase'
        hsv = rgb2hsv(img2);
    case 'decrease'
        hsv = rgb2hsv(img1);
    otherwise
        error('Mode must be "increase" or "decrease".');
end

% Compute change mask
diff = abs(double(im2gray(img1)) - double(im2gray(img2)));
mask = diff > threshold;

% HSV channels
H = hsv(:,:,1)*360;
S = hsv(:,:,2);
V = hsv(:,:,3);

[Hn,W] = size(H);
cat = zeros(Hn,W);

% 1: Snow/Ice
idx = mask & V>0.85 & S<0.2;
cat(idx)=1;

% 2: Sand
idx = mask & cat==0 & H>=25 & H<=60 & S<0.5 & V>0.3;
cat(idx)=2;

% 3: Vegetation
idx = mask & cat==0 & ...
      H >=60 & H <=150 & ...
      S >0.2;
cat(idx)=3;

% 4: Urban
idx = mask & cat==0 & H>=30 & H<=60 & S<0.4 & V>=0.3 & V<=0.6;
cat(idx)=4;

% 5: Water
idx = mask & cat==0 & H>=170 & H<=270 & S>0.15 & V<=0.85;
cat(idx)=5;

% 6: Bare Soil
idx = mask & cat==0 & ...
      (H>=0 & H<=60) & ...
      S >0.10 & ...
      V >=0.05 & V <=0.70;
cat(idx)=6;

% 7: Others
idx = mask & cat==0;
cat(idx)=7;

% Labels
labels = {'White:Snow/Ice/Rooftop','Light YellowGrey:Sand/Urban','Green:Vegetation','Grey:Urban/Shadow','Blue:Water/Shadow','Brown:BareSoil/Rooftop','Others'};
colors = {
    [0.6 0.7 0.85],
    [1 1 0],
    [0 1 0],
    [0.7 0 1],
    [0 0 1],
    [1 0.5 0],
    [1 0 0]
};

% Build overlay and collect stats
overlay = zeros(Hn,W,3);
total = nnz(mask);

% Precompute counts and percentages
counts = zeros(1,numel(labels));
percentages = zeros(1,numel(labels));

for i=1:numel(labels)
    m = (cat==i);
    cnt = nnz(m);
    counts(i) = cnt;
    percentages(i) = 100 * cnt / max(1,total);
end

% Sort indices by percentage descending, keeping 'Others' last
isOthers = strcmp(labels,'Others');
% Indices excluding Others
idxMain = find(~isOthers);
[~, sortIdx] = sort(percentages(idxMain),'descend');
sortedIdx = [idxMain(sortIdx), find(isOthers)];

% Build output strings
infoParts = {};
categoryStrings = {};

for k=1:numel(sortedIdx)
    i = sortedIdx(k);
    pct = percentages(i);
    if pct >=0.01 || i==7  % Always include Others
        infoParts{end+1} = sprintf('%s:%.2f%%',labels{i},pct);
        categoryStrings{end+1} = sprintf('%s (%.2f%%)',labels{i},pct);
        m = (cat==i);
        c = colors{i};
        for ch=1:3
            overlay(:,:,ch) = overlay(:,:,ch) + m*c(ch);
        end
    end
end

% Display
cla(ax);
imshow(img1,'Parent',ax);
hold(ax,'on');
h=imshow(overlay,'Parent',ax);
set(h,'AlphaData',(sum(overlay,3)>0)*0.7);
title(ax,sprintf('HSV Land Cover Classification (%s)',mode));
hold(ax,'off');

infoText = strjoin(infoParts,'   ');

end

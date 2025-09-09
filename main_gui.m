function main_gui()
f = figure('Name','Change Detection App','Position',[100 100 1200 800]);
f.SizeChangedFcn = @resize_callback;

% Shared variables
imgs = {};
faded = {};
timelapse_images = {}; 
image_filenames = {};
image_timestamps = {};
curtainImg1 = [];
curtainImg2 = [];
curtainIdx1 = [];
curtainIdx2 = [];


bgPara = uibuttongroup(f,'Title','User Parameters','Units','normalized',...
    'FontSize',13,...
    'Position',[0.01 0.84 0.555 0.15]);
bgButton = uibuttongroup(f,'Title','Function Selection','Units','normalized',...
    'FontSize',13,...
    'Position',[0.57 0.84 0.425 0.15]);
bgClass = uibuttongroup(f,'Title','Advanced','Units','normalized',...
    'FontSize',11,...
    'Position',[0.29 0.847 0.27 0.09]);

%% Folder Label
folderLabel = uicontrol(f, 'Style', 'text', ...
    'Units','normalized',...
    'BackgroundColor', [1 1 0.9],...
    'Position', [0.0167, 0.925, 0.155, 0.036], ...
    'HorizontalAlignment', 'left', ...
    'FontSize',10,...
    'String', 'No image folder selected');

%% Select Folder Button
btnFolder = uicontrol(f, 'Style','pushbutton', 'String','Select Image Folder', ...
    'Units','normalized',...
    'BackgroundColor', [0.8 0.85 0.9],...
    'FontSize',10,...
    'Position',[0.175, 0.928, 0.108, 0.0313], 'Callback',@select_folder);

%% Buttons Row
btnHeatmap = uicontrol(f, 'Style','pushbutton', 'String','Heatmap', ...
    'Units','normalized',...
    'BackgroundColor', [0.8 0.85 0.9],...
    'FontSize',12,...
    'Position',[0.58, 0.92, 0.11, 0.033], 'Callback',@run_heatmap_callback);

btnTimelapse = uicontrol(f, 'Style','pushbutton', 'String','Time-lapse', ...
    'Units','normalized',...
    'BackgroundColor', [0.8 0.85 0.9],...
    'FontSize',12,...
    'Position',[0.7, 0.92, 0.11, 0.033], 'Callback',@choose_timelapse_mode);

btnCurtain = uicontrol(f, 'Style','pushbutton', 'String','Curtain Compare', ...
    'Units','normalized',...
    'BackgroundColor', [0.8 0.85 0.9],...
    'FontSize',12,...
    'Position',[0.58, 0.87, 0.11, 0.033], 'Callback',@run_curtain_callback);

btnOverlay = uicontrol(f, 'Style','pushbutton', 'String','Show Difference', ...
    'Units','normalized',...
    'BackgroundColor', [0.8 0.85 0.9],...
    'FontSize',12,...
    'Position',[0.7, 0.87, 0.11, 0.033], 'Callback',@run_overlay_callback);

btnClassification = uicontrol(f, 'Style','pushbutton', 'String','Classification', ...
    'Units','normalized',...
    'BackgroundColor', [0.8 0.85 0.9],...
    'FontSize',14,...
    'Position',[0.8267, 0.915, 0.1583, 0.05], 'Callback',@run_preclassification_callback);

btnAnalysis = uicontrol(f, 'Style','pushbutton', 'String','Analysis', ...
    'Units','normalized',...
    'BackgroundColor', [0.8 0.85 0.9],...
    'FontSize',14,...
    'Position',[0.8267, 0.853, 0.1583, 0.05], 'Callback',@run_analysis_callback);


%% Baseline Image Dropdown
tBase = uicontrol(f, 'Style','text','Units','normalized','Position',[0.0167, 0.8875, 0.1000, 0.025],'FontSize',10,...
    'HorizontalAlignment','left',...
    'String','Baseline Image:');
popupBaseline = uicontrol(f, 'Style','popupmenu','Units','normalized','FontSize',10,...
    'Position',[0.1167, 0.8875, 0.1667, 0.0313],...
    'String',{'(No images loaded)'});

%% Comparison Image Dropdown
tComp = uicontrol(f, 'Style','text','Units','normalized','Position',[0.0167, 0.8500, 0.1000, 0.025],'FontSize',10,...,
    'HorizontalAlignment','left',...
    'String','Comparison Image:');
popupCompare = uicontrol(f, 'Style','popupmenu','Units','normalized','FontSize',10,'Position',[0.1167, 0.8500, 0.1667, 0.0313],...
    'String',{'(No images loaded)'});

%% Threshold Input
tThresh = uicontrol(f, 'Style','text','Units','normalized','Position',[0.2917, 0.935, 0.06, 0.025],'FontSize',10,...
    'HorizontalAlignment','left',...
    'String','Threshold:');
editThreshold = uicontrol(f, 'Style','edit','Units','normalized','FontSize',12,'Position',[0.35, 0.935, 0.045, 0.03],...
    'String','50');

%% selCluster Dropdown
tselCluster = uicontrol(f, 'Style','text','Units','normalized','Position',[0.2917, 0.8500, 0.09, 0.025],'FontSize',10,...
    'HorizontalAlignment','left', 'String','Select Category:');
popupSelCluster = uicontrol(f, 'Style','popupmenu','Units','normalized','FontSize',10,...
    'Position',[0.3798, 0.8500, 0.177, 0.032], 'String',{'Run Classification to get options!'});

%% Change Type
tType = uicontrol(f, 'Style','text','Units','normalized','Position',[0.415 0.935, 0.08, 0.025],'FontSize',10,...,
    'HorizontalAlignment','left',...
    'String','Change Type:');
cType = uicontrol(f, 'Style','popupmenu','Units','normalized','FontSize',10,'Position',[0.5, 0.932, 0.056, 0.032],...
    'String',{'All','Major','Minor'});

%% De/In Dropdown
tInDe = uicontrol(f, 'Style','text','Units','normalized','Position',[0.3178 0.885, 0.06, 0.025],'FontSize',10,...,
    'HorizontalAlignment','left',...
    'String','+/- Mode:');
De_Increase = uicontrol(f, 'Style','popupmenu','Units','normalized','FontSize',10,'Position',[0.3798, 0.885, 0.177, 0.032],...
    'String',{'Increase in Comparison Image', 'Decrease in Comparison Image'});

%% Info Box
infoBox = uicontrol(f, 'Style', 'text', ...
    'Units','normalized',...
    'Position', [0.01 0.745 0.98 0.095], ...
    'Max', 10, 'Min', 0, ...
    'Enable', 'inactive', ...
    'HorizontalAlignment','center', ...
    'ForegroundColor',[1 0 0], ...
    'String', 'Welcome to the CV Change Detection System! Please select a folder to start.' ,...
    'FontSize', 19);

%% Axes
panel = uipanel(f, ...
    'Units','normalized', ...
    'Position',[0.245, 0.01, 0.7500, 0.73], ...
    'BorderType','etchedout', ... 
    'BackgroundColor',[1 1 1]); 
ax = axes(panel, 'Units','pixels', 'Units','normalized',...
    'FontSize',10,...
    'Position',[0, 0.115, 1, 0.845]);
axis(ax, 'off');
axis(ax, 'image');

%% Slider for Time-lapse & Curtain
slider = uicontrol(f, 'Style','slider', ...
    'FontSize',11,...
    'Units','normalized',...
    'Min', 0, 'Max', 1, 'Value', 0.5, ...
    'SliderStep', [0.01 0.1], ...
    'Position',[0.3113, 0.055, 0.6180, 0.025], ...
    'Visible', 'off');
addlistener(slider,'ContinuousValueChange',@slider_callback);

%% Timestamp Label
timestampLabel = uicontrol(f, 'Style', 'text', ...
    'FontSize',10,...
    'Units','normalized',...
    'BackgroundColor', [1 1 1],...
    'Position', [0.3113, 0.025, 0.6180, 0.025], ...
    'HorizontalAlignment', 'center', ...
    'String', '');

%% Help Box
helpBox = uicontrol(f, ...
    'Style','edit', ...
    'Units','normalized', ...
    'Position',[0.01, 0.01, 0.23, 0.73], ...
    'String', { ...
        '========= README =========',...
        '== Change Detection System ==', ...
        '', ...
        'This application helps you', ...
        'detect and visualize changes', ...
        'in image sequences over time.', ...
        '', ...
        '======== How to Use ========', ...
        '', ...
        'Step 1:', ...
        '  Click "Select Image Folder"', ...
        '  to load and preprocess images.', ...
        '  Please be patient!',...
        '', ...
        'Step 2:', ...
        '  Choose Baseline and Comparison', ...
        '  images from the dropdowns.', ...
        '', ...
        'Step 3:', ...
        '  Adjust Threshold and Change',...
        '  Type as needed.', ...
        '  - Threshold is the value that',...
        '  defines the minimum pixel color',...
        '  difference for highlight.',...
        '  (Can be shown with "Heatmap")',...
        '  - Change Type only needed for',...
        '  the "Show Difference" function.',...
        '', ...
        'Step 4:', ...
        '  Select a visualization mode:', ...
        '', ...
        '+ Heatmap:', ...
        '  Show pixel difference heatmap.', ...
        '', ...
        '+ Time-lapse:', ...
        '  Browse images or view difference', ...
        '  over time.', ...
        '', ...
        '+ Curtain Compare:', ...
        '  Slide curtain to compare images.', ...
        '', ...
        '+ Show Difference:', ...
        '  Highlight Overlay changes.', ...
        '', ...
        '======== Advanced ========', ...
        '',...
        '# Classification:', ...
        '  Classify the changes and' ...
        '  calculate percentage of each',...
        '  category among all detected',...
        '  changes.',...
        '',...
        '  ******************************************',...
        '  ImageColor - MaskColor Map:',...
        '  ******************************************',...
        '  +++ White:     Light Greyblue +++',...
        '  +++ YellowGrey:         Yellow +++',...
        '  +++ Green:                 Green +++',...
        '  +++ Grey:                   Purple +++',...
        '  +++ Blue:                      Blue +++',...
        '  +++ Brown:                Orange +++',...
        '  +++ Others:                    Red +++',...
        '  ******************************************',...
        '  !! Classification function is' ...
        '  ONLY APPROXIMATION, no',...
        '  accuracy guaranteed!!',...
        '  !!Choose +/- Mode before',...
        '  executing Classification!!',...
        '',...
        '# +/- Mode:', ...
        '  Detect  Increase(-) or Decrease(+)', ...
        '  in comparison image.',...
        '',...
        '# Analysis:',...
        '  Compare the selected category',...
        '  between the reference and' ...
        '  comparison images. Calculates' ...
        '  the pixel count and change' ...
        '  percentage.',...
        '  Selected Category will be',...
        '  highlighten with mask.',...
        '  !! Select a category from the list',...
        '  before executing Analysis!!',...
        '',...
        '# Select Category:', ...
        '  Select a classified catagory',...
        '  for Analysis function.',...
        '',...
    }, ...
    'FontSize',12, ...
    'HorizontalAlignment','left', ...
    'BackgroundColor',[1 1 0.9], ...
    'Max',30, ...
    'Min',0, ...
    'Enable','inactive');


%% ========= Internal GUI Functions ==========
% Show in InfoBox
function print_to_gui(msg)
    %oldText = infoBox.String;
    %if ischar(oldText), oldText = {oldText}; end
    %newText = [oldText; {msg}];
    infoBox.String = msg;
    drawnow;
end

% Clear current Display
function clear_gui()
    cla(ax);                         
    set(slider, 'Visible', 'off');     
    set(timestampLabel, 'String', ''); 
    axes(ax);
end

% Folder selection and prepro
function select_folder(~,~)
    clear_gui();

    folder = uigetdir;
    if folder==0, return; end
    [~, foldername] = fileparts(folder);
    set(folderLabel, 'String', ['Loaded folder: ', foldername]);
    print_to_gui(['Loading image folder: ', foldername]);
    print_to_gui('Please wait until all the selected images have been preprocessed! Running...')

    [aligned_imgs, faded_imgs, ~, ~, image_timestamps, image_filenames] = prepro_and_regi(folder);

    imgs = aligned_imgs;
    faded = faded_imgs;

    dropdownLabels = cell(1,length(image_filenames));
    for k=1:length(image_filenames)
        dropdownLabels{k} = sprintf('%s - %s', image_timestamps{k}, image_filenames{k});
    end

    popupBaseline.String = dropdownLabels;
    popupBaseline.Value = 1;

    popupCompare.String = dropdownLabels;
    if length(dropdownLabels)>=2
        popupCompare.Value = 2;
    else
        popupCompare.Value = 1;
    end

    print_to_gui(sprintf('Successfully loaded %d images. Adjust parameters and select any function to run.', length(imgs)));
end

% Slider update in realtime
function slider_callback(~,~)
    if strcmp(slider.UserData,'timelapse')
        idx=round(slider.Value);
        imshow(timelapse_images{idx},'Parent',ax);
        axis(ax,'off'); axis(ax,'image');
        title(ax,['Date: ',image_timestamps{idx}]);
    elseif strcmp(slider.UserData,'curtain')
        pos=slider.Value;
        width=size(curtainImg1,2);
        cut=round(width*pos);
        curtain=curtainImg1;
        curtain(:,cut+1:end,:)=curtainImg2(:,cut+1:end,:);
        imshow(curtain,'Parent',ax);
        hold on;
        line([cut cut],[1 size(curtain,1)],'Color',[0 1 1],'LineWidth',2);
        hold off;
        title(ax,sprintf('Curtain Compare (%s vs %s)', ...
            image_timestamps{curtainIdx1}, image_timestamps{curtainIdx2}));
    elseif strcmp(slider.UserData,'timelapse_diff')
    idx=round(slider.Value);
    timelapse_images = evalin('base','timelapse_images_diff');
    imshow(timelapse_images{idx},'Parent',ax);
    axis(ax,'off'); axis(ax,'image');
    title(ax, sprintf('Difference: %s vs %s', ...
        image_timestamps{1}, image_timestamps{idx+1}));

    end
end

% custom questdlg begin
function choice = custom_questdlg()
    % Dialog configuration
    question = 'Choose Time-lapse mode:';
    dlgTitle = 'Time-lapse Mode';
    options = {'Time-lapse Original', 'Time-lapse Difference', 'Cancel'};
    
    % Create resizable figure with unique tag
    dlgFig = figure('Name', dlgTitle, ...
               'NumberTitle', 'off', ...
               'MenuBar', 'none', ...
               'ToolBar', 'none', ...
               'Units', 'normalized', ...
               'Position', [0.35, 0.4, 0.3, 0.25], ...
               'Tag', 'CustomQuestDlg', ...
               'WindowStyle', 'modal', ...
               'Resize', 'on', ...
               'CloseRequestFcn', @closeCallback);
    
    % Store choice in figure's application data
    choice = 'Cancel';
    setappdata(dlgFig, 'choice', choice);
    
    % Create question text
    textHandle = uicontrol(dlgFig, 'Style', 'text', ...
              'String', question, ...
              'Units', 'normalized', ...
              'Position', [0.05, 0.75, 0.9, 0.15], ...
              'FontSize', 14, ...
              'FontWeight', 'bold', ...
              'HorizontalAlignment', 'center', ...
              'BackgroundColor', get(dlgFig, 'Color'));
    
    % Create buttons
    numButtons = numel(options);
    buttonHandles = gobjects(1, numButtons);
    
    for i = 1:numButtons
        buttonHandles(i) = uicontrol(dlgFig, 'Style', 'pushbutton', ...
                          'String', options{i}, ...
                          'Units', 'normalized', ...
                          'FontSize', 12, ...
                          'Tag', options{i}, ...
                          'Callback', @(src,evt) buttonCallback(src, options{i}));
    end
    
    % Initialize layout with better positioning
    updateLayout(dlgFig, buttonHandles, textHandle);
    
    % Set resize function
    dlgFig.SizeChangedFcn = @(src,evt) updateLayout(src, buttonHandles, textHandle);
    
    % Wait for user selection
    uiwait(dlgFig);
    
    % Return final choice
    choice = getappdata(dlgFig, 'choice');
    
    % Ensure figure is properly deleted
    if ishandle(dlgFig)
        delete(dlgFig);
    end
end

function buttonCallback(src, selectedChoice)
    dlgFig = ancestor(src, 'figure');
    setappdata(dlgFig, 'choice', selectedChoice);
    uiresume(dlgFig);
end

function closeCallback(src, ~)
    setappdata(src, 'choice', 'Cancel');
    uiresume(src);
end

function updateLayout(dlgFig, buttons, textHandle)
    % Safety check
    if ~ishandle(dlgFig)
        return;
    end
    
    figPos = get(dlgFig, 'Position');
    figWidth = figPos(3);
    figHeight = figPos(4);
    aspectRatio = figWidth/figHeight;
    
    % Update text position (fixed at top)
    set(textHandle, 'Position', [0.05, 0.75, 0.9, 0.15]);
    
    numButtons = length(buttons);
    
    % Calculate button positions based on aspect ratio
    if aspectRatio > 1.5  % Wide layout: horizontal
        btnWidth = min(0.25, 0.9/numButtons);
        btnHeight = 0.2;
        startX = (1 - numButtons*btnWidth - (numButtons-1)*0.02)/2;
        
        for i = 1:numButtons
            set(buttons(i), 'Position', ...
                [startX + (i-1)*(btnWidth + 0.02), 0.3, btnWidth, btnHeight]);
        end
        
    else  % Tall layout: vertical
        btnWidth = 0.8;
        btnHeight = 0.15;
        verticalSpacing = 0.05;
        
        % Calculate total height of button block
        totalButtonHeight = numButtons * btnHeight + (numButtons-1) * verticalSpacing;
        
        % Calculate starting Y position to center buttons vertically
        startY = (0.75 - totalButtonHeight)/2 + 0.5;  % Centered vertically
        
        for i = 1:numButtons
            set(buttons(i), 'Position', ...
                [0.1, startY - (i-1)*(btnHeight + verticalSpacing), btnWidth, btnHeight]);
        end
    end
end
% custom questdlg end

% Popup to choose timelapse mode
function choose_timelapse_mode(~,~)
    if isempty(faded)
        errordlg('Please select a folder first.','Error');
        return;
    end
    
    % old questdlg has can't fully display the last button currectly and can't change size and font
    %choice = questdlg('Choose Time-lapse mode:', ...
    %                  'Time-lapse Mode', ...
    %                  'Time-lapse Original','Time-lapse Difference','Time-lapse Original'); 
    
    % new custom_questdlg
    choice = custom_questdlg();

    switch choice
        case 'Time-lapse Original'
            run_timelapse_callback();
        case 'Time-lapse Difference'
            run_timelapse_diff_callback();
    end
end

% Fontsize update according to window scale
function resize_callback(~,~)
    % Check if main figure still exists
    if ~ishandle(f)
        return;
    end
    
    figPos = f.Position;
    scaleFactor = figPos(3)/1200;
    
    % Get all valid child handles
    allChildren = findall(f);
    
    % Update font sizes only for valid handles
    for i = 1:length(allChildren)
        try
            if isprop(allChildren(i), 'FontSize')
                switch get(allChildren(i), 'Type')
                    case 'uicontrol'
                        switch get(allChildren(i), 'Style')
                            case {'pushbutton', 'popupmenu', 'edit', 'text', 'listbox'}
                                baseSize = 10;
                                if strcmp(get(allChildren(i), 'String'), 'Analysis') || ...
                                   strcmp(get(allChildren(i), 'String'), 'Classification')
                                    baseSize = 14;
                                end
                                newSize = round(baseSize * scaleFactor);
                                set(allChildren(i), 'FontSize', newSize);
                        end
                    
                    case 'uibuttongroup'
                        baseSize = 13;
                        newSize = round(baseSize * scaleFactor);
                        set(allChildren(i), 'FontSize', newSize);
                end
            end
        catch
            % Skip invalid handles
            continue;
        end
    end
    
    % Special handling for info box
    if ishandle(infoBox)
        newFontSize = round(19 * scaleFactor);
        set(infoBox, 'FontSize', newFontSize);
    end
    
    % Special handling for help box
    if ishandle(helpBox)
        newFontSize = round(12 * scaleFactor);
        set(helpBox, 'FontSize', newFontSize);
    end
end

%% ============= Call Immage processing functions =============================
% timelapse original
function run_timelapse_callback()
    if isempty(faded)
        errordlg('Please select a folder first.','Error');
        return;
    end

    clear_gui();
    timelapse_images = faded;

    run_timelapse(ax, faded, image_timestamps, slider, timestampLabel);

    print_to_gui(sprintf('Showing Time-lapse Original: loaded %d images', length(faded)));
end

% timelapse with difference highlight
function run_timelapse_diff_callback(~,~)
    if isempty(imgs)
        errordlg('Please select a folder first.','Error');
        return;
    end

    clear_gui();
    threshold = str2double(editThreshold.String);

    timelapse_images_diff = run_timelapse_diff(imgs, image_timestamps, threshold, ax, slider, timestampLabel);

    assignin('base','timelapse_images_diff',timelapse_images_diff);

    print_to_gui(sprintf('Showing Time-lapse Difference: loaded %d images with threshold = %d',...
        length(timelapse_images_diff), threshold));
end

% Show caurtain view
function run_curtain_callback(~,~)
    if isempty(faded)
        errordlg('Please select a folder first.','Error');
        return;
    end
    clear_gui();

    idx1 = popupBaseline.Value;
    idx2 = popupCompare.Value;

    if idx1 == idx2
        errordlg('Please select two different images to compare.','Selection Error');
        return;
    end

    [curtainImg1, curtainImg2, curtainIdx1, curtainIdx2] = ...
        run_curtain(faded, idx1, idx2, ax, slider, image_timestamps);

    print_to_gui(sprintf('Showing Curtain: Comparison between %s and %s', ...
        image_timestamps{idx1}, image_timestamps{idx2}));
end

% Highlight difference
function run_overlay_callback(~,~)
    if isempty(imgs)
        errordlg('Please select a folder first.','Error');
        return;
    end
    clear_gui();

    idx1 = popupBaseline.Value;
    idx2 = popupCompare.Value;

    if idx1 == idx2
        errordlg('Please select two different images to compare.','Selection Error');
        return;
    end

    img1 = imgs{idx1};
    img2 = imgs{idx2};
    threshold = str2double(editThreshold.String);

    type_str = cType.String{cType.Value};

    run_overlay(ax, img1, img2, threshold, image_timestamps{idx1}, image_timestamps{idx2}, type_str);

    print_to_gui(sprintf('Highlighting Difference (%s): %s vs. %s with threshold = %d',...
        type_str, image_timestamps{idx1}, image_timestamps{idx2}, threshold));
end


% Show heatmap
function run_heatmap_callback(~,~)
    if isempty(imgs)
        errordlg('Please select a folder first.','Error');
        return;
    end
    clear_gui();

    idx1 = popupBaseline.Value;
    idx2 = popupCompare.Value;

    if idx1 == idx2
        errordlg('Please select two different images to compare.','Selection Error');
        return;
    end

    img1 = imgs{idx1};
    img2 = imgs{idx2};

    run_heatmap(img1, img2, ax, idx1, idx2, image_timestamps);

    print_to_gui(sprintf('Showing Heatmap: Comparison between %s and %s',...
        image_timestamps{idx1}, image_timestamps{idx2}));
end

% Show Classification
function run_preclassification_callback(~,~)
    if isempty(imgs)
        errordlg('Please select a folder first.','Error');
        return;
    end
    clear_gui();
    
    if De_Increase.Value==1
        mode_str='Increase';
    else
        mode_str='Decrease';
    end

    idx1 = popupBaseline.Value;
    idx2 = popupCompare.Value;

    if idx1==idx2
        errordlg('Please select two different images to compare.','Selection Error');
        return;
    end

    img1 = imgs{idx1};
    img2 = imgs{idx2};
    threshold = str2double(editThreshold.String);

    [infoText, categoryStrings,counts] = preclassification_overview(img1, img2, threshold, ax, mode_str);
    assignin('base','counts_preclassification', counts);
    print_to_gui(infoText);
    popupSelCluster.String = categoryStrings;
    popupSelCluster.Value = 1; 
end

% Run Analysis
function run_analysis_callback(~,~)
    if isempty(imgs)
        errordlg('Please select a folder first.','Error');
        return;
    end
    clear_gui();

    idx1 = popupBaseline.Value;
    idx2 = popupCompare.Value;

    if idx1 == idx2
        errordlg('Please select two different images to compare.','Selection Error');
        return;
    end

    img1 = imgs{idx1};
    img2 = imgs{idx2};

    % Get selected category from popup
    rawString = popupSelCluster.String{popupSelCluster.Value};
    selectedLabel = strtrim(rawString);
    % Remove anything after " (" if present
    splitIdx = regexp(selectedLabel,'\s*\(');
    if ~isempty(splitIdx)
        selectedLabel = strtrim(selectedLabel(1:splitIdx(1)-1));
    end

    % Run analysis
    infoText = analysis_selected_category(img1, img2, selectedLabel, ax);

    % Display info
    print_to_gui(infoText);
end




end
function frameLineMeasurement()
    % Interactive Frame Line Measurement Tool
    % This function reads specific frame numbers from a CSV file,
    % displays each frame, allows user to draw a line, calculates length,
    % and saves results and figures.
    
    %% Get input folder path(s) from user
    folder_paths = getFolderPaths();
    
    %% Process each folder
    for folder_idx = 1:length(folder_paths)
        current_folder = folder_paths{folder_idx};
        fprintf('\n=== Processing folder %d/%d: %s ===\n', folder_idx, length(folder_paths), current_folder);
        
        processSingleFolder(current_folder);
    end
    
    fprintf('\n=== All folders processed! ===\n');
end

function folder_paths = getFolderPaths()
    % Get folder path(s) from user input
    fprintf('=== Frame Line Measurement Tool ===\n');
    fprintf('Select the folder(s) containing your frame images and Excel frame list file.\n\n');
    
    folder_paths = {};
    
    while true
        % Ask user to select a folder
        selected_folder = uigetdir(pwd, 'Select folder containing frames and Excel frame list');
        
        if selected_folder == 0
            % User cancelled
            if isempty(folder_paths)
                error('No folder selected. Exiting...');
            else
                break; % Exit loop if at least one folder was selected
            end
        end
        
        folder_paths{end+1} = selected_folder;
        fprintf('Selected folder: %s\n', selected_folder);
        
        % Ask if user wants to add more folders
        choice = questdlg('Do you want to add more folder to batch process?', ...
                         'Add More Folders', 'Yes', 'No', 'No');
        if strcmp(choice, 'No') || isempty(choice)
            break;
        end
    end
    
    fprintf('\nTotal folders selected: %d\n', length(folder_paths));
end

function processSingleFolder(base_folder)
    % Process a single folder containing frames and CSV
    
    %% Configuration for this folder
    image_folder = base_folder; % Folder containing your frame images
    image_extension = '.tif'; % Extension of your frame images
    
    % Create output directories
    output_figs_dir = fullfile(base_folder, 'Manual_Measure_Figs');
    output_csv_dir = fullfile(base_folder, 'Manual_Measure_CSV');
    
    if ~exist(output_figs_dir, 'dir')
        mkdir(output_figs_dir);
        fprintf('Created output directory: %s\n', output_figs_dir);
    end
    
    if ~exist(output_csv_dir, 'dir')
        mkdir(output_csv_dir);
        fprintf('Created output directory: %s\n', output_csv_dir);
    end
    
    % Output CSV file path with timestamp
    [~, folder_name] = fileparts(base_folder);
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    output_csv = fullfile(output_csv_dir, sprintf('line_measurements_%s_%s.csv', folder_name, timestamp));
    output_params_file = fullfile(output_csv_dir, sprintf('processing_parameters_%s_%s.m', folder_name, timestamp));
    
    %% Find and read frame numbers from Excel file
    % Look for any .xlsx file in the folder
    xlsx_files = dir(fullfile(base_folder, '*.xlsx'));
    
    if isempty(xlsx_files)
        error('No .xlsx file found in folder: %s', base_folder);
    elseif length(xlsx_files) > 1
        fprintf('Warning: Multiple .xlsx files found in folder. Using: %s\n', xlsx_files(1).name);
    end
    
    frame_list_file = fullfile(base_folder, xlsx_files(1).name);
    fprintf('Reading frame list from: %s\n', xlsx_files(1).name);
    
    try
        frame_numbers = readmatrix(frame_list_file);
        % If Excel has headers or multiple columns, adjust accordingly
        if size(frame_numbers, 2) > 1
            frame_numbers = frame_numbers(:, 1); % Take first column
        end
        frame_numbers = frame_numbers(~isnan(frame_numbers)); % Remove NaN values
    catch
        error('Could not read frame numbers from %s. Please check the file exists and contains valid numbers.', frame_list_file);
    end
    
    fprintf('Found %d frame numbers to process.\n', length(frame_numbers));
    
    %% Initialize results storage
    results = table();
    results.FrameNumber = frame_numbers;
    results.LineLength = zeros(length(frame_numbers), 1);
    results.Point1_X = zeros(length(frame_numbers), 1);
    results.Point1_Y = zeros(length(frame_numbers), 1);
    results.Point2_X = zeros(length(frame_numbers), 1);
    results.Point2_Y = zeros(length(frame_numbers), 1);
    
    %% Process each frame
    for i = 1:length(frame_numbers)
        frame_num = frame_numbers(i);
        
        % Find the corresponding image file
        frame_filename = findFrameFile(image_folder, frame_num, image_extension);
        
        if isempty(frame_filename)
            warning('Frame %d not found in folder: %s', frame_num, image_folder);
            continue;
        end
        
        frame_path = fullfile(image_folder, frame_filename);
        
        % Read and display the image
        try
            img = imread(frame_path);
            
            % Enhance contrast using imadjust
            if size(img, 3) == 3
                % RGB image - adjust each channel
                img_enhanced = img;
                for ch = 1:3
                    img_enhanced(:,:,ch) = imadjust(img(:,:,ch));
                end
            else
                % Grayscale image
                img_enhanced = imadjust(img);
            end
            
            % Create figure with better settings and make it full screen
            fig = figure('Name', sprintf('Frame %d (%d/%d)', frame_num, i, length(frame_numbers)), ...
                        'NumberTitle', 'off',...
                        'Units', 'normalized', 'Position', [0 0 1 1]); % Full screen
            
            % Display enhanced image
            imshow(img_enhanced);
            fullfig(fig);
            hold on;
            
            % Add title
            title(sprintf('Frame %d - Click two points to draw a line', frame_num), ...
                  'FontSize', 18, 'FontWeight', 'bold', 'Color', 'blue');
            
            % Make sure figure is visible and active
            figure(fig);
            drawnow;
            
            % Display instructions in command window
            fprintf('\n=== Frame %d (%d/%d) ===\n', frame_num, i, length(frame_numbers));
            fprintf('┌─────────────────────────────────────────┐\n');
            fprintf('│              INSTRUCTIONS               │\n');
            fprintf('├─────────────────────────────────────────┤\n');
            fprintf('│  1. Click FIRST point on the image     │\n');
            fprintf('│  2. Move mouse to see preview line     │\n');
            fprintf('│  3. Click SECOND point to finalize     │\n');
            fprintf('│  4. Choose action in dialog box        │\n');
            fprintf('└─────────────────────────────────────────┘\n');
            fprintf('Waiting for your input...\n');
            
            % Keep looping until user confirms the measurement for this frame
            measurement_confirmed = false;
            
            while ~measurement_confirmed
                % Get user input for line endpoints with real-time drawing
                [x, y] = getRealTimeLineInput(fig);
                fprintf('Points captured: (%.1f, %.1f) and (%.1f, %.1f)\n', x(1), y(1), x(2), y(2));
                
                % Validate input
                if length(x) ~= 2 || length(y) ~= 2 || any(isnan(x)) || any(isnan(y))
                    warning('Invalid input for frame %d. Please try again...', frame_num);
                    continue; % Stay in while loop to retry
                end
                
                % Clear previous drawings if any
                children = get(gca, 'Children');
                for j = 1:length(children)
                    if ~strcmp(get(children(j), 'Type'), 'image')
                        delete(children(j));
                    end
                end
                
                % Draw the line
                line_handle = plot([x(1), x(2)], [y(1), y(2)], 'r-', 'LineWidth', 4);
                plot(x, y, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'black', 'LineWidth', 2);
                
                % Calculate line length in pixels
                line_length = sqrt((x(2) - x(1))^2 + (y(2) - y(1))^2);
                
                % Add length annotation to top left corner at (0,0)
                text(0, 0, sprintf('Length: %.2f pixels', line_length), ...
                     'Color', 'red', 'FontSize', 12, 'FontWeight', 'normal', ...
                     'BackgroundColor', 'white', 'EdgeColor', 'red', 'LineWidth', 2, ...
                     'VerticalAlignment', 'top');
                
                % Update display
                drawnow;
                
                % Show confirmation dialog
                fprintf('Line drawn! Length: %.2f pixels\n', line_length);
                choice = questdlg(sprintf('Line length: %.2f pixels\n\nIs this the correct measurement for Frame %d?', line_length, frame_num), ...
                                 'Confirm Measurement', ...
                                 'Yes, Keep & Continue', 'No, Redraw Line', 'Yes, Keep & Continue');
                
                switch choice
                    case 'Yes, Keep & Continue'
                        % Store results and move to next frame
                        results.LineLength(i) = line_length;
                        results.Point1_X(i) = x(1);
                        results.Point1_Y(i) = y(1);
                        results.Point2_X(i) = x(2);
                        results.Point2_Y(i) = y(2);
                        
                        % Save figure in three formats
                        fig_filename = sprintf('frame_%d_measured', frame_num);
                        
                        % Save as .fig
                        savefig(fig, fullfile(output_figs_dir, [fig_filename '.fig']));
                        
                        % Save as .svg
                        saveas(fig, fullfile(output_figs_dir, [fig_filename '.svg']), 'svg');
                        
                        % Save as .png
                        saveas(fig, fullfile(output_figs_dir, [fig_filename '.png']), 'png');
                        
                        fprintf('Frame %d: Line length = %.2f pixels\n', frame_num, line_length);
                        fprintf('Saved: %s (in %s)\n', fig_filename, output_figs_dir);
                        
                        % Close figure and exit while loop
                        close(fig);
                        measurement_confirmed = true;
                        
                    case 'No, Redraw Line'
                        % Clear all drawings and continue while loop to redraw
                        fprintf('Redrawing line for frame %d...\n', frame_num);
                        
                        % Clear all plotted elements except the image
                        children = get(gca, 'Children');
                        for j = 1:length(children)
                            if ~strcmp(get(children(j), 'Type'), 'image')
                                delete(children(j));
                            end
                        end
                        drawnow;
                        
                        % measurement_confirmed remains false, so while loop continues
                        
                    otherwise
                        % User closed dialog - quit the program
                        fprintf('Dialog closed by user. Exiting program...\n');
                        close(fig);
                        return;
                end
            end % End while loop for current frame
            
        catch ME
            warning('Error processing frame %d: %s', frame_num, ME.message);
            if exist('fig', 'var') && isvalid(fig)
                close(fig);
            end
            continue;
        end
    end % End for loop through all frames
    
    %% Save results to CSV
    try
        writetable(results, output_csv);
        fprintf('\nResults saved to: %s\n', output_csv);
        fprintf('Figures saved in: %s\n', output_figs_dir);
        
        % Create and save processing parameters file
        saveProcessingParameters(output_params_file, base_folder, frame_list_file, image_folder, ...
                               image_extension, output_figs_dir, output_csv_dir, frame_numbers, results, timestamp);
        fprintf('Processing parameters saved to: %s\n', output_params_file);
        
        % Display summary
        valid_measurements = results.LineLength > 0;
        fprintf('\nSummary:\n');
        fprintf('- Total frames processed: %d\n', sum(valid_measurements));
        fprintf('- Average line length: %.2f pixels\n', mean(results.LineLength(valid_measurements)));
        fprintf('- Min line length: %.2f pixels\n', min(results.LineLength(valid_measurements)));
        fprintf('- Max line length: %.2f pixels\n', max(results.LineLength(valid_measurements)));
        
    catch ME
        error('Could not save results to CSV: %s', ME.message);
    end
    
    fprintf('\nProcessing complete!\n');
end

%% Helper function for real-time line drawing
function [x, y] = getRealTimeLineInput(fig)
    % Real-time line drawing function
    % Returns coordinates of two points defining a line
    
    % Make sure we're working with the right figure
    figure(fig);
    ax = gca;
    
    % Initialize variables
    x = zeros(1, 2);
    y = zeros(1, 2);
    line_handle = [];
    temp_line = [];
    
    % Set up mouse callbacks
    set(fig, 'WindowButtonDownFcn', @mouseDown);
    set(fig, 'WindowButtonMotionFcn', @mouseMove);
    set(fig, 'WindowButtonUpFcn', @mouseUp);
    
    % State variables
    isDrawing = false;
    firstPoint = [];
    
    % Wait for user to complete drawing
    uiwait(fig);
    
    % Clean up callbacks
    set(fig, 'WindowButtonDownFcn', []);
    set(fig, 'WindowButtonMotionFcn', []);
    set(fig, 'WindowButtonUpFcn', []);
    
    % Nested callback functions
    function mouseDown(~, ~)
        % Get current point
        currentPoint = get(ax, 'CurrentPoint');
        currentPoint = currentPoint(1, 1:2);
        
        % Check if click is within axes
        xlims = get(ax, 'XLim');
        ylims = get(ax, 'YLim');
        
        if currentPoint(1) >= xlims(1) && currentPoint(1) <= xlims(2) && ...
           currentPoint(2) >= ylims(1) && currentPoint(2) <= ylims(2)
            
            if isempty(firstPoint)
                % First click - store point and start drawing
                firstPoint = currentPoint;
                x(1) = currentPoint(1);
                y(1) = currentPoint(2);
                
                % Draw first point
                hold(ax, 'on');
                plot(ax, x(1), y(1), 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'green', 'MarkerEdgeColor', 'black');
                
                isDrawing = true;
                fprintf('First point set at (%.1f, %.1f). Move mouse to draw line...\n', x(1), y(1));
                
            else
                % Second click - finish line
                x(2) = currentPoint(1);
                y(2) = currentPoint(2);
                
                % Draw final line and second point
                if ~isempty(temp_line) && isvalid(temp_line)
                    delete(temp_line);
                end
                
                line_handle = plot(ax, [x(1), x(2)], [y(1), y(2)], 'r-', 'LineWidth', 4);
                plot(ax, x(2), y(2), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'black');
                
                drawnow;
                fprintf('Second point set at (%.1f, %.1f). Line complete!\n', x(2), y(2));
                
                % Resume execution
                uiresume(fig);
            end
        end
    end
    
    function mouseMove(~, ~)
        if isDrawing && ~isempty(firstPoint)
            % Get current mouse position
            currentPoint = get(ax, 'CurrentPoint');
            currentPoint = currentPoint(1, 1:2);
            
            % Delete previous temporary line
            if ~isempty(temp_line) && isvalid(temp_line)
                delete(temp_line);
            end
            
            % Draw temporary line
            temp_line = plot(ax, [firstPoint(1), currentPoint(1)], [firstPoint(2), currentPoint(2)], ...
                           'y--', 'LineWidth', 2);
            drawnow;
        end
    end
    
    function mouseUp(~, ~)
        % Mouse up event (could be used for additional functionality)
    end
end

%% Helper function to save processing parameters
function saveProcessingParameters(filename, base_folder, frame_list_file, image_folder, ...
                                image_extension, output_figs_dir, output_csv_dir, frame_numbers, results, timestamp)
    % Save all processing parameters and intermediate variables to a .m file
    
    fid = fopen(filename, 'w');
    if fid == -1
        warning('Could not create parameters file: %s', filename);
        return;
    end
    
    try
        % Write header
        fprintf(fid, '%% Frame Line Measurement Processing Parameters\n');
        fprintf(fid, '%% Generated on: %s\n', datestr(now));
        fprintf(fid, '%% Timestamp: %s\n\n', timestamp);
        
        % Write processing parameters
        fprintf(fid, '%% ========== PROCESSING PARAMETERS ==========\n');
        fprintf(fid, 'base_folder = ''%s'';\n', base_folder);
        fprintf(fid, 'frame_list_file = ''%s'';\n', frame_list_file);
        fprintf(fid, 'image_folder = ''%s'';\n', image_folder);
        fprintf(fid, 'image_extension = ''%s'';\n', image_extension);
        fprintf(fid, 'output_figs_dir = ''%s'';\n', output_figs_dir);
        fprintf(fid, 'output_csv_dir = ''%s'';\n', output_csv_dir);
        fprintf(fid, 'timestamp = ''%s'';\n\n', timestamp);
        
        % Write frame information
        fprintf(fid, '%% ========== FRAME INFORMATION ==========\n');
        fprintf(fid, 'total_frames_in_list = %d;\n', length(frame_numbers));
        fprintf(fid, 'frame_numbers = [');
        for i = 1:length(frame_numbers)
            fprintf(fid, '%d', frame_numbers(i));
            if i < length(frame_numbers)
                fprintf(fid, '; ');
            end
        end
        fprintf(fid, '];\n\n');
        
        % Write measurement results summary
        valid_measurements = results.LineLength > 0;
        fprintf(fid, '%% ========== MEASUREMENT RESULTS SUMMARY ==========\n');
        fprintf(fid, 'total_measurements_completed = %d;\n', sum(valid_measurements));
        fprintf(fid, 'average_line_length = %.6f; %% pixels\n', mean(results.LineLength(valid_measurements)));
        fprintf(fid, 'min_line_length = %.6f; %% pixels\n', min(results.LineLength(valid_measurements)));
        fprintf(fid, 'max_line_length = %.6f; %% pixels\n', max(results.LineLength(valid_measurements)));
        fprintf(fid, 'std_line_length = %.6f; %% pixels\n', std(results.LineLength(valid_measurements)));
        fprintf(fid, '\n');
        
        % Write detailed results
        fprintf(fid, '%% ========== DETAILED MEASUREMENT DATA ==========\n');
        fprintf(fid, '%% Format: [FrameNumber, LineLength, Point1_X, Point1_Y, Point2_X, Point2_Y]\n');
        fprintf(fid, 'measurement_data = [\n');
        for i = 1:height(results)
            fprintf(fid, '    %d, %.6f, %.6f, %.6f, %.6f, %.6f', ...
                    results.FrameNumber(i), results.LineLength(i), ...
                    results.Point1_X(i), results.Point1_Y(i), ...
                    results.Point2_X(i), results.Point2_Y(i));
            if i < height(results)
                fprintf(fid, ';');
            end
            fprintf(fid, '\n');
        end
        fprintf(fid, '];\n\n');
        
        % Write system information
        fprintf(fid, '%% ========== SYSTEM INFORMATION ==========\n');
        fprintf(fid, 'matlab_version = ''%s'';\n', version);
        fprintf(fid, 'computer_type = ''%s'';\n', computer);
        fprintf(fid, 'processing_date = ''%s'';\n', datestr(now));
        fprintf(fid, '\n');
        
        % Write instructions for data reconstruction
        fprintf(fid, '%% ========== DATA RECONSTRUCTION INSTRUCTIONS ==========\n');
        fprintf(fid, '%% To reconstruct the results table:\n');
        fprintf(fid, '%% results = table();\n');
        fprintf(fid, '%% results.FrameNumber = measurement_data(:,1);\n');
        fprintf(fid, '%% results.LineLength = measurement_data(:,2);\n');
        fprintf(fid, '%% results.Point1_X = measurement_data(:,3);\n');
        fprintf(fid, '%% results.Point1_Y = measurement_data(:,4);\n');
        fprintf(fid, '%% results.Point2_X = measurement_data(:,5);\n');
        fprintf(fid, '%% results.Point2_Y = measurement_data(:,6);\n\n');
        
        % Write file list (attempt to get actual processed files)
        fprintf(fid, '%% ========== PROCESSED FILES ==========\n');
        fprintf(fid, '%% Frame files that were successfully processed:\n');
        fprintf(fid, 'processed_files = {\n');
        for i = 1:length(frame_numbers)
            if results.LineLength(i) > 0  % Only include successfully measured frames
                frame_filename = findFrameFile(image_folder, frame_numbers(i), image_extension);
                if ~isempty(frame_filename)
                    fprintf(fid, '    ''%s''\n', frame_filename);
                end
            end
        end
        fprintf(fid, '};\n\n');
        
        fprintf(fid, '%% End of processing parameters file\n');
        
        fclose(fid);
        
    catch ME
        fclose(fid);
        warning('Error writing parameters file: %s', ME.message);
    end
end

%% Helper function to find frame file with flexible naming
function filename = findFrameFile(folder_path, frame_number, extension)
    % Find image file with frame_number in the last 4 digits before extension
    % Works with any prefix like "MeanZProjected0001.tif", "frame_0001.jpg", etc.
    
    % Get all files with the specified extension in the folder
    file_pattern = fullfile(folder_path, ['*' extension]);
    files = dir(file_pattern);
    
    if isempty(files)
        filename = '';
        return;
    end
    
    % Look for file with matching frame number in last 4 digits
    target_number_str = sprintf('%04d', frame_number); % Convert to 4-digit string
    
    for i = 1:length(files)
        current_filename = files(i).name;
        
        % Remove extension to work with base filename
        [~, base_name, ~] = fileparts(current_filename);
        
        % Check if filename ends with our target 4-digit number
        if length(base_name) >= 4
            last_4_chars = base_name(end-3:end);
            if strcmp(last_4_chars, target_number_str)
                filename = current_filename;
                return;
            end
        end
        
        % Also try checking if the last part of filename (after removing non-digits) matches
        % Extract all digits from filename
        digits_only = regexp(base_name, '\d+', 'match');
        if ~isempty(digits_only)
            % Check the last number found in filename
            last_number = str2double(digits_only{end});
            if last_number == frame_number
                filename = current_filename;
                return;
            end
        end
    end
    
    % If no exact match found, return empty
    filename = '';
end

%% Helper function to create sample Excel file for testing
function createSampleExcel()
    % Creates a sample frame_list.xlsx file for testing
    sample_frames = [1; 5; 10; 15; 20; 25; 30];
    writematrix(sample_frames, 'frame_list.xlsx');
    fprintf('Sample frame_list.xlsx created with frames: %s\n', mat2str(sample_frames'));
end

function [ h ] = fullfig(varargin)
%FULLFIG creates a full-screen figure. 
% 
%% Syntax 
% 
% fullfig
% fullfig('PropertyName',propertyvalue,...)
% fullfig(h)
% fullfig(...,'Border',BorderPercentage) 
% h = fullfig(...)
% 
%% Description 
%
% fullfig creates a new full-screen graphics figure.  This automatically becomes the
% the current figure and raises it above all other figures on the screen until a 
% new figure is either created or called.
% 
% fullfig('PropertyName',propertyvalue,...) creates a new figure object using the values 
% of the properties specified. For a description of the properties, see Figure Properties. 
% MATLAB uses default values for any properties that you do not explicitly define as arguments.
% 
% fullfig(h) does one of two things, depending on whether or not a figure with handle h 
% exists. If h is the handle to an existing figure, fullfig(h) makes the figure identified
% by h the current figure, makes it visible, makes it full-screen, applies a Border if a Border
% is specified, and raises the figure above all other figures on the screen. The current 
% figure is the target for graphics output. If h is not the handle to an existing figure, but 
% is an integer, fullfig(h) creates a figure and assigns it the handle h. fullfig(h) where h 
% is not the handle to a figure, and is not an integer, is an error.
% 
% fullfig(...,'Border',BorderPercentage) creates a Border between the perimeter of the figure
% and the perimeter of your screen. BorderPercentage must be in the range of 0 to 50, and can 
% be a scalar value to apply the same percentage value to the width and height of the figure, 
% or a two-element vector to apply different Borders in the x- and y- directions, respectively. 
%
% h = fullfig(...) returns the handle to the figure object.
% 
%% Author Info
% This function was written by Chad A. Greene (www.chadagreene.com) of the
% University of Texas Institute for Geophysics in sunny Austin, Texas, 
% October 2014.
% 
% See also: figure, Figure Properties, clf, close, axes

% Set defaults: 
bufx = 0; 
bufy = 0; 
NewFigure = true; 
SpecifiedNewFigureNumber = false; 

% If the first input argument is a handle of a current figure, don't create a new figure: 
if nargin>0 
    if ishandle(varargin{1})
        NewFigure = false; 
        h = varargin{1}; 
        varargin(1)=[]; 
    else
        % If the first input argument seems like it might be a figure handle, but isn't a handle 
        % of a current figure, create a new figure with the user-specified handle. 
        if isnumeric(varargin{1})==1
            SpecifiedNewFigureNumber = true; 
            h = varargin{1}; 
            varargin(1)=[]; 
        end
    end   
end

% Get Border preferences: I originally called this a buffer, but border is more intuitive. Accept either: 
tmp = strncmpi(varargin,'bor',3)|strncmpi(varargin,'buf',3); 
if any(tmp)
    Border = varargin{find(tmp)+1}; 
    tmp(find(tmp)+1)=1; 
    varargin = varargin(~tmp); 
    assert(isnumeric(Border)==1,'Border value must be numeric.')
    assert(numel(Border)<3,'Border must be a scalar or two-element vector.')
    assert(any(Border>=50)==0,'Border value cannot exceed 50 percent.') 
    assert(any(Border<0)==0,'Border value cannot be less than zero percent.') 
    
    if isscalar(Border)
        bufx = Border/100; 
        bufy = Border/100; 
    else
        bufx = Border(1)/100; 
        bufy = Border(2)/100; 
    end
end

% Create new figure or change old one: 
if NewFigure
    if SpecifiedNewFigureNumber
        h = set(h,'units','normalized','outerposition',[bufx bufy 1-2*bufx 1-2*bufy],varargin{:});
    else
        h = figure('units','normalized','outerposition',[bufx bufy 1-2*bufx 1-2*bufy],varargin{:}); 
    end
else
    set(h,'units','normalized','outerposition',[bufx bufy 1-2*bufx 1-2*bufy],varargin{:}); 
end
    

% Clean up:
if nargout==0
    clear h
end


end


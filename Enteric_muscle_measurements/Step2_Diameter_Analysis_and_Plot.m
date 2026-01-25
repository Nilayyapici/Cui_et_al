%% ---------- User-defined Parameters ----------
clear all
clc

input_folder = 'C:\111CXYFiles\Work2024\2025\Zasp66Data_Stats\Stat-New\CropDuct';
pixel_size_file = 'C:\111CXYFiles\Work2024\2025\Zasp66Data_Stats\Stat-New\PixelSizeUM\PixelSizeUM.xlsx';
output_folder = 'C:\111CXYFiles\Work2024\2025\Zasp66Data_Stats\Stat-New\NewCropDuct_AnalysisResult';

RedLightOnFrames=[65,185,306];
RedLightOffFrames=[125,245,366];
TotalTimeOfTrialInSec=240;
ZProjFrameNumberOfEachTrial=485;
DataSampledFromEachHowManyFrame=6;

% --- Normalization Settings ---
EnableNormalization = true;  % Set to true to enable normalization, false to disable
BasalTimeWindowSec = [0, 30];  % Time window in seconds used to define basal diameter. [0, 30] means "from the beginning of the trial (0s) to 30-th second of the trial".

%% ---------- Step 1: Load CSV and combine ----------
[diameter_matrix_pixels, file_names, frame_numbers] = load_and_combine_csv_files(input_folder);

pixel_output_file = fullfile(output_folder, 'diameter_data_pixels.xlsx');
save_diameter_matrix_to_excel(diameter_matrix_pixels, file_names, frame_numbers, pixel_output_file);

%% ---------- Step 2: Convert to micrometers ----------
[diameter_matrix_um, pixel_sizes] = convert_pixels_to_micrometers(diameter_matrix_pixels, file_names, pixel_size_file);

um_output_file = fullfile(output_folder, 'diameter_data_micrometers.xlsx');
save_diameter_matrix_to_excel(diameter_matrix_um, file_names, frame_numbers, um_output_file);

%% ---------- Step 3: Compute stats & plot raw diameter ----------
[mean_diameters, sem_diameters, stats_table] = calculate_statistics(diameter_matrix_um, file_names, frame_numbers);

stats_output_file = fullfile(output_folder, 'diameter_statistics.xlsx');
writetable(stats_table, stats_output_file);

TimeXAxis=create_plots(mean_diameters, sem_diameters, file_names, output_folder, frame_numbers, ...
    RedLightOnFrames, RedLightOffFrames, TotalTimeOfTrialInSec, ZProjFrameNumberOfEachTrial, ...
    DataSampledFromEachHowManyFrame,'Diameter(um)','Diameter (\mum)');
TimeXAxis=TimeXAxis';

% Save raw plotted time data
data_table = array2table([TimeXAxis, mean_diameters,sem_diameters], ...
    'VariableNames', [{'Time(s)'}, {'Mean Diameter'},{'SEM'}]);
Plot_output_file = fullfile(output_folder, 'Plotted_Data.xlsx');
writetable(data_table, Plot_output_file,'Sheet', 'Diameter(um)');

%% ---------- Step 3.5: Plot individual fly responses for raw diameter ----------
create_individual_fly_plots(diameter_matrix_um, file_names, frame_numbers, output_folder, ...
    RedLightOnFrames, RedLightOffFrames, TotalTimeOfTrialInSec, ZProjFrameNumberOfEachTrial, ...
    DataSampledFromEachHowManyFrame, 'Diameter(um)', 'Diameter (\mum)');

%% ---------- Step 4: Optional normalization ----------
if EnableNormalization
    fprintf('Step 4: Performing normalization...\n');
    [delta_matrix, delta_over_basal_matrix, basal_values] = normalize_diameters(...
        diameter_matrix_um, frame_numbers, BasalTimeWindowSec, TotalTimeOfTrialInSec);

    % Save basal values for record
    T_basal = table(file_names', basal_values', 'VariableNames', {'TrialName', 'BasalDiameter_um'});
    writetable(T_basal, fullfile(output_folder, 'BasalDiameters.xlsx'),'Sheet', 'BasalDiameters');

%% ----------- Creat plots-----------
    % Plot delta
    [mean_delta, sem_delta, stats_delta] = calculate_statistics(delta_matrix, file_names, frame_numbers);
    create_plots(mean_delta, sem_delta, file_names, output_folder, frame_numbers, ...
        RedLightOnFrames, RedLightOffFrames, TotalTimeOfTrialInSec, ...
        ZProjFrameNumberOfEachTrial, DataSampledFromEachHowManyFrame, ...
        'Delta Diameter','\DeltaDiameter (\mum)',[-6,10],2);

    % Plot individual flies for delta
    create_individual_fly_plots(delta_matrix, file_names, frame_numbers, output_folder, ...
        RedLightOnFrames, RedLightOffFrames, TotalTimeOfTrialInSec, ZProjFrameNumberOfEachTrial, ...
        DataSampledFromEachHowManyFrame, 'Delta Diameter', '\DeltaDiameter (\mum)');

    % Plot delta over basal
    [mean_dob, sem_dob, stats_dob] = calculate_statistics(delta_over_basal_matrix, file_names, frame_numbers);
    create_plots(mean_dob, sem_dob, file_names, output_folder, frame_numbers, ...
        RedLightOnFrames, RedLightOffFrames, TotalTimeOfTrialInSec, ...
        ZProjFrameNumberOfEachTrial, DataSampledFromEachHowManyFrame, ...
        'DeltaOverBasalDiameter','\DeltaDiameter/Diameter_0',[-0.2, 0.4],0.2);

    % Plot individual flies for delta over basal
    create_individual_fly_plots(delta_over_basal_matrix, file_names, frame_numbers, output_folder, ...
        RedLightOnFrames, RedLightOffFrames, TotalTimeOfTrialInSec, ZProjFrameNumberOfEachTrial, ...
        DataSampledFromEachHowManyFrame, 'DeltaOverBasalDiameter', '\DeltaDiameter/Diameter_0', [-0.5, 1], 0.5);

    % Save stats to diameter_statistics.xlsx
    writetable(stats_delta, stats_output_file, 'WriteMode', 'overwrite', 'Sheet', 'DeltaDiameter');
    writetable(stats_dob, stats_output_file, 'WriteMode', 'overwrite', 'Sheet', 'DelD_BasalD');

    % Save time-based to Plotted_Data.xlsx
    data_delta = array2table([TimeXAxis, mean_delta, sem_delta], ...
        'VariableNames', [{'Time(s)'}, {'Mean Delta'},{'SEM'}]);
    data_dob = array2table([TimeXAxis, mean_dob, sem_dob], ...
        'VariableNames', [{'Time(s)'}, {'Mean Δ/Basal'},{'SEM'}]);
    writetable(data_delta, Plot_output_file, 'WriteMode', 'overwrite', 'Sheet', 'DeltaDiameter');
    writetable(data_dob, Plot_output_file, 'WriteMode', 'overwrite', 'Sheet', 'DelD_BasalD');

    % Save each fly trace to diameter_data_micrometers.xlsx
    D1 = array2table(delta_matrix, 'VariableNames', file_names);
    D2 = array2table(delta_over_basal_matrix, 'VariableNames', file_names);
    D1 = addvars(D1, frame_numbers, 'Before', 1, 'NewVariableNames','Frame_No');
    D2 = addvars(D2, frame_numbers, 'Before', 1, 'NewVariableNames','Frame_No');
    writetable(D1, um_output_file, 'WriteMode', 'overwrite', 'Sheet', 'DeltaDiameter');
    writetable(D2, um_output_file, 'WriteMode', 'overwrite', 'Sheet', 'DelD_BasalD');

    % Compute Peak and AUC stats for each fly and each stim segment
    [peak_ddi, peak_dob, auc_values] = compute_segment_stats(delta_matrix, delta_over_basal_matrix, file_names, RedLightOnFrames, RedLightOffFrames, DataSampledFromEachHowManyFrame);

    % Save the 3 stats tables to a single Excel file
    SegmentStatFile = fullfile(output_folder, 'SegmentPeak_AUC_Stats.xlsx');
    peak_ddi = addvars(peak_ddi, file_names(:), 'Before', 1, 'NewVariableNames', 'TrialName');
    peak_dob = addvars(peak_dob, file_names(:), 'Before', 1, 'NewVariableNames', 'TrialName');
    auc_values = addvars(auc_values, file_names(:), 'Before', 1, 'NewVariableNames', 'TrialName');
    
    writetable(peak_ddi, SegmentStatFile, 'Sheet', 'DeltaDiameter', 'WriteRowNames', false);
    writetable(peak_dob, SegmentStatFile, 'Sheet', 'DeltaDi_BasalDi', 'WriteRowNames', false);
    writetable(auc_values, SegmentStatFile, 'Sheet', 'AUC', 'WriteRowNames', false);
end

function [peak_ddi_tbl, peak_dob_tbl, auc_tbl] = compute_segment_stats(delta_matrix, dob_matrix, file_names, ...
    RedLightOnFrames, RedLightOffFrames, DataSampledFromEachHowManyFrame)
    num_flies = size(delta_matrix, 2);
    num_segments = length(RedLightOnFrames);

    output_ddi_data = zeros(num_flies, num_segments * 3);
    output_dob_data = zeros(num_flies, num_segments * 3);
    auc_data = zeros(num_flies, num_segments * 2);

    % Scale frame indices according to subsampling rate
    frame_scaling = 1 / DataSampledFromEachHowManyFrame;
    OnIdxs  = round(RedLightOnFrames  * frame_scaling);
    OffIdxs = round(RedLightOffFrames * frame_scaling);

    for i = 1:num_flies
        for j = 1:num_segments
            idx_start = OnIdxs(j);
            idx_end   = OffIdxs(j);

            % Prevent out-of-bounds error
            idx_start = max(1, min(idx_start, size(delta_matrix,1)));
            idx_end   = max(1, min(idx_end,   size(delta_matrix,1)));

            ddi_seg = delta_matrix(idx_start:idx_end, i);
            dob_seg = dob_matrix(idx_start:idx_end, i);

            % DDi: max, min, peak
            % Column seq of output_ddi_data: 1st stim max, 1st stim min, 1st stime peak, 2nd stim max, min, peak, 3rd stim max, min, peak
            output_ddi_data(i, (j-1)*3 + 1) = max(ddi_seg, [], 'omitnan');
            output_ddi_data(i, (j-1)*3 + 2) = min(ddi_seg, [], 'omitnan');
            [~, peak_idx] = max(abs(ddi_seg));
            output_ddi_data(i, (j-1)*3 + 3) = ddi_seg(peak_idx);

            % DOB: max, min, peak
            % Column seq of output_dob_data: 1st stim max, 1st stim min, 1st stime peak, 2nd stim max, min, peak, 3rd stim max, min, peak
            output_dob_data(i, (j-1)*3 + 1) = max(dob_seg, [], 'omitnan');
            output_dob_data(i, (j-1)*3 + 2) = min(dob_seg, [], 'omitnan');
            [~, peak_idx] = max(abs(dob_seg));
            output_dob_data(i, (j-1)*3 + 3) = dob_seg(peak_idx);

            % AUC: trapz for each
            % Column seq of auc_data: 1st Stim DDI AUC, 1st Stim DOB AUC, 2nd Stim DDI AUC, 2nd Stim DOB AUC, 3rd Stim DDI AUC, 3rd Stim DOB AUC
            auc_data(i, (j-1)*2 + 1) = trapz(ddi_seg);
            auc_data(i, (j-1)*2 + 2) = trapz(dob_seg);
        end
    end

    % Create tables with appropriate headers
    ddi_headers = compose_headers({'Max','Min','Peak'}, 'Delta Diameter', 1:3, true);
    dob_headers = compose_headers({'Max','Min','Peak'}, 'Delta/Basal', 1:3, true);
    auc_headers = compose_headers({'AUC Delta Diameter', 'AUC Delta/Basal'}, '', 1:3, true);

    peak_ddi_tbl = array2table(output_ddi_data, 'VariableNames', ddi_headers);
    peak_dob_tbl = array2table(output_dob_data, 'VariableNames', dob_headers);
    auc_tbl      = array2table(auc_data, 'VariableNames', auc_headers);
end

function headers = compose_headers(types, prefix, segments, interleaved)
    if nargin < 3
        segments = 1:3;
    end
    if nargin < 4
        interleaved = false;
    end

    headers = {};
    if interleaved
        % Interleave types and segments: e.g., Max1, Min1, Max2, Min2, etc.
        for s = segments
            for t = 1:length(types)
                headers{end+1} = sprintf('%s %s During %d%s Stim', types{t}, prefix, s, nth_suffix(s));
            end
        end
    else
        % Group all of type1, then type2, etc.
        for t = 1:length(types)
            for s = segments
                headers{end+1} = sprintf('%s %s During %d%s Stim', types{t}, prefix, s, nth_suffix(s));
            end
        end
    end
end

function suf = nth_suffix(n)
    switch n
        case 1, suf = 'st';
        case 2, suf = 'nd';
        case 3, suf = 'rd';
        otherwise, suf = 'th';
    end
end

function create_individual_fly_plots(diameter_matrix, file_names, frame_numbers, output_folder, ...
    RedLightOnFrames, RedLightOffFrames, TotalTimeOfTrialInSec, ZProjFrameNumberOfEachTrial, ...
    DataSampledFromEachHowManyFrame, suffix, YAxisLabel, YLimits, YStepSize)

    % Handle optional parameters
    if nargin < 10 || isempty(suffix)
        suffix = '';
    else
        suffix = ['_' suffix];
    end
    
    % Create separate folder for individual fly plots
    sepfly_folder = fullfile(output_folder, ['IndividualFlies' suffix]);
    if ~exist(sepfly_folder, 'dir')
        mkdir(sepfly_folder);
    end
    
    % Calculate time parameters
    TimeOfEachFrame = TotalTimeOfTrialInSec / ZProjFrameNumberOfEachTrial;
    
    fprintf('Creating individual fly plots...\n');
    
    % Loop through each fly to create individual plots
    for fly_idx = 1:length(file_names)
        % Extract data for this specific fly
        fly_data = diameter_matrix(:, fly_idx);
        valid_fly_idx = ~isnan(fly_data);
        fly_data_valid = fly_data(valid_fly_idx);
        frames_fly_valid = frame_numbers(valid_fly_idx);
        time_fly_valid = frames_fly_valid * TimeOfEachFrame;
        
        if isempty(fly_data_valid)
            fprintf('Skipping %s: no valid data\n', file_names{fly_idx});
            continue; % Skip if no valid data for this fly
        end
        
        % Create figure for this fly
        fig_fly = figure('Position', [200, 200, 800, 400]);
        hax_fly = axes;
        set(gca, 'fontsize', 15);
        
        yyaxis(hax_fly, 'left');
        hold on;
        plot(time_fly_valid, fly_data_valid, 'k-', 'LineWidth', 1.5);
        
        xlim([0, ceil(max(frames_fly_valid) * TimeOfEachFrame)]);
        xlabel('Time (s)');
        ylabel(YAxisLabel);
        
        % Set Y limits if provided
        if exist('YLimits', 'var') && exist('YStepSize', 'var') && ~isempty(YLimits)
            ylim(YLimits);
            yticks(YLimits(1):YStepSize:YLimits(2));
        end
        
        title([file_names{fly_idx} ' \- ' strrep(suffix, ' \_', ' ')],'FontSize',14);
        
        % Add stimulation periods
        yyaxis(hax_fly, 'right');
        for i = 1:length(RedLightOnFrames)
            xb1 = [RedLightOnFrames(i)*TimeOfEachFrame, RedLightOnFrames(i)*TimeOfEachFrame, ...
                   RedLightOffFrames(i)*TimeOfEachFrame, RedLightOffFrames(i)*TimeOfEachFrame];
            yb1 = [0, 1, 1, 0];
            b1 = patch(xb1, yb1, 'r');
            b1.FaceAlpha = 0.15;
            b1.EdgeAlpha = 0;
            b1.EdgeColor = 'none';
        end
        
        ylabel('Optogenetic Stimulation');
        ylim([0, 1]);
        hax_fly.YAxis(1).Color = 'k';
        hax_fly.YAxis(2).Color = 'k';
        hax_fly.YAxis(2).Visible = 'off';
        
        set(fig_fly, 'Units', 'Inches', 'Position', [0, 0, 8, 3.5], 'PaperUnits', 'Inches', 'PaperSize', [12, 3.5]);
        
        % Save individual fly plot
        fly_filename = [file_names{fly_idx} suffix];
        saveas(fig_fly, fullfile(sepfly_folder, [fly_filename '.png']));
        saveas(fig_fly, fullfile(sepfly_folder, [fly_filename '.svg']));
        saveas(fig_fly, fullfile(sepfly_folder, [fly_filename '.fig']));
        
        close(fig_fly); % Close figure to save memory
        
        if mod(fly_idx, 10) == 0
            fprintf('Completed %d/%d individual plots\n', fly_idx, length(file_names));
        end
    end
    
    fprintf('Individual fly plots saved to: %s\n', sepfly_folder);
end

%% ---------- Helper Function: Normalize Diameters ----------
function [delta_matrix, delta_over_basal_matrix, basal_values] = normalize_diameters(diameter_matrix_um, frame_numbers, BasalTimeWindowSec, TotalTimeSec)
    num_flies = size(diameter_matrix_um, 2);
    num_frames = length(frame_numbers);
    delta_matrix = NaN(size(diameter_matrix_um));
    delta_over_basal_matrix = NaN(size(diameter_matrix_um));
    basal_values = NaN(1, num_flies);

    TimeOfEachFrame = TotalTimeSec / num_frames;
    TimeVector = (0:num_frames-1) * TimeOfEachFrame;

    for i = 1:num_flies
        fly_trace = diameter_matrix_um(:, i);
        % Get basal indices within the specified time window
        basal_idx = find(TimeVector >= BasalTimeWindowSec(1) & TimeVector <= BasalTimeWindowSec(2));
        valid_basal = fly_trace(basal_idx);
        valid_basal = valid_basal(~isnan(valid_basal));

        if isempty(valid_basal)
            warning('Fly %d: No valid basal data found.', i);
            continue;
        end

        basal_value = mean(valid_basal);
        basal_values(i) = basal_value;

        delta_matrix(:, i) = fly_trace - basal_value;
        delta_over_basal_matrix(:, i) = (fly_trace - basal_value) / basal_value;
    end
end

%% ---------- Updated Function: create_plots (Add suffix) ----------
function [TimeXAxis]=create_plots(mean_diameters, sem_diameters, file_names, output_folder, frame_numbers,...
    RedLightOnFrames, RedLightOffFrames, TotalTimeOfTrialInSec, ZProjFrameNumberOfEachTrial, ...
    DataSampledFromEachHowManyFrame, suffix,...
    CostumeLeftYlabel, CostumeLeftYLim,CostumeYStepSize)

    if nargin < 11
        suffix = '';
    else
        suffix = [', ' suffix];
    end

    valid_idx = ~isnan(mean_diameters);
    mean_valid = mean_diameters(valid_idx);
    sem_valid = sem_diameters(valid_idx);
    frames_valid = frame_numbers(valid_idx);

    fig1=figure();
    hax1=axes;
    yyaxis(hax1,'left');
    hold on;
    shadedErrorBar(frames_valid, mean_valid, sem_valid,'lineProps','k-');

    xlabel('Frame Number');
    ylabel(CostumeLeftYlabel);
    if exist('CostumeLeftYLim','var') && exist('CostumeYStepSize','var')
        ylim(CostumeLeftYLim);
        yticks([CostumeLeftYLim(1):CostumeYStepSize:CostumeLeftYLim(2)]);
    end
    title(['Mean Diameter \pm SEM' suffix]);
    xlim([0,max(frames_valid)]);
    set(gca,'fontsize',15);

    yyaxis(hax1,'right');
    for i=1:size(RedLightOnFrames,2)
        xb1=[RedLightOnFrames(i) RedLightOnFrames(i) RedLightOffFrames(i) RedLightOffFrames(i)];
        yb1=[0 1 1 0];
        b1=patch(xb1,yb1,'r');
        b1.FaceAlpha=0.15;
        b1.EdgeAlpha=0;
        b1.EdgeColor='none';
    end
    ylabel('Optogenetic Stimulation');
    ylim([0,1]);
    set(gca,'fontsize',15);
    set(fig1, 'Units', 'Inches', 'Position', [0, 0, 8, 3.5], 'PaperUnits', 'Inches', 'PaperSize', [12, 3.5]);    
    hax1.YAxis(1).Color='k';
    hax1.YAxis(2).Color='k';
    hax1.YAxis(2).Visible='off';

    saveas(fig1, fullfile(output_folder, ['Diameter_ByFrame' strrep(suffix,', ','_') '.png']));
    saveas(fig1, fullfile(output_folder, ['Diameter_ByFrame' strrep(suffix,', ','_') '.svg']));
    saveas(fig1, fullfile(output_folder, ['Diameter_ByFrame' strrep(suffix,', ','_') '.fig']));

    TimeOfEachFrame = TotalTimeOfTrialInSec/ZProjFrameNumberOfEachTrial;
    TimeXAxis=[0:TimeOfEachFrame*6:TotalTimeOfTrialInSec];
    TimeXAxis=TimeXAxis(2:1+size(frame_numbers,1));

    fig2=figure();
    hax2=axes;
    set(gca,'fontsize',15);

    yyaxis(hax2,'left');
    hold on;
    shadedErrorBar(TimeXAxis, mean_valid, sem_valid,'lineProps','k-');

    xlim([0, ceil(max(frames_valid)*TimeOfEachFrame)]);
    xlabel('Time (s)');
    ylabel(CostumeLeftYlabel);
    if exist('CostumeLeftYLim','var') && exist('CostumeYStepSize','var')
        ylim(CostumeLeftYLim);
        yticks([CostumeLeftYLim(1):CostumeYStepSize:CostumeLeftYLim(2)]);
    end
    title(['Mean Diameter \pm SEM' suffix]);

    yyaxis(hax2,'right');
    for i=1:size(RedLightOnFrames,2)
        xb1=[RedLightOnFrames(i)*TimeOfEachFrame, RedLightOnFrames(i)*TimeOfEachFrame, ...
            RedLightOffFrames(i)*TimeOfEachFrame, RedLightOffFrames(i)*TimeOfEachFrame];
        yb1=[0 1 1 0];
        b1=patch(xb1,yb1,'r');
        b1.FaceAlpha=0.15;
        b1.EdgeAlpha=0;
        b1.EdgeColor='none';
    end

    ylabel('Optogenetic Stimulation');
    ylim([0,1]);
    set(gca,'fontsize',15);

    set(fig2, 'Units', 'Inches', 'Position', [0, 0, 8, 3.5], 'PaperUnits', 'Inches', 'PaperSize', [12, 3.5]);    
    hax2.YAxis(1).Color='k';
    hax2.YAxis(2).Color='k';
    hax2.YAxis(2).Visible='off';

    saveas(fig2, fullfile(output_folder, ['Diameter_ByTime' strrep(suffix,', ','_') '.png']));
    saveas(fig2, fullfile(output_folder, ['Diameter_ByTime' strrep(suffix,', ','_') '.svg']));
    saveas(fig2, fullfile(output_folder, ['Diameter_ByTime' strrep(suffix,', ','_') '.fig']));

    % Close figures to save memory
    close(fig1);
    close(fig2);
end

function [diameter_matrix, file_names, frame_numbers] = load_and_combine_csv_files(input_folder)
    % Load all CSV files and combine diameter data
    
    % Get list of CSV files
    csv_files = dir(fullfile(input_folder, '*.csv'));
    num_files = length(csv_files);
    
    if num_files == 0
        error('No CSV files found in the specified folder.');
    end
    
    fprintf('Found %d CSV files\n', num_files);
    
    % Initialize variables
    diameter_matrix = [];
    file_names = {};
    frame_numbers = [];
    max_rows = 0;
    
    % First pass: determine maximum number of rows
    for i = 1:num_files
        csv_path = fullfile(input_folder, csv_files(i).name);
        data = readmatrix(csv_path);
        max_rows = max(max_rows, size(data, 1));
    end
    
    % Initialize matrix with NaN values
    diameter_matrix = NaN(max_rows, num_files);
    frame_numbers = NaN(max_rows, 1);
    
    % Second pass: load data
    for i = 1:num_files
        csv_path = fullfile(input_folder, csv_files(i).name);
        [~, filename, ~] = fileparts(csv_files(i).name);
        file_names{i} = filename;
        
        try
            data = readmatrix(csv_path);
            if size(data, 2) < 2
                warning('File %s does not have enough columns. Skipping.', csv_files(i).name);
                continue;
            end
            
            num_rows = size(data, 1);
            diameter_matrix(1:num_rows, i) = data(:, 2); % Diameter data (column 2)
            
            % Store frame numbers from first file (assuming all files have same frame structure)
            if i == 1
                frame_numbers(1:num_rows) = data(:, 1); % Frame numbers (column 1)
            end
            
            fprintf('Loaded %s: %d measurements\n', filename, num_rows);
            
        catch ME
            warning('Error loading file %s: %s', csv_files(i).name, ME.message);
        end
    end
    
    % Remove rows that are all NaN
    valid_rows = ~all(isnan(diameter_matrix), 2);
    diameter_matrix = diameter_matrix(valid_rows, :);
    frame_numbers = frame_numbers(valid_rows);
end

function save_diameter_matrix_to_excel(diameter_matrix, file_names, frame_numbers, output_file)
    % Save diameter matrix to Excel file with proper formatting
    
    % Create table with frame numbers as first column
    data_table = array2table([frame_numbers, diameter_matrix], ...
        'VariableNames', ['Frame_No', file_names]);
    
    % Write to Excel
    writetable(data_table, output_file, 'WriteRowNames', false);
end

function [diameter_matrix_um, pixel_sizes] = convert_pixels_to_micrometers(diameter_matrix_pixels, file_names, pixel_size_file)
    % Convert pixel measurements to micrometers using pixel size lookup table
    
    try
        % Read pixel size data
        pixel_size_table = readtable(pixel_size_file);
        
        % Initialize output matrix
        diameter_matrix_um = diameter_matrix_pixels;
        pixel_sizes = zeros(1, length(file_names));
        
        % Convert each file's data
        for i = 1:length(file_names)
            % Find matching pixel size for this file
            file_match_idx = [];
            
            % Try different matching strategies
            for j = 1:height(pixel_size_table)
                % Check if filename matches any column in the pixel size table
                table_entry = table2cell(pixel_size_table(j, 1));
                if ischar(table_entry{1}) || isstring(table_entry{1})
                    if contains(file_names{i}, char(table_entry{1})) || contains(char(table_entry{1}), file_names{i})
                        file_match_idx = j;
                        break;
                    end
                end
            end
            
            if isempty(file_match_idx)
                % If no exact match, prompt user or use default
                fprintf('No pixel size found for file: %s\n', file_names{i});
                pixel_size = input(sprintf('Enter pixel size (um/pixel) for %s: ', file_names{i}));
            else
                % Get pixel size from table (assuming it's in column 2)
                pixel_size = pixel_size_table{file_match_idx, 2};
                if iscell(pixel_size)
                    pixel_size = pixel_size{1};
                end
            end
            
            pixel_sizes(i) = pixel_size;
            diameter_matrix_um(:, i) = diameter_matrix_pixels(:, i) * pixel_size;
            
            fprintf('File %s: pixel size = %.4f um/pixel\n', file_names{i}, pixel_size);
        end
        
    catch ME
        warning('Error reading pixel size file: %s', ME.message);
        fprintf('Using default pixel size conversion...\n');
        
        % Fallback: ask user for default pixel size
        default_pixel_size = input('Enter default pixel size (um/pixel): ');
        pixel_sizes = repmat(default_pixel_size, 1, length(file_names));
        diameter_matrix_um = diameter_matrix_pixels * default_pixel_size;
    end
end

function [mean_diameters, sem_diameters, stats_table] = calculate_statistics(diameter_matrix_um, file_names, frame_numbers)
    % Calculate mean and SEM for diameter measurements across flies for each frame
    
    [num_frames, num_files] = size(diameter_matrix_um);
    mean_diameters = zeros(num_frames, 1);
    sem_diameters = zeros(num_frames, 1);
    std_diameters = zeros(num_frames, 1);
    n_flies_per_frame = zeros(num_frames, 1);
    
    % Calculate statistics for each frame (across flies)
    for i = 1:num_frames
        frame_data = diameter_matrix_um(i, :); % Data across all flies for this frame
        valid_data = frame_data(~isnan(frame_data));
        
        if length(valid_data) >= 1
            mean_diameters(i) = mean(valid_data);
            if length(valid_data) > 1
                std_diameters(i) = std(valid_data);
                sem_diameters(i) = std_diameters(i) / sqrt(length(valid_data));
            else
                std_diameters(i) = 0;
                sem_diameters(i) = 0;
            end
            n_flies_per_frame(i) = length(valid_data);
        else
            mean_diameters(i) = NaN;
            std_diameters(i) = NaN;
            sem_diameters(i) = NaN;
            n_flies_per_frame(i) = 0;
        end
    end
    
    % Remove frames with no valid data
    valid_frames = ~isnan(mean_diameters);
    
    % Create statistics table
    stats_table = table(frame_numbers(valid_frames), mean_diameters(valid_frames), ...
        std_diameters(valid_frames), sem_diameters(valid_frames), n_flies_per_frame(valid_frames), ...
        'VariableNames', {'Frame_Number', 'Mean_Diameter_um', 'Std_Diameter_um', 'SEM_Diameter_um', 'N_Flies'});
    
    % Display summary statistics
    fprintf('\nSummary Statistics (across frames):\n');
    fprintf('Number of valid frames: %d\n', sum(valid_frames));
    fprintf('Overall mean diameter across all frames: %.2f um\n', ...
        mean(mean_diameters, 'omitnan'));
    fprintf('Range of frame means: %.2f - %.2f um\n', ...
        min(mean_diameters, [], 'omitnan'), max(mean_diameters, [], 'omitnan'));
    fprintf('Average number of flies per frame: %.1f\n', mean(n_flies_per_frame(valid_frames)));
end


function varargout=shadedErrorBar(x,y,errBar,varargin)
% generate continuous error bar area around a line plot
%
% function H=shadedErrorBar(x,y,errBar, ...)
%
% Purpose 
% Makes a 2-d line plot with a pretty shaded error bar made
% using patch. Error bar color is chosen automatically.
%
%
% Inputs (required)
% x - vector of x values [optional, can be left empty]
% y - vector of y values or a matrix of n observations by m cases
%     where m has length(x);
% errBar - if a vector we draw symmetric errorbars. If it has a size
%          of [2,length(x)] then we draw asymmetric error bars with
%          row 1 being the upper bar and row 2 being the lower bar
%          (with respect to y -- see demo). ** alternatively ** 
%          errBar can be a cellArray of two function handles. The 
%          first defines statistic the line should be and the second 
%          defines the error bar.
%
% Inputs (optional, param/value pairs)
% 'lineProps' - ['-k' by default] defines the properties of
%             the data line. e.g.:    
%             'or-', or {'-or','markerfacecolor',[1,0.2,0.2]}
% 'transparent' - [true  by default] if true, the shaded error
%               bar is made transparent. However, for a transparent
%               vector image you will need to save as PDF, not EPS,
%               and set the figure renderer to "painters". An EPS 
%               will only be transparent if you set the renderer 
%               to OpenGL, however this makes a raster image.
% 'patchSaturation'- [0.2 by default] The saturation of the patch color.
%
%
%
% Outputs
% H - a structure of handles to the generated plot objects.
%
%
% Examples:
% y=randn(30,80); 
% x=1:size(y,2);
%
% 1)
% shadedErrorBar(x,mean(y,1),std(y),'lineprops','g');
%
% 2)
% shadedErrorBar(x,y,{@median,@std},'lineprops',{'r-o','markerfacecolor','r'});
%
% 3)
% shadedErrorBar([],y,{@median,@(x) std(x)*1.96},'lineprops',{'r-o','markerfacecolor','k'});
%
% 4)
% Overlay two transparent lines:
% clf
% y=randn(30,80)*10; 
% x=(1:size(y,2))-40;
% shadedErrorBar(x,y,{@mean,@std},'lineprops','-r','transparent',1);
% hold on
% y=ones(30,1)*x; y=y+0.06*y.^2+randn(size(y))*10;
% shadedErrorBar(x,y,{@mean,@std},'lineprops','-b','transparent',1);
% hold off
%
%
% Rob Campbell - November 2009



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse input arguments
narginchk(3,inf)

params = inputParser;
params.CaseSensitive = false;
params.addParameter('lineProps', '-k', @(x) ischar(x) | iscell(x));
params.addParameter('transparent', true, @(x) islogical(x) || x==0 || x==1);
params.addParameter('patchSaturation', 0.2, @(x) isnumeric(x) && x>=0 && x<=1);

params.parse(varargin{:});

%Extract values from the inputParser
lineProps =  params.Results.lineProps;
transparent =  params.Results.transparent;
patchSaturation = params.Results.patchSaturation;

if ~iscell(lineProps), lineProps={lineProps}; end


%Process y using function handles if needed to make the error bar dynamically
if iscell(errBar) 
    fun1=errBar{1};
    fun2=errBar{2};
    errBar=fun2(y);
    y=fun1(y);
else
    y=y(:).';
end

if isempty(x)
    x=1:length(y);
else
    x=x(:).';
end


%Make upper and lower error bars if only one was specified
if length(errBar)==length(errBar(:))
    errBar=repmat(errBar(:)',2,1);
else
    s=size(errBar);
    f=find(s==2);
    if isempty(f), error('errBar has the wrong size'), end
    if f==2, errBar=errBar'; end
end

if length(x) ~= length(errBar)
    error('length(x) must equal length(errBar)')
end


%Log the hold status so we don't change
initialHoldStatus=ishold;
if ~initialHoldStatus, hold on,  end

H = makePlot(x,y,errBar,lineProps,transparent,patchSaturation);

if ~initialHoldStatus, hold off, end

if nargout==1
    varargout{1}=H;
end
end

function H = makePlot(x,y,errBar,lineProps,transparent,patchSaturation)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot to get the parameters of the line

    H.mainLine=plot(x,y,lineProps{:});


    % Work out the color of the shaded region and associated lines.
    % Here we have the option of choosing alpha or a de-saturated
    % solid colour for the patch surface.
    mainLineColor=get(H.mainLine,'color');
    edgeColor=mainLineColor+(1-mainLineColor)*0.55;

    if transparent
        faceAlpha=patchSaturation;
        patchColor=mainLineColor;
    else
        faceAlpha=1;
        patchColor=mainLineColor+(1-mainLineColor)*(1-patchSaturation);
    end


    %Calculate the error bars
    uE=y+errBar(1,:);
    lE=y-errBar(2,:);


    %Add the patch error bar



    %Make the patch
    yP=[lE,fliplr(uE)];
    xP=[x,fliplr(x)];

    %remove nans otherwise patch won't work
    xP(isnan(yP))=[];
    yP(isnan(yP))=[];


    if(isdatetime(x))
        H.patch=patch(datenum(xP),yP,1,'HandleVisibility','off');
    else
        H.patch=patch(xP,yP,1,'HandleVisibility','off');
    end

    set(H.patch,'facecolor',patchColor, ...
        'edgecolor','none', ...
        'facealpha',faceAlpha)


    %Make pretty edges around the patch. 
    H.edge(1)=plot(x,lE,'-','color',edgeColor,'HandleVisibility','off');
    H.edge(2)=plot(x,uE,'-','color',edgeColor,'HandleVisibility','off');


%--------CXY disabled this line below at 2019 0630, re-able if necessary------
     uistack(H.mainLine,'top') % Bring the main line to the top 
%--------CXY disabled this line above at 2019 0630, re-able if necessary------
end
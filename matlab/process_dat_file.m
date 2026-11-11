function chosen_q_value = process_dat_file(dat_file, visualize)
   % Read signal data from .dat file
    fid = fopen(dat_file, 'r');
    if fid == -1
        error('Cannot open file: %s', dat_file);
    end
    data = fread(fid, 'int16'); % Assuming 16-bit integer encoding
    fclose(fid);

    % Assumed parameters (modify as per data specification)
    fs = 1000; % Example sampling frequency, replace with actual value if known
    num_channels = 12; % Example number of channels, replace if known

    % Reshape data if multi-channel
    data = reshape(data, num_channels, []).';

    % Process Lead II (second channel)
    lead_ii = data(:, 2);

    % Filter design parameters
    fc_low = 0.5; % Low cutoff frequency
    fc_high = 40; % High cutoff frequency
    [b, a] = butter(1, [fc_low, fc_high] / (fs / 2), 'bandpass'); % First-order bandpass filter

    % Filter and normalize the signal for Lead II
    filtered_ii = filtfilt(b, a, lead_ii);
    
    normalized_ii = (filtered_ii - min(filtered_ii)) / (max(filtered_ii) - min(filtered_ii));

    % Find R-peaks for Lead II
    [r_peaks_y_ii, r_peaks_x_ii] = findpeaks(normalized_ii, 'MinPeakHeight', 0.4);

    % Detect Q-points for Lead II
    q_points_x_ii = zeros(size(r_peaks_x_ii));
    q_points_y_ii = zeros(size(r_peaks_x_ii));
    window_size = round(0.05 * fs); % 50 ms window
    for i = 1:length(r_peaks_x_ii)
        if r_peaks_x_ii(i) > window_size
            search_window = normalized_ii(r_peaks_x_ii(i) - window_size : r_peaks_x_ii(i));
            [q_min_y, q_min_idx] = min(search_window);
            q_points_x_ii(i) = r_peaks_x_ii(i) - window_size + q_min_idx - 1;
            q_points_y_ii(i) = q_min_y;
        end
    end

    % Ensure only the single global minimum closest to each R-peak is used
    for i = 1:length(r_peaks_x_ii)
        if r_peaks_x_ii(i) > window_size
            search_window = normalized_ii(r_peaks_x_ii(i) - window_size : r_peaks_x_ii(i));
            [q_min_y, q_min_idx] = min(search_window);
            q_points_x_ii(i) = r_peaks_x_ii(i) - window_size + q_min_idx - 1;
            q_points_y_ii(i) = q_min_y;
        end
    end

    % Plot only one signal with all steps if visualization is enabled
    persistent has_plotted;
    if visualize && isempty(has_plotted)
        has_plotted = true;
        figure;

        % Raw Signal
        figure;
        plot(lead_ii);
        title('Raw Signal');
        xlabel('Samples'); ylabel('Amplitude');

        % Filtered Signal
        figure;
        plot(filtered_ii);
        title('Filtered Signal');
        xlabel('Samples'); ylabel('Amplitude');

        %Normalized and Filtered Signal
        figure;
        plot(normalized_ii);
        title('Normalized and Filtered Signal');
        xlabel('Samples'); ylabel('Amplitude');

    end

    mean_q_ii = mean(q_points_y_ii);
    std_q_ii = std(q_points_y_ii);

    % Process all leads and compute the average statistics
    mean_q_all = zeros(num_channels, 1);
    std_q_all = zeros(num_channels, 1);
    for lead_idx = 1:num_channels
        lead = data(:, lead_idx);
        filtered_lead = filtfilt(b, a, lead);
        normalized_lead = (filtered_lead - min(filtered_lead)) / (max(filtered_lead) - min(filtered_lead));

        [r_peaks_y, r_peaks_x] = findpeaks(normalized_lead, 'MinPeakHeight', 0.4);

        q_points_x = zeros(size(r_peaks_x));
        q_points_y = zeros(size(r_peaks_x));
        for i = 1:length(r_peaks_x)
            if r_peaks_x(i) > window_size
                search_window = normalized_lead(r_peaks_x(i) - window_size : r_peaks_x(i));
                [q_min_y, q_min_idx] = min(search_window);
                q_points_x(i) = r_peaks_x(i) - window_size + q_min_idx - 1;
                q_points_y(i) = q_min_y;
            end
        end

        mean_q_all(lead_idx) = mean(q_points_y);
        std_q_all(lead_idx) = std(q_points_y);
    end

    overall_mean_q = mean(mean_q_all);
    overall_std_q = mean(std_q_all);

    % Compare standard deviations and select the best
    if std_q_ii < overall_std_q
        chosen_q_value = mean_q_ii;
        fprintf('Chose Lead II for %s with mean Q amplitude: %.4f\n', dat_file, mean_q_ii);
    else
        chosen_q_value = overall_mean_q;
        fprintf('Chose All-Leads Average for %s with mean Q amplitude: %.4f\n', dat_file, overall_mean_q);
    end
end

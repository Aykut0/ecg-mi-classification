% Iterate over all .dat files in the base folder and its subfolders for healthy and previous_MI patients
healthy_folder ="data/Controls"; % Path to healthy patients
previous_one_mi_folder = "data/Only_previous"; % Path to previous MI patients
%previous_two_mi_folder = 'data/Two_previous'; % Path to previous MI patients
test_folder = "data/Test_File"; % Path to mixed patients


% Process healthy and previous MI patient folders
[healthy_q_amplitudes, healthy_file_names] = process_patient_folder(healthy_folder);
[previous_one_mi_q_amplitudes, previous_one_mi_file_names] = process_patient_folder(previous_one_mi_folder);
[mixed_q_amplitudes, mixed_file_names] = process_patient_folder(test_folder);

% Determine thresholds  
healthy_mean = mean(healthy_q_amplitudes);
healthy_std = std(healthy_q_amplitudes);
previous_one_mi_mean = mean(previous_one_mi_q_amplitudes);
previous_one_mi_std = std(previous_one_mi_q_amplitudes);
threshold = (healthy_mean + previous_one_mi_mean) / 2;

fprintf('Threshold for classification: %.4f\n', threshold);

% Classify mixed patients
healthy_subjects = {};
previous_one_mi_subjects = {};

for file_idx = 1:length(mixed_q_amplitudes)
    if mixed_q_amplitudes(file_idx) < threshold
        healthy_subjects = [healthy_subjects; mixed_file_names{file_idx}];
    else
        previous_one_mi_subjects = [previous_one_mi_subjects; mixed_file_names{file_idx}];
    end
end

% Output classification results
fprintf('Healthy subjects:\n');
for i = 1:length(healthy_subjects)
    fprintf('  %s\n', healthy_subjects{i});
end

fprintf('Previous MI subjects:\n');
for i = 1:length(previous_one_mi_subjects)
    fprintf('  %s\n', previous_one_mi_subjects{i});
end



function [q_amplitudes, file_names] = process_patient_folder(base_folder)
    % Find all patient folders within the base folder
    all_patient_folders = dir(fullfile(base_folder, 'patient*')); % Match patient folders
    q_amplitudes = [];
    file_names = {}; % Initialize cell array to store file names

    % Iterate through each patient folder
    for folder_idx = 1:length(all_patient_folders)
        patient_folder = fullfile(all_patient_folders(folder_idx).folder, all_patient_folders(folder_idx).name);
        all_dat_files = dir(fullfile(patient_folder, '*.dat')); % Find .dat files inside each patient folder

        % Process each .dat file
        for file_idx = 1:length(all_dat_files)
            dat_file = fullfile(all_dat_files(file_idx).folder, all_dat_files(file_idx).name);

            fprintf('Processing %s\n', dat_file);
            chosen_q_value = process_dat_file(dat_file); % Pass .dat file path
            q_amplitudes = [q_amplitudes; chosen_q_value];
            file_names = [file_names; all_dat_files(file_idx).name]; % Add file name to list
        end
    end
end

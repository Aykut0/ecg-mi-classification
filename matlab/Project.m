% Iterate over all .dat files in the base folder and its subfolders for healthy and previous_MI patients
healthy_folder = "data/Controls_Corrected"; % Path to healthy patients
previous_one_mi_folder = "data/Only_previous_Corrected"; % Path to previous MI patients

% Process healthy and previous MI patient folders
[healthy_q_amplitudes, healthy_file_names] = process_patient_folder(healthy_folder);
[previous_one_mi_q_amplitudes, previous_one_mi_file_names] = process_patient_folder(previous_one_mi_folder);

% Combine data for LOOCV
all_q_amplitudes = [healthy_q_amplitudes; previous_one_mi_q_amplitudes];
all_labels = [zeros(size(healthy_q_amplitudes)); ones(size(previous_one_mi_q_amplitudes))]; % 0 for Healthy, 1 for Previous MI  
all_file_names = [healthy_file_names; previous_one_mi_file_names];

% Leave-One-Out Cross-Validation (LOOCV)
n_samples = length(all_q_amplitudes);
predicted_labels = zeros(n_samples, 1);

for i = 1:n_samples
    % Split data into training and test sets
    X_train = all_q_amplitudes([1:i-1, i+1:end]);
    y_train = all_labels([1:i-1, i+1:end]);
    X_test = all_q_amplitudes(i);

    % Train a Support Vector Machine (SVM) with RBF kernel
    ml_model = fitcsvm(X_train, y_train, 'KernelFunction', 'rbf', 'Standardize', true);

    % Visualize the training process
    visualize_svm_training(X_train, y_train, X_test, all_labels(i), ml_model, i);

    % Predict the label for the test sample
    predicted_labels(i) = predict(ml_model, X_test);
end

% Calculate accuracy
accuracy = mean(predicted_labels == all_labels);
fprintf('LOOCV Accuracy: %.2f%%\n', accuracy * 100);

% Display predictions
fprintf('LOOCV Predictions:\n');
for i = 1:n_samples
    fprintf('File: %s, True Label: %d, Predicted Label: %d\n', all_file_names{i}, all_labels(i), predicted_labels(i));
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
            chosen_q_value = process_dat_file(dat_file, true); % Pass .dat file path with visualization
            q_amplitudes = [q_amplitudes; chosen_q_value];
            file_names = [file_names; all_dat_files(file_idx).name]; % Add file name to list
        end
    end
end
function visualize_svm_training(X_train, y_train, X_test, y_test, model, iteration)
    figure;
    gscatter(X_train, zeros(size(X_train)), y_train, 'rb', 'xo');
    hold on;

    % Plot the decision boundary
    x_vals = linspace(min(X_train) - 0.1, max(X_train) + 0.1, 100);
    [~, score] = predict(model, x_vals');
    plot(x_vals, score(:, 2), 'k-', 'LineWidth', 2);

    % Highlight test point
    scatter(X_test, 0, 100, 'g', 'filled');
    legend('Healthy', 'Previous MI', 'Decision Boundary', 'Test Point');
    title(sprintf('SVM Training Visualization - Iteration %d', iteration));
    xlabel('Q Amplitude');
    ylabel('SVM Score');
    grid on;
    hold off;
end

function [Dataset_50HZ_Limited_Train_19974_eachclass, Dataset_50HZ_Limited_Test_Final] = Data_PreProcessing_FeatureEngineering()
% DataPreparation, Preprocesses our raw 50HZ datasets
%
%   Outputs:
%       Dataset_50HZ_Limited_Train_19974_eachclass: Balanced training table.
%       Dataset_50HZ_Limited_Test_Final: Testing table.

    %  PART 1: TRAINING DATA PREPARATION
    
    % Setting up the path relative to the current folder
    if isfolder('Data')
        dataFolder = 'Data';
    elseif isfolder('data')
        dataFolder = 'data';
    else
        % Fallback manual selection
        dataFolder = uigetdir(pwd, 'Select the Data folder');
    end

    fprintf('Processing Training Data from: %s\n', dataFolder);

    % First, we will load the dataset
    IMU_Dataset_50HZ_Unlimited = readtable(fullfile(dataFolder, 'S020.csv'));
   
    %As we can see that every class does not have enough data to reliably train each class in our original dataset, to fix this we will load more datasets which have more observations for other classes which were lacking in our original dataset. After we will append those rows into our original dataset

    % Loading in further datasets so we have enough data for each class
  
    class13_set = readtable(fullfile(dataFolder, 'S006.csv'));
    class3_set = readtable(fullfile(dataFolder, 'S008.csv'));
    class2_set = readtable(fullfile(dataFolder, 'S023.csv'));
    class14_set = readtable(fullfile(dataFolder, 'S026.csv'));
    class130_set_1 = class13_set;
    class130_set_2 = readtable(fullfile(dataFolder, 'S009.csv'));
    class4_set_1 = readtable(fullfile(dataFolder, 'S010.csv'));
    class4_set_2 = readtable(fullfile(dataFolder, 'S014.csv'));
    class4_set_3 = readtable(fullfile(dataFolder, 'S017.csv'));
    class4_set_4 = readtable(fullfile(dataFolder, 'S038.csv'));
    class5_set_1 = readtable(fullfile(dataFolder, 'S026.csv'));
    class5_set_2 = readtable(fullfile(dataFolder, 'S031.csv'));
    class5_set_3 = readtable(fullfile(dataFolder, 'S037.csv'));
    class5_set_4 = class4_set_3;

    % Appending the data from those classes into our original dataset
    IMU_Dataset_50HZ_Unlimited = [IMU_Dataset_50HZ_Unlimited; class13_set(class13_set.label==13,:)];
    IMU_Dataset_50HZ_Unlimited = [IMU_Dataset_50HZ_Unlimited; class14_set(class14_set.label==14,:)];
    IMU_Dataset_50HZ_Unlimited = [IMU_Dataset_50HZ_Unlimited; class2_set(class2_set.label==2,:)];
    IMU_Dataset_50HZ_Unlimited = [IMU_Dataset_50HZ_Unlimited; class3_set(class3_set.label==3,:)];
    IMU_Dataset_50HZ_Unlimited = [IMU_Dataset_50HZ_Unlimited; class130_set_1(class130_set_1.label==130,:)];
    IMU_Dataset_50HZ_Unlimited = [IMU_Dataset_50HZ_Unlimited; class130_set_2(class130_set_2.label==130,:)];
    IMU_Dataset_50HZ_Unlimited = [IMU_Dataset_50HZ_Unlimited; class4_set_1(class4_set_1.label==4, :)];
    IMU_Dataset_50HZ_Unlimited = [IMU_Dataset_50HZ_Unlimited; class4_set_2(class4_set_2.label==4, :)];
    IMU_Dataset_50HZ_Unlimited = [IMU_Dataset_50HZ_Unlimited; class4_set_3(class4_set_3.label==4, :)];
    IMU_Dataset_50HZ_Unlimited = [IMU_Dataset_50HZ_Unlimited; class4_set_4(class4_set_4.label==4, :)];
    IMU_Dataset_50HZ_Unlimited = [IMU_Dataset_50HZ_Unlimited; class5_set_1(class5_set_1.label==5, :)];
    IMU_Dataset_50HZ_Unlimited = [IMU_Dataset_50HZ_Unlimited; class5_set_2(class5_set_2.label==5, :)];
    IMU_Dataset_50HZ_Unlimited = [IMU_Dataset_50HZ_Unlimited; class5_set_3(class5_set_3.label==5, :)];
    IMU_Dataset_50HZ_Unlimited = [IMU_Dataset_50HZ_Unlimited; class5_set_4(class5_set_4.label==5, :)];

    % In order to keep our dataset balanced, we will keep the number of observations for each class same
    target_num_of_rows = 19974;
    skipped_rows = 250; % skipping the first few rows to avoid noise
    IMU_Dataset_50HZ_Limited = table();
    class_labels = unique(IMU_Dataset_50HZ_Unlimited.label); 

    % making a loop in which each class's rows will be limited to 19974 rows
    for i = 1:length(class_labels)
        current_class = class_labels(i); 
        current_class_rows = IMU_Dataset_50HZ_Unlimited(IMU_Dataset_50HZ_Unlimited.label==current_class, :);
        
        starting_row = skipped_rows + 1;
        ending_row = target_num_of_rows + skipped_rows;
        
        if height(current_class_rows) >= ending_row
            sampled_data = current_class_rows(starting_row:ending_row, :);
            IMU_Dataset_50HZ_Limited = [IMU_Dataset_50HZ_Limited; sampled_data]; 
        else
            % Fallback if not enough data
            if height(current_class_rows) > skipped_rows
                 sampled_data = current_class_rows(starting_row:end, :);
            else
                 sampled_data = current_class_rows;
            end
            IMU_Dataset_50HZ_Limited = [IMU_Dataset_50HZ_Limited; sampled_data];
        end
    end

    
%Now as our dataset is at 50HZ meaning 50 readings per second, so one row will not have enough time's worth of data to determine the activity, in order to fix this we need to have more time's data in a single row. We will window our data for this, our goal is to achieve 2.5 seconds worth of data in one row so since 50 rows amount to a second of data, we would need to average out 125 rows into one feature vector. This would mean we will have a total of 160 samples each class, which is good enough.
%We will also increase our features from 6 to 12, as 6 features would be the mean of all the 125 rows's features and the other 6 would be the standard deviation as that helps us in determine classes like walking more. Extra physical features=more accuracy, we are doing the best with what quality of the data we have                                                                                                                                                                                                                                                                                                     

    % Windowing logic
    windowsize = 125;
    overlap_A = 0; % no stride
    features_A = [];
    labels_A = [];
    
    % Recalculate labels based on limited dataset
    class_labels = unique(IMU_Dataset_50HZ_Limited.label);

    for i = 1:length(class_labels)
        lbl = class_labels(i);

        % first we extract raw data for each class
        back_x_raw = IMU_Dataset_50HZ_Limited{IMU_Dataset_50HZ_Limited.label==lbl, "back_x"};
        back_y_raw = IMU_Dataset_50HZ_Limited{IMU_Dataset_50HZ_Limited.label==lbl, "back_y"};
        back_z_raw = IMU_Dataset_50HZ_Limited{IMU_Dataset_50HZ_Limited.label==lbl, "back_z"};
        thigh_x_raw = IMU_Dataset_50HZ_Limited{IMU_Dataset_50HZ_Limited.label==lbl, "thigh_x"};
        thigh_y_raw = IMU_Dataset_50HZ_Limited{IMU_Dataset_50HZ_Limited.label==lbl, "thigh_y"};
        thigh_z_raw = IMU_Dataset_50HZ_Limited{IMU_Dataset_50HZ_Limited.label==lbl, "thigh_z"};

        % buffer logic
        back_x_A = buffer(back_x_raw, windowsize, overlap_A, 'nodelay');
        back_y_A = buffer(back_y_raw, windowsize, overlap_A, 'nodelay');
        back_z_A = buffer(back_z_raw, windowsize, overlap_A, 'nodelay');
        thigh_x_A = buffer(thigh_x_raw, windowsize, overlap_A, 'nodelay');
        thigh_y_A = buffer(thigh_y_raw, windowsize, overlap_A, 'nodelay');
        thigh_z_A = buffer(thigh_z_raw, windowsize, overlap_A, 'nodelay');

        fA = [mean(back_x_A)', mean(back_y_A)', mean(back_z_A)', mean(thigh_x_A)', mean(thigh_y_A)', mean(thigh_z_A)', ...
              std(back_x_A)', std(back_y_A)', std(back_z_A)', std(thigh_x_A)', std(thigh_y_A)', std(thigh_z_A)'];
          
        lA = repmat(lbl, size(fA,1), 1);
        features_A = [features_A; fA];
        labels_A = [labels_A; lA];
    end

    Dataset_50HZ_Limited_Train_19974_eachclass = array2table(features_A, ...
        'VariableNames', {'back_x_mean', 'back_y_mean','back_z_mean','thigh_x_mean','thigh_y_mean','thigh_z_mean', ...
                          'back_x_std','back_y_std','back_z_std','thigh_x_std','thigh_y_std','thigh_z_std'});
    Dataset_50HZ_Limited_Train_19974_eachclass.label = labels_A;

    
    %  PART 2: TESTING DATA PREPARATION
    fprintf('Processing Testing Data...\n');
    
    % Setting up path for testing
    if isfolder('Testing Datasets')
        testFolder = 'Testing Datasets';
    elseif isfolder(fullfile(dataFolder, 'Testing Datasets'))
        testFolder = fullfile(dataFolder, 'Testing Datasets');
    else
        % Fallback
        testFolder = dataFolder; % Assume they might be in the main folder
    end

    % First, we will load the main dataset for testing
    IMU_Testing_Initial = readtable(fullfile(testFolder, 'S016.csv'));

    % adding more data
    class14_set_test = readtable(fullfile(testFolder, 'S025.csv'));
    IMU_Testing_Initial = [IMU_Testing_Initial; class14_set_test(class14_set_test.label==14,:)];

    class_labels = unique(IMU_Testing_Initial.label);

    % Using your testing windowing logic
    windowsize = 125;
    overlap_A = 0; % for dataset without stride
    features_A = [];
    labels_A = [];

    for i = 1:length(class_labels)
        lbl = class_labels(i);

        % first we extract raw data for each class
        back_x_raw = IMU_Testing_Initial{IMU_Testing_Initial.label==lbl, "back_x"};
        back_y_raw = IMU_Testing_Initial{IMU_Testing_Initial.label==lbl, "back_y"};
        back_z_raw = IMU_Testing_Initial{IMU_Testing_Initial.label==lbl, "back_z"};
        thigh_x_raw = IMU_Testing_Initial{IMU_Testing_Initial.label==lbl, "thigh_x"};
        thigh_y_raw = IMU_Testing_Initial{IMU_Testing_Initial.label==lbl, "thigh_y"};
        thigh_z_raw = IMU_Testing_Initial{IMU_Testing_Initial.label==lbl, "thigh_z"};

        % buffer logic
        back_x_A = buffer(back_x_raw, windowsize, overlap_A, 'nodelay');
        back_y_A = buffer(back_y_raw, windowsize, overlap_A, 'nodelay');
        back_z_A = buffer(back_z_raw, windowsize, overlap_A, 'nodelay');
        thigh_x_A = buffer(thigh_x_raw, windowsize, overlap_A, 'nodelay');
        thigh_y_A = buffer(thigh_y_raw, windowsize, overlap_A, 'nodelay');
        thigh_z_A = buffer(thigh_z_raw, windowsize, overlap_A, 'nodelay');

        fA = [mean(back_x_A)', mean(back_y_A)', mean(back_z_A)', mean(thigh_x_A)', mean(thigh_y_A)', mean(thigh_z_A)', ...
              std(back_x_A)', std(back_y_A)', std(back_z_A)', std(thigh_x_A)', std(thigh_y_A)', std(thigh_z_A)'];
          
        lA = repmat(lbl, size(fA,1), 1);
        features_A = [features_A; fA];
        labels_A = [labels_A; lA];
    end

    Dataset_50HZ_Limited_Test_Final = array2table(features_A, ...
        'VariableNames', {'back_x_mean', 'back_y_mean','back_z_mean','thigh_x_mean','thigh_y_mean','thigh_z_mean', ...
                          'back_x_std','back_y_std','back_z_std','thigh_x_std','thigh_y_std','thigh_z_std'});
    Dataset_50HZ_Limited_Test_Final.label = labels_A;

    fprintf('Data Preparation Complete.\n');
end
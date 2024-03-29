%% Main module for quality control of SCAN/USCRN data 
% Run by block for quality control

% preparation
in_path = "G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\2_data_selected";
out_path = "G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\4_data";
network = ["SCAN";"USCRN"];
ngflags = ["D06";"D07";"D08";"D09";"D10"];

%% 1st block to run
for i = 1:length(network)
    list = dir(fullfile(in_path, network(i)));
    
    for j = 1:length(list)
        filename = fullfile(list(j).folder, list(j).name);
        
        if isfile(filename) && contains(filename, 'sm') && contains(filename, 'csv')
            % Standardize the time series
            smTT = qc_step1(network(i), filename, ngflags);

            % Data cleaning
            % qc_step1-2
            % Skip as it is already done in Dorigo's flag or can be ignored
            % (Replace SM > 100% with NaN) ... ignore when only relative values matter
            % (Replace SM < 0% with NaN) ... ignore when only relative values matter
            % Replace dSM/dt(t=1hr) < -10% with NaN ... ignore as it is the same as xxx in Dorigo's flag
            % Replace dSM/dt(t=1h) > 20% with NaN ... ignore as it is the same as xxx in Dorigo's flag
            % Replace flag values with NaN ... ignore as it is the same as xxx in Dorigo's flag
            % Replace data whose length is less than 5 days with NaN ... ignore or relax if only seasonal trends matter

            % Save as temporary file
            smTT.Properties.VariableNames = {'sm'};
            fname = fullfile(out_path, network(i), 'temporary', list(j).name);
            writetimetable(smTT, fname,'Delimiter',',');

            clear smTT
        end
    end
end

%% 2nd block to run
% Open GUI app and classify the stations based on the quality

%% 3rd block to run
% Replace data errors during the initial, the mid, the end of the observation period with NaN (record the operation in spreadsheet for future use)

% First, run qc_step3-1 to plot out the flagged time series
i = 1;
qc_step3p1(102, network(i), out_path);
qc_step3p1(103, network(i), out_path);
qc_step3p1(104, network(i), out_path);
qc_step3p1(105, network(i), out_path);
% Second, open csv file and record the row# for erroneous data
% Last, run qc_step3-2 to remove the erroneous portion
qc_step3p2(network(i), out_path);

% repeat that for other networks
i = 2;
qc_step3p1(102, network(i), out_path);
qc_step3p1(103, network(i), out_path);
qc_step3p1(104, network(i), out_path);
qc_step3p1(105, network(i), out_path);
qc_step3p2(network(i), out_path);

%% 4th block to run
% Open GUI again and classify whether the data show trends or not
% Skip this step as this is done in signature code
    % Try more quantitative assessment in future...

%% End of the code
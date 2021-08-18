%%% Quality control of SCAN/USCRN data 

%% Read the data

%% Standardize the time series
% make the unit consistent (e.g. m3/m3 → percent)
% standardize the fill value for missing data
% make the interval regular
% synchronize all data within the network (to have the same start day & end day of the record). if there is precip & sm, synchronize both, too

%% Data cleaning
% Clean based on Dorigo's quality flag
% (Replace SM > 100% with NaN) ... ignore when only relative values matter
% (Replace SM < 0% with NaN) ... ignore when only relative values matter
% Replace dSM/dt(t=1hr) < -10% with NaN ... ignore as it is the same as xxx in Dorigo's flag
% Replace dSM/dt(t=1h) > 20% with NaN ... ignore as it is the same as xxx in Dorigo's flag
% Replace flag values with NaN ... ignore as it is the same as xxx in Dorigo's flag
% Replace data whose length is less than 5 days with NaN ... ignore or relax if only seasonal trends matter

% Save as temporary file

% Open GUI app and classify the stations based on the quality

% Replace data errors during the initial, the mid, the end of the observation period with NaN (record the operation in spreadsheet for future use)
    % Try change detection ...
% Replace any other erroneous data with NaN (record the operation in spreadsheet for future use)

% Save as temporary file

% Open GUI again and classify whether the data show trends or not
    % Try more quantitative assessment ...
    
% Save as final file
function smTT = qc_step1(network, filename, ngflags)

switch network
    case "SCAN"
        sdate = datetime(2000,1,1,0,0,0);
        edate = datetime(2020,2,29,23,0,0);
    case "USCRN"
        sdate = datetime(2009,7,31,0,0,0);
        edate = datetime(2020,2,29,23,0,0);
end

%% Read the data
T = readtable(filename);
sm = T.soil_moisture;

%% Standardize the time series
% make sire the unit is consistent (e.g. m3/m3 → percent)

% standardize the fill value for missing data
% already standardized to 'NaN'
% Clean based on Dorigo's quality flag
for k = 1:length(ngflags)
    flag_rows = find(contains(T.soil_moisture_flag, ngflags(k))==1);
    sm(flag_rows) = NaN;
end

% create a timetable
% convert time zone
% synchronize all data within the network (to have the same start day & end day of the record). if there is precip & sm, synchronize both, too
smTT0 = timetable([sdate;T.date_time;edate], [NaN;sm;NaN]);

% make the interval regular
smTT = retime(smTT0, 'regular', 'mean', 'TimeStep', hours(1));

end

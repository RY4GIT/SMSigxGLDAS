%% Get the station numbers and statistics that were used for the analysis

% =========== BEGINNING OF THE CODE ============

%% Preparation
clear all; close all;
slCharacterEncoding('UTF-8');
save_results = true; % if you want to clear the previous results and save new results

% Set path
cd("G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\5_code_sig\");
in_path = "..\4_data\";
out_path = "..\4_data\";

% Site information
network = ["Oznet"; "USCRN"; "SCAN"];

%% Main execution
for i = 1:length(network)
 
    disp(i)
    [depth, nstation, ~, ninsitu, fn0] = io_siteinfo(network(i));


    % read the station flag
    fn = fullfile(in_path, network(i), 'ts_without_2seasons.txt');
    stationflag = readmatrix(fn);
    
    % read metadata
    fn = fullfile(in_path, network(i), 'insitu', 'metadata.csv');
    station_location = readtable(fn);
    
    for k = 1 %:length(depth)-1
        % Read data 
        if network(i) == "Oznet"
            fn0 = ["OZNET_alldepth_arid.csv"];
        end
        fn = fullfile(in_path, network(i), "combined", fn0(k));
        fid = fopen(fn, 'r');
        if depth(k) ~= 10
            % for sensorwise data
            smtt0 = textscan(fid,'%d %q %f %f','HeaderLines',1,'DateLocale','en_US','Delimiter',',');
        elseif i == 1
            % for watershed average data
            smtt0 = textscan(fid,'%q %f %f','HeaderLines',1,'DateLocale','en_US','Delimiter',',');
        end
        
        stations_with_data = unique(smtt0{1,1});
        stations_for_stat = stations_with_data;
        stations_with_data(ismember(stations_with_data, stationflag')) = [];
        stations_for_seasonsig = stations_with_data;


        station_location.flag_stat_analysis = ismember(station_location.sid, stations_for_stat);
        station_location.flag_seasonsig_analysis = ismember(station_location.sid, stations_for_seasonsig);
        writetable(station_location, fullfile(in_path, network(i), 'insitu', 'metadata.csv'));
        % writematrix(stations_for_stat, fullfile(out_path, network(i), sprintf("stations_for_stat_%.fcm.csv", depth(k))));
        % writematrix(stations_for_seasonsig, fullfile(out_path, network(i), sprintf("stations_for_seasonsig_%.fcm.csv", depth(k))));
    end
        
end



%% =========== END OF THE CODE ============

%% Run this, and them plot_scatter_main.m
function [] = calc_variability_location_vs_time()

%% Preparation
close all; clear all;

% Set path
cd("G:\Shared drives\Ryoko and Hilary\SMSigxgldas\7_code_postprocess");
out_path = "..\8_out_stat";

% Site information
networks = ["Oznet"; "USCRN"; "SCAN"];
data_type = "combined"; % "combined_weighted"; "combined"
output_version = "20221224";

% read the format for the plots
sigT = readtable('..\9_code_plot\sig_format.csv','HeaderLines',0,'Delimiter',',');

%
sz = [8 6];
varTypes = ["string","string","string", "string","string","string"];
varNames = ["Network","Depth","Start of wetting (GLDAS-insitu, days)", ...
    "End of wetting (GLDAS-insitu, days)", ...
    "Start of drying (GLDAS-insitu, days)", ...
    "End of drying (GLDAS-insitu, days)"];
temps = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
T_all = [];

%% Figures
% create scatter plot & calculate correlation coefficient
for s = 1:4
    
    for i = 1:length(networks)
        in_path = fullfile("..\6_out_sigs", output_version, data_type, networks(i));
        T = readtable(fullfile(in_path, sprintf('%s.csv', string(sigT.sig_abb(s)))), 'Delimiter', ',');
        T = T(T.depth~=10,:);
        T.network = repelem(networks(i),[length(T.insitu)])';
        T.diff = T.gldas - T.insitu;
        T_all = [T_all;T]; 
    end
    
end

T_all.gldas_year = year(datetime(T_all.gldas,'ConvertFrom','datenum'));
T_all.insitu_year = year(datetime(T_all.insitu,'ConvertFrom','datenum'));
T_all.diff_year = T_all.gldas_year - T_all.insitu_year;
T_all.year = T_all.insitu_year;
T_all.year(T_all.diff_year==-1) = T_all.gldas_year(T_all.diff_year == -1);
T_all.year(T_all.diff_year== 1) = T_all.insitu_year(T_all.diff_year == 1);

stdiv_per_sensor_throughout_years0 = table;
stdiv_per_sensor_throughout_years = [];
stdiv_per_year_throughout_network0 = table;
stdiv_per_year_throughout_network = [];

for s = 1:4
    for i = 1:length(networks)
        
        T_network = T_all(T_all.network == networks(i),:);
        unique_stations = unique(T_network.station);
        unique_year = unique(T_network.year);
        unique_year(isnan(unique_year))=[];
        
        for station = 1:length(unique_stations)
            stdiv_per_sensor_throughout_years0.network = networks(i);
            stdiv_per_sensor_throughout_years0.station = unique_stations(station);
            stdiv_per_sensor_throughout_years0.transition = sigT.sig_fullname(s);
            stdiv_per_sensor_throughout_years0.stdiv = std(T_network.diff(T_network.station == unique_stations(station)), 'omitnan');
            stdiv_per_sensor_throughout_years = [stdiv_per_sensor_throughout_years; stdiv_per_sensor_throughout_years0];
        end
        
        for a_year = 1:length(unique_year)
            stdiv_per_year_throughout_network0.network = networks(i);
            stdiv_per_year_throughout_network0.year = unique_year(a_year);
            stdiv_per_year_throughout_network0.transition = sigT.sig_fullname(s);
            stdiv_per_year_throughout_network0.stdiv = std(T_network.diff(T_network.year == unique_year(a_year)), 'omitnan');
            stdiv_per_year_throughout_network = [stdiv_per_year_throughout_network; stdiv_per_year_throughout_network0];
        end
        
    end
    
end

stdiv_per_sensor_throughout_years0.network = "all networks average";
stdiv_per_sensor_throughout_years0.station = "all networks average";
stdiv_per_sensor_throughout_years0.transition = "all season average";
stdiv_per_sensor_throughout_years0.stdiv = mean(stdiv_per_sensor_throughout_years.stdiv, 'omitnan');
stdiv_per_sensor_throughout_years = [stdiv_per_sensor_throughout_years; stdiv_per_sensor_throughout_years0];

writetable(stdiv_per_sensor_throughout_years,fullfile(out_path, sprintf('variability_in_time_%s.csv', data_type)))

stdiv_per_year_throughout_network0.network = "all networks average";
stdiv_per_year_throughout_network0.year = "all year average";
stdiv_per_year_throughout_network0.transition = "all season average";
stdiv_per_year_throughout_network0.stdiv = mean(stdiv_per_year_throughout_network.stdiv, 'omitnan');
stdiv_per_year_throughout_network = [stdiv_per_year_throughout_network; stdiv_per_year_throughout_network0];

writetable(stdiv_per_year_throughout_network,fullfile(out_path, sprintf('variability_in_location_%s.csv', data_type)))

end


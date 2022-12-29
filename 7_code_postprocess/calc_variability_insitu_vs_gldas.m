%% Run this, and them plot_scatter_main.m
function [] = calc_variability_insitu_vs_gldas()

%% Preparation
close all; clear all;

% Set path
cd("G:\Shared drives\Ryoko and Hilary\SMSigxgldas\7_code_postprocess");
out_path = "..\8_out_stat";

% Site information
networks = ["Oznet"; "USCRN"; "SCAN"];
data_type = "combined_weighted"; %"combined_weighted"; "combined"
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
T_stdiv = [];
T_stdiv_all_results = [];

%% Figures
% create scatter plot & calculate correlation coefficient
for s = 1:4
    
    switch s
        case 1
            sig_string = "Start of wetting (GLDAS-insitu, days)";
        case 2
            sig_string = "End of wetting (GLDAS-insitu, days)";
        case 3
            sig_string = "Start of drying (GLDAS-insitu, days)";
        case 4
            sig_string = "End of drying (GLDAS-insitu, days)";
    end
    
    for i = 1:length(networks)
        in_path = fullfile("..\6_out_sigs", output_version, data_type, networks(i));
        T = readtable(fullfile(in_path, sprintf('%s.csv', string(sigT.sig_abb(s)))), 'Delimiter', ',');
        T = T(T.depth~=10,:);
        
        T.gldas_dayoftheyear = day(datetime(T.gldas,'ConvertFrom','datenum'), 'dayofyear');
        T.insitu_dayoftheyear = day(datetime(T.insitu,'ConvertFrom','datenum'), 'dayofyear');
        T.gldas_year = year(datetime(T.gldas,'ConvertFrom','datenum'));
        T.insitu_year = year(datetime(T.insitu,'ConvertFrom','datenum'));
        T.diff_year = T.gldas_year - T.insitu_year;
        T.insitu_dayoftheyear(T.diff_year == -1) = T.insitu_dayoftheyear(T.diff_year == -1) + 365;
        T.gldas_dayoftheyear(T.diff_year == +1) = T.gldas_dayoftheyear(T.diff_year == 1) + 365;
        
        insitu_stdiv = std(T.insitu_dayoftheyear, 'omitnan');
        gldas_stdiv = std(T.gldas_dayoftheyear, 'omitnan');
        
        T_stdiv0 = table;
        
        T_stdiv0.transition = string(sigT.sig_fullname(s));
        T_stdiv0.insitu_stdiv = insitu_stdiv;
        T_stdiv0.gldas_stdiv = gldas_stdiv;
        T_stdiv0.network = networks(i);
        
        T_stdiv = [T_stdiv; T_stdiv0];
        
    end
    
end

T_stdiv_all_results = T_stdiv;
T_stdiv0 = table;
for s = 1:4
    insitu_stdiv = mean(T_stdiv.insitu_stdiv(T_stdiv.transition==sigT.sig_fullname(s)), 'omitnan');
    gldas_stdiv = mean(T_stdiv.gldas_stdiv(T_stdiv.transition==sigT.sig_fullname(s)), 'omitnan');
    
    T_stdiv0.transition = string(sigT.sig_fullname(s)) + " average";
    T_stdiv0.insitu_stdiv = insitu_stdiv;
    T_stdiv0.gldas_stdiv = gldas_stdiv;
    T_stdiv0.network = "All networks average";
    
    T_stdiv_all_results = [T_stdiv_all_results; T_stdiv0]; 
    
end

insitu_stdiv = mean(T_stdiv.insitu_stdiv, 'omitnan');
gldas_stdiv = mean(T_stdiv.gldas_stdiv, 'omitnan');

T_stdiv0.transition = "All seasons average";
T_stdiv0.insitu_stdiv = insitu_stdiv;
T_stdiv0.gldas_stdiv = gldas_stdiv;
T_stdiv0.network = "All networks average";
T_stdiv_all_results = [T_stdiv_all_results; T_stdiv0];

writetable(T_stdiv_all_results,fullfile(out_path, sprintf('variability_insitu_vs_gldas_%s.xlsx', data_type)))

end


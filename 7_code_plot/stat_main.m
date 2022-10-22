function [] = stat_main()

%% Preparation
close all; clear all;

% Set path
cd("G:\Shared drives\Ryoko and Hilary\SMSigxgldas\9_code_plot");
out_path = "..\10_out_plot";

% Site information
networks = ["Oznet"; "USCRN"; "SCAN"];

% read the format for the plots
sigT = readtable('sig_format.csv','HeaderLines',0,'Delimiter',',');

%
sz = [8 6];
varTypes = ["string","string","string", "string","string","string"];
varNames = ["Network","Depth","Start of wetting (GLDAS-insitu, days)", ...
    "End of wetting (GLDAS-insitu, days)", ...
    "Start of drying (GLDAS-insitu, days)", ...
    "End of drying (GLDAS-insitu, days)"];
temps = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

%% Figures
% create scatter plot & calculate correlation coefficient
for s = 1:4
    
    nrow = 0;
    T_all_diff = [];
    T_all_depth = [];
    T_us_diff = [];
    T_us_depth = [];
    
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
        in_path = fullfile("..\8_out_stat", networks(i));
        T = readtable(fullfile(in_path, sprintf('%s.csv', string(sigT.sig_abb(s)))), 'Delimiter', ',');
        
        T.diff = T.gldas - T.insitu;
        T_all_diff = [T_all_diff;T.diff];
        T_all_depth = [T_all_depth; T.depth];
        
        if networks(i) == "USCRN" || networks(i) == "SCAN"
            T_us_diff = [T_us_diff;T.diff];
            T_us_depth = [T_us_depth; T.depth];        
        end
        
        switch networks(i)
            case "Oznet"
                depth = [2.5; 4; 10];
            case "USCRN"
                depth = [5; 10];
            case "SCAN"
                depth = [5.08; 10];
        end
        
        for k = 1:length(depth)
            nrow = nrow + 1
            % get the corresponding data
            selected = (T.depth == depth(k));
            
            % calculate the mean
            mean_diff = mean(T.diff(selected), 'omitnan');
            std_diff = std(T.diff(selected), 'omitnan');
            
            temps.Network(nrow) = networks(i);
            if depth(k) == 10
                temps.Depth(nrow) = "Basin average";
            else
                temps.Depth(nrow) = sprintf('%.2f cm',  depth(k));
            end
            temps.(sig_string)(nrow) = sprintf('%.0f %.0f', mean_diff, std_diff);
        end
        
    end
    
    nrow = nrow + 1;
    selected = (T_us_depth ~= 10);
    mean_diff = mean(T_us_diff(selected), 'omitnan');
    std_diff = std(T_us_diff(selected), 'omitnan');
    temps.Network(nrow) = "U.S. watersheds";
    temps.Depth(nrow) = "U.S. watersheds";
    temps.(sig_string)(nrow) = sprintf('%.0f %.0f', mean_diff, std_diff);
    
    nrow = nrow + 1;
    selected = (T_all_depth ~= 10);
    mean_diff = mean(T_all_diff(selected), 'omitnan');
    std_diff = std(T_all_diff(selected), 'omitnan');
    temps.Network(nrow) = "All watersheds";
    temps.Depth(nrow) = "All watersheds";
    temps.(sig_string)(nrow) = sprintf('%.0f %.0f', mean_diff, std_diff);
    
end

writetable(temps,fullfile(out_path, 'stat.xlsx'))

end


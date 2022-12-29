%% Run this, and them plot_scatter_main.m
function [] = calc_variability_insitu_vs_gldas()

%% Preparation
close all; clear all;

% Set path
cd("G:\Shared drives\Ryoko and Hilary\SMSigxgldas\7_code_postprocess");


% Site information
networks = ["Oznet"; "SCAN"; "USCRN"];
data_type = "combined"; %"combined_weighted"; "combined"
output_version = "20221224";
out_path = "..\8_out_stat\table_results";
out_path2 = fullfile("..\10_out_plot", data_type);

% read the format for the plots
sigT = readtable('..\9_code_plot\sig_format.csv','HeaderLines',0,'Delimiter',',');

T_results = [];
T_all_data = [];

%% Figures
% create scatter plot & calculate correlation coefficient
for s = 1:4
    
    for i = 1:length(networks)
        in_path = fullfile("..\6_out_sigs", output_version, data_type, networks(i));
        T = readtable(fullfile(in_path, sprintf('%s.csv', string(sigT.sig_abb(s)))), 'Delimiter', ',');
        T = T(T.depth~=10,:);
        
        T.gldas_dayoftheyear = day(datetime(T.gldas,'ConvertFrom','datenum'), 'dayofyear');
        T.insitu_dayoftheyear = day(datetime(T.insitu,'ConvertFrom','datenum'), 'dayofyear');
        T.gldas_year = year(datetime(T.gldas,'ConvertFrom','datenum'));
        T.insitu_year = year(datetime(T.insitu,'ConvertFrom','datenum'));
        T.diff_year = T.insitu_year - T.gldas_year;

        T.gldas_dayoftheyear(T.diff_year == -1) = T.gldas_dayoftheyear(T.diff_year == -1) + 365;
        T.gldas_dayoftheyear(T.diff_year == +1) = T.gldas_dayoftheyear(T.diff_year == 1) - 365;
        
        insitu_stdiv = std(T.insitu_dayoftheyear, 'omitnan');
        gldas_stdiv = std(T.gldas_dayoftheyear, 'omitnan');
        insitu_mean = mean(T.insitu_dayoftheyear, 'omitnan');
        gldas_mean = mean(T.gldas_dayoftheyear, 'omitnan');
        insitu_iqr = iqr(T.insitu_dayoftheyear(~isnan(T.insitu_dayoftheyear)));
        gldas_iqr = iqr(T.gldas_dayoftheyear(~isnan(T.gldas_dayoftheyear)));
        
%         figure();
%         histogram(T.insitu_dayoftheyear, 'BinWidth', 25, 'Normalization', 'probability', 'DisplayName', sprintf('insitu stdiv = %.2f, CV = %.2f, IQR = %.2f', insitu_stdiv, insitu_stdiv/insitu_mean, insitu_iqr)); hold on;
%         histogram(T.gldas_dayoftheyear, 'BinWidth', 25, 'Normalization', 'probability', 'DisplayName', sprintf('gldas stdiv = %.2f, CV=%.2f, IQR = %.2f', gldas_stdiv, gldas_stdiv/gldas_mean, gldas_iqr)); hold on;
%         title(sprintf('%s-%s', string(sigT.sig_fullname(s)), string(networks(i))));
%         xlabel('Transition dates [day of the year]');
%         ylabel('Probability [-]')
%         legend;
%         hold off;
        
        T_results0 = table;
        
        T_results0.transition = string(sigT.sig_fullname(s));
        T_results0.insitu_cv = insitu_stdiv/insitu_mean;
        T_results0.gldas_cv = gldas_stdiv/gldas_mean;
        T_results0.network = networks(i);
        T_results0.number_of_records = length(T.insitu_dayoftheyear);
        T_results = [T_results; T_results0];
        
        T.network = repelem(string(networks(i)),[length(T.gldas_year)])';
        network_DisplayName =  sprintf('%s \n   In-situ: stdiv = %.2f, CV = %.2f, IQR = %.2f  \n   GLDAS: stdiv = %.2f, CV=%.2f, IQR = %.2f', networks(i), insitu_stdiv, insitu_stdiv/insitu_mean, insitu_iqr,  gldas_stdiv, gldas_stdiv/gldas_mean, gldas_iqr);
        T.network = repelem(string(networks(i)),[length(T.gldas_year)])';
        T.network_DisplayName = repelem(string(network_DisplayName),[length(T.gldas_year)])';
        T.transition = repelem(string(sigT.sig_fullname(s)),[length(T.gldas_year)])';
        T_all_data = [T_all_data; T];
        
    end
    
end

T_results_all_results = T_results;
T_results0 = table;
for s = 1:4
    
    target_season = T_results.transition==sigT.sig_fullname(s);
    % Take the weighted average of CV based on the number of sensors
    insitu_cv = sum((T_results.insitu_cv(target_season).*T_results.number_of_records(target_season)/sum(T_results.number_of_records(target_season))), 'omitnan');
    gldas_cv = sum((T_results.gldas_cv(target_season).*T_results.number_of_records(target_season)/sum(T_results.number_of_records(target_season))), 'omitnan');

    T_results0.transition = string(sigT.sig_fullname(s)) + " average";
    T_results0.insitu_cv = insitu_cv;
    T_results0.gldas_cv = gldas_cv;
    T_results0.network = "All networks average";
    T_results0.number_of_records = sum(T_results.number_of_records(target_season));
    T_results_all_results = [T_results_all_results; T_results0]; 
    
    figure();
    frame_factor = 5;
    set(gcf, 'Position',[100 100 200*frame_factor 200*frame_factor]);
    target_season_in_datatable = T_all_data.transition==sigT.sig_fullname(s);
    h = scatterhist(T_all_data.insitu_dayoftheyear(target_season_in_datatable),T_all_data.gldas_dayoftheyear(target_season_in_datatable),'Group',T_all_data.network_DisplayName(target_season_in_datatable) ...
        , 'Kernel','off',  'Style', 'bar', 'Color',[[117 112 179]./225;[217,95,2]./225;[27,158,119]./225],'MarkerSize', 10);
    
    title(sprintf('%s', string(sigT.sig_fullname(s))));
    xlim([-100, 400]);
    ylim([-100, 400]);
    xlabel('In-situ [day of the year]');
    ylabel('GLDAS [day of the year]');
    set(gca,'fontsize',16);
    
    hline = refline(1,0);
    hline.Color = 'k';
    hline.LineStyle = '--';
    hline.DisplayName = '1:1 line';
    
    legend('FontSize',12);
        
    fn = sprintf('scatter_with_marginal_%s_%s.png',string(sigT.sig_abb(s)), data_type);
    exportgraphics(gcf,fullfile(out_path2, fn),'Resolution',600);

    hold off;
    
end

T_results0.transition = "All seasons average";
T_results0.insitu_cv = mean(T_results.insitu_cv, 'omitnan');
T_results0.gldas_cv = mean(T_results.gldas_cv, 'omitnan');
T_results0.network = "All networks average";
T_results_all_results = [T_results_all_results; T_results0];

writetable(T_results_all_results,fullfile(out_path, sprintf('variability_insitu_vs_gldas_%s.csv', data_type)))

end


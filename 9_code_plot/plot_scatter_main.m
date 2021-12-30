function [] = plot_scatter_main2()

%% Preparation
close all; clear all;

% Set path
cd("G:\Shared drives\Ryoko and Hilary\SMSigxgldas\9_code_plot");
out_path = "..\10_out_plot";

% Site information
networks = ["Oznet"; "USCRN"; "SCAN"];

% read the format for the plots
sigT = readtable('sig_format.csv','HeaderLines',0,'Delimiter',',');

%% Figures
% create scatter plot & calculate correlation coefficient
for s = 2 %1:size(sigT,1)
    
    figure(s);
    set(gcf, 'Position',[100 100 400 600]);
    set(gca,'fontsize',14)
    
    for i = 1 %1:length(networks)
        in_path = fullfile("..\8_out_stat", networks(i));
        T = readtable(fullfile(in_path, sprintf('%s.csv', string(sigT.sig_abb(s)))), 'Delimiter', ',');
        
        if s <= 4
            data_insitu0 = datetime(T.insitu, 'ConvertFrom', 'datenum');
            data_insitu = day(data_insitu0,'dayofyear');
            data_insitu_yr = year(data_insitu0);
            
            data_gldas0 = datetime(T.gldas, 'ConvertFrom', 'datenum');
            data_gldas = day(data_gldas0,'dayofyear');
            data_gldas_yr = year(data_gldas0);
            
            data_gldas(data_insitu_yr - data_gldas_yr == -1) = data_gldas(data_insitu_yr - data_gldas_yr == -1) + 365;
            data_gldas(data_insitu_yr - data_gldas_yr == 1) = data_gldas(data_insitu_yr - data_gldas_yr == 1) - 365;
            
        else
            data_insitu = T.insitu;
            data_gldas = T.gldas;
        end
    
        switch networks(i)
            case "Oznet"
                depth = [2.5; 4; 10];
                c = [117 112 179]./225;
            case "USCRN"
                depth = [5; 10];
                c = [27,158,119]./225;
            case "SCAN"
                depth = [5.08; 10];
                c = [217,95,2]./225;
        end
        
        for k = 1:length(depth)
            
            % get the corresponding data
            selected = (T.depth == depth(k));
            
            % calculate correlation coefficient
            r0 = corrcoef(data_insitu(selected), data_gldas(selected), 'rows', 'pairwise');
            if length(r0) == 1
                r = r0;
            else
                r = r0(1,2);
            end
            
            % Highlight the average 
            if depth(k) == 10
                e = 'k';
                a = 1;
            else
                e = 'w';
                a = (10 - depth(k))/10;
            end

            % Create scatter plot & display correlation coefficient
            scatter(data_insitu(selected), data_gldas(selected), 30, c, string(sigT.marker(s)), 'filled', ...
                'MarkerFaceColor', c, 'MarkerEdgeColor', e, 'MarkerFaceAlpha', a, ...
                'DisplayName', sprintf('%s (%d cm), R = %.2f', networks(i), depth(k), r(1,1)));
            hold on;
            
        end
        
    end
    
    title(sigT.sig_fullname(s));
    xlabel(sprintf('In-situ [%s]', string(sigT.ylabel(s))));
    ylabel(sprintf('GLDAS [%s]', string(sigT.ylabel(s))));
    ylim([sigT.lowerlim(s) sigT.upperlim(s)]);
    xlim([sigT.lowerlim(s) sigT.upperlim(s)]);
    
    hline = refline(1,0);
    hline.Color = 'k';
    hline.LineStyle = '--';
    hline.DisplayName = '1:1 line';
    
    legend('Location','southoutside');
    hold off;
    
    fn = sprintf('%s.png',string(sigT.sig_abb(s)));
    exportgraphics(gcf,fullfile(out_path, fn),'Resolution',600)
    clear fn
    
end

end


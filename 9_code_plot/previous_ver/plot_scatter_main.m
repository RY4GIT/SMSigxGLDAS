function [] = plot_scatter_main()
% This scriaT calculates stats for seasonal transition signatures results of twi sets of data, GLDAS and Oznet.

close all; clear all;
%% Preparation
% Set path
cd("G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\9_code_plot");
out_path = "..\10_out_plot";

% Site information
networks = ["Oznet"; "USCRN"; "SCAN"];

% read the format for the plots
sigT = readtable('sig_format.csv','HeaderLines',0,'Delimiter',',');

%% Figures
% create scatter plot & calculate correlation coefficient
for s = 3:size(sigT,1)
    
    figure(s);
    set(gcf, 'Position',[100 100 400 600]);
    set(gca,'fontsize',14)
    
    for i = 2 %1:length(networks)
        in_path = fullfile("..\8_out_stat", networks(i));
        T = readtable(fullfile(in_path, sprintf('%s.csv', string(sigT.sig_abb(s)))), 'Delimiter', ',');
    
        switch networks(i)
            case "Oznet"
                depth = [3; 4; 10];
                c = [117 112 179]./225;
            case "USCRN"
                depth = [5; 10];
                c = [27,158,119]./225;
            case "SCAN"
                depth = [5.08; 10];
                c = [217,95,2]./225;
        end
        
        for k = 2 %1:length(depth)
            
            % get the corresponding data
            selected = T.depth == depth(k);
            
            % calculate correlation coefficient
            r0 = corrcoef(T.insitu(selected), T.GLDAS(selected), 'rows', 'pairwise');
            if length(r0) == 1
                r = r0;
            else
                r = r0(1,2);
            end
            
            if depth(k) == 10
                e = 'k';
                a = 1;
            else
                e = 'w';
                a = (10 - depth(k))/10;
            end
            
            % create scatter plot & calculate correlation coefficient
            scatter(T.insitu(selected), T.GLDAS(selected), 30, c, string(sigT.marker(s)), 'filled', ...
                'MarkerFaceColor', c, 'MarkerEdgeColor', e, 'MarkerFaceAlpha', a, 'DisplayName', sprintf('%s (%d cm), R = %.2f', networks(i), depth(k), r(1,1)));
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


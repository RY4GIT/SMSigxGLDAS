function [] = stat_calc2(site, depth, nstation, sig_abb, sig_abb2)

% This scriaT calculates stats for seasonal transition signatures results of twi sets of data, GLDAS and Oznet. 

    %% Preparation 
    % set path
    cd("G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\3_codes_plotters");
    in_path = "..\4_out\stats";
    out_path = "..\4_out\scatter";
    
    % color
    dots_color = [0 0 139]./255;
    dots_mkr = ['.'];
    dots_size = 15;
    font_point = 14;

    % read data 
    aT = readtable(fullfile(in_path, 'sine_amplitude.csv'), 'Delimiter', ',');

    %% amplitude & phi
    % create scatter plot & calculate correlation coefficient
    for s = 1:2
        figure('Position',[100 100 350*3 400]);
        set(gca,'fontsize',font_point)
        if s == 1
            axisbound = [0 0.1];
        elseif s == 2
            axisbound = [0 3];
        end
        
        for k = 1:length(depth)
            % loop for signature type
            selected = (aT.depth == depth(k)) & (aT.sig_type == sig_abb2(s));
            r0 = corrcoef(aT.Oznet_date(selected), aT.GLDAS_date(selected), 'rows', 'pairwise');
            if length(r0) == 1
                r = r0;
            else
                r = r0(1,2);
            end
            subplot(1,3,k)
            if size(r,1) == 1
                scatter(aT.Oznet_date(selected), aT.GLDAS_date(selected),  'MarkerFaceColor', dots_color,  'DisplayName',sprintf('%s, R = %.2f',sig_abb2(s),r(1,1))); 
            else
                scatter(aT.Oznet_date(selected), aT.GLDAS_date(selected),  'MarkerFaceColor', dots_color,  'DisplayName',sprintf('%s, R = %.2f',sig_abb2(s),r(1,2)));
            end
            xlabel('Station (m^3/m^3)'); ylabel('GLDAS (m^3/m^3)');
            ylim(axisbound);xlim(axisbound);
            switch k
                case 1
                    title('Depth 2.5 cm');
                case 2
                    title('Depth 4 cm');
                case 3
                    title('Watershed average');
            end
            legend('Location','southoutside');
            hline = refline(1,0); hline.Color = 'k'; hline.LineStyle = '--'; hline.DisplayName = '1:1 line';
        end   % create scatter plot & calculate correlation coefficient
        
        fn = sprintf('sine_%s.pdf',sig_abb2(s)); % saveas(gcf,fnout2);
        exportgraphics(gcf, fullfile(out_path, fn));
        clear fn
        
        fn = sprintf('sine_%s.png',sig_abb2(s)); % saveas(gcf,fnout2);
        exportgraphics(gcf,fullfile(out_path, fn),'Resolution',600)
        clear fn
        
    end
    

end
        

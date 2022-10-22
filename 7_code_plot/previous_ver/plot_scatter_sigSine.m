function [] = plot_scatter_sigSine(site, depth, nstation, sig_abb, sig_abb2)

% This script calculates stats for seasonal transition signatures results of twi sets of data, GLDAS and Oznet. 

    %% Preparation 
    % set path
    cd("G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\3_codes_plotters");
   
    % Color code 
    % Piecewise ... red
    % Logistic ... blue 
    % Start day ... circle
    % End day ... cross
    
    % color
    dots_color = ["r"; "b"; ...
                "r"; "b"; ...
                "r"; "b"; ...
                "r"; "b"; ...
                "r"; "b"; ...
                "r"; "b"];
    dots_mkr = ['o'; 'o'; ...
                '+';'+'; ...
                'o'; 'o'; ...
                '+'; '+'; ...
                '.'; '.'; ...
                '.'; '.'];
%     dots_size = 30;
    font_point = 14;
        
    
    %% Duration analysis
    cd("G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\3_codes_plotters");
    in_path = "..\4_out\stats";
    out_path = "..\4_out\scatter";
    
    % read data 
    tT = readtable(fullfile(in_path, 'timing_deviation.csv'), 'Delimiter', ',');
    dT = readtable(fullfile(in_path, 'duration.csv'), 'Delimiter', ',');
    
    % create scatter plot & calculate correlation coefficient
    for k = 1:length(depth)
        figure('Position',[100 100 350 450]);
        for s = 9:10
            selected = (dT.depth == depth(k)) & (dT.sig_type == sig_abb(s));
            r = corrcoef(dT.Oznet_days(selected), dT.GLDAS_days(selected), 'rows', 'pairwise');
            % Use 'pairwise' to compute each two-column correlation coefficient on a pairwise basis. If one of the two columns contains a NaN, that row is omitted.
            % https://www.mathworks.com/help/matlab/ref/corrcoef.html#buty8js
            if length(r) ~= 2
                scatter(dT.Oznet_days(selected), dT.GLDAS_days(selected), 'MarkerEdgeColor','w', 'MarkerFaceColor', dots_color(s), 'DisplayName',sprintf('%s, R = %.2f',sig_abb2(s),r)); hold on;
            else
                scatter(dT.Oznet_days(selected), dT.GLDAS_days(selected), 'MarkerEdgeColor', 'w', 'MarkerFaceColor',  dots_color(s), 'DisplayName',sprintf('%s, R = %.2f',sig_abb2(s),r(1,2))); hold on;
            end
        end
        xlabel('Oznet [days]'); ylabel('GLDAS [days]');
        ylim([0 250]);xlim([0 250]);
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
        fn = sprintf('duration_w2d_depth%d.pdf',depth(k)); % saveas(gcf,fnout2);
        set(gca,'fontsize', font_point)
        exportgraphics(gcf, fullfile(out_path, fn));
        clear fn
    end
    
    for k = 1:length(depth)
        figure('Position',[100 100 350 450]);
        for s = 11:12
            selected = (dT.depth == depth(k)) & (dT.sig_type == sig_abb(s));
            r = corrcoef(dT.Oznet_days(selected), dT.GLDAS_days(selected), 'rows', 'pairwise');
            % Use 'pairwise' to compute each two-column correlation coefficient on a pairwise basis. If one of the two columns contains a NaN, that row is omitted.
            % https://www.mathworks.com/help/matlab/ref/corrcoef.html#buty8js
            if length(r) ~= 2
                scatter(dT.Oznet_days(selected), dT.GLDAS_days(selected), 'MarkerEdgeColor', 'w',  'MarkerFaceColor', dots_color(s), 'DisplayName',sprintf('%s, R = %.2f',sig_abb2(s),r)); hold on;
            else
                scatter(dT.Oznet_days(selected), dT.GLDAS_days(selected),  'MarkerEdgeColor', 'w', 'MarkerFaceColor', dots_color(s), 'DisplayName',sprintf('%s, R = %.2f',sig_abb2(s),r(1,2))); hold on;
            end
        end
        xlabel('Oznet [days]'); ylabel('GLDAS [days]');
        ylim([0 250]);xlim([0 250]);
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
        fn = sprintf('duration_d2w_depth%d.pdf',depth(k)); % saveas(gcf,fnout2);
        set(gca,'fontsize', font_point)
        exportgraphics(gcf, fullfile(out_path, fn));
        clear fn
    end
    
    
    %% timing analysis 

    % create scatter plot & calculate correlation coefficient
    for k = 1:length(depth)
        figure('Position',[100 100 350 475]);
        % loop for signature type
        for s = 1:4
            selected = (tT.depth == depth(k)) & (tT.sig_type == sig_abb(s));
            r = corrcoef(tT.Oznet_date(selected), tT.GLDAS_date(selected), 'rows', 'pairwise');
            if length(r) ~= 2
                scatter(tT.Oznet_date(selected), tT.GLDAS_date(selected), dots_color(s), dots_mkr(s),'DisplayName',sprintf('%s, R = %.2f',sig_abb2(s),r)); hold on;
            else
                scatter(tT.Oznet_date(selected), tT.GLDAS_date(selected), dots_color(s), dots_mkr(s),'DisplayName',sprintf('%s, R = %.2f',sig_abb2(s),r(1,2))); hold on;
            end
        end        % loop for Oznet & GLDAS
        
        xlabel('Station (days)'); ylabel('GLDAS (days)');
        ylim([-200 200]);xlim([-200 200]);
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
        
        fn = sprintf('timing_w2d_depth%d.pdf',depth(k)); % saveas(gcf,fnout2);
        set(gca,'fontsize', font_point)
        exportgraphics(gcf, fullfile(out_path, fn));
        clear fn
    end
    
    for k = 1:length(depth)
        figure('Position',[100 100 350 475]);
        % loop for signature type
        for s = 5:8
            selected = (tT.depth == depth(k)) & (tT.sig_type == sig_abb(s));
            r = corrcoef(tT.Oznet_date(selected), tT.GLDAS_date(selected), 'rows', 'pairwise');
            if length(r) ~= 2
                scatter(tT.Oznet_date(selected), tT.GLDAS_date(selected), dots_color(s), dots_mkr(s),'DisplayName',sprintf('%s, R = %.2f',sig_abb2(s),r)); hold on;
            else
                scatter(tT.Oznet_date(selected), tT.GLDAS_date(selected), dots_color(s), dots_mkr(s),'DisplayName',sprintf('%s, R = %.2f',sig_abb2(s),r(1,2))); hold on;
            end
        end        % loop for Oznet & GLDAS
        
        xlabel('Station (days)'); ylabel('GLDAS (days)');
        ylim([-200 200]);xlim([-200 200]);
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
        
        fn = sprintf('timing_d2w_depth%d.pdf',depth(k)); % saveas(gcf,fnout2);
        set(gca,'fontsize',font_point);
        exportgraphics(gcf, fullfile(out_path, fn)); 
        clear fn
    end

end
        
         % plot the times series of data

         % if the depth/station has the GLDAS/Oznet data, 

             % plot the seasonal transition timings (Piecewise)

             % plot the seasonal transition timings (Logistic)


     % if both GLDAS/Oznet has the data, find the close wet/drying seasons (within 50days of error or something?) and take the residuals

     % save them as output

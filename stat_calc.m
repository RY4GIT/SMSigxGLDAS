function [] = stat_calc(site, depth, nstation, sig_abb, sig_abb2)

% This script calculates stats for seasonal transition signatures results of twi sets of data, GLDAS and Oznet. 

    %% Preparation 
    % set path
    cd("G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\3_codes_plotters");
   
    % color
    dots_color = ["r"; "r"; ...
                "r"; "r"; ...
                "b"; "b"; ...
                "b"; "b"; ...
                "r"; "r"; ...
                "b"; "b"];
    dots_mkr = ['o'; 'o'; ...
                '+';'+'; ...
                'o'; 'o'; ...
                '+'; '+'; ...
                'o'; '+'; ...
                'o'; '+'];
    
    %% Duration analysis
    in_path = "G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\4_out\stats";
    out_path = "G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\4_out\scatter";
    
    % read data 
    tT = readtable(fullfile(in_path, 'timing_deviation.csv'), 'Delimiter', ',');
    dT = readtable(fullfile(in_path, 'duration.csv'), 'Delimiter', ',');
    
    % create scatter plot & calculate correlation coefficient
    for k = 1:length(depth)
        figure('Position',[100 100 500 350]);
        for s = 9:12
            selected = (dT.depth == depth(k)) & (dT.sig_type == sig_abb2(s));
            r = corrcoef(dT.Oznet_days(selected), dT.GLDAS_days(selected));
            if length(r) ~= 2
                scatter(dT.Oznet_days(selected), dT.GLDAS_days(selected), dots_color(s), dots_mkr(s),'DisplayName',sprintf('%s, R = %.2f',sig_abb2(s),r)); hold on;
            else
                scatter(dT.Oznet_days(selected), dT.GLDAS_days(selected), dots_color(s), dots_mkr(s),'DisplayName',sprintf('%s, R = %.2f',sig_abb2(s),r(1,2))); hold on;
            end
        end
        xlabel('Oznet [days]'); ylabel('GLDAS [days]');
        ylim([0 300]);xlim([0 300]);
        title(sprintf('depth %dcm',depth(k)));
        legend('Location','eastoutside');
        hline = refline(1,0); hline.Color = 'k'; hline.LineStyle = '--'; hline.DisplayName = '1:1 line';
        fn = sprintf('duration_depth%d.pdf',depth(k)); % saveas(gcf,fnout2);
        exportgraphics(gcf, fullfile(out_path, fn));
        clear fn
        % Figure using Gramm package
%         fig = figure('Position',[100 100 350 350]);
%         clear g;
%         selected_depth = (dT.depth == depth(k));
%         g=gramm('x', dT.Oznet_days(selected_depth),'y', dT.GLDAS_days(selected_depth), ...
%             'subset', string(dT.sig_type(selected_depth)) ~= 'NaN', 'color', dT.sig_type((selected_depth))); %sig.network ~= "NaN" );
%         g.geom_point(); g.set_names('x', 'Oznet', 'y', 'GLDAS', 'color', 'Signature type'); 
%         g.set_title(sprintf('depth %dcm',depth(k)));
%         g.axe_property('YLim',[0 300]);
%         g.draw(); 
%         fn = sprintf('duration_depth%d.pdf',depth(k)); % saveas(gcf,fnout2);
%         exportgraphics(gcf, fullfile(out_path, fn));
%         clear fn

    end
    
    clear in_path out_path
    
    %% timing analysis 
    in_path = "G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\2_out";
    out_path = "G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\4_out\scatter";
    
    % read data 



    
    % create scatter plot & calculate correlation coefficient
    for k = 1:length(depth)
        figure('Position',[100 100 500 350]);
        % loop for signature type
        for s = 1:8
            selected = (tT.depth == depth(k)) & (tT.sig_type == sig_abb2(s));
            r = corrcoef(tT.Oznet_date(selected), tT.GLDAS_date(selected));
            if length(r) ~= 2
                scatter(tT.Oznet_date(selected), tT.GLDAS_date(selected), dots_color(s), dots_mkr(s),'DisplayName',sprintf('%s, R = %.2f',sig_abb2(s),r)); hold on;
            else
                scatter(tT.Oznet_date(selected), tT.GLDAS_date(selected), dots_color(s), dots_mkr(s),'DisplayName',sprintf('%s, R = %.2f',sig_abb2(s),r(1,2))); hold on;
            end
        end        % loop for Oznet & GLDAS
        xlabel('Station (days)'); ylabel('GLDAS (days)');
        ylim([-200 200]);xlim([-200 200]);
        title(sprintf('depth %dcm',depth(k)));
        legend('Location','eastoutside');
        hline = refline(1,0); hline.Color = 'k'; hline.LineStyle = '--'; hline.DisplayName = '1:1 line';
        fn = sprintf('timing_depth%d.pdf',depth(k)); % saveas(gcf,fnout2);
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

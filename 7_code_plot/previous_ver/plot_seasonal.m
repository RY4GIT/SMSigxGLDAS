function [] = plot_seasonal(site, plot_transday, plot_duration, savetype)
    slCharacterEncoding('UTF-8');
    
    % read the format for the plots  
    sig_abb = ["seasontrans_sdate_wet2dry_p"; "seasontrans_sdate_wet2dry_l"; ...
        "seasontrans_edate_wet2dry_p"; "seasontrans_edate_wet2dry_l"; ...
        "seasontrans_sdate_dry2wet_p"; "seasontrans_sdate_dry2wet_l"; ...
        "seasontrans_edate_dry2wet_p"; "seasontrans_edate_dry2wet_l"; ...
        "seasontrans_duration_wet2dry_p"; "seasontrans_duration_wet2dry_l"; ...
        "seasontrans_duration_dry2wet_p"; "seasontrans_duration_dry2wet_l"];
    
    sig_abb2 = ["Wet end (p)"; "Wet end (p)"; ...
        "Dry start (p)"; "Dry start (l)"; ...
        "Dry end (p)"; "Dry end (l)"; ...
        "Wet start (p)"; "Wet start (l)"; ...
        "Wet to dry (p)"; "Wet to dry (l)"; ...
        "Dry to wet (p)"; "Dry to wet (l)"];
    
    % Initialize the struct
    sig.network = [];sig.depth = [];sig.station = []; sig.type = []; sig.value = [];

    for s = 1:size(sig_abb,1)
        for i = 1:size(site,1)

            % read the signature data in a struct format
            fn = sprintf('%s_%s.txt', sig_abb(s), site(i,:));
            fid = fopen(fullfile('G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\2_out',fn),'r')
                sig0 = textscan(fid, '%d %d %f \n','HeaderLines',0, 'Delimiter',',');
            fclose(fid);

            sig.network = [sig.network; repelem(string(site(i,:)),1,length(sig0{1}))'];
            sig.depth = [sig.depth; sig0{1}];
            sig.station = [sig.station; sig0{2}];
            sig.type = [sig.type; repelem(sig_abb2(s),1,length(sig0{1}))'];
            sig.value = [sig.value; sig0{3}];
            clear sig0
            clear fn
        end
    end
    
    %% Plot
    %% for seasonal trans estimated by piecewise
    if plot_transday
        for i = 1:size(site,1)
            clear g;
            selected_network = find(sig.network==site(i,:) & ...
                (sig.type == sig_abb2(1) | sig.type == sig_abb2(3) | sig.type == sig_abb2(5) | sig.type == sig_abb2(7)) );
            g=gramm('x',cellstr(sig.type(selected_network)),'y',sig.value(selected_network));
            g.stat_boxplot(); g.set_title(sprintf('%s (piecewise est.)',site(i,:))); g.set_names('x', 'Seasonal transition dates', 'y', 'Day of the year', 'color', 'depth (cm)');
            g.axe_property('xdir','reverse');g.axe_property('YLim',[0 365]);
            fig2 = figure('Position',[100 100 500 300]);  g.draw(); 
            fnout2 = sprintf('G://Shared drives//Ryoko and Hilary//SoilMoistureSignature//GLDAS//4_out_plots//transday_p_%s.%s',site(i,:), savetype); % saveas(gcf,fnout2);
            exportgraphics(gcf, fnout2);
            % close all;
        end

        for i = 1:size(site,1)
            clear g;
            selected_network = find(sig.network==site(i,:) & ...
                (sig.type == sig_abb2(2) | sig.type == sig_abb2(4) | sig.type == sig_abb2(6) | sig.type == sig_abb2(8)) );
            g=gramm('x',cellstr(sig.type(selected_network)),'y',sig.value(selected_network));
            g.stat_boxplot(); g.set_title(sprintf('%s (logistic est.)',site(i,:))); g.set_names('x', 'Seasonal transition dates', 'y', 'Day of the year', 'color', 'depth (cm)');
            g.axe_property('xdir','reverse');g.axe_property('YLim',[0 365]);
            fig2 = figure('Position',[100 100 500 300]);  g.draw(); 
            fnout2 = sprintf('G://Shared drives//Ryoko and Hilary//SoilMoistureSignature//GLDAS//4_out_plots//transday_l_%s.%s',site(i,:), savetype); % saveas(gcf,fnout2);
            exportgraphics(gcf, fnout2);
            % close all;
        end
    end
    
    %% for transition duration
    if plot_duration
        for i = 1:size(site,1)
            clear g;
            selected_network = find(sig.network==site(i,:) & ...
                (sig.type == sig_abb2(9) | sig.type == sig_abb2(11) ));
            g=gramm('x',cellstr(sig.type(selected_network)),'y',sig.value(selected_network));
            g.stat_boxplot(); g.set_title(sprintf('%s (piecewise est.)',site(i,:))); g.set_names('x', 'Season', 'y', 'Transition duration (days)', 'color', 'depth (cm)');
            g.axe_property('xdir','reverse');g.axe_property('YLim',[0 300]);
            fig2 = figure('Position',[100 100 350 300]);  g.draw(); 
            fnout2 = sprintf('G://Shared drives//Ryoko and Hilary//SoilMoistureSignature//GLDAS//4_out_plots//duration_p_%s.%s',site(i,:), savetype); % saveas(gcf,fnout2);
            exportgraphics(gcf, fnout2);
            % close all;
        end
        
        for i = 1:size(site,1)
            clear g;
            selected_network = find(sig.network==site(i,:) & ...
                (sig.type == sig_abb2(10) | sig.type == sig_abb2(12) ));
            g=gramm('x',cellstr(sig.type(selected_network)),'y',sig.value(selected_network));
            g.stat_boxplot(); g.set_title(sprintf('%s (logistic est.)',site(i,:))); g.set_names('x', 'Season', 'y', 'Transition duration (days)', 'color', 'depth (cm)');
            g.axe_property('xdir','reverse');g.axe_property('YLim',[0 300]);
            fig2 = figure('Position',[100 100 350 300]);  g.draw(); 
            fnout2 = sprintf('G://Shared drives//Ryoko and Hilary//SoilMoistureSignature//GLDAS//4_out_plots//duration_l_%s.%s',site(i,:), savetype); % saveas(gcf,fnout2);
            exportgraphics(gcf, fnout2);
            % close all;
        end
        
    end
   
end
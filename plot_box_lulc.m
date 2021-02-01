function [] = plot_box_lulc(sig_abb, sig_fullname, sig_ylabel, site,plot_lulc, plot_lulcdepth, savetype)
    slCharacterEncoding('UTF-8');

for i = 1:size(site,1)
for j = 1
    
    %% read the signature data in a struct format
    sig.network = [];sig.depth = [];sig.station = [];sig.value = []; sig.lu = "";    % Initialize the struct
    fn = sprintf('.\\results\\%s_%s_%s.txt', sig_abb, site(i,:),obs(j,:));
    fid = fopen(fullfile('G:\Shared drives\Ryoko and Hilary\SignatureAnalysis',fn),'r')
        sig0 = textscan(fid, '%d %d %f \n','HeaderLines',0, 'Delimiter',',');
    fclose(fid);

    sig.network = [sig.network; repelem(string(site(i,:)),1,length(sig0{1}))'];
    sig.depth = [sig.depth; sig0{1}];
    sig.station = [sig.station; sig0{2}];
    sig.value = [sig.value; sig0{3}];
    clear sig0 fn
    
    %% read the land use/cover info from the station metadata
    fn = sprintf('G:\\Shared drives\\Ryoko and Hilary\\SignatureAnalysis\\data\\%s_%s\\StationInformation.xlsx', site(i,:),obs(j,:));
    metadata = readtable(fn, 'Sheet', 'stationinfo4plot');
    
    % align the land-use
    for p = 1:length(sig.station)
        p2 = find(metadata.sid == sig.station(p));
        if ~isempty(p2)
            sig.lu(p) = string(metadata.lu(p2));
        else
            sig.lu(p) = "NaN";
        end
    end
    sig.lu = sig.lu';
    
    if string(site(i,:)) == "TX"
    % algin the land-use (TX has two land-types)
    for p = 1:length(sig.station)
        p2 = find(metadata.sid == sig.station(p));
        if ~isempty(p2)
            sig.lc(p) = string(metadata.lc(p2));
        else
            sig.lc(p) = "NaN";
        end
    end
    sig.lc = sig.lc';
    end
    
    %% Plot for each land cover/use
    if plot_lulc
        clear g;
        switch char(site(i,:))
            case 'HB'
                subsetlu = (sig.lu == "Green space" | sig.lu =="Housing");
            case 'MQ'
                subsetlu = (sig.lu == "Wetland" | sig.lu =="Grass"); 
            case 'TX' % texas has both land-cover and land-use classification
                subsetlu = (sig.lu == "Ungrazed" | sig.lu =="Grazed" | sig.lu =="Mowed"); 
                % subsetlu2 = (sig.lc == "Shrubland" | sig.lc =="Grass" | sig.lc =="Developed" | sig.lc =="Forest"); 
            case 'OZ'
                subsetlu = (sig.lu == "Grass" | sig.lu =="Grazed" | sig.lu =="Crop" | sig.lu =="Irrigated crop"); 
            case 'WB'
                subsetlu = (sig.lu == "Forested" | sig.lu =="Deforested"); 
            case 'WB1318'
                subsetlu = (sig.lu == "Forested" | sig.lu =="Deforested"); 
        end

        clear g;
        g=gramm('x',cellstr(sig.network),'y',sig.value, 'color', cellstr(sig.lu),'subset', subsetlu);
        g.stat_boxplot(); g.set_title(sig_fullname); g.set_names('x', 'Site', 'y',sig_ylabel, 'color', 'Land cover/use');
        if sig_abb == "amplitude" || sig_abb == "risingtime"
            g.axe_property('YScale','log')
        end
        fig = figure('Position',[100 100 400 300]); g.draw(); 
        fnout = sprintf('.//results_plots//boxplots//lulc//%s_%s_lulc.%s',sig_abb,site(i,:),savetype); 
        exportgraphics(gcf, fnout); %, 'ContentType','vector');
        % saveas(fig,fnout);

%         if exist('g2','var')
%             g2.stat_boxplot(); g2.set_title(sig_fullname); g2.set_names('x', 'Site', 'y',sig_ylabel, 'color', 'Land cover/use');
%             fig2 = figure('Position',[100 100 400 300]); g2.draw(); 
%             fnout2 = sprintf('.//results_plots//boxplots//lulc//%s_%s_lulc2.%s',sig_abb,site(i,:),savetype); 
%             exportgraphics(gcf, fnout2, 'ContentType','vector');
%             % saveas(fig2,fnout2);   
%             clear g2;
%         end

    end
    
    %% Plot for each land cover/use and depth
    if plot_lulcdepth
        clear g;
        if string(site(i,:)) == "OZ" % Oznet has multiple sensor depth. Picked only the sensors that has a lots of numbers
           g=gramm('x',cellstr(sig.lu),'y',sig.value, 'color', sig.depth, ...
            'subset', sig.depth==2.5 | sig.depth==3.5 | sig.depth==15 | sig.depth==45 | sig.depth==75); % how to do the different cases ...? 
                g.stat_boxplot(); g.set_title(sig_fullname); g.set_names('x', 'Land cover/use', 'y',sig_ylabel, 'color', 'depth (cm)');
           fig = figure('Position',[100 100 700 300]);
        else
            g=gramm('x',cellstr(sig.lu),'y',sig.value, 'color', sig.depth, ...
            'subset', sig.depth~=0); % how to do the different cases ...? 
                g.stat_boxplot(); g.set_title(sig_fullname); g.set_names('x', 'Land cover/use', 'y',sig_ylabel, 'color', 'depth (cm)');
            fig = figure('Position',[100 100 500 300]);
        end
        if sig_abb == "amplitude" || sig_abb == "risingtime"
            g.axe_property('YScale','log')
        end
        g.draw(); 
        fnout3 = sprintf('.//results_plots//boxplots//lulcdepth//%s_%s_lulcdepth.%s',sig_abb,site(i,:),savetype); 
        % saveas(gcf,fnout3);
        exportgraphics(gcf, fnout3); %, 'ContentType','vector');

%         if string(site(i,:)) == "TX" % texas has both land-cover and land-use classification
%            clear g; 
%            g=gramm('x',cellstr(sig.lc),'y',sig.value, 'color', sig.depth, ...
%               'subset', sig.depth~=0); % how to do the different cases ...? 
%            g.stat_boxplot(); g.set_title(sig_fullname); g.set_names('x', 'Land cover/use', 'y',sig_ylabel, 'color', 'depth (cm)');
%            if sig_abb == "amplitude" || sig_abb == "risingtime"
%                 g.axe_property('YScale','log')
%            end
%            fig = figure('Position',[100 100 500 300]);g.draw(); 
%            fnout3 = sprintf('.//results_plots//boxplots//lulcdepth//%s_%s_lulcdepth2.pdf',sig_abb,site(i,:)); 
%            exportgraphics(gcf, fnout3, 'ContentType','vector');
%     %        saveas(gcf,fnout3);
%         end

    %     close all;    
        clear sig;
    end
    
end
end
   
end
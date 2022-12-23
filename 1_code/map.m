%% read data
hmdir = "G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\2_data_selected";

oznet_ds = readtable("G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\2_data_selected\OZNET\metadata_ismn.csv");
scan_ds = readtable(fullfile(hmdir, 'SCAN', 'metadata.csv'));
uscrn_ds = readtable(fullfile(hmdir, 'USCRN', 'metadata.csv'));

mksize = 12;

%% plot Australian data
figure;
worldmap('Australia')
setm(gca, 'mapprojection','mercator','Fontsize', 12)
geoshow('landareas.shp','FaceColor','w'); hold on;
p0 = geoshow(oznet_ds.lat, oznet_ds.lon, 'DisplayType','point',...
    'Marker', '.', 'MarkerEdgeColor',[117 112 179]./225, 'DisplayName', 'Oznet','MarkerSize', mksize);
legend(p0,'Oznet');
ax = gca; 
ax.FontSize = 16; 
% save
fnout = fullfile(hmdir, 'Oznet.png');
exportgraphics(gcf, fnout);
close all;
clear fnout;

figure;
worldmap([min(oznet_ds.lat)-1., max(oznet_ds.lat)+1.], [min(oznet_ds.lon)-1., max(oznet_ds.lon)+1.])
setm(gca, 'mapprojection','mercator')
geoshow('landareas.shp','FaceColor','w'); hold on;
p0 = geoshow(oznet_ds.lat, oznet_ds.lon, 'DisplayType','point',...
    'Marker', '.', 'MarkerEdgeColor',[117 112 179]./225, 'DisplayName', 'Oznet','MarkerSize', mksize);
legend(p0,'Oznet') ;
ax = gca; 
ax.FontSize = 16; 

% save
fnout = fullfile(hmdir, 'Oznet_zoom.png');
exportgraphics(gcf, fnout);
close all;
clear fnout;

% shpfile = shaperead("G:\Shared drives\Ryoko and Hilary\SMSigxLU\ArcGIS\2_gisdata\OZ_F\catchment_boundary\watershedboundary_oznet.shp",'usegeo', true)


% save
fnout = fullfile(hmdir, 'Oznet.png');
exportgraphics(gcf, fnout);
close all;
clear fnout;

%% plot US data
figure;
usamap('conus')
setm(gca, 'mapprojection','mercator','MapLatLimit', [24 60],'Fontsize', 12)
geoshow('landareas.shp','FaceColor','w'); hold on;
p1 = geoshow(scan_ds.lat, scan_ds.lon, 'DisplayType','point', ...
    'Marker', '.', 'MarkerEdgeColor',[27,158,119]./225, 'DisplayName', 'SCAN', 'MarkerSize', mksize);
p2 = geoshow(uscrn_ds.lat, uscrn_ds.lon, 'DisplayType','point', ...
    'Marker', '.', 'MarkerEdgeColor',[217,95,2]./225, 'DisplayName','USCRN', 'MarkerSize', mksize);
legend([p1 p2],'SCAN','USCRN', 'Location', 'northeast') ;
ax = gca; 
ax.FontSize = 16; 

% save
fnout = fullfile(hmdir, 'USCRN_SCAN.png');
exportgraphics(gcf, fnout);
close all;






%% read data
hmdir = "G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\4_data";

oznet_ds = readtable(fullfile(hmdir, 'Oznet', 'metadata.csv'));
scan_ds = readtable(fullfile(hmdir, 'SCAN', 'metadata.csv'));
uscrn_ds = readtable(fullfile(hmdir, 'USCRN', 'metadata.csv'));

%% plot Australian data
figure;
worldmap('Australia')
setm(gca, 'mapprojection','mercator')
geoshow('landareas.shp','FaceColor','w'); hold on;
p0 = geoshow(oznet_ds.Var2, oznet_ds.Var3, 'DisplayType','point',...
    'Marker', '.', 'MarkerEdgeColor',[117 112 179]./225, 'DisplayName', 'Oznet');
legend(p0,'Oznet') 


% save
fnout = fullfile(hmdir, 'Oznet.png');
exportgraphics(gcf, fnout);
close all;
clear fnout;

%% plot US data
figure;
usamap('conus')
setm(gca, 'mapprojection','mercator','MapLatLimit', [24 60])
geoshow('landareas.shp','FaceColor','w'); hold on;
p1 = geoshow(scan_ds.lat, scan_ds.lon, 'DisplayType','point', ...
    'Marker', '.', 'MarkerEdgeColor',[27,158,119]./225, 'DisplayName', 'SCAN');
p2 = geoshow(uscrn_ds.lat, uscrn_ds.lon, 'DisplayType','point', ...
    'Marker', '.', 'MarkerEdgeColor',[217,95,2]./225, 'DisplayName', 'USCRN');
legend([p1 p2],'SCAN','USCRN') 

% save
fnout = fullfile(hmdir, 'USCRN_SCAN.png');
exportgraphics(gcf, fnout);
close all;






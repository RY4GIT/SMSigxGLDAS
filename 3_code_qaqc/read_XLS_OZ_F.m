% To read Oznet Field data file in xls format
% Ryoko Araki 30 May - 2 Jun, 2020

%% =========== BEGINNING OF THE CODE ============

%% Set current path
addpath("G:\Shared drives\Ryoko and Hilary\SignatureAnalysis");
cd('G:\Shared drives\Ryoko and Hilary\SignatureAnalysis\data\OZ_F');

%% Manual Inputs
site = ['OZ'];          % abbreviated site name
obs = ['F'];            % observation method; F:field S:satellite
depth = [3,4,15,42,45,56,59,66,71,72,75];    % sensor depths in (cm)
%     depth = [3,4,15,45,75];
%         depthm = depth/100; % sensor depths in (m)
nstation = 38;
fillvalue = -99;
regionname = {'murrumbidgee','adelong','kyeamba','yanco'};regionname = string(regionname);
regionname2 = {'m', 'a', 'k','y'};regionname2 = string(regionname2);
season = {'su', 'au', 'wi', 'sp' };season = string(season);

%% Read station data
% Manually import the data from G:\Shared drives\Ryoko and Hilary\SignatureAnalysis\data\OZ_F\SensorSpecification.xls
% Geocoordinates in WGS84

% Read station locations (decimal longitude and latitudes in WGS coordinates,
% and evelcation in m Australian Height Datum)
a = LON; b = LAT; c = Elevation;

% Name stations and assign locations
for i = 1 : nstation
    stationfield = sprintf('station%d', i);
    stationdata.(stationfield).lon = a(i);
    stationdata.(stationfield).lat = b(i);
    stationdata.(stationfield).alt = c(i);
end

%% Read SM data
%initialize data struct
dummytime = {'2001-1-1 00:00:00';'2020-2-28 23:00:00'};
dummytime = datetime(dummytime);
for k = 1:nstation
    stationnum = sprintf('station%d',k);
    %     if k == 18  %'y3'
    %         data.(stationnum).sm = array2timetable(ones(1,3)*(-0.99),'rowTimes', dummytime);
    %     else
    data.(stationnum).sm = array2timetable(ones(2,4)*(-0.99),'rowTimes', dummytime);
    %     end
    data.(stationnum).precip = array2timetable(ones(2,1)*(-99),'rowTimes', dummytime);
end

% read data in temporal format
for nreagion = 1:4 % #regions
    for nmaxst = 1:14 % max# of stations in a region
        stationname = sprintf('%s%d',regionname2(nreagion),nmaxst);
        stationname = string(stationname)
        %     renamevar = 0;
        for year = 1:19 % observation year from 20'01' to 20'19'
            disp(year)
            for nseason = 1:4 % #season
                %     renamevar = renamevar+1;
                %     disp(season(nseason))
                
                filename = sprintf('%s_%02d_%s_sm.xls', stationname, year, season(nseason));
                
                % check if the file exists
                if isfile(filename) == 0
                    continue
                else
                end
                
                % find which station we've got the data
                % import station list from 'SensorSpecifications.xlsx'
                k = find(ismember(stationlist,stationname) == 1);
                % if the stationname is in old station
                if 1 <= k && k <= 18; sheetname = '30min Data';
                    % elseif the stationname is in new station
                else; sheetname = '20min Data';
                end
                
                try
                    rawdata = readtimetable(filename, 'Sheet', sheetname);
                catch
                    %nothing to do
                end
                rawdata = standardizeMissing(rawdata,-99);
                
                % specify the variable names of soil moisture and rainfall data
                tablevarname = rawdata.Properties.VariableNames;
                swccolumn = contains(tablevarname, 'SM');raincolumn = contains(tablevarname, 'Rainfall');
                removefromswc = find((swccolumn)==0);removefromrain = find((raincolumn)==0);
                swc = removevars(rawdata, tablevarname(removefromswc)); % select only specified variables
                rain = removevars(rawdata, tablevarname(removefromrain));
                
                % aggregate data to hourly, and change swc unit %vol to m3/m3
                dt = minutes(60);
                swc = retime(swc,'regular','mean','TimeStep',dt);
                rain = retime(rain,'regular','sum','TimeStep',dt);
                
                % change sm unit from %vol to m3/m3
                swcvarname2 = tablevarname(find((swccolumn)==1));
                for i = 1:size(swcvarname2,2)
                    swc.(string(swcvarname2(i)))= swc.(string(swcvarname2(i)))*0.01;
                end
                
                % assign the data to the data struct
                % vertically combine with the data of previous season
                stationnum = sprintf('station%d',k);
                
                data.(stationnum).sm.Properties.VariableNames = swcvarname2;
                data.(stationnum).sm = [data.(stationnum).sm;swc];
                
                data.(stationnum).precip.Properties.VariableNames = rain.Properties.VariableNames;
                data.(stationnum).precip = [data.(stationnum).precip;rain];
                
            end
        end
        % sort out the time table, standardize the missing data
        data.(stationnum).sm = standardizeMissing(data.(stationnum).sm,-0.99);
        data.(stationnum).precip = standardizeMissing(data.(stationnum).precip,-99);
        data.(stationnum).sm = retime(data.(stationnum).sm, 'regular', 'TimeStep', minutes(60));
    end
end

% change the data format to desired one
% after completing one season, join the data struct

tablevarname = string('Var1');
for k = 2:nstation
    varname = sprintf('Var%d',k);
    tablevarname = [tablevarname, string(varname)];
end

tS = datetime(2001,01,12,00,00,00); %start time
swcvarname = [1	1	2	3	3	4	4	4	4	4	4];
for i = 1:size(depth,2)
    station4depth = depthstationlist(:,i);station4depth = rmmissing(station4depth);
    depthfield = sprintf('depth%dcm', depth(i))
    %        swcvarname = {'SM0_5cm','SM0_8cm','SM0_30cm','SM30_60cm','SM60_90cm'};
    i2 = swcvarname(i);
    
    for k =1:nstation
        stationfield = sprintf('station%d',k);
        % if the station data exist, but the output struct not yet exist
        if ismember(k,station4depth)==1 && k ==1
            data.(depthfield).sm = data.(stationfield).sm(:,i2);
            
            % if the station data exist, and to be syncronized with the existing struct
        elseif ismember(k,station4depth)==1 && k > 1
            data.(depthfield).sm =  ...
                synchronize(data.(depthfield).sm, data.(stationfield).sm(:,i2), ...
                'regular','TimeStep',minutes(60));
            
            % if the station data doesn't exist but first data
        elseif ismember(k,station4depth)==0 && k ==1
            data.(depthfield).sm = array2timetable([NaN],'rowTimes', tS);
            
            % if the station data doesn't exist, and to be syncronized with the existing struct
        elseif ismember(k,station4depth)==0 && k > 1
            data.(depthfield).sm =  ...
                synchronize(data.(depthfield).sm, array2timetable([NaN],'rowTimes', tS), ...
                'regular','TimeStep',minutes(60));
        end
        
    end
    data.(depthfield).sm.Properties.VariableNames = tablevarname;
end

% for precipitation
for k =1:nstation
    stationfield = sprintf('station%d',k);
    
    % if the station data exist, but the output struct not yet exist
    if ismember(k,station4depth)==1 && k ==1
        data.precip = data.(stationfield).precip;
        
        % if the station data exist, and to be syncronized with the existing struct
    elseif ismember(k,station4depth)==1 && k > 1
        data.precip =  ...
            synchronize(data.precip, data.(stationfield).precip, ...
            'regular','TimeStep',minutes(60));
        
        % if the station data doesn't exist but first data
    elseif ismember(k,station4depth)==0 && k ==1
        data.precip = array2timetable([NaN],'rowTimes', tS);
        
        % if the station data doesn't exist, and to be syncronized with the existing struct
    elseif ismember(k,station4depth)==0 && k > 1
        data.precip =  ...
            synchronize(data.precip, array2timetable([NaN],'rowTimes', tS), ...
            'regular','TimeStep',minutes(60));
    end
    
end
data.precip.Properties.VariableNames = tablevarname;

%% save the data and clear from the workspace
dim = 167952;% get dimension

cd('G:\Shared drives\Ryoko and Hilary\SignatureAnalysis');
savefile = sprintf('%s_%s.mat', site, obs);
save(savefile, 'data','stationdata','depth','stationlist','nstation','fillvalue','dim','site','obs','-v7.3');
clear all;

%% =========== END OF THE CODE ============


% To read nrc file
% Ref: https://www.mathworks.com/help/matlab/import_export/importing-network-common-data-form-netcdf-files-and-opendap-data.html


% Some codes tested
% %  teststring = {'Var1','Var2','Var3'};teststring = string(teststring);
%
%     data.(depthfield).sm = [data.(depthfield).sm; aggdata.(year).(month).(depthfield).sm];
%
%     % specify the variable names for soil moisture and rainfall data
%     tablevarname = rawdata.Properties.VariableNames;
%     swccolumn = contains(tablevarname, 'SM');raincolumn = contains(tablevarname, 'Rainfall');
%     removefromswc = find((swccolumn)==0);removefromrain = find((raincolumn)==0);
%     swc = removevars(rawdata, tablevarname(removefromswc)); % select only specified variables
%     rain = removevars(rawdata, tablevarname(removefromrain));
%
%     % aggregate data to hourly, and change swc unit %vol to m3/m3
%     dt = minutes(60);
%         swc = retime(swc,'regular','mean','TimeStep',dt);
%         swc100tab = timetable2table(swc);
%         swc = table2array(swc100tab(:,2:end)).*0.01;
%         swc = timetable(swc,'RowTimes',swc100tab.DATE_TIME);
%     rain = retime(rain,'regular','sum','TimeStep',dt);
%
%     % find at which depths we've got data
%     swcvarname2 = tablevarname(find((swccolumn)==1));
%     swcvarname = {'SM0_5cm','SM0_7cm','SM0_8cm','SM0_30cm','SM27_57cm','SM30_60cm','SM41_71cm', ...
%         'SM43.5_73.5cm','SM51_81cm','SM56_86cm','SM57_87cm','SM60_90cm'};
%     imatrix = find(ismember(swcvarname,swcvarname2) == 1);
%
%     varname = sprintf('Var%d',k);
% %   swcvarname3 = string(swcvarname2(k));
%     for i = 1:size(imatrix,2)
%         depthfield = sprintf('depth%dcm', depth(imatrix(i)));
%         seasonaldata.(depthfield).sm(:,k) = synchronize(data.(depthfield).sm(:,k), swc(:,k));
%         data.precip.(varname) = rain;
%     end


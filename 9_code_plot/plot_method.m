%% Script to run the soil moisture signature from csv file
% publish('main_gldas.m', 'doc')

% =========== BEGINNING OF THE CODE ============

clear all; close all;
slCharacterEncoding('UTF-8');

%% Preparation
% Select the module you want to run ...
save_results = true; % if you want to clear the previous results and save new results

% Set path
cd("G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\3_codes_plotters");
in_path = "G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\0_data\";
out_path = "G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\2_out\";
addpath("G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\1_codes");


% Site information
obs = ["GLDAS"]; %"Oznet";
depth = 4; 
nstation = 1;
% Original in-situ depths are: depth = [3,4,15,42,45,56,59,66,71,72,75];

%% Main execution

for j = 1:size(obs,1)
    
%     % Read stationflag
%     if obs(j,:) == "Oznet"
%         fid = fopen(fullfile(in_path, 'Oznet', 'stationflag.csv'), 'r');
%         stationflag0 = textscan(fid,repmat('%f', 1, length(depth)),'HeaderLines',0,'Delimiter',',');
%         fclose(fid);
%         stationflag = cell2mat(stationflag0);
%     end
    
    for n = 1:nstation
        stationfield = sprintf('station%d', n);
        varname = sprintf('Var%d',n);
        for k = 1:size(depth,2)
            depthfield = sprintf('depth%dcm', depth(k));
            statement = sprintf('Currently processing the %s data (depth %d cm, station %d)', obs(j,:), depth(k), n);
            disp(statement)
            
            % Read SM data    
            if obs(j,:) == "Oznet"
                fn0 = sprintf('sm_d%02d_s%02d.csv', depth(k), n);
                fn = fullfile(in_path, "Oznet", fn0);
            elseif obs(j,:) == "GLDAS"
                fn0 = sprintf('depth_%dcm.csv', depth(k));
                fn = fullfile(in_path, "GLDAS", fn0);
            end

            if exist(fn, 'file') == 2
                fid = fopen(fn, 'r');
                    if obs(j,:) == "Oznet"
                        smtt0 = textscan(fid,'%q %f','HeaderLines',1,'DateLocale','en_US','Delimiter',',');
                        smtt = timetable(datetime(smtt0{1}),smtt0{2});
                    elseif obs(j,:) == "GLDAS"
                        smtt0 = textscan(fid,'%d %q %f','HeaderLines',1,'DateLocale','en_US','Delimiter',',');
                        n_rows = find(smtt0{1} == n);
                        smtt1 = timetable(datetime(smtt0{2}),smtt0{3});      
                        smtt = smtt1(n_rows,'Var1');
                    end
                fclose(fid);

                if isempty(smtt)
                    continue
                end

                if obs(j,:) == "GLDAS"
                    smtt = sortrows(smtt, 'Time');
                    smtt = retime(smtt, 'regular', 'linear', 'TimeStep', hours(1));
                end

                sm = smtt.Var1;
                % figure; plot(smtt.Time, sm)
                clear smtt0 smtt1

                [smdtr, smttdtr] = util_detrend(sm,smtt);

                % Field capacity and wilting points
                [fc, wp] = sig_fcwp(smdtr, smttdtr, false);

                %  Read sine curve data 
                fid = fopen(fullfile(in_path, 'Oznet', sprintf('sine_ridge_%dcm.csv',depth(k))), 'r');
                ridge0 = textscan(fid,'%s','HeaderLines',0,'Delimiter',',');
                fclose(fid);
                ridge = datetime(string(ridge0{1}));
                clear fid

                fid = fopen(fullfile(in_path, 'Oznet', sprintf('sine_valley_%dcm.csv',depth(k))), 'r');
                valley0 = textscan(fid,'%s','HeaderLines',0,'Delimiter',',');
                fclose(fid);
                valley = datetime(string(valley0{1}));
                clear fid

                [WY, seasontrans_sdate_wet2dry_p, seasontrans_edate_wet2dry_p, seasontrans_sdate_dry2wet_p, seasontrans_edate_dry2wet_p, ...
                seasontrans_duration_wet2dry_p, seasontrans_duration_dry2wet_p, seasontrans_sdate_wet2dry_l, seasontrans_edate_wet2dry_l, ...
                seasontrans_sdate_dry2wet_l, seasontrans_edate_dry2wet_l, seasontrans_duration_wet2dry_l, seasontrans_duration_dry2wet_l] ...
                = sig_seasontrans(smttdtr, ridge, valley, wp, fc, true, "date");

            

            end      
        end 
    end
     
end

plot(smmttdtr.Properties.RowTimes, smttdtr.Var1, 'Line Width', 2)
%% =========== END OF THE CODE ============

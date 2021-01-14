%% Script to run the soil moisture signature from csv file
% publish('main_gldas.m', 'doc')

% =========== BEGINNING OF THE CODE ============

clear all;
slCharacterEncoding('UTF-8');

%% Preparation
% Select the module you want to run ...
save_results = true; % if you want to clear the previous results and save new results

% Set path
cd("G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\1_codes");
in_path = "G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\0_data\";
out_path = "G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\2_out\";
addpath("G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\SignatureAnalysis\5_codes_signatures");

% Site information
obs = ["Oznet";"GLDAS"];
depth = [3,4,15]; 
nstation = 38;
% Original in-situ depths are: depth = [3,4,15,42,45,56,59,66,71,72,75];

%% Main execution

for j = 1:size(obs,1)
    
    % create/read new file for recording results
    % soil-related signatures
    fn1 = sprintf('modality_%s.txt', obs(j,:));
    fn2 = sprintf('fc_%s.txt', obs(j,:));
    fn3 = sprintf('wp_%s.txt', obs(j,:));
    % seasonal signatures 
    fn5 = sprintf('seasontrans_sdate_wet2dry_p_%s.txt', obs(j,:));
    fn5_2 = sprintf('seasontrans_sdate_wet2dry_l_%s.txt', obs(j,:));
    fn6 = sprintf('seasontrans_edate_wet2dry_p_%s.txt', obs(j,:));
    fn6_2 = sprintf('seasontrans_edate_wet2dry_l_%s.txt', obs(j,:));
    fn7 = sprintf('seasontrans_sdate_dry2wet_p_%s.txt', obs(j,:));
    fn7_2 = sprintf('seasontrans_sdate_dry2wet_l_%s.txt', obs(j,:));
    fn8 = sprintf('seasontrans_edate_dry2wet_p_%s.txt', obs(j,:));
    fn8_2 = sprintf('seasontrans_edate_dry2wet_l_%s.txt', obs(j,:));
    fn9 = sprintf('seasontrans_duration_wet2dry_p_%s.txt', obs(j,:));
    fn9_2 = sprintf('seasontrans_duration_wet2dry_l_%s.txt', obs(j,:));
    fn10 = sprintf('seasontrans_duration_dry2wet_p_%s.txt', obs(j,:));
    fn10_2 = sprintf('seasontrans_duration_dry2wet_l_%s.txt', obs(j,:));

    % delete existing files
    if save_results
        delete(fullfile(out_path,fn1));delete(fullfile(out_path,fn2));delete(fullfile(out_path,fn3));
        delete(fullfile(out_path,fn5));delete(fullfile(out_path,fn5_2));delete(fullfile(out_path,fn6));delete(fullfile(out_path,fn6_2));
        delete(fullfile(out_path,fn7));delete(fullfile(out_path,fn7_2)); delete(fullfile(out_path,fn8));delete(fullfile(out_path,fn8_2));
        delete(fullfile(out_path,fn9));delete(fullfile(out_path,fn9_2));delete(fullfile(out_path,fn10));delete(fullfile(out_path,fn10_2));
    end
    
    % Read stationflag
    if obs(j,:) == "Oznet"
        fid = fopen(fullfile(in_path, 'Oznet', 'stationflag.csv'), 'r');
        stationflag0 = textscan(fid,repmat('%f', 1, length(depth)),'HeaderLines',0,'Delimiter',',');
        fclose(fid);
        stationflag = cell2mat(stationflag0);
    end
    
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

            %% Calculate the signatures
            %% if the data have wired errors/decifict, put NaN in results
            if obs(j,:) == "Oznet" && (stationflag(n,k) == 101 || stationflag(n,k) == 107 || stationflag(n,k) == 108)
                modality = 'NaN';
                fc = NaN; wp = NaN;
                seasontrans_sdate_wet2dry_p = NaN;seasontrans_edate_wet2dry_p = NaN;
                seasontrans_sdate_dry2wet_p = NaN;seasontrans_edate_dry2wet_p = NaN;
                seasontrans_duration_wet2dry_p = NaN;seasontrans_duration_dry2wet_p = NaN;
                seasontrans_sdate_wet2dry_l = NaN;seasontrans_edate_wet2dry_l = NaN;
                seasontrans_sdate_dry2wet_l = NaN;seasontrans_edate_dry2wet_l = NaN;
                seasontrans_duration_wet2dry_l = NaN;seasontrans_duration_dry2wet_l = NaN;
                amplitude = NaN; risingtime = NaN; noresrate = NaN;
                RLD = NaN;
                
            % if the time series have trends, execute signatures that are durable to de-trending 
            ... maybe include them when I got time! exclude for now 
            elseif obs(j,:) == "Oznet" && (stationflag(n,k) == 106)
                % Detrend the time series
                [smdtr, smttdtr] = util_detrend(sm,smtt);
                
                %  Modality 
                % modality = sig_pdf(smdtr);

                % Field capacity and wilting points
                [fc, wp] = sig_fcwp(smdtr, smttdtr, false);

                % Seasonal transition duration and dates
                if fc ~= wp %modality == 'bimodal' && fc ~= wp
                    [seasontrans_sdate_wet2dry_p, seasontrans_edate_wet2dry_p, seasontrans_sdate_dry2wet_p, seasontrans_edate_dry2wet_p, ...
                    seasontrans_duration_wet2dry_p, seasontrans_duration_dry2wet_p, seasontrans_sdate_wet2dry_l, seasontrans_edate_wet2dry_l, ...
                    seasontrans_sdate_dry2wet_l, seasontrans_edate_dry2wet_l, seasontrans_duration_wet2dry_l, seasontrans_duration_dry2wet_l] ...
                    = sig_seasontrans(smttdtr, wp, fc, false, "date");
                else
                    seasontrans_sdate_wet2dry_p = NaN;seasontrans_edate_wet2dry_p = NaN;
                    seasontrans_sdate_dry2wet_p = NaN;seasontrans_edate_dry2wet_p = NaN;
                    seasontrans_duration_wet2dry_p = NaN;seasontrans_duration_dry2wet_p = NaN;
                    seasontrans_sdate_wet2dry_l = NaN;seasontrans_edate_wet2dry_l = NaN;
                    seasontrans_sdate_dry2wet_l = NaN;seasontrans_edate_dry2wet_l = NaN;
                    seasontrans_duration_wet2dry_l = NaN;seasontrans_duration_dry2wet_l = NaN;
                end
                
                % As the absolute values of fc and wp are not reliable for trending time series, reset the values and do not include them to the stats
                fc = NaN;
                wp = NaN;

            %% for OzNet without erroneous trends/data, and GLDAS, always execute the signatures
            else

                % Detrend the time series
                [smdtr, smttdtr] = util_detrend(sm,smtt);
                
                %  Modality 
                % modality = sig_pdf(smdtr);

                % Field capacity and wilting points
                [fc, wp] = sig_fcwp(smdtr, smttdtr, false);

                % Seasonal transition duration and dates
                if fc ~= wp %modality == 'bimodal' && fc ~= wp
                    [seasontrans_sdate_wet2dry_p, seasontrans_edate_wet2dry_p, seasontrans_sdate_dry2wet_p, seasontrans_edate_dry2wet_p, ...
                    seasontrans_duration_wet2dry_p, seasontrans_duration_dry2wet_p, seasontrans_sdate_wet2dry_l, seasontrans_edate_wet2dry_l, ...
                    seasontrans_sdate_dry2wet_l, seasontrans_edate_dry2wet_l, seasontrans_duration_wet2dry_l, seasontrans_duration_dry2wet_l] ...
                    = sig_seasontrans(smttdtr, wp, fc, false, "date");
                else
                    seasontrans_sdate_wet2dry_p = NaN;seasontrans_edate_wet2dry_p = NaN;
                    seasontrans_sdate_dry2wet_p = NaN;seasontrans_edate_dry2wet_p = NaN;
                    seasontrans_duration_wet2dry_p = NaN;seasontrans_duration_dry2wet_p = NaN;
                    seasontrans_sdate_wet2dry_l = NaN;seasontrans_edate_wet2dry_l = NaN;
                    seasontrans_sdate_dry2wet_l = NaN;seasontrans_edate_dry2wet_l = NaN;
                    seasontrans_duration_wet2dry_l = NaN;seasontrans_duration_dry2wet_l = NaN;
                end

            end
            
            % save the results
            if save_results
%                 fid = fopen(fullfile(out_path,fn1),'a');
%                     fprintf(fid, '%d %d %s \n', depth(k), n, modality);
%                 fclose(fid);

                fid = fopen(fullfile(out_path,fn2),'a');
                    fprintf(fid, '%d %d %f \n', depth(k), n, fc);
                fclose(fid);
                
                fid = fopen(fullfile(out_path,fn3),'a');
                    fprintf(fid, '%d %d %f \n', depth(k), n, wp);
                fclose(fid);

                fid = fopen(fullfile(out_path,fn5),'a');
                for p = 1:size(seasontrans_sdate_wet2dry_p,1)
                    fprintf(fid, '%d %d %s \n', depth(k), n, seasontrans_sdate_wet2dry_p(p));
                end
                fclose(fid);
                
                fid = fopen(fullfile(out_path,fn5_2),'a');
                for p = 1:size(seasontrans_sdate_wet2dry_l,1)
                    fprintf(fid, '%d %d %s \n', depth(k), n, seasontrans_sdate_wet2dry_l(p));
                end
                fclose(fid);

                fid = fopen(fullfile(out_path,fn6),'a');
                for p = 1:size(seasontrans_edate_wet2dry_p,1)
                    fprintf(fid, '%d %d %s \n', depth(k), n, seasontrans_edate_wet2dry_p(p));
                end
                fclose(fid);
                
                fid = fopen(fullfile(out_path,fn6_2),'a');
                for p = 1:size(seasontrans_edate_wet2dry_l,1)
                    fprintf(fid, '%d %d %s \n', depth(k), n, seasontrans_edate_wet2dry_l(p));
                end
                fclose(fid);

                fid = fopen(fullfile(out_path,fn7),'a');
                for p = 1:size(seasontrans_sdate_dry2wet_p,1)
                    fprintf(fid, '%d %d %s \n', depth(k), n, seasontrans_sdate_dry2wet_p(p));
                end
                fclose(fid);
                
                fid = fopen(fullfile(out_path,fn7_2),'a');
                for p = 1:size(seasontrans_sdate_dry2wet_l,1)
                    fprintf(fid, '%d %d %s \n', depth(k), n, seasontrans_sdate_dry2wet_l(p));
                end
                fclose(fid);

                fid = fopen(fullfile(out_path,fn8),'a');
                for p = 1:size(seasontrans_edate_dry2wet_p,1)
                    fprintf(fid, '%d %d %s \n', depth(k), n, seasontrans_edate_dry2wet_p(p));
                end
                fclose(fid);
                
                fid = fopen(fullfile(out_path,fn8_2),'a');
                for p = 1:size(seasontrans_edate_dry2wet_l,1)
                    fprintf(fid, '%d %d %s \n', depth(k), n, seasontrans_edate_dry2wet_l(p));
                end
                fclose(fid);

                fid = fopen(fullfile(out_path,fn9),'a');
                for p = 1:size(seasontrans_duration_wet2dry_p,1)
                    fprintf(fid, '%d %d %d \n', depth(k), n, seasontrans_duration_wet2dry_p(p));
                end
                fclose(fid);
                
                fid = fopen(fullfile(out_path,fn9_2),'a');
                for p = 1:size(seasontrans_duration_wet2dry_l,1)
                    fprintf(fid, '%d %d %d \n', depth(k), n, seasontrans_duration_wet2dry_l(p));
                end
                fclose(fid);

                fid = fopen(fullfile(out_path,fn10),'a');
                for p = 1:size(seasontrans_duration_dry2wet_p,1)
                    fprintf(fid, '%d %d %d \n', depth(k), n, seasontrans_duration_dry2wet_p(p));
                end
                fclose(fid);
                
                fid = fopen(fullfile(out_path,fn10_2),'a');
                for p = 1:size(seasontrans_duration_dry2wet_l,1)
                    fprintf(fid, '%d %d %d \n', depth(k), n, seasontrans_duration_dry2wet_l(p));
                end
                fclose(fid);

            end

            clear smtt sm smttdtr smdtr depthfield stationfield fc wp npeaks ...
            seasontrans_sdate_wet2dry_p seasontrans_edate_wet2dry_p seasontrans_sdate_dry2wet_p seasontrans_edate_dry2wet_p seasontrans_duration_wet2dry_p seasontrans_duration_dry2wet_p ...
            seasontrans_sdate_wet2dry_l seasontrans_edate_wet2dry_l seasontrans_sdate_dry2wet_l seasontrans_edate_dry2wet_l seasontrans_duration_wet2dry_l seasontrans_duration_dry2wet_l;
            
        else
            % if the soil moisture data file does not exist, do nothing
        end
        
    end      
    end 
    
     
end

load handel
sound(y,Fs)

%% =========== END OF THE CODE ============

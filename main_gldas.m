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

% Site information
obs = ["Oznet";"GLDAS"];
depth = [3,4,10]; 
% case 1: station 3cm vs. gldas 0_10cm, point-to-pixel comparison
% case 2: station 4cm vs. gldas 0_10cm, point-to-pixel comparison
% case 3: station average vs. 

nstation = 38;
% Original in-situ depths are: depth = [3,4,15,42,45,56,59,66,71,72,75];

%% Main execution

for j = 2 %1:size(obs,1)
    
    % create/read new file for recording results
    % soil-related signatures
    fn1 = sprintf('modality_%s.txt', obs(j,:));
    fn2 = sprintf('fc_%s.txt', obs(j,:));
    fn3 = sprintf('wp_%s.txt', obs(j,:));
    
    % seasonal signatures 
    fn4 = sprintf('seasontrans_sdate_wet2dry_p_%s.txt', obs(j,:));
    fn5 = sprintf('seasontrans_sdate_wet2dry_l_%s.txt', obs(j,:));
    fn6 = sprintf('seasontrans_edate_wet2dry_p_%s.txt', obs(j,:));
    fn7 = sprintf('seasontrans_edate_wet2dry_l_%s.txt', obs(j,:));
    fn8 = sprintf('seasontrans_sdate_dry2wet_p_%s.txt', obs(j,:));
    fn9 = sprintf('seasontrans_sdate_dry2wet_l_%s.txt', obs(j,:));
    fn10 = sprintf('seasontrans_edate_dry2wet_p_%s.txt', obs(j,:));
    fn11 = sprintf('seasontrans_edate_dry2wet_l_%s.txt', obs(j,:));
    fn12 = sprintf('seasontrans_duration_wet2dry_p_%s.txt', obs(j,:));
    fn13 = sprintf('seasontrans_duration_wet2dry_l_%s.txt', obs(j,:));
    fn14 = sprintf('seasontrans_duration_dry2wet_p_%s.txt', obs(j,:));
    fn15 = sprintf('seasontrans_duration_dry2wet_l_%s.txt', obs(j,:));
    
    fn16 = sprintf('seasontrans_sdate_wet2dry_p2_%s.txt', obs(j,:));
    fn17 = sprintf('seasontrans_sdate_wet2dry_l2_%s.txt', obs(j,:));
    fn18 = sprintf('seasontrans_edate_wet2dry_p2_%s.txt', obs(j,:));
    fn19 = sprintf('seasontrans_edate_wet2dry_l2_%s.txt', obs(j,:));
    fn20 = sprintf('seasontrans_sdate_dry2wet_p2_%s.txt', obs(j,:));
    fn21 = sprintf('seasontrans_sdate_dry2wet_l2_%s.txt', obs(j,:));
    fn22 = sprintf('seasontrans_edate_dry2wet_p2_%s.txt', obs(j,:));
    fn23 = sprintf('seasontrans_edate_dry2wet_l2_%s.txt', obs(j,:));

    % delete existing files
    if save_results
        delete(fullfile(out_path,fn1));delete(fullfile(out_path,fn2));delete(fullfile(out_path,fn3));
        delete(fullfile(out_path,fn4));delete(fullfile(out_path,fn5));delete(fullfile(out_path,fn6));delete(fullfile(out_path,fn7));
        delete(fullfile(out_path,fn8));delete(fullfile(out_path,fn9)); delete(fullfile(out_path,fn10));delete(fullfile(out_path,fn11));
        delete(fullfile(out_path,fn12));delete(fullfile(out_path,fn13));delete(fullfile(out_path,fn14));delete(fullfile(out_path,fn15));
        delete(fullfile(out_path,fn16));delete(fullfile(out_path,fn17)); delete(fullfile(out_path,fn18));delete(fullfile(out_path,fn19));
        delete(fullfile(out_path,fn20));delete(fullfile(out_path,fn21));delete(fullfile(out_path,fn22));delete(fullfile(out_path,fn23));
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
                    seasontrans_sdate_wet2dry_p = NaT;seasontrans_edate_wet2dry_p = NaT;
                    seasontrans_sdate_dry2wet_p = NaT;seasontrans_edate_dry2wet_p = NaT;
                    seasontrans_sdate_wet2dry_p2 = NaN;seasontrans_edate_wet2dry_p2 = NaN;
                    seasontrans_sdate_dry2wet_p2 = NaN;seasontrans_edate_dry2wet_p2 = NaN;
                    seasontrans_duration_wet2dry_p = NaN;seasontrans_duration_dry2wet_p = NaN;
                    seasontrans_sdate_wet2dry_l = NaT;seasontrans_edate_wet2dry_l = NaT;
                    seasontrans_sdate_dry2wet_l = NaT;seasontrans_edate_dry2wet_l = NaT;
                    seasontrans_sdate_wet2dry_l2 = NaN;seasontrans_edate_wet2dry_l2 = NaN;
                    seasontrans_sdate_dry2wet_l2 = NaN;seasontrans_edate_dry2wet_l2 = NaN;
                    seasontrans_duration_wet2dry_l = NaN;seasontrans_duration_dry2wet_l = NaN;
                    WY = NaN;

                % if the time series have trends, execute signatures that are durable to de-trending 
                % ... maybe include them when I got time! exclude for now 
                else %if obs(j,:) == "Oznet" && (stationflag(n,k) == 106)
                    % Detrend the time series
                    [smdtr, smttdtr] = util_detrend(sm,smtt);

                    %  Modality 
                    % modality = sig_pdf(smdtr);

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
                    = sig_seasontrans(smttdtr, ridge, valley, wp, fc, false, "date");

                    [~, seasontrans_sdate_wet2dry_p2, seasontrans_edate_wet2dry_p2, seasontrans_sdate_dry2wet_p2, seasontrans_edate_dry2wet_p2, ...
                    ~, ~, seasontrans_sdate_wet2dry_l2, seasontrans_edate_wet2dry_l2, ...
                    seasontrans_sdate_dry2wet_l2, seasontrans_edate_dry2wet_l2, ~, ~] ...
                    = sig_seasontrans(smttdtr, ridge, valley, wp, fc, false, "deviation");

                end

                % save the results
                if save_results
    %                 fid = fopen(fullfile(out_path,fn1),'a');
    %                     fprintf(fid, '%d %d %s \n', depth(k), n, modality);
    %                 fclose(fid);

                    fid = fopen(fullfile(out_path,fn2),'a');
                        fprintf(fid, '%d %d %f \n', depth(k), n, fc);
                    fclose(fid); clear fid;
                    
                    fid = fopen(fullfile(out_path,fn3),'a');
                        fprintf(fid, '%d %d %f \n', depth(k), n, wp);
                    fclose(fid); clear fid;

                    %  ============  record as dates 
                    seasontrans_sdate_wet2dry_p.Format = 'dd-MMM-yyyy';
                    fid = fopen(fullfile(out_path,fn4),'a');
                    for p = 1:size(seasontrans_sdate_wet2dry_p,1)
                        fprintf(fid, '%d %d %s %d \n', depth(k), n, seasontrans_sdate_wet2dry_p(p), WY(p));
                    end
                    fclose(fid); clear fid;

                    fid = fopen(fullfile(out_path,fn5),'a');
                    for p = 1:size(seasontrans_sdate_wet2dry_l,1)
                        fprintf(fid, '%d %d %s %d \n', depth(k), n, seasontrans_sdate_wet2dry_l(p), WY(p));
                    end
                    fclose(fid); clear fid;

                    seasontrans_edate_wet2dry_p.Format = 'dd-MMM-yyyy';
                    fid = fopen(fullfile(out_path,fn6),'a');
                    for p = 1:size(seasontrans_edate_wet2dry_p,1)
                        fprintf(fid, '%d %d %s %d \n', depth(k), n, seasontrans_edate_wet2dry_p(p), WY(p));
                    end
                    fclose(fid); clear fid;

                    fid = fopen(fullfile(out_path,fn7),'a');
                    for p = 1:size(seasontrans_edate_wet2dry_l,1)
                        fprintf(fid, '%d %d %s %d \n', depth(k), n, seasontrans_edate_wet2dry_l(p), WY(p));
                    end
                    fclose(fid); clear fid;

                    seasontrans_sdate_dry2wet_p.Format = 'dd-MMM-yyyy';
                    fid = fopen(fullfile(out_path,fn8),'a');
                    for p = 1:size(seasontrans_sdate_dry2wet_p,1)                     
                        fprintf(fid, '%d %d %s %d \n', depth(k), n, seasontrans_sdate_dry2wet_p(p), WY(p));
                    end
                    fclose(fid); clear fid;

                    fid = fopen(fullfile(out_path,fn9),'a');
                    for p = 1:size(seasontrans_sdate_dry2wet_l,1)
                        fprintf(fid, '%d %d %s %d \n', depth(k), n, seasontrans_sdate_dry2wet_l(p), WY(p));
                    end
                    fclose(fid); clear fid;

                    seasontrans_edate_dry2wet_p.Format = 'dd-MMM-yyyy';
                    fid = fopen(fullfile(out_path,fn10),'a');
                    for p = 1:size(seasontrans_edate_dry2wet_p,1)
                        fprintf(fid, '%d %d %s %d \n', depth(k), n, seasontrans_edate_dry2wet_p(p), WY(p));
                    end
                    fclose(fid); clear fid;

                    fid = fopen(fullfile(out_path,fn11),'a');
                    for p = 1:size(seasontrans_edate_dry2wet_l,1)
                        fprintf(fid, '%d %d %s %d \n', depth(k), n, seasontrans_edate_dry2wet_l(p), WY(p));
                    end
                    fclose(fid); clear fid;

                    %  ============  record as deviation 
                    fid = fopen(fullfile(out_path,fn16),'a');
                    for p = 1:size(seasontrans_sdate_wet2dry_p2,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_sdate_wet2dry_p2(p), WY(p));
                    end
                    fclose(fid); clear fid;

                    fid = fopen(fullfile(out_path,fn17),'a');
                    for p = 1:size(seasontrans_sdate_wet2dry_l2,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_sdate_wet2dry_l2(p), WY(p));
                    end
                    fclose(fid); clear fid;

                    fid = fopen(fullfile(out_path,fn18),'a');
                    for p = 1:size(seasontrans_edate_wet2dry_p2,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_edate_wet2dry_p2(p), WY(p));
                    end
                    fclose(fid); clear fid;

                    fid = fopen(fullfile(out_path,fn19),'a');
                    for p = 1:size(seasontrans_edate_wet2dry_l2,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_edate_wet2dry_l2(p), WY(p));
                    end
                    fclose(fid); clear fid;

                    fid = fopen(fullfile(out_path,fn20),'a');
                    for p = 1:size(seasontrans_sdate_dry2wet_p2,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_sdate_dry2wet_p2(p), WY(p));
                    end
                    fclose(fid); clear fid;

                    fid = fopen(fullfile(out_path,fn21),'a');
                    for p = 1:size(seasontrans_sdate_dry2wet_l2,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_sdate_dry2wet_l2(p), WY(p));
                    end
                    fclose(fid); clear fid;

                    fid = fopen(fullfile(out_path,fn22),'a');
                    for p = 1:size(seasontrans_edate_dry2wet_p2,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_edate_dry2wet_p2(p), WY(p));
                    end
                    fclose(fid); clear fid;

                    fid = fopen(fullfile(out_path,fn23),'a');
                    for p = 1:size(seasontrans_edate_dry2wet_l2,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_edate_dry2wet_l2(p), WY(p));
                    end
                    fclose(fid); clear fid;


                    %  ============  duration
                    fid = fopen(fullfile(out_path,fn12),'a');
                    for p = 1:size(seasontrans_duration_wet2dry_p,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_duration_wet2dry_p(p), WY(p));
                    end
                    fclose(fid); clear fid;

                    fid = fopen(fullfile(out_path,fn13),'a');
                    for p = 1:size(seasontrans_duration_wet2dry_l,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_duration_wet2dry_l(p), WY(p));
                    end
                    fclose(fid); clear fid;

                    fid = fopen(fullfile(out_path,fn14),'a');
                    for p = 1:size(seasontrans_duration_dry2wet_p,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_duration_dry2wet_p(p), WY(p));
                    end
                    fclose(fid); clear fid;

                    fid = fopen(fullfile(out_path,fn15),'a');
                    for p = 1:size(seasontrans_duration_dry2wet_l,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_duration_dry2wet_l(p), WY(p));
                    end
                    fclose(fid); clear fid;

                end
                
                clear smtt sm smttdtr smdtr depthfield stationfield fc wp npeaks ...
                seasontrans_sdate_wet2dry_p seasontrans_edate_wet2dry_p seasontrans_sdate_dry2wet_p seasontrans_edate_dry2wet_p seasontrans_duration_wet2dry_p seasontrans_duration_dry2wet_p ...
                seasontrans_sdate_wet2dry_l seasontrans_edate_wet2dry_l seasontrans_sdate_dry2wet_l seasontrans_edate_dry2wet_l seasontrans_duration_wet2dry_l seasontrans_duration_dry2wet_l ...
                ridge valley WY;
            else
                % if the soil moisture data file does not exist, do nothing
            end

        end      
    end 
    
     
end

load handel
sound(y,Fs)

%% =========== END OF THE CODE ============

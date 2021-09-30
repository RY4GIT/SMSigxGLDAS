%% Main module to calculate season-transition signatures
% !! Run after running main_sinesurve.m
% publish('main_gldas.m', 'doc')

% =========== BEGINNING OF THE CODE ============

clear all;
slCharacterEncoding('UTF-8');

%% Preparation
% Select the module you want to run ...
save_results = true; % if you want to clear the previous results and save new results

% Set path
cd("G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\5_code_sig");


% Site information
network = ["Oznet"; "USCRN"; "SCAN"];
obs = ["gldas";"insitu"];

for i = 1:length(network)
    
    % Set path
    in_path = fullfile("..\4_data\",network(i));
    out_path = fullfile("..\6_out_sig\",network(i));
    
    switch network(i)
        case "Oznet"
            depth = [3; 4; 10];
        case "USCRN"
            depth = [5; 10];
        case "SCAN"
            depth = [5.08; 10];
    end
    
    %  Read sine curve data
    fid = fopen(fullfile(in_path, 'combined', 'sine_ridge_gldas.txt'),'r');
    ridge_date0 = textscan(fid,'%s','HeaderLines',0);
    fclose(fid);
    ridge_date = datetime(string(ridge_date0{1}));
    clear fid
    
    fid = fopen(fullfile(in_path, 'combined', 'sine_valley_gldas.txt'), 'r');
    valley_date0 = textscan(fid,'%s','HeaderLines',0);
    fclose(fid);
    valley_date = datetime(string(valley_date0{1}));
    clear fid
    
    %% Main execution
    for j = 1:size(obs,1)
        
        % create/read new file for recording results
        % soil-related signatures
        fn1 = sprintf('modality_%s.txt', obs(j,:));
        fn2 = sprintf('fc_%s.txt', obs(j,:));
        fn3 = sprintf('wp_%s.txt', obs(j,:));
        
        % seasonal signatures
        % transition date in date
        fn4 = sprintf('seasontrans_sdate_wet2dry_p_%s.txt', obs(j,:));
        fn5 = sprintf('seasontrans_sdate_wet2dry_l_%s.txt', obs(j,:));
        fn6 = sprintf('seasontrans_edate_wet2dry_p_%s.txt', obs(j,:));
        fn7 = sprintf('seasontrans_edate_wet2dry_l_%s.txt', obs(j,:));
        fn8 = sprintf('seasontrans_sdate_dry2wet_p_%s.txt', obs(j,:));
        fn9 = sprintf('seasontrans_sdate_dry2wet_l_%s.txt', obs(j,:));
        fn10 = sprintf('seasontrans_edate_dry2wet_p_%s.txt', obs(j,:));
        fn11 = sprintf('seasontrans_edate_dry2wet_l_%s.txt', obs(j,:));
        
        % transition duration
        fn12 = sprintf('seasontrans_duration_wet2dry_p_%s.txt', obs(j,:));
        fn13 = sprintf('seasontrans_duration_wet2dry_l_%s.txt', obs(j,:));
        fn14 = sprintf('seasontrans_duration_dry2wet_p_%s.txt', obs(j,:));
        fn15 = sprintf('seasontrans_duration_dry2wet_l_%s.txt', obs(j,:));
        
        % transition date in deviation
        fn16 = sprintf('seasontrans_sdate_wet2dry_p2_%s.txt', obs(j,:));
        fn17 = sprintf('seasontrans_sdate_wet2dry_l2_%s.txt', obs(j,:));
        fn18 = sprintf('seasontrans_edate_wet2dry_p2_%s.txt', obs(j,:));
        fn19 = sprintf('seasontrans_edate_wet2dry_l2_%s.txt', obs(j,:));
        fn20 = sprintf('seasontrans_sdate_dry2wet_p2_%s.txt', obs(j,:));
        fn21 = sprintf('seasontrans_sdate_dry2wet_l2_%s.txt', obs(j,:));
        fn22 = sprintf('seasontrans_edate_dry2wet_p2_%s.txt', obs(j,:));
        fn23 = sprintf('seasontrans_edate_dry2wet_l2_%s.txt', obs(j,:));
        
        % performance metrics
        fn24 = sprintf('performance_dry2wet_p_%s.txt', obs(j,:));
        fn25 = sprintf('performance_dry2wet_l_%s.txt', obs(j,:));
        fn26 = sprintf('performance_wet2dry_p_%s.txt', obs(j,:));
        fn27 = sprintf('performance_wet2dry_l_%s.txt', obs(j,:));
        
        
        % delete existing files
        if save_results
            % soil-related signatures
            delete(fullfile(out_path,fn1));delete(fullfile(out_path,fn2));delete(fullfile(out_path,fn3));
            % seasonal signatures
            % transition date in date
            delete(fullfile(out_path,fn4));delete(fullfile(out_path,fn5));delete(fullfile(out_path,fn6));delete(fullfile(out_path,fn7));
            delete(fullfile(out_path,fn8));delete(fullfile(out_path,fn9)); delete(fullfile(out_path,fn10));delete(fullfile(out_path,fn11));
            % transition duration
            delete(fullfile(out_path,fn12));delete(fullfile(out_path,fn13));delete(fullfile(out_path,fn14));delete(fullfile(out_path,fn15));
            % transition date in deviation
            delete(fullfile(out_path,fn16));delete(fullfile(out_path,fn17)); delete(fullfile(out_path,fn18));delete(fullfile(out_path,fn19));
            delete(fullfile(out_path,fn20));delete(fullfile(out_path,fn21));delete(fullfile(out_path,fn22));delete(fullfile(out_path,fn23));
            % performance metrics
            delete(fullfile(out_path,fn24));delete(fullfile(out_path,fn25));delete(fullfile(out_path,fn26));delete(fullfile(out_path,fn27));
        end
        
        for k = 1:length(depth)
            switch network(i)
                % for Oznet,
                % case 1: insitu 3cm vs. gldas 0_10cm, point-to-pixel comparison
                % case 2: insitu 4cm vs. gldas 0_10cm, point-to-pixel comparison
                % case 3: insitu basin average vs. gldas basin average
                case "Oznet"
                    switch k
                        case 1
                            ninsitu = 38;
                            fn0 = 'depth_3cm.csv'; % input file name
                        case 2
                            ninsitu = 38;
                            fn0 = 'depth_4cm.csv';
                        case 3
                            ninsitu = 1;
                            fn0 = 'depth_0_10cm.csv';
                    end
                case "USCRN"
                    switch k
                        case 1
                            ninsitu = 29;
                            fn0 = 'USCRN.csv';
                        case 2
                            ninsitu = 1;
                            fn0 = 'average.csv';
                    end
                case "SCAN"
                    switch k
                        case 1
                            ninsitu = 91;
                            fn0 = 'SCAN.csv';
                        case 2
                            ninsitu = 1;
                            fn0 = 'average.csv';
                    end
            end
            
            % Read GLDAS SM data
            fn = fullfile(in_path, "combined", fn0);
            fid = fopen(fn, 'r');
            % for sensorwise data
            if depth(k) ~= 10
                smtt0 = textscan(fid,'%d %q %f %f','HeaderLines',1,'DateLocale','en_US','Delimiter',',');
                % for watershed average data
            elseif i == 1
                smtt0 = textscan(fid,'%q %f %f','HeaderLines',1,'DateLocale','en_US','Delimiter',',');
            else
                smtt0 = textscan(fid,'%q %f %f','HeaderLines',1,'Delimiter',',');
            end
            fclose(fid);
            
            for n = 1:ninsitu %1:ninsitu
                fprintf('Currently processing the %s, %s data (%d cm, station %d) \n', network(i), obs(j,:), depth(k), n);
                
                if depth(k) ~= 10
                    n_rows = find(smtt0{1} == n);
                    if obs(j) == "insitu"
                        smtt1 = timetable(datetime(smtt0{2}),smtt0{3});
                    elseif obs(j) == "gldas"
                        smtt1 = timetable(datetime(smtt0{2}),smtt0{4});
                    end
                    smtt = smtt1(n_rows,'Var1');
                else
                    if obs(j) == "insitu"
                        smtt = timetable(datetime(smtt0{1}),smtt0{2});
                    elseif obs(j) == "gldas"
                        smtt = timetable(datetime(smtt0{1}),smtt0{3});
                    end
                end
                
                if isempty(smtt)
                    continue
                end
                
                smtt = sortrows(smtt, 'Time');
                smtt = retime(smtt, 'regular', 'linear', 'TimeStep', hours(1));
                
                sm = smtt.Var1;
                
                %% Calculate the signatures
                [smdtr, smttdtr] = util_detrend(sm,smtt);
                
                %  Modality
                % modality = sig_pdf(smdtr);
                
                % Field capacity and wilting points
                [fc, wp] = sig_fcwp(smdtr, smttdtr, false);
                
                [WY, seasontrans_sdate_wet2dry_p, seasontrans_edate_wet2dry_p, seasontrans_sdate_dry2wet_p, seasontrans_edate_dry2wet_p, ...
                    seasontrans_duration_wet2dry_p, seasontrans_duration_dry2wet_p, seasontrans_sdate_wet2dry_l, seasontrans_edate_wet2dry_l, ...
                    seasontrans_sdate_dry2wet_l, seasontrans_edate_dry2wet_l, seasontrans_duration_wet2dry_l, seasontrans_duration_dry2wet_l, ...
                    record_squaredMiOi, record_n] ...
                    = sig_seasontrans(smttdtr, ridge_date, valley_date, wp, fc, false, "date");
                
                [~, seasontrans_sdate_wet2dry_p2, seasontrans_edate_wet2dry_p2, seasontrans_sdate_dry2wet_p2, seasontrans_edate_dry2wet_p2, ...
                    ~, ~, seasontrans_sdate_wet2dry_l2, seasontrans_edate_wet2dry_l2, ...
                    seasontrans_sdate_dry2wet_l2, seasontrans_edate_dry2wet_l2, ~, ~] ...
                    = sig_seasontrans(smttdtr, ridge_date, valley_date, wp, fc, false, "deviation");
                
                %% save the results
                if save_results
                    %                 fid = fopen(fullfile(out_path,fn1),'a');
                    %                     fprintf(fid, '%d %d %s \n', depth(k), n, modality);
                    %                 fclose(fid);
                    
                    fid = fopen(fullfile(out_path, fn2),'a');
                    fprintf(fid, '%d %d %f \n', depth(k), n, fc);
                    fclose(fid); clear fid;
                    
                    fid = fopen(fullfile(out_path, fn3),'a');
                    fprintf(fid, '%d %d %f \n', depth(k), n, wp);
                    fclose(fid); clear fid;
                    
                    %  ============  record as dates
                    seasontrans_sdate_wet2dry_p.Format = 'dd-MMM-yyyy';
                    fid = fopen(fullfile(out_path, fn4),'a');
                    for p = 1:size(seasontrans_sdate_wet2dry_p,1)
                        fprintf(fid, '%d %d %s %d \n', depth(k), n, seasontrans_sdate_wet2dry_p(p), WY(p));
                    end
                    fclose(fid); clear fid;
                    
                    fid = fopen(fullfile(out_path, fn5),'a');
                    for p = 1:size(seasontrans_sdate_wet2dry_l,1)
                        fprintf(fid, '%d %d %s %d \n', depth(k), n, seasontrans_sdate_wet2dry_l(p), WY(p));
                    end
                    fclose(fid); clear fid;
                    
                    seasontrans_edate_wet2dry_p.Format = 'dd-MMM-yyyy';
                    fid = fopen(fullfile(out_path, fn6),'a');
                    for p = 1:size(seasontrans_edate_wet2dry_p,1)
                        fprintf(fid, '%d %d %s %d \n', depth(k), n, seasontrans_edate_wet2dry_p(p), WY(p));
                    end
                    fclose(fid); clear fid;
                    
                    fid = fopen(fullfile(out_path, fn7),'a');
                    for p = 1:size(seasontrans_edate_wet2dry_l,1)
                        fprintf(fid, '%d %d %s %d \n', depth(k), n, seasontrans_edate_wet2dry_l(p), WY(p));
                    end
                    fclose(fid); clear fid;
                    
                    seasontrans_sdate_dry2wet_p.Format = 'dd-MMM-yyyy';
                    fid = fopen(fullfile(out_path, fn8),'a');
                    for p = 1:size(seasontrans_sdate_dry2wet_p,1)
                        fprintf(fid, '%d %d %s %d \n', depth(k), n, seasontrans_sdate_dry2wet_p(p), WY(p));
                    end
                    fclose(fid); clear fid;
                    
                    fid = fopen(fullfile(out_path, fn9),'a');
                    for p = 1:size(seasontrans_sdate_dry2wet_l,1)
                        fprintf(fid, '%d %d %s %d \n', depth(k), n, seasontrans_sdate_dry2wet_l(p), WY(p));
                    end
                    fclose(fid); clear fid;
                    
                    seasontrans_edate_dry2wet_p.Format = 'dd-MMM-yyyy';
                    fid = fopen(fullfile(out_path, fn10),'a');
                    for p = 1:size(seasontrans_edate_dry2wet_p,1)
                        fprintf(fid, '%d %d %s %d \n', depth(k), n, seasontrans_edate_dry2wet_p(p), WY(p));
                    end
                    fclose(fid); clear fid;
                    
                    fid = fopen(fullfile(out_path, fn11),'a');
                    for p = 1:size(seasontrans_edate_dry2wet_l,1)
                        fprintf(fid, '%d %d %s %d \n', depth(k), n, seasontrans_edate_dry2wet_l(p), WY(p));
                    end
                    fclose(fid); clear fid;
                    
                    
                    %  ============  record as deviation
                    fid = fopen(fullfile(out_path, fn16),'a');
                    for p = 1:size(seasontrans_sdate_wet2dry_p2,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_sdate_wet2dry_p2(p), WY(p));
                    end
                    fclose(fid); clear fid;
                    
                    fid = fopen(fullfile(out_path, fn17),'a');
                    for p = 1:size(seasontrans_sdate_wet2dry_l2,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_sdate_wet2dry_l2(p), WY(p));
                    end
                    fclose(fid); clear fid;
                    
                    fid = fopen(fullfile(out_path, fn18),'a');
                    for p = 1:size(seasontrans_edate_wet2dry_p2,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_edate_wet2dry_p2(p), WY(p));
                    end
                    fclose(fid); clear fid;
                    
                    fid = fopen(fullfile(out_path, fn19),'a');
                    for p = 1:size(seasontrans_edate_wet2dry_l2,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_edate_wet2dry_l2(p), WY(p));
                    end
                    fclose(fid); clear fid;
                    
                    fid = fopen(fullfile(out_path, fn20),'a');
                    for p = 1:size(seasontrans_sdate_dry2wet_p2,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_sdate_dry2wet_p2(p), WY(p));
                    end
                    fclose(fid); clear fid;
                    
                    fid = fopen(fullfile(out_path, fn21),'a');
                    for p = 1:size(seasontrans_sdate_dry2wet_l2,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_sdate_dry2wet_l2(p), WY(p));
                    end
                    fclose(fid); clear fid;
                    
                    fid = fopen(fullfile(out_path, fn22),'a');
                    for p = 1:size(seasontrans_edate_dry2wet_p2,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_edate_dry2wet_p2(p), WY(p));
                    end
                    fclose(fid); clear fid;
                    
                    fid = fopen(fullfile(out_path, fn23),'a');
                    for p = 1:size(seasontrans_edate_dry2wet_l2,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_edate_dry2wet_l2(p), WY(p));
                    end
                    fclose(fid); clear fid;
                    
                    %  ============  duration
                    fid = fopen(fullfile(out_path, fn12),'a');
                    for p = 1:size(seasontrans_duration_wet2dry_p,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_duration_wet2dry_p(p), WY(p));
                    end
                    fclose(fid); clear fid;
                    
                    fid = fopen(fullfile(out_path, fn13),'a');
                    for p = 1:size(seasontrans_duration_wet2dry_l,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_duration_wet2dry_l(p), WY(p));
                    end
                    fclose(fid); clear fid;
                    
                    fid = fopen(fullfile(out_path, fn14),'a');
                    for p = 1:size(seasontrans_duration_dry2wet_p,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_duration_dry2wet_p(p), WY(p));
                    end
                    fclose(fid); clear fid;
                    
                    fid = fopen(fullfile(out_path, fn15),'a');
                    for p = 1:size(seasontrans_duration_dry2wet_l,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, seasontrans_duration_dry2wet_l(p), WY(p));
                    end
                    fclose(fid); clear fid;
                    
                    % ============ record r2 and n
                    fid = fopen(fullfile(out_path, fn24),'a');
                    for p = 1:size(record_squaredMiOi,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, record_squaredMiOi(p,1), record_n(p,1));
                    end
                    fclose(fid); clear fid;
                    
                    fid = fopen(fullfile(out_path, fn25),'a');
                    for p = 1:size(record_squaredMiOi,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, record_squaredMiOi(p,2), record_n(p,2));
                    end
                    fclose(fid); clear fid;
                    
                    fid = fopen(fullfile(out_path, fn26),'a');
                    for p = 1:size(record_squaredMiOi,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, record_squaredMiOi(p,3), record_n(p,3));
                    end
                    fclose(fid); clear fid;
                    
                    fid = fopen(fullfile(out_path, fn27),'a');
                    for p = 1:size(record_squaredMiOi,1)
                        fprintf(fid, '%d %d %f %d \n', depth(k), n, record_squaredMiOi(p,4), record_n(p,4));
                    end
                    fclose(fid); clear fid;
                    
                end
                
                clear smtt sm smttdtr smdtr fc wp npeaks ...
                    seasontrans_sdate_wet2dry_p seasontrans_edate_wet2dry_p seasontrans_sdate_dry2wet_p seasontrans_edate_dry2wet_p seasontrans_duration_wet2dry_p seasontrans_duration_dry2wet_p ...
                    seasontrans_sdate_wet2dry_l seasontrans_edate_wet2dry_l seasontrans_sdate_dry2wet_l seasontrans_edate_dry2wet_l seasontrans_duration_wet2dry_l seasontrans_duration_dry2wet_l ...
                    WY record_squaredMiOi record_n;
                
            end
        end
    end
end

load handel
sound(y,Fs)

%% =========== END OF THE CODE ============

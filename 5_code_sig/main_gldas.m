%% Main module to calculate season-transition signatures 
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
obs = ["gldas";"station"];
depth = [3; 4; 10];

%  Read sine curve data 
fid = fopen(fullfile(in_path, 'Oznet', 'sine_ridge.csv'),'r');
ridge_date0 = textscan(fid,'%s','HeaderLines',0,'Delimiter',',');
fclose(fid);
ridge_date = datetime(string(ridge_date0{1}));
clear fid

fid = fopen(fullfile(in_path, 'Oznet', 'sine_valley.csv'), 'r');
valley_date0 = textscan(fid,'%s','HeaderLines',0,'Delimiter',',');
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
        
        fn24 = sprintf('performance_dry2wet_p_%s.txt', obs(j,:));
        fn25 = sprintf('performance_dry2wet_l_%s.txt', obs(j,:));
        fn26 = sprintf('performance_wet2dry_p_%s.txt', obs(j,:));
        fn27 = sprintf('performance_wet2dry_l_%s.txt', obs(j,:));


        % delete existing files
        if save_results
            delete(fullfile(out_path,fn1));delete(fullfile(out_path,fn2));delete(fullfile(out_path,fn3));
            delete(fullfile(out_path,fn4));delete(fullfile(out_path,fn5));delete(fullfile(out_path,fn6));delete(fullfile(out_path,fn7));
            delete(fullfile(out_path,fn8));delete(fullfile(out_path,fn9)); delete(fullfile(out_path,fn10));delete(fullfile(out_path,fn11));
            delete(fullfile(out_path,fn12));delete(fullfile(out_path,fn13));delete(fullfile(out_path,fn14));delete(fullfile(out_path,fn15));
%             delete(fullfile(out_path,fn16));delete(fullfile(out_path,fn17)); delete(fullfile(out_path,fn18));delete(fullfile(out_path,fn19));
%             delete(fullfile(out_path,fn20));delete(fullfile(out_path,fn21));delete(fullfile(out_path,fn22));delete(fullfile(out_path,fn23));
            delete(fullfile(out_path,fn24));delete(fullfile(out_path,fn25));delete(fullfile(out_path,fn26));delete(fullfile(out_path,fn27));
        end
        
    for k = 1:3 %size(depth,2)
        % case 1: station 3cm vs. gldas 0_10cm, point-to-pixel comparison
        % case 2: station 4cm vs. gldas 0_10cm, point-to-pixel comparison
        % case 3: station basin average vs. gldas basin average

        switch k
            case 1
                nstation = 38;
                fn0 = 'depth_3cm.csv'; % name of the input file name
            case 2
                nstation = 38;
                fn0 = 'depth_4cm.csv';
            case 3
                nstation = 1;
                fn0 = 'depth_0_10cm.csv';
        end

        % Read SM data    
        fn = fullfile(in_path, "GLDAS", fn0);
        fid = fopen(fn, 'r');
        if k == 1 || k == 2
            smtt0 = textscan(fid,'%d %q %f %f','HeaderLines',1,'DateLocale','en_US','Delimiter',',');
        else
            smtt0 = textscan(fid,'%q %f %f','HeaderLines',1,'DateLocale','en_US','Delimiter',',');
        end
        fclose(fid);

        for n = 1:nstation

            statement = sprintf('Currently processing the %s data (case %d, station %d)', obs(j,:), k, n);
            disp(statement)


            if k == 1 || k == 2
                n_rows = find(smtt0{1} == n);
                if obs(j) == "station"
                    smtt1 = timetable(datetime(smtt0{2}),smtt0{3});
                elseif obs(j) == "gldas"
                    smtt1 = timetable(datetime(smtt0{2}),smtt0{4});
                end
                smtt = smtt1(n_rows,'Var1');
            else
                if obs(j) == "station"
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

            % figure; plot(smtt.Time, sm)

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

%             [~, seasontrans_sdate_wet2dry_p2, seasontrans_edate_wet2dry_p2, seasontrans_sdate_dry2wet_p2, seasontrans_edate_dry2wet_p2, ...
%             ~, ~, seasontrans_sdate_wet2dry_l2, seasontrans_edate_wet2dry_l2, ...
%             seasontrans_sdate_dry2wet_l2, seasontrans_edate_dry2wet_l2, ~, ~] ...
%             = sig_seasontrans(smttdtr, ridge_date, valley_date, wp, fc, false, "deviation");

            %% save the results
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

                %{
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
                %}


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
                
                % ============ record r2 and n
                fid = fopen(fullfile(out_path,fn24),'a');
                for p = 1:size(record_squaredMiOi,1)
                    fprintf(fid, '%d %d %f %d \n', depth(k), n, record_squaredMiOi(p,1), record_n(p,1));
                end
                fclose(fid); clear fid;
                
                fid = fopen(fullfile(out_path,fn25),'a');
                for p = 1:size(record_squaredMiOi,1)
                    fprintf(fid, '%d %d %f %d \n', depth(k), n, record_squaredMiOi(p,2), record_n(p,2));
                end
                fclose(fid); clear fid;
                
                fid = fopen(fullfile(out_path,fn26),'a');
                for p = 1:size(record_squaredMiOi,1)
                    fprintf(fid, '%d %d %f %d \n', depth(k), n, record_squaredMiOi(p,3), record_n(p,3));
                end
                fclose(fid); clear fid;
                
                fid = fopen(fullfile(out_path,fn27),'a');
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

load handel
sound(y,Fs)

%% =========== END OF THE CODE ============

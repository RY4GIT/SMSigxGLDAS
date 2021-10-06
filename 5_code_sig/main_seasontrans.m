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
sigT = readtable('./sig_run_format.csv', 'HeaderLines',0,'Delimiter',',');

for i = 1:length(network)
    
    % Set path
    in_path = fullfile("..\4_data\", network(i));
    out_path = fullfile("..\6_out_sig\", network(i));
    
    [depth, nstation, ~] = io_siteinfo(network(i));
    
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
        
        for s = 1:size(sigT,1)
            % create/read new file for recording results
            fn = sprintf('%s_%s.txt', string(sigT.sig_abb(s)), obs(j,:));
            if save_results
                fid = fopen(fullfile(out_path, fn),'w');
                fprintf(fid, "depth,sid,value,WY\n");
                fclose(fid);
            end
            % initialize the recording struct
            R.(string(sigT.sig_abb(s))) = [];
        end
        R.WY = [];
        
        for k = 1:length(depth)
            [smtt0, ninsitu] = read_data1(network(i), k, depth, in_path);
            
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
                R.fc = fc;
                R.wp = wp;
                
                [R.WY, R.seasontrans_sdate_wet2dry_p, R.seasontrans_edate_wet2dry_p, R.seasontrans_sdate_dry2wet_p, R.seasontrans_edate_dry2wet_p, ...
                    R.seasontrans_duration_wet2dry_p, R.seasontrans_duration_dry2wet_p, R.seasontrans_sdate_wet2dry_l, R.seasontrans_edate_wet2dry_l, ...
                    R.seasontrans_sdate_dry2wet_l, R.seasontrans_edate_dry2wet_l, R.seasontrans_duration_wet2dry_l, R.seasontrans_duration_dry2wet_l, ...
                    record_squaredMiOi, record_n] ...
                    = sig_seasontrans(smttdtr, ridge_date, valley_date, wp, fc, false, "date");
                
                R.performance_dry2wet_p = horzcat(record_squaredMiOi(:,1), record_n(:,1));
                R.performance_dry2wet_l = horzcat(record_squaredMiOi(:,2), record_n(:,2));
                R.performance_wet2dry_p = horzcat(record_squaredMiOi(:,3), record_n(:,3));
                R.performance_wet2dry_l = horzcat(record_squaredMiOi(:,4), record_n(:,4));

                [~, R.seasontrans_sdate_wet2dry_p2, R.seasontrans_edate_wet2dry_p2, R.seasontrans_sdate_dry2wet_p2, R.seasontrans_edate_dry2wet_p2, ...
                    ~, ~, R.seasontrans_sdate_wet2dry_l2, R.seasontrans_edate_wet2dry_l2, ...
                    R.seasontrans_sdate_dry2wet_l2, R.seasontrans_edate_dry2wet_l2, ~, ~] ...
                    = sig_seasontrans(smttdtr, ridge_date, valley_date, wp, fc, false, "deviation");
                
                %% save the results
                if save_results
                    for s = 1:size(sigT,1)
                        sig_values = R.(string(sigT.sig_abb(s)));
                        fn = sprintf('%s_%s.txt', string(sigT.sig_abb(s)), obs(j,:));
                        fid = fopen(fullfile(out_path, fn),'a');
                        for p = 1:size(sig_values,1)
                            if contains(string(sigT.sig_abb(s)), 'performance')
                                fprintf(fid, string(sigT.out_format(s)), ...
                                    depth(k), n, sig_values(p,:));
                            elseif contains(string(sigT.sig_abb(s)), 'wp') || contains(string(sigT.sig_abb(s)), 'fc') || contains(string(sigT.sig_abb(s)), 'modality')
                                fprintf(fid, string(sigT.out_format(s)), ...
                                    depth(k), n, sig_values(p));
                            else
                                fprintf(fid, string(sigT.out_format(s)), ...
                                    depth(k), n, sig_values(p), R.WY(p));
                            end
                        end
                        fclose(fid);
                        clear fid;
                    end
                end
                
            end
        end
    end
end

load handel
sound(y,Fs)

%% =========== END OF THE CODE ============

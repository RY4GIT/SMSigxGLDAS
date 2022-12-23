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

for i = 3 %1:length(network)
    
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
        
        for k = 2 %1:length(depth)
            [smtt0, ninsitu] = read_data1(network(i), k, depth, in_path);
            
            for n = 1 %:ninsitu
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
                
                [WY, seasontrans_time_date, seasontrans_time_deviation, seasontrans_duration, record_squaredMiOi, record_n] ...
                    = sig_seasontrans_test(smtt, ridge_date, wp, fc, "piecewise", true)

            end
        end
    end
end

load handel
sound(y,Fs)

%% =========== END OF THE CODE ============

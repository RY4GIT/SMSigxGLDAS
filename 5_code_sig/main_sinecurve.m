%% Main module to calculate sine-curve signatures
% publish('main_gldas.m', 'doc')

% =========== BEGINNING OF THE CODE ============

clear all;
slCharacterEncoding('UTF-8');

%% Preparation
% Select the module you want to run ...
save_results = true; % if you want to clear the previous results and save new results

% Set path
cd("G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\5_code_sig\");
in_path = "G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\4_data\";
out_path1 = "G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\6_out_sig\"; % to output the amplitude and phase shift info
out_path2 = "G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\4_data\"; % to putout the valley and peak info

% Site information
network = ["Oznet"; "USCRN"; "SCAN"];
obs = ["gldas";"insitu"];

%% Main execution
for i = 1 %:length(network)
    
    switch network(i)
        case "Oznet"
            depth = [3; 4; 10];
        case "USCRN"
            depth = [5; 10];
        case "SCAN"
            depth = [5.08; 10];
    end
    
    % delete existing files
    fn3 = 'sine_ridge_gldas.txt';
    fn4 = 'sine_valley_gldas.txt';
    if save_results
        delete(fullfile(out_path1, network(i), fn3));delete(fullfile(out_path1, network(i), fn4));
    end
    
    for j = 1:size(obs,1)
        % create/read new file for recording results
        fn1 = sprintf('amplitude_%s.txt', obs(j,:));
        fn2 = sprintf('phaseshift_%s.txt', obs(j,:));
        
        % delete existing files
        if save_results
            delete(fullfile(out_path1, network(i), "combined", fn1));
            delete(fullfile(out_path1, network(i), "combined", fn2));
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
                            fn0 = 'depth_3cm.csv'; % name of the input file name
                        case 2
                            ninsitu = 38;
                            fn0 = 'depth_4cm.csv';
                        case 3
                            ninsitu = 1;
                            fn0 = 'depth_0_10cm.csv';
                    end
            end
            
            % Read GLDAS SM data
            fn = fullfile(in_path, network(i), "combined", fn0);
            fid = fopen(fn, 'r');
            % for sensorwise data
            if k == 1 || k == 2
                smtt0 = textscan(fid,'%d %q %f %f','HeaderLines',1,'DateLocale','en_US','Delimiter',',');
                % for watershed average data
            else
                smtt0 = textscan(fid,'%q %f %f','HeaderLines',1,'DateLocale','en_US','Delimiter',',');
            end
            fclose(fid);
            
            for n = 1:ninsitu
                statement = sprintf('Currently processing the %s data (case %d, insitu %d)', obs(j,:), k, n);
                disp(statement)
                
                % for sensorwise data
                if k == 1 || k == 2
                    n_rows = find(smtt0{1} == n);
                    if obs(j) == "insitu"
                        smtt1 = timetable(datetime(smtt0{2}),smtt0{3});
                    elseif obs(j) == "gldas"
                        smtt1 = timetable(datetime(smtt0{2}),smtt0{4});
                    end
                    smtt = smtt1(n_rows,'Var1');
                    % for watershed average data
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
                t_datetime = smtt.Properties.RowTimes;
                t_datenum = datenum(smtt.Properties.RowTimes);
                
                %% get sine curve
                w = 2*pi/365;
                [A, phi, k2] = util_FitSineCurve(t_datenum, sm, w);
                
                %% get seasonal transition valley and peaks
                if obs(j,:) == "gldas" && k == 3
                    sine_start = fix(t_datenum/365 + phi/2/pi);
                    sine_end = fix(t_datenum/365 + phi/2/pi)-1;
                    
                    y_hat = A*sin(w*t_datenum + phi) + k2;
                    sine_n = fix(length(t_datenum)/24/365);
                    sine_start0 = fix(t_datenum(1)/365 + phi/2/pi);
                    sine_start_v = 365/2/pi*(2*sine_start0*pi -pi/2 - phi);
                    sine_start_r = 365/2/pi*(2*sine_start0*pi +pi/2 - phi);
                    valley = [sine_start_v:365:sine_start_v+365*sine_n];
                    ridge = [sine_start_r:365:sine_start_r+365*sine_n];
                    valley = datetime(valley, 'ConvertFrom','datenum');
                    ridge = datetime(ridge, 'ConvertFrom','datenum');
                    
                    %                     figure;
                    %                     plot(t_datenum, y_hat); hold on;
                    %                     scatter(valley, repelem(min(y_hat),14));
                    %                     scatter(peak, repelem(max(y_hat),14));
                    
                end
                
                %% save the results
                if save_results
                    
                    fid = fopen(fullfile(out_path1, network(i), fn1),'a');
                    fprintf(fid, '%d %d %f \n', depth(k), n, A);
                    fclose(fid); clear fid;
                    
                    fid = fopen(fullfile(out_path1, network(i), fn2),'a');
                    fprintf(fid, '%d %d %f \n', depth(k), n, phi);
                    fclose(fid); clear fid;
                    
                    if obs(j,:) == "gldas" && k == 3
                        fid = fopen(fullfile(out_path2, network(i), 'combined', fn3),'a');
                        fprintf(fid, '%s \n', valley);
                        fclose(fid); clear fid;
                        
                        fid = fopen(fullfile(out_path2, network(i), 'combined', fn4),'a');
                        fprintf(fid, '%s \n', ridge);
                        fclose(fid); clear fid;
                    end
                    
                end
                
            end
        end
    end
end

load handel
sound(y,Fs)

%% =========== END OF THE CODE ============

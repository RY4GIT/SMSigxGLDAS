%% Main module to calculate sine-curve signatures
% publish('main_gldas.m', 'doc')

% =========== BEGINNING OF THE CODE ============

%% Preparation
clear all; close all;
slCharacterEncoding('UTF-8');
save_results = true; % if you want to clear the previous results and save new results

% Set path
cd("G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\5_code_sig\");
in_path = "..\4_data\";

% Site information
network = ["Oznet"; "USCRN"; "SCAN"];
obs = ["gldas";"insitu"];
data_type = "combined"; %"combined_weighted";
plot_results = false;

%% Main execution
for i = 1:length(network)
    
    close all;
    
    % initiation
    record_depth = [];
    record_station = [];
    record_date_insitu = [];
    record_date_gldas = [];
    record_duration_insitu = [];
    record_duration_gldas = [];

    [depth, nstation, ~, ninsitu, fn0] = io_siteinfo(network(i));

    % read the station flag
    fn = fullfile(in_path, network(i), 'ts_without_2seasons.txt');
    stationflag = readmatrix(fn);

    for k = 1:length(depth)
        
        %%
        % //////////////////////////////////////////////////
        % ////    1. Read comparing SM data /////////////
        % //////////////////////////////////////////////////
        
        % Read data 
        fn = fullfile(in_path, network(i), data_type, fn0(k));
        fid = fopen(fn, 'r');
        if depth(k) ~= 10
            % for sensorwise data
            if data_type == "combined"
                smtt0 = textscan(fid,'%d %q %f %f','HeaderLines',1,'DateLocale','en_US','Delimiter',',');
                sid_cells = smtt0{1};
                date_cells = smtt0{2};
                insitu_data_cells = smtt0{3};
                gldas_data_cells = smtt0{4};
            elseif data_type == "combined_weighted"
                smtt0 = textscan(fid,'%q %d %f %f','HeaderLines',1,'DateLocale','en_US','Delimiter',',');
                sid_cells = smtt0{2};
                date_cells = smtt0{1};
                insitu_data_cells = smtt0{3};
                gldas_data_cells = smtt0{4};
            end
        elseif i == 1
            % for watershed average data
            smtt0 = textscan(fid,'%q %f %f','HeaderLines',1,'DateLocale','en_US','Delimiter',',');
        else
            % for data in other formats
            smtt0 = textscan(fid,'%q %f %f','HeaderLines',1,'Delimiter',',');
        end
        fclose(fid);

        for n = 1:ninsitu(k)
            statement = sprintf('Currently processing the %s data (case %d, station %d)', network(i), k, n);
            disp(statement)

            if depth(k) ~= 10 && ismember(n, stationflag)
                continue
            end
            
            % Read each station data 
            if depth(k) ~= 10
            % for sensorwise data
                n_rows = find(sid_cells == n);
                smtt_insitu = timetable(datetime(date_cells), insitu_data_cells, 'VariableNames', {'Var1'});
                smtt_insitu = smtt_insitu(n_rows,'Var1');
                smtt_gldas = timetable(datetime(date_cells), gldas_data_cells, 'VariableNames', {'Var1'});
                smtt_gldas = smtt_gldas(n_rows,'Var1');
            % for watershed average data
            else
                smtt_insitu = timetable(datetime(smtt0{1}),smtt0{2});
                smtt_gldas = timetable(datetime(smtt0{1}),smtt0{3});
            end

            if isempty(smtt_insitu) || isempty(smtt_gldas)
                continue
            end
            
            % Detrend the data 
            [~, smtt_insitu_dtr] = util_detrend(smtt_insitu.Var1, smtt_insitu);
            [~, smtt_gldas_dtr] = util_detrend(smtt_gldas.Var1, smtt_gldas);
            
            % Combine both insitu and gldas data
            smtt = synchronize(smtt_insitu_dtr, smtt_gldas_dtr);
            smtt.Properties.VariableNames = {'insitu','gldas'};

            smtt = retime(smtt, 'regular', 'fillwithmissing', 'TimeStep', days(1));
            smtt = retime(smtt, 'regular', 'mean', 'TimeStep', days(1));

            % Get time values 
            t_datenum = datenum(smtt.Properties.RowTimes);
            
            %% Calculate the signatures
            % //////////////////////////////////////////////////
            % ////    2. Get the sine curve        /////////////
            % //////////////////////////////////////////////////
            % Get sine curve information from insitu data 
            w = 2*pi/365;
            [A, phi, k2] = util_FitSineCurve(t_datenum, smtt.insitu, w);
            % get seasonal transition valley
            sine_n = fix(length(t_datenum)/365);
            sine_start0 = fix(t_datenum(1)/365 + phi/2/pi);
            sine_start_v = 365/2/pi*(2*sine_start0*pi -pi/2 - phi);
            valley = [sine_start_v:365:sine_start_v+365*sine_n];
            t_valley = datetime(valley, 'ConvertFrom','datenum');
            
            % //////////////////////////////////////////////////
            % ////    3. Seasonal transition signature /////////
            % //////////////////////////////////////////////////
 
            % Send to seasonal transition signature, get results 
            [fc_insitu, wp_insitu] = sig_fcwp(smtt.insitu, smtt(:,1), false);
            [fc_gldas, wp_gldas] = sig_fcwp(smtt.gldas, smtt(:,2), false);
            
            % Set initial parameters to fit for the network (not sure if it is necessary tho...)
            % P0_d2w/w2d = [P1(shift in y-axis) P2(slope) P3(trans_start) P4(duration) wilting_point/field capacity(constraints) wilting_point/field capacity(constraints)]
            switch network(i)
                case "Oznet"
                    P0_d2w_insitu = [0     0.001   20   150  wp_insitu-0.1  fc_insitu+0.1];
                    P0_w2d_insitu = [0.5   -0.001  60   60   fc_insitu+0.1  wp_insitu-0.1];
                    P0_d2w_gldas = [0     0.001   20   150  wp_gldas-0.1  fc_gldas+0.1];
                    P0_w2d_gldas = [0.5   -0.001  60   60   fc_gldas+0.1  wp_gldas-0.1];
                case "USCRN"
                    P0_d2w_insitu = [0     0.001   10   100  0.4  0.7];
                    P0_w2d_insitu = [0.5   -0.001  10   100   0.7  0.4];
                    P0_d2w_gldas = [0     0.001   10   100  0.4  0.7];
                    P0_w2d_gldas = [0.5   -0.001  10   100   0.7  0.4];
                case "SCAN"
                    P0_d2w_insitu = [0     0.001   20   60  wp_insitu  fc_insitu];
                    P0_w2d_insitu = [0.5   -0.001  60   60   fc_insitu  wp_insitu];
                    P0_d2w_gldas = [0     0.001   20   150  wp_gldas  fc_gldas];
                    P0_w2d_gldas = [0.5   -0.001  60   60   fc_gldas  wp_gldas];
            end
            
            [seasontrans_date_insitu, seasontrans_duration_insitu] ...
            = sig_seasontrans(smtt(:,1), t_valley, P0_d2w_insitu, P0_w2d_insitu, plot_results, 'insitu');
            [seasontrans_date_gldas, seasontrans_duration_gldas] ...
            = sig_seasontrans(smtt(:,2), t_valley, P0_d2w_gldas, P0_w2d_gldas, plot_results, 'gldas');

            % Record the results 
            record_depth = [record_depth; repelem(depth(k), size(seasontrans_date_insitu,1), 1)];
            record_station = [record_station; repelem(n, size(seasontrans_date_insitu,1), 1)];
            record_date_insitu = [record_date_insitu; seasontrans_date_insitu];
            record_date_gldas = [record_date_gldas; seasontrans_date_gldas];
            record_duration_insitu = [record_duration_insitu; seasontrans_duration_insitu];
            record_duration_gldas = [record_duration_gldas; seasontrans_duration_gldas];
            
        end
        
        
    end
    
    % Save the results 
    varnames = {'depth', 'station', 'insitu', 'gldas'};

    output_path = fullfile("..\6_out_stat\temp", data_type, network(i));
    if ~exist(output_path, 'dir')
       mkdir(output_path)
    end

    if ~isempty(record_date_insitu)
        sdate_dry2wet = table(record_depth, record_station, record_date_insitu(:,1), record_date_gldas(:,1));
        sdate_dry2wet.Properties.VariableNames = varnames;
        writetable(sdate_dry2wet, fullfile(output_path, "seasontrans_sdate_dry2wet.csv"));

        edate_dry2wet = table(record_depth, record_station, record_date_insitu(:,2), record_date_gldas(:,2));
        edate_dry2wet.Properties.VariableNames = varnames;
        writetable(edate_dry2wet, fullfile(output_path, "seasontrans_edate_dry2wet.csv"));

        sdate_wet2dry = table(record_depth, record_station, record_date_insitu(:,3), record_date_gldas(:,3));
        sdate_wet2dry.Properties.VariableNames = varnames;
        writetable(sdate_wet2dry, fullfile(output_path, "seasontrans_sdate_wet2dry.csv"));

        edate_wet2dry = table(record_depth, record_station, record_date_insitu(:,4), record_date_gldas(:,4));
        edate_wet2dry.Properties.VariableNames = varnames;
        writetable(edate_wet2dry, fullfile(output_path, "seasontrans_edate_wet2dry.csv"));
    end
    
    if ~isempty(record_duration_insitu)
        duration_dry2wet = table(record_depth, record_station, record_duration_insitu(:,1), record_duration_gldas(:,1));
        duration_dry2wet.Properties.VariableNames = varnames;
        writetable(duration_dry2wet, fullfile(output_path, "seasontrans_duration_dry2wet.csv"));
        
        duration_wet2dry = table(record_depth, record_station, record_duration_insitu(:,2), record_duration_gldas(:,2));
        duration_wet2dry.Properties.VariableNames = varnames;
        writetable(duration_wet2dry, fullfile(output_path, "seasontrans_duration_wet2dry.csv"));
    end
    
    
%     figHandles = findall(0,'Type','figure');
%      
%      % Save first figure
%      fn = sprintf("plots_%s", network(i));
%      export_fig(fn, '-pdf', figHandles(1));
% 
%      % Loop through figures 2:end
%      for n_fig = 2:numel(figHandles)
%          export_fig(fn, '-pdf', figHandles(n_fig), '-append')
%      end

        
end


% load handel
% sound(y,Fs)

%% =========== END OF THE CODE ============

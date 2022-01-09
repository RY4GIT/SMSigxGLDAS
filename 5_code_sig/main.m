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

%% Main execution
for i = 1 %:length(network)
    % initiation
    record_depth = [];
    record_station = [];
    record_date_insitu = [];
    record_date_gldas = [];
    record_duration_insitu = [];
    record_duration_gldas = [];

    [depth, nstation, ~, ninsitu, fn0] = io_siteinfo(network(i));
    
    for k = 1 %:length(depth)
        
        %%
        % //////////////////////////////////////////////////
        % ////    1. Read comparing SM data /////////////
        % //////////////////////////////////////////////////
        
        % Read data 
        fn = fullfile(in_path, network(i), "combined", fn0(k));
        fid = fopen(fn, 'r');
        if depth(k) ~= 10
            % for sensorwise data
            smtt0 = textscan(fid,'%d %q %f %f','HeaderLines',1,'DateLocale','en_US','Delimiter',',');
        elseif i == 1
            % for watershed average data
            smtt0 = textscan(fid,'%q %f %f','HeaderLines',1,'DateLocale','en_US','Delimiter',',');
        else
            % for data in other formats
            smtt0 = textscan(fid,'%q %f %f','HeaderLines',1,'Delimiter',',');
        end
        fclose(fid);
        
        for n = 35 %1:ninsitu
            statement = sprintf('Currently processing the %s data (case %d, station %d)', network(i), k, n);
            disp(statement)
            
            % Read each station data 
            if depth(k) ~= 10
            % for sensorwise data
                n_rows = find(smtt0{1} == n);
                smtt_insitu = timetable(datetime(smtt0{2}),smtt0{3});
                smtt_insitu = smtt_insitu(n_rows,'Var1');
                smtt_gldas = timetable(datetime(smtt0{2}),smtt0{4});
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

            [fc, wp] = sig_fcwp(smtt.insitu, smtt(:,1), false);
            [seasontrans_date_insitu, seasontrans_duration_insitu] ...
            = sig_seasontrans(smtt(:,1), t_valley, wp, fc, true, 'insitu');
            [seasontrans_date_gldas, seasontrans_duration_gldas] ...
            = sig_seasontrans(smtt(:,2), t_valley, wp, fc, true, 'gldas');

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

    sdate_dry2wet = table(record_depth, record_station, record_date_insitu(:,1), record_date_gldas(:,1));
    sdate_dry2wet.Properties.VariableNames = varnames;
    writetable(sdate_dry2wet, fullfile("..\8_out_stat", network(i), "seasontrans_sdate_dry2wet.csv"));
    
    edate_dry2wet = table(record_depth, record_station, record_date_insitu(:,2), record_date_gldas(:,2));
    edate_dry2wet.Properties.VariableNames = varnames;
    writetable(edate_dry2wet, fullfile("..\8_out_stat", network(i), "seasontrans_edate_dry2wet.csv"));
    
    sdate_wet2dry = table(record_depth, record_station, record_date_insitu(:,3), record_date_gldas(:,3));
    sdate_wet2dry.Properties.VariableNames = varnames;
    writetable(sdate_wet2dry, fullfile("..\8_out_stat", network(i), "seasontrans_sdate_wet2dry.csv"));
    
    edate_wet2dry = table(record_depth, record_station, record_date_insitu(:,4), record_date_gldas(:,4));
    edate_wet2dry.Properties.VariableNames = varnames;
    writetable(edate_wet2dry, fullfile("..\8_out_stat", network(i), "seasontrans_edate_wet2dry.csv"));
    
    duration_dry2wet = table(record_depth, record_station, record_duration_insitu(:,1), record_duration_gldas(:,1));
    duration_dry2wet.Properties.VariableNames = varnames;
    writetable(duration_dry2wet, fullfile("..\8_out_stat", network(i), "seasontrans_duration_dry2wet.csv"));
    
    duration_wet2dry = table(record_depth, record_station, record_duration_insitu(:,2), record_duration_gldas(:,2));
    duration_wet2dry.Properties.VariableNames = varnames;
    writetable(duration_wet2dry, fullfile("..\8_out_stat", network(i), "seasontrans_duration_wet2dry.csv"));
    
end


load handel
sound(y,Fs)

%% =========== END OF THE CODE ============

%% Main module to calculate sine-curve signatures
% publish('main_gldas.m', 'doc')

% =========== BEGINNING OF THE CODE ============

%% Preparation
clear all;
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
        
        for n = 1 %:ninsitu
            statement = sprintf('Currently processing the %s data (case %d, insitu %d)', network(i), k, n);
            disp(statement)
            
            % Read each station data 
            % for sensorwise data
            if depth(k) ~= 10
                smtt_insitu = timetable(datetime(smtt0{2}),smtt0{3});
                smtt_gldas = timetable(datetime(smtt0{2}),smtt0{4});
            % for watershed average data
            else
                smtt_insitu = timetable(datetime(smtt0{1}),smtt0{2});
                smtt_gldas = timetable(datetime(smtt0{1}),smtt0{3});
            end

            % Detrend the data 
            [~, smtt_insitu_dtr] = util_detrend(smtt_insitu.Var1, smtt_insitu);
            [~, smtt_gldas_dtr] = util_detrend(smtt_gldas.Var1, smtt_gldas);
            
            % Combine both insitu and gldas data
            smtt = synchronize(smtt_insitu_dtr, smtt_gldas_dtr);
            smtt.Properties.VariableNames = {'insitu','gldas'};
            if isempty(smtt)
                continue
            end
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
            = sig_seasontrans2(smtt(:,1), t_valley, wp, fc, true);
%             [seasontrans_date_gldas, seasontrans_duration_gldas] ...
%             = sig_seasontrans2(smtt(:,2), t_valley, wp, fc, true);

            % Record the results 
            
            
 
        end
        
        
    end
end


% load handel
% sound(y,Fs)

%% =========== END OF THE CODE ============

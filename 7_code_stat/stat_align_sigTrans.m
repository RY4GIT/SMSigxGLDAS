function [sig] = stat_align_sigTrans(network, depth, nstation, sig_abb)
% publish('plot_seasonal_TS.m', 'doc')

% This script aligns seasonal transition signatures results of twi sets of data, GLDAS and insitu.

% Set path
in_path = fullfile("..\6_out_sig\", network);
out_path = fullfile("..\8_out_stat\", network);

obs = ["gldas";"insitu"];

% Initialize the struct
sig.network = [];sig.depth = [];sig.station = []; sig.type = []; sig.value = []; sig.WY = []; sig.value2 = [];
sig2.network = [];sig2.depth = [];sig2.station = []; sig2.type = []; sig2.value = []; sig2.WY = []; sig2.value2 = [];

% loop for signature type
for s = 1:size(sig_abb,1)
    disp(sig_abb(s))
    
    % loop for insitu & GLDAS
    for i = 1:size(obs,1)
        % read the signature data in a struct format
        fn = sprintf('%s_%s.txt', sig_abb(s), obs(i,:));
        fid = fopen(fullfile(in_path,fn),'r');
        sig0 = textscan(fid, '%f %d %s %d \n','HeaderLines',0, 'Delimiter',' ');
        fclose(fid);
        clear fn fid
        
        sig.network = [sig.network; repelem(string(obs(i,:)),1,length(sig0{1}))'];
        sig.depth = [sig.depth; sig0{1}];
        sig.station = [sig.station; sig0{2}];
        sig.type = [sig.type; repelem(sig_abb(s),1,length(sig0{1}))'];
        sig.value = [sig.value; sig0{3}];
        sig.WY = [sig.WY; sig0{4}];
        
        if s <= 8
            fn = sprintf('%s2_%s.txt', sig_abb(s), obs(i,:));
            fid = fopen(fullfile(in_path,fn),'r');
            sig02 = textscan(fid, '%d %d %s %d \n','HeaderLines',0, 'Delimiter',' ');
            fclose(fid);
            clear fn fid
            
            sig2.network = [sig2.network; repelem(string(obs(i,:)),1,length(sig02{1}))'];
            sig2.depth = [sig2.depth; sig02{1}];
            sig2.station = [sig2.station; sig02{2}];
            sig2.type = [sig2.type; repelem(sig_abb(s),1,length(sig02{1}))'];
            sig2.value = [sig2.value; sig02{3}];
            sig2.WY = [sig2.WY; sig02{4}];
        end
 
        clear sig0 sig02
    end
end

%% Align seasonal transition date signatures (date)
% Initialize the struct for seasonal transition timings
results_timing.depth = []; results_timing.station = []; results_timing.type = []; results_timing.oz = []; results_timing.gl = []; results_timing.residual = [];
% loop for the depth
for k = 1:size(depth,1)
    % loop for the station
    for n = 1:nstation
        %             fprintf('Currently processing the data at depth %d cm, station %d \n', depth(k), n);
        row1 = logical(sig.depth == depth(k));
        row2 = logical(sig.station == n);
        
        for s = 1:8
            row3_1 = logical(sig.network == obs(1)); % station
            row3_2 = logical(sig.network == obs(2)); % GLDAS
            row4 = logical(sig.type == sig_abb(s));
            
            for wy = 2000:2021
                row5 = logical(sig.WY == wy);
                
                row6 = row1&row2&row3_1&row4&row5;
                selected_sig_oz = sig.value(row6);
                clear row6
                
                row6 = row1&row2&row3_2&row4&row5;
                selected_sig_gl = sig.value(row6);
                clear row6
                
                if isempty(selected_sig_oz)
                    continue
                end
                
                if length(selected_sig_gl) == length(selected_sig_oz)
                    for s2 = 1:length(selected_sig_gl)
                        if char(selected_sig_gl(s2)) ~= "NaN " && char(selected_sig_gl(s2)) ~= "NaT " && char(selected_sig_oz(s2)) ~= "NaN " && char(selected_sig_oz(s2)) ~= "NaT "
                            % Take and record the residuals
                            % record the s2 to look for duration signatures
                            % if abs(datetime(selected_sig_gl(s2)) - datetime(selected_sig_oz(s2))) < month(2)
                            results_timing.depth = [results_timing.depth; depth(k)];
                            results_timing.station = [results_timing.station; n];
                            results_timing.type = [results_timing.type; sig_abb(s)];
                            results_timing.oz = [results_timing.oz; selected_sig_oz(s2)];
                            results_timing.gl = [results_timing.gl; selected_sig_gl(s2)];
                            results_timing.residual = [results_timing.residual; days(datetime(selected_sig_gl(s2)) - datetime(selected_sig_oz(s2)))];
                            % end
                        end
                    end
                end
            end
        end
    end
end

clear selected_sig_gl selected_sig_oz selected_sig_gl2 selected_sig_oz2

%% Align seasonal transition date signatures (deviation)
results_timing2.depth = []; results_timing2.station = []; results_timing2.type = []; results_timing2.oz = []; results_timing2.gl = []; results_timing2.residual = [];
% loop for the depth
for k = 1:size(depth,1)
    fprintf('Currently processing Trans Timing sig of the data at %s, depth %d cm \n', network, depth(k));
    % loop for the station
    for n = 1:nstation
        %             fprintf('Currently processing the data at depth %d cm, station %d \n', depth(k), n);
        row1 = logical(sig2.depth == depth(k));
        row2 = logical(sig2.station == n);
        
        for s = 1:8
            row3_1 = logical(sig2.network == obs(1)); % station
            row3_2 = logical(sig2.network == obs(2)); % gldas
            row4 = logical(sig2.type == sig_abb(s));
            
            for wy = 2001:2019
                row5 = logical(sig2.WY == wy);
                
                row6 = row1&row2&row3_1&row4&row5;
                selected_sig_oz = sig2.value(row6);
                clear row6
                
                row6 = row1&row2&row3_2&row4&row5;
                selected_sig_gl = sig2.value(row6);
                clear row6
                
                if isempty(selected_sig_oz)
                    continue
                end
                
                if length(selected_sig_gl) == length(selected_sig_oz)
                    for s2 = 1:length(selected_sig_gl)
                        if char(selected_sig_gl(s2)) ~= "NaN " && char(selected_sig_gl(s2)) ~= "NaT " && char(selected_sig_oz(s2)) ~= "NaN " && char(selected_sig_oz(s2)) ~= "NaT "
                            % Take and record the residuals
                            % record the s2 to look for duration signatures
                            % if abs(datetime(selected_sig_gl(s2)) - datetime(selected_sig_oz(s2))) < month(2)
                            results_timing2.depth = [results_timing2.depth; depth(k)];
                            results_timing2.station = [results_timing2.station; n];
                            results_timing2.type = [results_timing2.type; sig_abb(s)];
                            results_timing2.oz = [results_timing2.oz; str2double(cell2mat(selected_sig_oz(s2)))];
                            results_timing2.gl = [results_timing2.gl; str2double(cell2mat(selected_sig_gl(s2)))];
                            results_timing2.residual = [results_timing2.residual; str2double(cell2mat(selected_sig_gl(s2))) - str2double(cell2mat(selected_sig_oz(s2)))];
                            % end
                        end
                    end
                end
            end
        end
    end
end

%% Align for seasonal transition duration
results_duration.depth = []; results_duration.station = []; results_duration.type = []; results_duration.oz = []; results_duration.gl = []; results_duration.residual = [];
% loop for the depth
for k = 1:size(depth,1)
    % loop for the station
    fprintf('Currently processing Trans Duration sig of the data at %s, depth %d cm \n', network, depth(k));
    for n = 1:nstation
        %% Get corresponding signature values
        %     sig_abb2 = ["Wet end (p)"; "Wet end (l)"; ...
        %         "Dry start (p)"; "Dry start (l)"; ...
        %         "Dry end (p)"; "Dry end (l)"; ...
        %         "Wet start (p)"; "Wet start (l)"; ...
        %         "Wet to dry (p)"; "Wet to dry (l)"; ...
        %         "Dry to wet (p)"; "Dry to wet (l)"];
        
        
        % loop for seasonal transition date signatures
        
        row1 = logical(sig.depth == depth(k));
        row2 = logical(sig.station == n);
        
        for s4 = 9:12
            
            row3_1 = logical(sig.network == obs(1)); %station
            row4 = logical(sig.type == sig_abb(s4));
            row6 = row1&row2&row3_1&row4;
            selected_sig_oz = sig.value(row6);
            clear row3 row4 row5
            
            row3_1 = logical(sig.network == obs(2)); % gldas
            row4 = logical(sig.type == sig_abb(s4));
            row6 = row1&row2&row3_1&row4;
            selected_sig_gl = sig.value(row6);
            clear row3 row4 row5
            
            if length(selected_sig_gl) == length(selected_sig_oz)
                for s5 = 1:length(selected_sig_gl)
                    if char(selected_sig_gl(s5)) ~= "NaN " && char(selected_sig_oz(s5)) ~= "NaN "
                        results_duration.depth = [results_duration.depth; depth(k)];
                        results_duration.station = [results_duration.station; n];
                        results_duration.type = [results_duration.type; sig_abb(s4)];
                        results_duration.oz = [results_duration.oz; str2double(cell2mat(selected_sig_oz(s5)))];
                        results_duration.gl = [results_duration.gl;  str2double(cell2mat(selected_sig_gl(s5)))];
                        results_duration.residual = [results_duration.residual; str2double(cell2mat(selected_sig_gl(s5))) - str2double(cell2mat(selected_sig_oz(s5)))];
                    end
                end
            end
        end
        
        
    end
    
end

T1 = table(results_timing.depth, results_timing.station, results_timing.type, results_timing.oz, results_timing.gl, results_timing.residual, ...
    'VariableNames', {'depth','station','sig_type','insitu_date','GLDAS_date','residual_days'});
writetable(T1, fullfile(out_path, 'timing_date.csv'), 'Delimiter', ',');

T2 = table(results_timing2.depth, results_timing2.station, results_timing2.type, results_timing2.oz, results_timing2.gl, results_timing2.residual, ...
    'VariableNames', {'depth','station','sig_type','insitu_date','GLDAS_date','residual_days'});
writetable(T2, fullfile(out_path, 'timing_deviation.csv'), 'Delimiter', ',');

T3 = table(results_duration.depth, results_duration.station, results_duration.type, results_duration.oz, results_duration.gl, results_duration.residual, ...
    'VariableNames', {'depth','station','sig_type','insitu_days','GLDAS_days','residual_days'});
writetable(T3, fullfile(out_path, 'duration.csv'), 'Delimiter', ',');

end

% plot the times series of data

% if the depth/station has the GLDAS/insitu data,

% plot the seasonal transition timings (Piecewise)

% plot the seasonal transition timings (Logistic)


% if both GLDAS/insitu has the data, find the close wet/drying seasons (within 50days of error or something?) and take the residuals

% save them as output

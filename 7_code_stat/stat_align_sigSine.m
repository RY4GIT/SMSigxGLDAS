function [sig] = stat_align_sigSine(network, depth, nstation, sig_abb)
% publish('plot_seasonal_TS.m', 'doc')

% This script aligns seasonal transition signatures results of twi sets of data, GLDAS and insitu.

% Set path
in_path = fullfile("..\6_out_sig\", network);
out_path = fullfile("..\8_out_stat\", network);

obs = ["gldas";"insitu"];

% Initialize the struct
sig.network = [];sig.depth = [];sig.station = []; sig.type = []; sig.value = [];

% loop for signature type
for s = 1:size(sig_abb,1)
    % loop for insitu & GLDAS
    disp(sig_abb(s))
    for i = 1:size(obs,1)
        % read the signature data in a struct format
        fn = sprintf('%s_%s.txt', sig_abb(s), obs(i,:));
        fid = fopen(fullfile(in_path,fn),'r');
        sig0 = textscan(fid, '%f %d %f \n','HeaderLines',0, 'Delimiter',' ');
        fclose(fid);
        clear fn fid
        
        sig.network = [sig.network; repelem(string(obs(i,:)),1,length(sig0{1}))'];
        sig.depth = [sig.depth; sig0{1}];
        sig.station = [sig.station; sig0{2}];
        sig.type = [sig.type; repelem(sig_abb(s),1,length(sig0{1}))'];
        sig.value = [sig.value; sig0{3}];
        
        clear sig0 sig02
    end
end

%% Align amplitude
% Initialize the struct for seasonal transition timings
results.depth = []; results.station = []; results.type = []; results.insitu = []; results.gl = []; results.residual = [];
% loop for the depth
for k = 1:size(depth,1)
    fprintf('Currently processing Amplitude sig of the data at %s, depth %d cm \n', network, depth(k));
    % loop for the station
    for n = 1:nstation

        row1 = logical(sig.depth == depth(k));
        row2 = logical(sig.station == n);
        
        for s = 1:length(sig_abb)
            row3_1 = logical(sig.network == obs(1)); % station
            row3_2 = logical(sig.network == obs(2)); % GLDAS
            row4 = logical(sig.type == sig_abb(s));
            
            selected = row1&row2&row3_1&row4;
            selected_sig_insitu = sig.value(selected);
            clear selected
            
            selected = row1&row2&row3_2&row4;
            selected_sig_gl = sig.value(selected);
            clear selected
            
            if isempty(selected_sig_insitu)
                continue
            end
            
            if length(selected_sig_gl) == length(selected_sig_insitu)
                for s2 = 1:length(selected_sig_gl)
                    if char(selected_sig_gl(s2)) ~= "NaN " && char(selected_sig_gl(s2)) ~= "NaT " && char(selected_sig_insitu(s2)) ~= "NaN " && char(selected_sig_insitu(s2)) ~= "NaT "
                        % Take and record the residuals
                        % record the s2 to look for duration signatures
                        % if abs(datetime(selected_sig_gl(s2)) - datetime(selected_sig_insitu(s2))) < month(2)
                        results.depth = [results.depth; depth(k)];
                        results.station = [results.station; n];
                        results.type = [results.type; sig_abb(s)];
                        results.insitu = [results.insitu; selected_sig_insitu(s2)];
                        results.gl = [results.gl; selected_sig_gl(s2)];
                        results.residual = [results.residual; selected_sig_gl(s2) - selected_sig_insitu(s2)];
                        % end
                    end
                end
            end
        end
    end
end

clear selected_sig_gl selected_sig_insitu selected_sig_gl2 selected_sig_insitu2

T1 = table(results.depth, results.station, results.type, results.insitu, results.gl, results.residual, ...
    'VariableNames', {'depth','station','sig_type','insitu_date','GLDAS_date','residual_days'});
writetable(T1, fullfile(out_path, 'sine_amplitude.csv'), 'Delimiter', ',');


end


function [sig] = stat_align2(site, depth, nstation, sig_abb, sig_abb2)
% publish('plot_seasonal_TS.m', 'doc')

% This script aligns seasonal transition signatures results of twi sets of data, GLDAS and Oznet. 

  % Set path
   cd("G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\3_codes_plotters");
   in_path = "..\2_out";
   out_path = "..\4_out\stats";

    % Initialize the struct
    sig.network = [];sig.depth = [];sig.station = []; sig.type = []; sig.value = []; 

    % loop for signature type
    for s = 1:size(sig_abb,1)
        % loop for Oznet & GLDAS
        disp(sig_abb(s))
        for i = 1:size(site,1)
            % read the signature data in a struct format
            fn = sprintf('%s_%s.txt', sig_abb(s), site(i,:));
            fid = fopen(fullfile(in_path,fn),'r');
            disp(fid);
            sig0 = textscan(fid, '%d %d %f \n','HeaderLines',0, 'Delimiter',' ');
            fclose(fid);
            clear fn fid
            
            sig.network = [sig.network; repelem(string(site(i,:)),1,length(sig0{1}))'];
            sig.depth = [sig.depth; sig0{1}];
            sig.station = [sig.station; sig0{2}];
            sig.type = [sig.type; repelem(sig_abb2(s),1,length(sig0{1}))'];
            sig.value = [sig.value; sig0{3}];
            
            clear sig0 sig02
        end
    end

%% Align amplitude
% Initialize the struct for seasonal transition timings
results.depth = []; results.station = []; results.type = []; results.oz = []; results.gl = []; results.residual = [];
    % loop for the depth
    for k = 1:size(depth,1)
    % loop for the station
        for n = 1:nstation 
%             fprintf('Currently processing the data at depth %d cm, station %d \n', depth(k), n);    
            row1 = logical(sig.depth == depth(k));
            row2 = logical(sig.station == n);

            for s = 1:length(sig_abb)
                row3_1 = logical(sig.network == site(1)); % station
                row3_2 = logical(sig.network == site(2)); % GLDAS
                row4 = logical(sig.type == sig_abb2(s));
                
                selected = row1&row2&row3_1&row4;
                selected_sig_oz = sig.value(selected);
                clear selected

                selected = row1&row2&row3_2&row4;
                selected_sig_gl = sig.value(selected);
                clear selected

                if isempty(selected_sig_oz)
                    continue
                end

                if length(selected_sig_gl) == length(selected_sig_oz)
                    for s2 = 1:length(selected_sig_gl)
                        if char(selected_sig_gl(s2)) ~= "NaN " && char(selected_sig_gl(s2)) ~= "NaT " && char(selected_sig_oz(s2)) ~= "NaN " && char(selected_sig_oz(s2)) ~= "NaT "
                            % Take and record the residuals
                            % record the s2 to look for duration signatures
                            % if abs(datetime(selected_sig_gl(s2)) - datetime(selected_sig_oz(s2))) < month(2)
                                results.depth = [results.depth; depth(k)];
                                results.station = [results.station; n];
                                results.type = [results.type; sig_abb2(s)];
                                results.oz = [results.oz; selected_sig_oz(s2)];
                                results.gl = [results.gl; selected_sig_gl(s2)]; 
                                results.residual = [results.residual; selected_sig_gl(s2) - selected_sig_oz(s2)];
                            % end
                        end
                    end
                end
             end
        end
    end
            
clear selected_sig_gl selected_sig_oz selected_sig_gl2 selected_sig_oz2
     

T1 = table(results.depth, results.station, results.type, results.oz, results.gl, results.residual, ...
    'VariableNames', {'depth','station','sig_type','Oznet_date','GLDAS_date','residual_days'});  
writetable(T1, fullfile(out_path, 'sine_amplitude.csv'), 'Delimiter', ',');

    
end
       

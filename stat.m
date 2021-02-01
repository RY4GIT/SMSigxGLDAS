% publish('plot_seasonal_TS.m', 'doc')

% This script aligns seasonal transition signatures results of twi sets of data, GLDAS and Oznet. 

    % Set path
  %  in_path = "G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\0_data\";
   out_path = "G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\5_out";
   cd("G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\3_codes_plotters");

    % Site information
    site = ["Oznet";"GLDAS"];
    depth = [3,4,15]; 
    nstation = 38;
    
    % read the format for the plots  
    sig_abb = ["seasontrans_sdate_wet2dry_p"; "seasontrans_sdate_wet2dry_l"; ...
        "seasontrans_edate_wet2dry_p"; "seasontrans_edate_wet2dry_l"; ...
        "seasontrans_sdate_dry2wet_p"; "seasontrans_sdate_dry2wet_l"; ...
        "seasontrans_edate_dry2wet_p"; "seasontrans_edate_dry2wet_l"; ...
        "seasontrans_duration_wet2dry_p"; "seasontrans_duration_wet2dry_l"; ...
        "seasontrans_duration_dry2wet_p"; "seasontrans_duration_dry2wet_l"];
    
    sig_abb2 = ["Wet end (p)"; "Wet end (l)"; ...
        "Dry start (p)"; "Dry start (l)"; ...
        "Dry end (p)"; "Dry end (l)"; ...
        "Wet start (p)"; "Wet start (l)"; ...
        "Wet to dry (p)"; "Wet to dry (l)"; ...
        "Dry to wet (p)"; "Dry to wet (l)"];
    
    % Initialize the struct
    sig.network = [];sig.depth = [];sig.station = []; sig.type = []; sig.value = [];

    % loop for signature type
    for s = 1:size(sig_abb,1)
        % loop for Oznet & GLDAS
        for i = 1:size(site,1)
            % read the signature data in a struct format
            fn = sprintf('%s_%s.txt', sig_abb(s), site(i,:));
            fid = fopen(fullfile('G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\2_out',fn),'r')
            sig0 = textscan(fid, '%d %d %s \n','HeaderLines',0, 'Delimiter',',');
            fclose(fid);

            sig.network = [sig.network; repelem(string(site(i,:)),1,length(sig0{1}))'];
            sig.depth = [sig.depth; sig0{1}];
            sig.station = [sig.station; sig0{2}];
            sig.type = [sig.type; repelem(sig_abb2(s),1,length(sig0{1}))'];
            sig.value = [sig.value; sig0{3}];
            
            clear fn
        end
    end

% Align all the reuslts

% Initialize the struct for seasonal transition timings
results_timing.depth = []; results_timing.station = []; results_timing.type = []; results_timing.oz = []; results_timing.gl = []; results_timing.residual = [];
    % loop for the depth
    for k = 1:size(depth,2)
    % loop for the station
        for n = 1:nstation 
            statement = sprintf('Currently processing the data at depth %d cm, station %d', depth(k), n);
            disp(statement)
            
            %% Get corresponding signature values
%     sig_abb2 = ["Wet end (p)"; "Wet end (l)"; ...
%         "Dry start (p)"; "Dry start (l)"; ...
%         "Dry end (p)"; "Dry end (l)"; ...
%         "Wet start (p)"; "Wet start (l)"; ...
%         "Wet to dry (p)"; "Wet to dry (l)"; ...
%         "Dry to wet (p)"; "Dry to wet (l)"];
            % Oznet
%             s3 = [];
            
            % loop for seasonal transition date signatures 
            
            row1 = logical(sig.depth == depth(k));
            row2 = logical(sig.station == n);

            for s = 1:8
                row3 = logical(sig.network == "Oznet");
                row4 = logical(sig.type == sig_abb2(s));
                row5 = row1&row2&row3&row4;
                selected_sig_oz = sig.value(row5);
                clear row3 row4 row5
                
                row3 = logical(sig.network == "GLDAS");
                row4 = logical(sig.type == sig_abb2(s));
                row5 = row1&row2&row3&row4;
                selected_sig_gl = sig.value(row5);
                clear row3 row4 row5
                
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
                                results_timing.type = [results_timing.type; sig_abb2(s)];
                                results_timing.oz = [results_timing.oz; selected_sig_oz(s2)];
                                results_timing.gl = [results_timing.gl; selected_sig_gl(s2)]; 
                                results_timing.residual = [results_timing.residual; days(datetime(selected_sig_gl(s2)) - datetime(selected_sig_oz(s2)))];
%                                 s3 = [s3;s2];
                            % end
                        end
                    end
                end
            end
        end
    end
            
                clear selected_sig_gl selected_sig_oz
                

% Initialize the struct for seasonal transition duration
results_duration.depth = []; results_duration.station = []; results_duration.type = []; results_duration.oz = []; results_duration.gl = []; results_duration.residual = [];
    % loop for the depth
    for k = 1:size(depth,2)
    % loop for the station
        for n = 1:nstation 
            statement = sprintf('Currently processing the data at depth %d cm, station %d', depth(k), n);
            disp(statement)
            
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
                
                    row3 = logical(sig.network == "Oznet");
                    row4 = logical(sig.type == sig_abb2(s4));
                    row5 = row1&row2&row3&row4;
                    selected_sig_oz = sig.value(row5);
                    clear row3 row4 row5

                    row3 = logical(sig.network == "GLDAS");
                    row4 = logical(sig.type == sig_abb2(s4));
                    row5 = row1&row2&row3&row4;
                    selected_sig_gl = sig.value(row5);
                    clear row3 row4 row5
                    
                    if length(selected_sig_gl) == length(selected_sig_oz)
                          for s5 = 1:length(selected_sig_gl)
                               if char(selected_sig_gl(s5)) ~= "NaN " && char(selected_sig_oz(s5)) ~= "NaN "
                                    results_duration.depth = [results_duration.depth; depth(k)];
                                    results_duration.station = [results_duration.station; n];
                                    results_duration.type = [results_duration.type; sig_abb2(s4)];
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
        'VariableNames', {'depth','station','sig_type','Oznet_date','GLDAS_date','residual_days'});  
    writetable(T1, fullfile(out_path, 'timing.csv'), 'Delimiter', ',');
    
    T2 = table(results_duration.depth, results_duration.station, results_duration.type, results_duration.oz, results_duration.gl, results_duration.residual, ...
        'VariableNames', {'depth','station','sig_type','Oznet_days','GLDAS_days','residual_days'});  
    writetable(T2, fullfile(out_path, 'duration.csv'), 'Delimiter', ',');
    
        
         % plot the times series of data

         % if the depth/station has the GLDAS/Oznet data, 

             % plot the seasonal transition timings (Piecewise)

             % plot the seasonal transition timings (Logistic)


     % if both GLDAS/Oznet has the data, find the close wet/drying seasons (within 50days of error or something?) and take the residuals

     % save them as output

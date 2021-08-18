function [] = stat_pl_count(site, depth, nstation, sig_abb, sig_abb2)

    % This script calculates stats for seasonal transition signatures results of twi sets of data, GLDAS and Oznet. 

    %% Preparation 
    % set path
    cd("G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\3_codes_plotters");

    in_path = "..\4_out\stats";
    out_path = "..\4_out\comparison_PL";
    
    % read data 
    dataT = readtable(fullfile(in_path, 'timing_deviation.csv'), 'Delimiter', ',');
   
    % initialize
    result = nan(4,6);
    
    % calculate how much it was successful / unsuccessful
    for k = 1:length(depth)
        for s = [5 6 1 2] % s=5and6 for dry-to-wet, s=1and2 for wet-to-dry. s=5and1 for piecewise, 6 and 2 for logistic
            selected = (dataT.depth == depth(k)) & (dataT.sig_type == sig_abb(s));
            oz_success = sum(~isnan(dataT.Oznet_date(selected))) / length(dataT.Oznet_date(selected)) * 100;
            gl_success = sum(~isnan(dataT.GLDAS_date(selected))) / length(dataT.GLDAS_date(selected)) * 100;
            
            if s == 5 || s == 6
                offset_dw = 0;
            elseif s == 1 || s == 2
                offset_dw = 1;
            end
            if s == 5 || s == 1
                offset_pl = 0;
            elseif s == 6 || s == 2
                offset_pl = 2;
            end
            offset_de = 2*(k-1);
            
            result(offset_pl+1,1+offset_dw+offset_de) = oz_success;
            result(offset_pl+2,1+offset_dw+offset_de) = gl_success;
            
        end
    end
    
%     T = table(result, ...
%         'VariableNames', {'depth','station','sig_type','Oznet_dates','GLDAS_dates','residual_dates'});  
    writematrix(result, fullfile(out_path, 'success_count.csv'), 'Delimiter', ',');

function [] = stat_r2_count()

% This script calculates stats for seasonal transition signatures results of twi sets of data, GLDAS and Oznet.

%% Preparation
% set path
cd("G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\3_codes_plotters");

in_path = "..\2_out\";
out_path = "..\4_out\comparison_R2";

% site information
site = ["station";"gldas"];
depth = [3;4;10];

% signature information
trans_season = ["dry2wet";"wet2dry"];
trans_method = ["p";"l"];

% initialize
result = nan(4,6);

% calculate how much it was successful / unsuccessful
for ts = 1:length(trans_season)
    for tm = 1:length(trans_method)
        for k = 1:length(depth)
            % read the signature data
            fn = sprintf('performance_%s_%s_station.txt', trans_season(ts), trans_method(tm));
            fid = fopen(fullfile(in_path,fn),'r');
            disp(fid);
            data_oz = textscan(fid, '%d %d %f %f \n','HeaderLines',0, 'Delimiter',' ');
            fclose(fid);
            clear fn fid
            
            fn = sprintf('performance_%s_%s_gldas.txt', trans_season(ts), trans_method(tm));
            fid = fopen(fullfile(in_path,fn),'r');
            disp(fid);
            data_gl = textscan(fid, '%d %d %f %f \n','HeaderLines',0, 'Delimiter',' ');
            fclose(fid);
            clear fn fid

            % Calculate R2
            selected = (data_oz{1} == depth(k));
            squaredMiOi_oz = data_oz{3};
            n_oz = data_oz{4};
            oz_r2 = sum(squaredMiOi_oz(selected),'omitnan') / sum(n_oz(selected),'omitnan');
            
            selected = (data_gl{1} == depth(k));
            squaredMiOi_gl = data_gl{3};
            n_gl = data_gl{4};
            gl_r2 = sum(squaredMiOi_gl(selected),'omitnan') / sum(n_gl(selected),'omitnan');

            if trans_season(ts) == "dry2wet"
                offset_dw = 0;
            elseif trans_season(ts) == "wet2dry"
                offset_dw = 1;
            end
            if trans_method(tm) == "p"
                offset_pl = 0;
            elseif trans_method(tm) == "l"
                offset_pl = 2;
            end
            offset_de = 2*(k-1);
            
            result(offset_pl+1,1+offset_dw+offset_de) = oz_r2;
            result(offset_pl+2,1+offset_dw+offset_de) = gl_r2;
            
        end
    end
end

writematrix(result, fullfile(out_path, 'success_r2.csv'), 'Delimiter', ',');

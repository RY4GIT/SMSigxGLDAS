%% Main module to calculate sine-curve signatures 
% publish('main_gldas.m', 'doc')

% =========== BEGINNING OF THE CODE ============

clear all;
slCharacterEncoding('UTF-8');

%% Preparation
% Select the module you want to run ...
save_results = true; % if you want to clear the previous results and save new results

% Set path
cd("G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\1_codes");
in_path = "G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\0_data\";
out_path = "G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\2_out\";

% Site information
obs = ["gldas";"station"];
depth = [3; 4; 10];

%% Main execution
     
for j = 1:size(obs,1)
    % create/read new file for recording results
    fn1 = sprintf('amplitude_%s.txt', obs(j,:));
    fn2 = sprintf('phaseshift_%s.txt', obs(j,:));

    % delete existing files
    if save_results
        delete(fullfile(out_path,fn1));delete(fullfile(out_path,fn2));
    end
        
    for k = 1:3 %size(depth,2)
        % case 1: station 3cm vs. gldas 0_10cm, point-to-pixel comparison
        % case 2: station 4cm vs. gldas 0_10cm, point-to-pixel comparison
        % case 3: station basin average vs. gldas basin average

        switch k
            case 1
                nstation = 38;
                fn0 = 'depth_3cm.csv'; % name of the input file name
            case 2
                nstation = 38;
                fn0 = 'depth_4cm.csv';
            case 3
                nstation = 1;
                fn0 = 'depth_0_10cm.csv';
        end

        % Read SM data    
        fn = fullfile(in_path, "GLDAS", fn0);
        fid = fopen(fn, 'r');
        if k == 1 || k == 2
            smtt0 = textscan(fid,'%d %q %f %f','HeaderLines',1,'DateLocale','en_US','Delimiter',',');
        else
            smtt0 = textscan(fid,'%q %f %f','HeaderLines',1,'DateLocale','en_US','Delimiter',',');
        end
        fclose(fid);

        for n = 1:nstation

            statement = sprintf('Currently processing the %s data (case %d, station %d)', obs(j,:), k, n);
            disp(statement)


            if k == 1 || k == 2
                n_rows = find(smtt0{1} == n);
                if obs(j) == "station"
                    smtt1 = timetable(datetime(smtt0{2}),smtt0{3});
                elseif obs(j) == "gldas"
                    smtt1 = timetable(datetime(smtt0{2}),smtt0{4});
                end
                smtt = smtt1(n_rows,'Var1');
            else
                if obs(j) == "station"
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

            % figure; plot(smtt.Time, sm)

            %% Calculate the signatures
            t_datetime = smtt.Properties.RowTimes;
            t_datenum = datenum(smtt.Properties.RowTimes);

            %% get sine curve
            w = 2*pi/365;
            [A, phi, k2] = util_FitSineCurve(t_datenum, sm, w);

            %% save the results
            if save_results

                fid = fopen(fullfile(out_path,fn1),'a');
                    fprintf(fid, '%d %d %f \n', depth(k), n, A);
                fclose(fid); clear fid;

                fid = fopen(fullfile(out_path,fn2),'a');
                    fprintf(fid, '%d %d %f \n', depth(k), n, phi);
                fclose(fid); clear fid;
            end

        end
    end      
end 

load handel
sound(y,Fs)

%% =========== END OF THE CODE ============

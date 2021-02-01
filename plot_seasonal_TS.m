% publish('plot_seasonal_TS.m', 'doc')

    % Set path
  %  in_path = "G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\0_data\";
   % out_path = "G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\2_out\";

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

    for s = 1:size(sig_abb,1)
        for i = 1:size(site,1)
            % read the signature data in a struct format
            fn = sprintf('%s_%s.txt', sig_abb(s), site(i,:));
            fid = fopen(fullfile('G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\2_out',fn),'r')
            if s <= 8
                sig0 = textscan(fid, '%d %d %s \n','HeaderLines',0, 'Delimiter',',');
            else
                sig0 = textscan(fid, '%d %d %f \n','HeaderLines',0, 'Delimiter',',');
            end
            fclose(fid);

            sig.network = [sig.network; repelem(string(site(i,:)),1,length(sig0{1}))'];
            sig.depth = [sig.depth; sig0{1}];
            sig.station = [sig.station; sig0{2}];
            sig.type = [sig.type; repelem(sig_abb2(s),1,length(sig0{1}))'];
            sig.value = [sig.value; sig0{3}];
            
            clear sig0
            clear fn
        end
    end

    % loop for the depth
    for k = 1:size(depth,2)
    % loop for the station
        for n = 1:nstation 
            statement = sprintf('Currently processing the data at depth %d cm, station %d', depth(k), n);
            disp(statement)
            
            %% read the time series of data 
            %  Oznet
            fn0 = sprintf('sm_d%02d_s%02d.csv', depth(k), n);
            fn = fullfile('G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\0_data\', "Oznet", fn0);
            
            if exist(fn, 'file') == 2
                fid = fopen(fn, 'r');
                smtt0 = textscan(fid,'%q %f','HeaderLines',1,'DateLocale','en_US','Delimiter',',');
                smtt_oz = timetable(datetime(smtt0{1}),smtt0{2});
                fclose(fid);
                if isempty(smtt_oz)
                    continue
                end
                sm_oz = smtt_oz.Var1;
                clear smtt0 smtt1 fn0 fn
            end

            % GLDAS
            fn0 = sprintf('depth_%dcm.csv', depth(k));
            fn = fullfile('G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\0_data\', "GLDAS", fn0);
            if exist(fn, 'file') == 2
                fid = fopen(fn, 'r');
                smtt0 = textscan(fid,'%d %q %f','HeaderLines',1,'DateLocale','en_US','Delimiter',',');
                n_rows = find(smtt0{1} == n);
                smttl = timetable(datetime(smtt0{2}),smtt0{3});
                fclose(fid);
                smtt1 = timetable(datetime(smtt0{2}),smtt0{3});      
                smtt_gl = smtt1(n_rows,'Var1');
                if isempty(smtt_gl)
                    continue
                end
                smtt_gl = sortrows(smtt_gl, 'Time');
                smtt_gl = retime(smtt_gl, 'regular', 'linear', 'TimeStep', hours(1));
                sm_gl = smtt_gl.Var1;
                clear smtt0 smtt1 fn0 fn
            end
            
            %% Get corresponding signature values
%     sig_abb2 = ["Wet end (p)"; "Wet end (l)"; ...
%         "Dry start (p)"; "Dry start (l)"; ...
%         "Dry end (p)"; "Dry end (l)"; ...
%         "Wet start (p)"; "Wet start (l)"; ...
%         "Wet to dry (p)"; "Wet to dry (l)"; ...
%         "Dry to wet (p)"; "Dry to wet (l)"];
            % Oznet
            
            xline_format = ["--r"; "-r"; ...
                "--r"; "-r"; ...
                "--b"; "-b"; ...
                "--b"; "-b"];
            
            %% plot the time series of data
            figure;
            % Oznet
            subplot(2,1,1);
            plot(smtt_oz.Time, smtt_oz.Var1);hold on;
            titlename = sprintf("Oznet (depth %d cm, station %d)", depth(k), n);
            title(titlename);
                        
            row1 = logical(sig.depth == depth(k));
            row2 = logical(sig.station == n);
            row3 = logical(sig.network == "Oznet");
            
            for s = [1,3,5,7]
                row4 = logical(sig.type == sig_abb2(s));
                row5 = row1&row2&row3&row4;
                selected_sig = sig.value(row5);
                clear row4 row5
                if ~isempty(selected_sig)
                    for i2 = 1:length(selected_sig)
                        if char(selected_sig(i2)) ~= "NaN " && char(selected_sig(i2)) ~= "NaT " 
                            x1 = datetime(selected_sig(i2));
                            xline(x1,xline_format(s));hold on;
                        end
                    end
                end
            end
            
            for s = [2,4,6,8]
                row4 = logical(sig.type == sig_abb2(s));
                row5 = row1&row2&row3&row4;
                selected_sig = sig.value(row5);
                clear row4 row5
                if ~isempty(selected_sig)
                    for i2 = 1:length(selected_sig)
                        if char(selected_sig(i2)) ~= "NaN " && char(selected_sig(i2)) ~= "NaT " 
                            x1 = datetime(selected_sig(i2));
                            xline(x1,xline_format(s));hold on;
                        end
                    end
                end
            end
            
            hold off;
            
            % GLDAS
            clear row3
            row3 = logical(sig.network == "GLDAS");
                        
            subplot(2,1,2);
            plot(smtt_gl.Time, smtt_gl.Var1)
            titlename = sprintf("GLDAS (depth %d cm, station %d)", depth(k), n);
            title(titlename);
            
            for s = [1,3,5,7]
                row4 = logical(sig.type == sig_abb2(s));
                row5 = row1&row2&row3&row4;
                selected_sig = sig.value(row5);
                clear row4 row5
                if ~isempty(selected_sig)
                    for i2 = 1:length(selected_sig)
                        if char(selected_sig(i2)) ~= "NaN " && char(selected_sig(i2)) ~= "NaT " 
                            x1 = datetime(selected_sig(i2));
                            xline(x1,xline_format(s));hold on;
                        end
                    end
                end
            end
            
            for s = [2,4,6,8]
                row4 = logical(sig.type == sig_abb2(s));
                row5 = row1&row2&row3&row4;
                selected_sig = sig.value(row5);
                clear row4 row5
                if ~isempty(selected_sig)
                    for i2 = 1:length(selected_sig)
                        if char(selected_sig(i2)) ~= "NaN " && char(selected_sig(i2)) ~= "NaT " 
                            x1 = datetime(selected_sig(i2));
                            xline(x1,xline_format(s));hold on;
                        end
                    end
                end
            end
            
            hold off;
            
        end

         % plot the times series of data

         % if the depth/station has the GLDAS/Oznet data, 

             % plot the seasonal transition timings (Piecewise)

             % plot the seasonal transition timings (Logistic)
    end

     % if both GLDAS/Oznet has the data, find the close wet/drying seasons (within 50days of error or something?) and take the residuals

     % save them as output

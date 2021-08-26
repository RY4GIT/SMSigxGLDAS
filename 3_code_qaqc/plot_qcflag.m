% preparation
in_path = "G:\Shared drives\Ryoko and Hilary\GLDAS\2_data_selected";
network = ["SCAN";"USCRN"];
qf_meta = readtable("G:\Shared drives\Ryoko and Hilary\GLDAS\2_data_selected\quality_flag.xlsx");
qf_code = string(qf_meta.Flag);
qf_color = string(qf_meta.Color);

% read data
for i = 1:length(network)
    
    list = dir(fullfile(in_path, network(i)));
    
    % initialize
    start_date = datetime(2021,8,1);
    end_date = datetime(1999,1,1);
    
    for j = 1:length(list)
        filename = fullfile(list(j).folder, list(j).name);
        
        
        % get the oldest & newest record day for the network
        T = readtable(filename);
        if T.date_time(1) < start_date
            start_date = T.date_time(1);
        end
        if T.date_time(end) > end_date
            end_date = T.date_time(end);
        end
        
        % plot out for quality flags
        flags = string(T.soil_moisture_flag);
        flagvalues = unique(flags);
        
        for k = 1:length(qf_code)-1
            figure(j)
            set(gcf, 'Position', [100 100 1200 600])
            flagTF = contains(flags, qf_code(k));
            sm_masked = T.soil_moisture .* flagTF;
            sm_masked(sm_masked == 0) = nan;
            
            hex = char(qf_color(k));
            rgb = hex2rgb(hex);
            
            plot(T.date_time, sm_masked, 'DisplayName', qf_code(k), 'Color', rgb);
            hold on;
        end
        
        title(sprintf('%s - %s',network(i),list(j).name));
        legend('Location', 'eastoutside');
        savefig(fullfile(in_path, network(i),strrep(list(j).name, 'csv','fig')))
        
        get the newest and oldest record
        
    end
  
fprintf('The start and the end date of the record for %s is \n %s \n %s \n', network(i), start_date, end_date)
  
end

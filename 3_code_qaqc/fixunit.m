in_path = "G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\4_data\";
network = ["SCAN";"USCRN"];

for i = 1:length(network)
    % get all files 
    list = dir(fullfile(in_path, network(i)));
    
    for j = 1:length(list)
        fn = fullfile(list(j).folder, list(j).name);
        
        if contains(fn, 'sm') && contains(fn, '.csv')

            % read the data 
            fid = fopen(fn,'r');
            data = textscan(fid,'%D %f','HeaderLines',1,'Delimiter',',');
            time = data{1};
            sm = data{2};
            fclose(fid);

            % percent to VWC
            sm = sm./100;
            smTT = timetable(time,sm);

            % save
            writetimetable(smTT, fn);
            disp(fn);
        
        end
        
    end
end
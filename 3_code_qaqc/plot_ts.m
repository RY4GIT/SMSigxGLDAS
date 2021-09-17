in_path = "G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\4_data\";
network = ["SCAN";"USCRN"];

for i = 1 %1:length(network)
    % get all files 
    list = dir(fullfile(in_path, network(i)));
    infn{1,1} = [];
    
    n = 0;
    
    for j = 1:length(list)
        fn = fullfile(list(j).folder, list(j).name);
        
        if contains(fn, 'sm') && contains(fn, '.csv')
            n = n+1;

            % open the data
            fid = fopen(fn,'r');
            data = textscan(fid,'%D %f','HeaderLines',1,'Delimiter',',');
            time = data{1};
            sm = data{2};
            fclose(fid);
            
            % plot the data
            figure;
            set(gcf, 'Position', [100 100 600 400])
            plot(time, sm);
            ylabel('VSWC (m^3/m^3)');
            xlabel('time');
            ylim([0 1]);
            title(list(j).name);
            
            % save
            fnout = strrep(list(j).name, 'csv', 'pdf');
            exportgraphics(gcf, fullfile(in_path, network(i), 'plot', fnout));
            close all;
            infn{1,n} = fullfile(in_path, network(i), 'plot', fnout);
        end
        
    end

    append_pdfs(fullfile(in_path, network(i), 'plot', 'summary_ts.pdf'), infn);
    
end
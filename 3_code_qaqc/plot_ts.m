in_path = "G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\4_data\";
addpath("G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\5_code_sig");
% network =["Oznet"];
network = ["USCRN"];

for i = 1 %1:length(network)
    % get all files 
    list = dir(fullfile(in_path, network(i),"insitu"));
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
            
            % get the sine curve
            % Get sine curve information from insitu data
            t_datenum = datenum(time);
            w = 2*pi/365;
            [A, phi, k] = util_FitSineCurve(t_datenum, sm, w);
            
            % plot the data
            sm_mov = movmean(sm, 365, 'omitnan');
            figure;
            set(gcf, 'Position', [100 100 600 400])
            plot(time, sm);
            ylabel('VSWC (m^3/m^3)');
            xlabel('time');
            ylim([0 1]);
            title(list(j).name); hold on;
            
            % plot the sine curve
            y_hat = 5*A*sin(w*t_datenum + phi) + k;
            plot(time,y_hat, 'LineWidth', 2)
            
            % Save
            fnout = strrep(list(j).name, 'csv', 'pdf');
            exportgraphics(gcf, fullfile(in_path, network(i), 'insitu', 'plot', fnout));
            close all;
            infn{1,n} = fullfile(in_path, network(i), 'insitu',  'plot', fnout);
        end
        
    end

    % append_pdfs(fullfile(in_path, network(i), 'insitu',  'plot', 'summary_ts.pdf'), infn);
    
end
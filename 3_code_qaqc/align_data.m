% Align data for USCRN and SCAN (Oznet was already alighned by Effrain)

network = ["USCRN"; "SCAN"];

in_path = "G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\4_data\";
out_path = "G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\4_data\";

for i = 1:length(network)
% read data 
    % GLDAS      
    T = readtable(fullfile(in_path, network(i), "GLDAS", sprintf("%s.csv", network(i)))); 
    date = strrep(T.date, 'T', ' ');
    TT = timetable(datetime(date,'InputFormat','yyyy-MM-dd HH:mm:SS'), ...
        T.sid, T.sm);
    TT.Properties.VariableNames = {'ID'  'gldas'};
    TT.Properties.DimensionNames = {'date'  'Variables'};
    
    % in-situ
    
% synchronize and concatinate? 

% save data
end
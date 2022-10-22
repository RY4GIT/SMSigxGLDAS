% =========== BEGINNING OF THE CODE ============

clear all;
slCharacterEncoding('UTF-8');

%% Preparation
% Set path
cd("G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\3_code_qaqc\");
in_path = "G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\4_data\";
out_path = "G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\4_data\";

% Site information
network = ["Oznet"];

for i = 1:length(network)
    % read data
    fn = fullfile(in_path, network(i), "combined", "OZNET_alldepth_arid.csv");
    fid = fopen(fn, 'r');
    smtt0 = textscan(fid,'%d %q %f %f','HeaderLines',1,'DateLocale','en_US','Delimiter',',');
    fclose(fid);
    
    smtt = timetable(datetime(smtt0{2}), smtt0{1}, smtt0{3}, smtt0{4});
    smtt.Properties.VariableNames =  [{'sid'} {'insitu'} {'gldas'}];
    
    % iterate through dates
    switch network(i)
        case "SCAN"
            sdate = datetime(2000,1,1,0,0,0);
            edate = datetime(2020,2,29,0,0,0);
        case "USCRN"
            sdate = datetime(2009,7,31,0,0,0);
            edate = datetime(2020,2,29,0,0,0);
        case "Oznet"
            sdate = datetime(2001,9,27,0,0,0);
            edate = datetime(2020,2,29,0,0,0);
    end
    Time = [sdate:hours(24):edate]';
    smtt_avg = timetable(Time, nan(length(Time),1), nan(length(Time),1));
    smtt_avg.Properties.VariableNames =  [{'insitu'} {'gldas'}];
    
    for d = 1:length(Time)
        % find the data that matches the date, and average out
        avg_insitu = mean(smtt.insitu(smtt.Time == Time(d)), 'omitnan');
        avg_gldas = mean(smtt.gldas(smtt.Time == Time(d)), 'omitnan');
        smtt_avg.insitu(d) = avg_insitu;
        smtt_avg.gldas(d) = avg_gldas;
    end

    % save
    fn = fullfile(out_path, network(i), "combined", "average.csv");
    writetimetable(smtt_avg, fn, 'DateLocale', 'en-US');
    fprintf("Finished processing network %s", network(i))
    
end
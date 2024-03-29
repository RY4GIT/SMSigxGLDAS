function [] = qc_step3p2(network, out_path)

% preparation
flags = [101;102;103;104;105];
[depth, nstation] = io_siteinfo(network);

for f = 1
    % read stationflag 101
    stationflag = readmatrix(fullfile(out_path, network, 'stationflag1.csv'));
    [n,k] = find(stationflag == 101);
    
    for i = 1:length(n)
        % open data
        fn = sprintf('sm_d%.3f_s%02d.csv', depth(k(i)), n(i));
        fid = fopen(fullfile(out_path,network, fn),'r');
        data = textscan(fid,'%D %f','HeaderLines',1,'Delimiter',',');
        time = data{1};
        sm = data{2};
        fclose(fid);

        % remove all record for erroneous data
        sm = nan(length(sm),1);
        smTT = timetable(time,sm);

        % save
        writetimetable(smTT, fullfile(out_path,network,fn));
        disp(fn)
    end
    
end
clear n k fn stationflag

for f = 2:length(flags)
    % Check if there is stationflag record
    try
        stationflag_of_interest = readmatrix(fullfile(out_path, network, sprintf('stationflag%d.csv', flags(f))));
    catch
        continue
    end
    
    if ~isempty(stationflag_of_interest)
        for i = 1:length(stationflag_of_interest)
            n = stationflag_of_interest(i,1);
            k = stationflag_of_interest(i,2);
            s_row = stationflag_of_interest(i,3);
            e_row = stationflag_of_interest(i,4);
            
            if s_row ~= 0
                % read the data 
                fn = sprintf('sm_d%.3f_s%02d.csv', depth(k), n);
                fid = fopen(fullfile(out_path,network,fn),'r');
                data = textscan(fid,'%D %f','HeaderLines',1,'Delimiter',',');
                time = data{1};
                sm = data{2};
                fclose(fid);

                % if row # is not 0, remove the data 
                sm(s_row:e_row) = NaN;
                smTT = timetable(time,sm);
                
                % save
                writetimetable(smTT, fullfile(out_path,network,fn));
                disp(fn);
            end
        end
    end
    
end

end

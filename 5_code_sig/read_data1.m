function [smtt0, ninsitu] = read_data1(network, k, depth, in_path)

switch network
    % for Oznet,
    % case 1: insitu 3cm vs. gldas 0_10cm, point-to-pixel comparison
    % case 2: insitu 4cm vs. gldas 0_10cm, point-to-pixel comparison
    % case 3: insitu basin average vs. gldas basin average
    case "Oznet"
        switch k
            case 1
                ninsitu = 38;
                fn0 = 'depth_3cm.csv'; % input file name
            case 2
                ninsitu = 38;
                fn0 = 'depth_4cm.csv';
            case 3
                ninsitu = 1;
                fn0 = 'depth_0_10cm.csv';
        end
    case "USCRN"
        switch k
            case 1
                ninsitu = 29;
                fn0 = 'USCRN.csv';
            case 2
                ninsitu = 1;
                fn0 = 'average.csv';
        end
    case "SCAN"
        switch k
            case 1
                ninsitu = 91;
                fn0 = 'SCAN.csv';
            case 2
                ninsitu = 1;
                fn0 = 'average.csv';
        end
end

% Read GLDAS SM data
fn = fullfile(in_path, "combined", fn0);
fid = fopen(fn, 'r');
% for sensorwise data
if depth(k) ~= 10
    smtt0 = textscan(fid,'%d %q %f %f','HeaderLines',1,'DateLocale','en_US','Delimiter',',');
    % for watershed average data
elseif network == "Oznet"
    smtt0 = textscan(fid,'%q %f %f','HeaderLines',1,'DateLocale','en_US','Delimiter',',');
else
    smtt0 = textscan(fid,'%q %f %f','HeaderLines',1,'Delimiter',',');
end
fclose(fid);

end
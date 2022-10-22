function [depth, nstation, truedepth, ninsitu, fn0] = io_siteinfo(network)

switch network
    case "Oznet"
        % for Oznet,
        % case 1: insitu 3cm vs. gldas 0_10cm, point-to-pixel comparison
        % case 2: insitu 4cm vs. gldas 0_10cm, point-to-pixel comparison
        % case 3: insitu basin average vs. gldas basin average
        depth = [2.5; 4; 10];
        truedepth = ["2.5"; "4"; "Average"];
        nstation = 38;
        ninsitu = [38; 38; 1];
        fn0 = ["depth_3cm_arid.csv"; "depth_4cm_arid.csv"; "average.csv"];
    case "USCRN"
        depth = [5; 10];
        truedepth = ["5"; "Average"];
        nstation = 29;
        ninsitu = [29; 1];
        fn0 = ["USCRN.csv"; "average.csv"];
    case "SCAN"
        depth = [5.08; 10];
        truedepth = ["5.08"; "Average"];
        nstation = 91;
        ninsitu = [91; 1];
        fn0 = ["SCAN.csv"; "average.csv"];
end

end
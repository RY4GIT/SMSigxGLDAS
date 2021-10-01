function [depth, nstation, truedepth] = io_siteinfo(network)

switch network
    case "Oznet"
        depth = [2.5; 4; 10];
        truedepth = ["2.5"; "4"; "Average"];
        nstation = 38;
    case "USCRN"
        depth = [5; 10];
        truedepth = ["5"; "Average"];
        nstation = 29;
    case "SCAN"
        depth = [5.08; 10];
        truedepth = ["5.08"; "Average"];
        nstation = 91;
end

end
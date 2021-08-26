function [depth, nstation] = io_siteinfo(network)
    % returns desired station information to plot out
    switch network
        case "SCAN"
            depth = 5.080;
            nstation = 91; 
            dim = 176760;
        case "USCRN"
            depth = 5.000; 
            nstation = 29;
    end
end
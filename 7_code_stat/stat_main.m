
%% Preparation
clear all;
close all;

cd("G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\7_code_stat");
    
% Site information
network = ["Oznet"; "USCRN"; "SCAN"];
obs = ["gldas";"insitu"];

% read the format for the plots
sig_abb = ["seasontrans_sdate_wet2dry_p"; "seasontrans_sdate_wet2dry_l"; ...
    "seasontrans_edate_wet2dry_p"; "seasontrans_edate_wet2dry_l"; ...
    "seasontrans_sdate_dry2wet_p"; "seasontrans_sdate_dry2wet_l"; ...
    "seasontrans_edate_dry2wet_p"; "seasontrans_edate_dry2wet_l"; ...
    "seasontrans_duration_wet2dry_p"; "seasontrans_duration_wet2dry_l"; ...
    "seasontrans_duration_dry2wet_p"; "seasontrans_duration_dry2wet_l"];

sig_abb2 = ["Start day (piecewise)"; "Start day (logistic)"; ...
    "End day (piecewise)"; "End day (logistic)"; ...
    "Start day (piecewise)"; "Start day (logistic)"; ...
    "End day (piecewise)"; "End day (logistic)"; ...
    "Wet to dry (piecewise)"; "Wet to dry (logistic)"; ...
    "Dry to wet (piecewise)"; "Dry to wet (logistic)"];

sig_abb3 = ["amplitude"; "phaseshift"];
sig_abb4 = ["Amplitude"; "Phase shift"];

for i = 2:length(network)
    switch network(i)
        case "Oznet"
            depth = [3; 4; 10];
            nstation = 38;
        case "USCRN"
            depth = [5; 10];
            nstation = 29;
        case "SCAN"
            depth = [5.08; 10];
            nstation = 91;
    end

    %% align the seasonal transition and save into csv
    % Seasonal transition signatures
    stat_align_sigTrans(network(i), depth, nstation, sig_abb);
    % Sine curve signatures
    stat_align_sigSine(network(i), depth, nstation, sig_abb3);
end

    stat_calc(site, depth, nstation, sig_abb, sig_abb2);
    stat_pl_count(site, depth, nstation, sig_abb, sig_abb2);
    stat_r2_count();
    
        stat_calc2(site, depth, nstation, sig_abb3, sig_abb4);
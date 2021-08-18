
clear all;
close all;

cd("G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\3_codes_plotters");
    
% Site information
site = ["station";"gldas"];
depth = [3;4;10]; 
nstation = 38;

% Color code 
% Piecewise ... red
% Logistic ... blue 
% Start day ... circle
% End day ... cross

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

xline_format = ["--r"; "-r"; ...
                "--r"; "-r"; ...
                "--b"; "-b"; ...
                "--b"; "-b"];
            
% read the format for the plots  
sig_abb3 = ["amplitude"; "phaseshift"];

sig_abb4 = ["Amplitude"; "Phase shift"];

%% Seasonal transition signatures     
% align the seasonal transition and save into csv
% sig = stat_align(site, depth, nstation, sig_abb, sig_abb2);
% stat_calc(site, depth, nstation, sig_abb, sig_abb2);
% stat_pl_count(site, depth, nstation, sig_abb, sig_abb2);
stat_r2_count();


%% Sine curve signatures
% align the sine curve signature and save into csv
% sig2 = stat_align2(site, depth, nstation, sig_abb3, sig_abb4);
% stat_calc2(site, depth, nstation, sig_abb3, sig_abb4);


%% Script to plot out the signatures
% publish('plot_main.m', 'doc')
% =========== BEGINNING OF THE CODE ============

clear all;
slCharacterEncoding('UTF-8');

%% Preparation

% Set path
cd("G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\3_codes_plotters");
in_path = "G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\2_out\";
out_path = "G:\Shared drives\Ryoko and Hilary\SoilMoistureSignature\GLDAS\4_out\boxplots";

% Site information
site = ["Oznet"; "GLDAS"]; 

% read the format for the plots  
sigT = readtable('sig_format.csv','HeaderLines',0,'Delimiter',',');

%% Box plots for seasonal transition 
% plot_seasonal2(site, true, true, 'pdf');

%% Time series for seasonal transition
% sig = plot_TS('pdf');



% %% Box plots for each depth & all stations
% for s = 1:size(sigT,1)
%     disp(s)
%    plot_box_depth(string(sigT.sig_abb(s)), string(sigT.sig_fullname(s)), string(sigT.ylabel(s)), allsites, obs, true, true, 'pdf');
% end

%% Box plots for each land-use & each land-use/depth
% For all sites except WB
% for s = 1:size(sigT,1)
%    disp(s)
%    plot_box_lulc(string(sigT.sig_abb(s)), string(sigT.sig_fullname(s)), string(sigT.ylabel(s)), site, obs, true, true, 'pdf');
% end

% Only for WB
% for s = 1:size(sigT,1)
%    disp(s)
%    plot_box_WBdef(string(sigT.sig_abb(s)), string(sigT.sig_fullname(s)), string(sigT.ylabel(s)), site2, obs, true, true, 'pdf');
% end

%% just for de-bugging
% s=1
% sig_abb = string(sigT.sig_abb(s))
% sig_fullname = string(sigT.sig_fullname(s))
% sig_ylabel = string(sigT.ylabel(s))
% i = 1
% j = 1
% site = ["MQ";"OZ";"TX";"WB";"HB";"RM"]; 

% =========== END OF THE CODE ============
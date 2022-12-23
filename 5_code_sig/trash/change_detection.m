
in_path = "G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\2_data_selected\USCRN\sm_d5.000_s01.csv";
smtt0 = readtable(in_path);
smtt = timetable(smtt0.date_time, smtt0.soil_moisture);
smtt = retime(smtt,'daily','mean');

nWY = size(unique(year(smtt.Properties.RowTimes)),1);
nWetSeason = 1;

findchangepts(fillmissing(smtt.Var1,'linear'),'MaxNumChanges',(nWY-2)*nWetSeason*2)

plot(smtt0.date_time, smtt0.soil_moisture)
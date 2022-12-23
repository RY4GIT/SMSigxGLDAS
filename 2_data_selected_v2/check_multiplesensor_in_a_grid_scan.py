import os
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

in_path = r"G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\GIS\counting_sensors_per_grids\SpatialJoin_CONUS_SCAN.csv"
in_path_2 = r"G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\2_data_selected"
out_path = r"G:\Shared drives\Ryoko and Hilary\SMSigxGLDAS\2_data_selected_v2\SCAN\plot"
network = 'SCAN'
depth = 5.080

df_sensor_metadata = pd.read_csv(in_path)
df_multiple_sensors_in_a_grid = df_sensor_metadata[df_sensor_metadata['sensors_in_a_grid'] >= 2]
# df_multiple_sensors_in_a_grid['updating_sensor'] = df_multiple_sensors_in_a_grid[['lon','lat']].duplicated().copy()

unique_gridid = df_multiple_sensors_in_a_grid['JOIN_FID'].unique()
for i, grid_n in enumerate(unique_gridid):
    print(f"Currently processing grid {i}/{len(unique_gridid)}")
    df_sensors_in_a_target_grid = df_multiple_sensors_in_a_grid[df_multiple_sensors_in_a_grid['JOIN_FID']==grid_n].copy()

    for j, sensor_n in enumerate(df_sensors_in_a_target_grid['sid'].values):
        print(f'sensor #{sensor_n}')
        fn = os.path.join(in_path_2, network, f"sm_d{depth:.3f}_s{sensor_n:02d}.csv")
        sensor_data = pd.read_csv(fn)

        datetime_index = pd.DatetimeIndex(sensor_data['date_time'])
        sensor_data = sensor_data.set_index(datetime_index)
        sensor_data_daily = sensor_data['soil_moisture'].resample('D', axis=0).mean()

        if j==0:
            # initiate figure
            fig, ax = plt.subplots()
            ax.plot(sensor_data_daily, label=sensor_n)
        else:
            # add plots to the figure
            ax.plot(sensor_data_daily, label=sensor_n)
            ax.legend()
            print(j, len(df_sensors_in_a_target_grid)-1)

        if j == (len(df_sensors_in_a_target_grid)-1):
            # save figure
            print('saving ...')
            fig.savefig(os.path.join(out_path, f'timeseries_{grid_n}.png'))
            del fig, ax




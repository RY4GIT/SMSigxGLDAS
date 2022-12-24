# Import libraries
import pandas as pd
import numpy as np
import os
import matplotlib.pyplot as plt
import warnings
warnings.filterwarnings('ignore')

# network = 'Oznet'
# metadata_filename = 'SpatialJoin_AU_Oznet_v2.csv'
# timeseriesdata_filename = 'depth_3cm_arid.csv'

# network = 'SCAN'
# metadata_filename = 'SpatialJoin_CONUS_SCAN_v2.csv'
# timeseriesdata_filename = 'SCAN.csv'

network = 'USCRN'
metadata_filename = 'SpatialJoin_CONUS_USCRN_v2.csv'
timeseriesdata_filename = 'USCRN.csv'

# Set path
input_path = r"3_code_calc_weight_by_Thiessen\counting_sensors_per_grids"
input_path_2 = os.path.join("4_data", network, "combined")
output_path =  os.path.join("4_data", network, "combined_weighted")

# Read statistics of counting sensors per grids 
df_sensor_metadata = pd.read_csv(os.path.join(input_path, metadata_filename))
df_multiple_sensors_in_a_grid = df_sensor_metadata[(df_sensor_metadata['sensors_in_a_grid'] >= 2) & (df_sensor_metadata['obs_period_overlapping']==True)]

# Identify the multile-sensors-in-a-grid situation
unique_gridid = df_multiple_sensors_in_a_grid['JOIN_FID'].unique()

# Read timeseries of data 
df_sensor_timeseries_original = pd.read_csv(os.path.join(input_path_2, timeseriesdata_filename))
df_sensor_timeseries_overwritten = df_sensor_timeseries_original.copy()

for i, grid_n in enumerate(unique_gridid):
    print(f"Currently processing grid {i+1}/{len(unique_gridid)}")

    # Get the target grid
    df_sensors_in_a_target_grid = df_multiple_sensors_in_a_grid[df_multiple_sensors_in_a_grid['JOIN_FID']==grid_n].copy()

    # Get target timeseries of data
    df_timeseries_merged_with_metadata = df_sensor_timeseries_original.merge(df_sensors_in_a_target_grid, left_on='ID', right_on='sid', how='right')

    # Get weighted average for each timestep
    unique_dates = df_timeseries_merged_with_metadata['date'].unique()
    for j, target_date in enumerate(unique_dates):
        
        print(f'Calculating weighted average ... {j}/{len(unique_dates)}')
        
        # Weighted average
        ts_a_day = df_timeseries_merged_with_metadata[df_timeseries_merged_with_metadata['date']==target_date].copy()
        
        if len(ts_a_day)==1:
            weighted_insitu_value = np.nan
        else:
            ts_a_day['scaled_weight'] = ts_a_day['weight']/(sum(ts_a_day['weight'].values))
            weighted_insitu_value = sum(ts_a_day['insitu'] * ts_a_day['scaled_weight'])
        
            newline_df_weighted = pd.DataFrame(data={'ID':[ts_a_day['sid'].values[0]], 'date':[target_date], 'insitu':[weighted_insitu_value], 'gldas':[ ts_a_day['gldas'].values[0]]})
            if not 'df_weighted' in globals():
                df_weighted = newline_df_weighted
            else:
                df_weighted = pd.concat([df_weighted, newline_df_weighted], ignore_index=True)
    
    df_weighted['date'] = pd.to_datetime(df_weighted['date'])
    df_weighted.set_index('date', inplace=True)
    df_weighted = df_weighted.resample('D').fillna("backfill")
    
    if i==0:
        df_weighted_allgrids = df_weighted
    else:
        df_weighted_allgrids = pd.concat([df_weighted_allgrids, df_weighted])
        
    # Plot to confirm    
    print('Plotting the results ... ') 
    fig = plt.figure(figsize=(9, 9))
    ax =  fig.add_subplot() 
    
    df_weighted.sort_values(by='date', inplace=True)
    df_timeseries_merged_with_metadata_for_plot = df_timeseries_merged_with_metadata.sort_values(by='date').copy()
    
    df_timeseries_merged_with_metadata_for_plot['date'] = pd.to_datetime(df_timeseries_merged_with_metadata_for_plot['date'])
    df_timeseries_merged_with_metadata_for_plot.set_index('date', inplace=True)

    sid = df_timeseries_merged_with_metadata_for_plot['sid'].unique()
    for k in range(len(sid)):
        ax.plot(df_timeseries_merged_with_metadata_for_plot['insitu'][df_timeseries_merged_with_metadata_for_plot['sid']==sid[k]], alpha=0.5, label=f'sid={sid[k]}')
    ax.plot(df_weighted['insitu'], alpha=0.5, label='weighted')
    ax.set_xlabel("Time")
    ax.set_ylabel("VSWC[-]")
    ax.legend()
    fig.autofmt_xdate()
    fig.savefig(os.path.join(output_path, f'grid_{grid_n}_ts.png'))
        
    # Delete non-weighted averaged timeseries 
    for k in range(len(sid)):
        indexMergedStation = df_sensor_timeseries_overwritten[df_sensor_timeseries_overwritten['ID']==sid[k]].index
        df_sensor_timeseries_overwritten.drop(indexMergedStation, inplace=True)
        
    del df_weighted

df_sensor_timeseries_overwritten['date'] = pd.to_datetime(df_sensor_timeseries_overwritten['date'])
df_sensor_timeseries_overwritten.set_index('date', inplace=True)
    
final_timeseries = pd.concat([df_sensor_timeseries_overwritten, df_weighted_allgrids])


final_timeseries['date'] = final_timeseries.index
final_timeseries['date'] = final_timeseries['date'].dt.strftime("%m/%d/%Y")
final_timeseries.sort_index(inplace=True)
final_timeseries.sort_values(by='ID', inplace=True)

# Save 
final_timeseries = final_timeseries[['date', 'ID', 'insitu','gldas']]
final_timeseries.to_csv(os.path.join(output_path, timeseriesdata_filename), header=True, index=False)


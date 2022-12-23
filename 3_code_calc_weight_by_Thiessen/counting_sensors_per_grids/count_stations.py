
import pandas as pd
import geopandas

input_fn = "G:/Shared drives/Ryoko and Hilary/SMSigxGLDAS/4_data/GIS/SpatialJoin_CONUS_SCAN.shp"
output_fn = "G:/Shared drives/Ryoko and Hilary/SMSigxGLDAS/4_data/GIS/SpatialJoin_CONUS_SCAN.csv"
gdf = geopandas.read_file(input_fn)
gdf.head()

df_for_analysis = gdf[gdf["flag_stat_"]==1]
df_for_analysis['sensors_in_a_grid']=df_for_analysis.groupby('JOIN_FID')['sid'].transform('count')

df_for_saving = df_for_analysis[["sid", "lon", "lat", "depth_cm_", "JOIN_FID", "sensors_in_a_grid"]]
df_for_saving.to_csv(output_fn,index=False)
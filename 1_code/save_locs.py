# To read and save ismn data for a selected climate (group B: desert and arid) between depth of 0 to 5 cm

# source: https://ismn.readthedocs.io/en/latest/

import os
from ismn.interface import ISMN_Interface
from ismn.meta import Depth
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

os.chdir('G:/Shared drives/Ryoko and Hilary/SMSigxGLDAS')
out_path = 'G:/Shared drives/Ryoko and Hilary/SMSigxGLDAS/2_data_selected_v2'



def save_loc(in_path, netname):
    dataset = ISMN_Interface(in_path, network=[netname])
    lon = []
    lat = []
    alt = []
    nstation = []
    depth_cm = []
    station_name = []
    instrument = []
    i = 0

    for network, station, sensor in dataset.collection \
            .iter_sensors(variable='soil_moisture',
                          depth=Depth(0.,0.0508),
                          filter_meta_dict={'climate_KG':['BWk', 'BWh', 'BWn', 'BSk', 'BSh', 'BSn']}):
        print(network)
        print(station)
        print(sensor)
        i += 1
        depth0 = (sensor.depth.end + sensor.depth.start) / 2 * 100
        nstation.append(i)
        lon.append(station.lon)
        lat.append(station.lat)
        alt.append(station.elev)
        depth_cm.append(depth0)
        station_name.append(station.name)
        instrument.append(sensor.instrument)

    station_loc = np.array([nstation, lon, lat, alt, depth_cm, station_name, instrument])
    station_loc = station_loc.transpose()
    df = pd.DataFrame(station_loc, columns = ['sid', 'lon', 'lat', 'alt', 'depth (cm)', 'station_name', 'instrument'])

    if not os.path.exists(os.path.join(out_path, netname)):
        os.makedirs(os.path.join(out_path, netname))

    df.to_csv(os.path.join(out_path, netname, 'metadata.csv'), sep = ',', index = False)

def save_data(in_path, netname):
    dataset = ISMN_Interface(in_path, network=[netname])
    i = 0

    for network, station, sensor in dataset.collection \
            .iter_sensors(variable='soil_moisture',
                          depth=Depth(0., 0.0508),
                          filter_meta_dict={'climate_KG': ['BWk', 'BWh', 'BWn', 'BSk', 'BSh', 'BSn']}):
        i += 1
        sdepth = (sensor.depth.end + sensor.depth.start) / 2 * 100
        data = sensor.read_data()
        # data.loc[data['soil_moisture_flag'] != 'G', 'soil_moisture'] = np.nan
        fn_out = 'sm_d%.3f_s%02d.csv' % (sdepth, i)
        data.to_csv(os.path.join(out_path, netname, fn_out), sep=',', index=True)

def main():
    # save_loc(in_path = 'G:/Shared drives/Ryoko and Hilary/GLDAS/0_data_raw/Data_separate_files_20000101_20200229_6817_FTVy_20210521', netname = 'USCRN')
    save_loc(in_path = './0_data_raw/SCAN', netname = 'SCAN')
    # save_data(in_path = 'G:/Shared drives/Ryoko and Hilary/GLDAS/0_data_raw/Data_separate_files_20000101_20200229_6817_FTVy_20210521', netname = 'USCRN')
    # save_data(in_path = 'G:/Shared drives/Ryoko and Hilary/GLDAS/0_data_raw/SCAN', netname = 'SCAN')
    # save_loc(in_path = 'G:/Shared drives/Ryoko and Hilary/SMSigxGLDAS/0_data_raw/Data_separate_files_20091022_20091023_6817_Sgsr_20210830', netname = 'OZNET')
    # save_data(in_path = 'G:/Shared drives/Ryoko and Hilary/SMSigxGLDAS/0_data_raw/Data_separate_files_header_20090731_20140930_6817_CFaZ_20220330', netname = 'Oznet')

if __name__ == '__main__':
    main()
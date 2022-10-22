# To read and save ismn data in arid environments

# source: https://ismn.readthedocs.io/en/latest/

import os
from ismn.interface import ISMN_Interface
from ismn.meta import Depth
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

os.chdir('G:/Shared drives/Ryoko and Hilary/SMSigxGLDAS')
out_path = 'G:/Shared drives/Ryoko and Hilary/SMSigxGLDAS/2_data_selected_v2'

def save_data(network_name, in_path):
    in_path = 'G:/Shared drives/Ryoko and Hilary/GLDAS/0_data_raw/Data_separate_files_header_20090731_20140930_6817_CFaZ_20220330'
    data_net = ISMN_Interface(in_path, network=[network_name])

    for network, station, sensor in data_net.collection \
            .iter_sensors(variable='soil_moisture',
                          depth=Depth(0.,0.05),
                          filter_meta_dict={'climate_KG':['BWk', 'BWh', 'BWn', 'BSk', 'BSh', 'BSn']}):

        data = sensor.read_data()
        # print(data)
        data.loc[data['soil_moisture_flag'] != 'G', 'soil_moisture'] = np.nan

        # data.save()
        # ax = data.plot(figsize=(12,4), title=f"G-flagged SM for '{sensor.name}' at station '{station.name}' in network '{network.name}''")
        # ax.set_xlabel("Time [year]")
        # ax.set_ylabel("Soil Moisture [$m^3 m^{-3}$]")
        break # for this example we stop after the first sensor

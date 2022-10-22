# To read and save ismn data in arid environments

# source: https://ismn.readthedocs.io/en/latest/

import os
from ismn.interface import ISMN_Interface
from ismn.meta import Depth
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

os.chdir('G:/Shared drives/Ryoko and Hilary/GLDAS')
out_path = 'G:/Shared drives/Ryoko and Hilary/GLDAS/2_data_processed'
# Enter the path to your ISMN data
path_to_scan_data = "G:\\Shared drives\\Ryoko and Hilary\\GLDAS\\0_data_raw\\Data_separate_files_20000101_20200229_6817_FTVy_20210520"
scan_data = ISMN_Interface(path_to_scan_data, network=['SCAN'])

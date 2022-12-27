import os 
import pandas as pd

input_path = r"6_out_stat\20221224"
output_path = r"6_out_stat"

network = ['Oznet', 'SCAN', 'USCRN']
data_type = ['combined', 'combined_weighted']
output_filename = ['seasonal_signature_results_without_weighting.csv', 'seasonal_signature_results_with_weighting.csv']
signature_type =  ['seasontrans_sdate_wet2dry', 'seasontrans_sdate_dry2wet', 'seasontrans_edate_wet2dry', 'seasontrans_edate_dry2wet']
signature_displayname = ['Start of drying', 'Start of wetting', 'End of drying', 'End of wetting']

for dt in range(len(data_type)):
    for i in range(len(network)):
        
        for j in range(len(signature_type)):
            
            input_file = os.path.join(input_path, data_type[dt], network[i], f'{signature_type[j]}.csv')

            signature_output = pd.read_csv(input_file)

            # Calculate errors in seasonal trasition dates 
            signature_output['error(days, gldas-insitu)'] = signature_output['gldas'] - signature_output['insitu']

            # Drop "average" timeseries
            indexAvgTimeseries = signature_output[signature_output['depth']==10].index
            signature_output.drop(indexAvgTimeseries, inplace=True)

            # Add network name column
            signature_output['network'] = network[i]

            # Add signature type column
            signature_output['signature_type'] = signature_displayname[j]

            # 
            if not 'signature_outputs' in globals():
                signature_outputs = signature_output
            else:
                signature_outputs = pd.concat([signature_outputs, signature_output], ignore_index=True)

    signature_outputs.to_csv(os.path.join(output_path, output_filename[dt]), header=True, index=False)
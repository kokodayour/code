import glob
import numpy as np
import pandas as pd

if __name__ == '__main__':
    
    metadata_GCD = pd.read_csv('./metadata/Seoul_metadata_withCHELSA.csv',index_col=0)
    metadata_LST = pd.read_csv('./metadata/Seoul_metadata_withLST.csv',index_col=0)
    metadata = pd.merge(metadata_GCD,metadata_LST,how='left')
    metadata[['CHELSA','Latitude','Longitude','Elevation']] = (metadata[['CHELSA','Latitude','Longitude','Elevation']] - metadata[['CHELSA','Latitude','Longitude','Elevation']].min()) / (metadata[['CHELSA','Latitude','Longitude','Elevation']].max()-metadata[['CHELSA','Latitude','Longitude','Elevation']].min())

    GCDlabel = metadata[['y_x','Latitude','Longitude','Elevation','CHELSA']]

    metadata = metadata[metadata['LST_summer'].isna() == False]
    metadata = metadata.sort_values(by='LST_summer').reset_index(drop=True)
    metadata['LSTlabel'] = (metadata.index // (len(metadata)/5))
    metadata['LSTlabel'] = metadata['LSTlabel'].apply(lambda x: int(x))

    metadata = metadata.sort_values(by='LST_all').reset_index(drop=True)
    metadata['LSTlabel_all'] = (metadata.index // (len(metadata)/5))
    metadata['LSTlabel_all'] = metadata['LSTlabel_all'].apply(lambda x: int(x))
    LSTlabel_all = metadata.sample(frac=1).reset_index(drop=True)

    LSTlabel_all['diff'] = LSTlabel_all['LSTlabel'] - LSTlabel_all['LSTlabel_all']
    LSTlabel_all['diff'] = LSTlabel_all['diff'].apply(lambda x: abs(x))
    LSTlabel_all = LSTlabel_all[LSTlabel_all['diff']<=1]

    LSTlabel = LSTlabel_all[['y_x','Latitude','Longitude','Elevation','LST_summer','LSTlabel']].reset_index(drop=True)

    LSTlabel.to_csv('./metadata/Seoul_metadata_cls5_LSTloss.csv',mode='w')
    GCDlabel.to_csv('./metadata/Seoul_metadata_CHELSAloss.csv',mode='w')

    
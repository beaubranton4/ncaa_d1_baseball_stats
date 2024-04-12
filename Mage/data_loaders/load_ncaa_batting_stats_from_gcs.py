from mage_ai.settings.repo import get_repo_path
from mage_ai.io.config import ConfigFileLoader
from mage_ai.io.google_cloud_storage import GoogleCloudStorage
from os import path
import os
from datetime import datetime, timedelta
import pandas as pd
if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test

config_path = path.join(get_repo_path(), 'io_config.yaml')
config_profile = 'default'
bucket_name = os.getenv('GCS_BUCKET_NAME') 
object_key = 'batting_stats/date=' 

def extract_dates(strings):
    dates = []
    for s in strings:
        start = s.find('date=') + len('date=')
        date_str = s[start:start+10]
        date_obj = datetime.strptime(date_str, '%Y-%m-%d').date()  # Convert to date
        dates.append(date_obj)
    return dates

def get_all_scraped_dates_and_obj_keys_in_gcs():
    gcs = GoogleCloudStorage.with_config(ConfigFileLoader(config_path, config_profile))
    blobs = gcs.client.list_blobs(bucket_name, prefix=object_key)
    object_keys = [blob.name for blob in blobs if blob.name.endswith('.parquet')]
    date_strings = extract_dates(object_keys)
    dates = [date_string for date_string in date_strings]
    return dates, object_keys
   
@data_loader
def load_all_partitions_from_gcs(*args, **kwargs):
    
    dates, object_keys = get_all_scraped_dates_and_obj_keys_in_gcs()
    
    df = pd.DataFrame()
    for object_key, date in zip(object_keys, dates):
        print(object_key)
        print(dates)
        data = GoogleCloudStorage.with_config(ConfigFileLoader(config_path, config_profile)).load(
            bucket_name,
            object_key,
            format='parquet'
        )

        # ADD DATE BACK AS A COLUMN
        data = data.assign(date=date)
        df = pd.concat([df,data])
        print(f"Finished appending data from {date}")

    # Return the DataFrame
    return df

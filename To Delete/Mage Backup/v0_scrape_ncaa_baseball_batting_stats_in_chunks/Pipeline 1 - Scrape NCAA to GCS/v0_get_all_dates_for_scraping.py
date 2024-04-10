from mage_ai.settings.repo import get_repo_path
from mage_ai.io.config import ConfigFileLoader
from mage_ai.io.google_cloud_storage import GoogleCloudStorage
from os import path
from datetime import datetime, timedelta
if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test

config_path = path.join(get_repo_path(), 'io_config.yaml')
config_profile = 'default'
bucket_name = 'mage_zoomcamp_beau_branton_bucket' #replace w global variable
object_key = 'd1_baseball_project/batting_box_scores_test/date=' #replace w global variable

def extract_dates(strings):
    dates = []
    for s in strings:
        start = s.find('date=') + len('date=')
        date_str = s[start:start+10]
        date_obj = datetime.strptime(date_str, '%Y-%m-%d').date()  # Convert to date
        dates.append(date_obj)
    return dates

def get_all_scraped_dates_in_gcs():
    gcs = GoogleCloudStorage.with_config(ConfigFileLoader(config_path, config_profile))
    blobs = gcs.client.list_blobs(bucket_name, prefix=object_key)
    object_keys = [blob.name for blob in blobs if blob.name.endswith('.parquet')]
    date_strings = extract_dates(object_keys)
    dates = [date_string for date_string in date_strings]
    return dates
    
def get_all_dates_in_season():
    start_date_str = '02/16/2024'  # Replace with automatic variable for first day of season
    start_date = datetime.strptime(start_date_str, "%m/%d/%Y").date()
    end_date = datetime.now().date() - timedelta(days=1)
    all_dates = [start_date + timedelta(days=i) for i in range((end_date - start_date).days + 1)]
    return all_dates

@data_loader
def load_from_google_cloud_storage(*args, **kwargs):
   
    dates_scraped = get_all_scraped_dates_in_gcs()
    all_dates = get_all_dates_in_season()
    missing_dates = [date for date in all_dates if date not in dates_scraped]

    return [missing_dates]
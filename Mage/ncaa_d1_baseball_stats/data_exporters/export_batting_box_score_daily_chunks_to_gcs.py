from mage_ai.settings.repo import get_repo_path
from mage_ai.io.config import ConfigFileLoader
from mage_ai.io.google_cloud_storage import GoogleCloudStorage
from google.cloud import storage
from pandas import DataFrame
import pandas as pd
from os import path
import os  
import pyarrow as pa
import pyarrow.parquet as pq

if 'data_exporter' not in globals():
    from mage_ai.data_preparation.decorators import data_exporter

os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = "./ncaa-d1-baseball-stats-project-da5969b42075.json" #MUST REPLACE
bucket_name = 'ncaa_d1_baseball_stats_bucket' #MUST REPLACE
project_id = 'ncaa-d1-baseball-stats-project' #MUST REPLACE
table_name = 'batting_stats' #MUST REPLACE

root_path = f'{bucket_name}/{table_name}'

def delete_gcs_folder_if_dates_exist(bucket_name, date_list):
    """Checks if a folder with a specific date exists in the bucket and deletes if found."""
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blobs = bucket.list_blobs()
    for folder_date in date_list:
        for blob in bucket.list_blobs():
            if f"/date={folder_date}/" in blob.name:
                print(f"Deleted blob: {blob.name}")
                blob.delete()

@data_exporter
def export_data_to_google_cloud_storage(df: DataFrame, **kwargs) -> None:
    if df.empty:
        return None
    else:
        #CODE TO DELETE AN EXISTING BLOB BASED ON THE DATE PASSED IN
        scraped_dates = df['date'].unique().tolist() 
        delete_gcs_folder_if_dates_exist(bucket_name, scraped_dates)
        table = pa.Table.from_pandas(df)
        gcs = pa.fs.GcsFileSystem()
        pq.write_to_dataset(
            table,
            root_path=root_path,
            partition_cols=['date'],
            filesystem=gcs
    )

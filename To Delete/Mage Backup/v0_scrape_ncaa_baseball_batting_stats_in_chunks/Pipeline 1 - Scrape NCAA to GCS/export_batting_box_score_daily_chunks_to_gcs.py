from mage_ai.settings.repo import get_repo_path
from mage_ai.io.config import ConfigFileLoader
from mage_ai.io.google_cloud_storage import GoogleCloudStorage
from pandas import DataFrame
import pandas as pd
from os import path
import os  
import pyarrow as pa
import pyarrow.parquet as pq

if 'data_exporter' not in globals():
    from mage_ai.data_preparation.decorators import data_exporter

#Consider writing code here to upload and replace if data already exists there, just in case we need to backfill data and overwrite it. Should otherwise work on it's own

###CONFUSED ABOUT HOW THIS CAN SCRIPT CAN BE UPDATED SO THAT SOMEONE CAN REPLICATE THIS PROJECT. WILL THEY SETUP THEIR OWN GCS AND UPDATE THESE CREDENTIALS?
#HOW CAN I MAKE THESE CREDENTIALS VARIABLES THAT THE END USER CAN UPDATE
os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = "./peppy-citron-411704-888e6b9e01ee.json"

bucket_name = 'mage_zoomcamp_beau_branton_bucket'
project_id = 'peppy-citron-411704'

table_name = "batting_box_scores_test"
root_path = f'{bucket_name}/d1_baseball_project/{table_name}'

@data_exporter
def export_data_to_google_cloud_storage(df: DataFrame, **kwargs) -> None:

    table = pa.Table.from_pandas(df)

    gcs = pa.fs.GcsFileSystem()
    pq.write_to_dataset(
        table,
        root_path=root_path,
        partition_cols=['date'],
        filesystem=gcs
   )

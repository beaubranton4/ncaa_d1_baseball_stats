from mage_ai.settings.repo import get_repo_path
from mage_ai.io.bigquery import BigQuery
from mage_ai.io.config import ConfigFileLoader
from pandas import DataFrame
from os import path
import os
from mage_ai.orchestration.triggers.api import trigger_pipeline

if 'data_exporter' not in globals():
    from mage_ai.data_preparation.decorators import data_exporter


@data_exporter
def export_data_to_big_query(df: DataFrame, **kwargs) -> None:

    #Replace with variables somewhere
    project_name = os.getenv('GCP_PROJECT_NAME')
    dataset_name = os.getenv('BIQ_QUERY_DATASET_STG')
    table_name = 'batting_stats'
    table_id = f'{project_name}.{dataset_name}.{table_name}'
    config_path = path.join(get_repo_path(), 'io_config.yaml')
    config_profile = 'default'

    BigQuery.with_config(ConfigFileLoader(config_path, config_profile)).export(
        df,
        table_id,
        if_exists='replace',  # Specify resolution policy if table name already exists
    )

    trigger_pipeline(
        'dbt_transform_ncaa_d1_baseball_stats'        # Required: enter the UUID of the pipeline to trigger
    )
    


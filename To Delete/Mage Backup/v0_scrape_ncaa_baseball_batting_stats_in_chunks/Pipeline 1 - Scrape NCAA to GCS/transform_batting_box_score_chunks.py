from mage_ai.data_cleaner.transformer_actions.base import BaseAction
from mage_ai.data_cleaner.transformer_actions.constants import ActionType, Axis
from mage_ai.data_cleaner.transformer_actions.utils import build_transformer_action
from pandas import DataFrame
import pandas as pd
import numpy as np
from datetime import datetime, timedelta

if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@transformer
def execute_transformer_action(df, *args, **kwargs):
    
    final_batting_df = df
    #TRANSFORM DATA (CASTING TO CORRECT DTYPES etc.)
    batting_int_cols = ['G', 'R', 'AB', 'H', '2B', '3B', 'TB', 'HR', 'RBI', 'BB', 'HBP', 'SF', 'SH', 'K', 'OPP DP', 'CS', 'Picked', 'SB', 'IBB', 'GDP', 'RBI2out','game_id','attendance']

    for col in batting_int_cols:
        final_batting_df[col] = final_batting_df[col].astype(str).str.replace(',', '')
        final_batting_df[col] = pd.to_numeric(final_batting_df[col].replace('', np.nan), errors='coerce').astype('Int64')

    final_batting_df['ingestion_date'] = datetime.now()
    final_batting_df = final_batting_df.astype({
        'Player': str,
        'Pos': str,
        'team': str,
        'location': str,
        'date': 'datetime64[ns]',
        'ingestion_date': 'datetime64[ns]'
    })

    final_batting_df['date']=final_batting_df['date'].dt.date

    return final_batting_df

@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'
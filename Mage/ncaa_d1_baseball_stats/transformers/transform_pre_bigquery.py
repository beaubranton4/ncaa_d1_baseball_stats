if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@transformer
def transform(data, *args, **kwargs):

    new_column_names = {
        "Player": "player",
        "Pos": "position",
        "G": "games",
        "R": "runs",
        "AB": "at_bats",
        "H": "hits",
        "2B": "doubles",
        "3B": "triples",
        "TB": "total_bases",
        "HR": "home_runs",
        "RBI": "rbis",
        "BB": "walks",
        "HBP": "hit_by_pitch",
        "SF": "sacrifice_flys",
        "SH": "sacrifice_hits",
        "K": "strikeouts",
        "OPP DP": "opp_double_play",
        "CS": "caught_stealing",
        "Picked": "picked",
        "SB": "stolen_bases",
        "IBB": "intentional_walks",
        "GDP": "ground_into_double_play",
        "RBI2out": "two_out_rbis",
        "game_id": "game_id",
        "team": "team",
        "side": "home_or_away",
        "location": "location",
        "attendance": "attendance",
        "ingestion_date": "ingestion_date",
        "date": "date"
    }


    # Define your new column order here
    new_column_order = [
        "date",
        "game_id",
        "team",
        "home_or_away",
        "player",
        "position",
        "games",
        "runs",
        "at_bats",
        "hits",
        "doubles",
        "triples",
        "total_bases",
        "home_runs",
        "rbis",
        "walks",
        "hit_by_pitch",
        "sacrifice_flys",
        "sacrifice_hits",
        "strikeouts",
        "opp_double_play",
        "caught_stealing",
        "picked",
        "stolen_bases",
        "intentional_walks",
        "ground_into_double_play",
        "two_out_rbis",
        "location",
        "attendance",
        "ingestion_date"       
    ]

    # Rename the columns
    data.rename(columns=new_column_names, inplace=True)

    # Reorder the columns
    data = data[new_column_order]
    
    return data

@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'

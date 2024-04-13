from mage_ai.orchestration.run_status_checker import check_status

if 'sensor' not in globals():
    from mage_ai.data_preparation.decorators import sensor


@sensor
def check_condition(*args, **kwargs) -> bool:

    return check_status(
        'test_scrape_ncaa_d1_baseball_stats',
        kwargs['execution_date']
    )

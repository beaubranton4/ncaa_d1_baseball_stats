{{ config(
    alias='stg_all_batting_stats',
) }}

select *
from {{ source('stg','batting_stats') }}
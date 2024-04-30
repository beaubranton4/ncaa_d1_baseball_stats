{{ config(
    alias='stg_all_batting_stats',
) }}

select *
from {{ source('stg','batting_stats') }}
where not (at_bats+walks+hit_by_pitch+sacrifice_flys+sacrifice_hits+runs+stolen_bases+caught_stealing=0 and position = 'P') #remove pitchers who did not bat
select *
from {{ source('stg','ncaa_d1_baseball_batting_stats') }}
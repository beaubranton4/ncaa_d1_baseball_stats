select date_day as date
from( 
{{ dbt_utils.date_spine(
    datepart="day",
    start_date="cast('2024-02-16' as date)", 
    end_date="cast(current_date() as date)"
   )
}}
) 
where DATE_TRUNC(date_day, DAY) <= (select greatest('2024-02-16',least('2024-06-24',max(date))) from {{ ref('stg_2024_all_batting_box_scores') }})
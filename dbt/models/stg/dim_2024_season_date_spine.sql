WITH date_range AS (
  SELECT
    GENERATE_DATE_ARRAY('{{ var("2024_season_start_date") }}', '{{ var("2024_season_end_date") }}') AS date_array
)
SELECT
  date
FROM
  date_range,
  UNNEST(date_range.date_array) AS date
where DATE_TRUNC(date, DAY) <= (select greatest('{{ var("2024_season_start_date") }}',least('{{ var("2024_season_end_date") }}',max(date))) from {{ ref('stg_all_batting_box_scores') }})
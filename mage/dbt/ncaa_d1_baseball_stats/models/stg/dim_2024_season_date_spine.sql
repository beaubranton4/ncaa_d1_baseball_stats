WITH date_range AS (
  SELECT
    GENERATE_DATE_ARRAY('2024-02-16', '2024-06-24') AS date_array
)
SELECT
  date
FROM
  date_range,
  UNNEST(date_range.date_array) AS date
where DATE_TRUNC(date, DAY) <= (select greatest('2024-02-16',least('2024-06-24',max(date))) from {{ ref('stg_all_batting_box_scores') }})
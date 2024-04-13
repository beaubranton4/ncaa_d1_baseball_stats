

  create or replace view `ncaa-d1-baseball-stats-project`.`prod_d1_baseball_stats_prod`.`dim_2024_season_date_spine`
  OPTIONS()
  as WITH date_range AS (
  SELECT
    GENERATE_DATE_ARRAY('2024-02-16', '2024-06-24') AS date_array
)
SELECT
  date
FROM
  date_range,
  UNNEST(date_range.date_array) AS date
where DATE_TRUNC(date, DAY) <= (select greatest('2024-02-16',least('2024-06-24',max(date))) from `ncaa-d1-baseball-stats-project`.`ncaa_d1_baseball_stats_stg`.`ncaa_d1_baseball_batting_stats`);


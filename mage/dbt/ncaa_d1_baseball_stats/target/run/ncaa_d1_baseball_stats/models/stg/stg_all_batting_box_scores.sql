

  create or replace view `ncaa-d1-baseball-stats-project`.`prod_d1_baseball_stats_prod`.`stg_all_batting_box_scores`
  OPTIONS()
  as select *
from `ncaa-d1-baseball-stats-project`.`ncaa_d1_baseball_stats_stg`.`ncaa_d1_baseball_batting_stats`;


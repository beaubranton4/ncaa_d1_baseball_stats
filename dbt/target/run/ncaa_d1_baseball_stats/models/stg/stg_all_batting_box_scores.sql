

  create or replace view `ncaa-d1-baseball-stats-project`.`prod_ncaa_d1_baseball_stats`.`stg_all_batting_stats`
  OPTIONS()
  as 

select *
from `ncaa-d1-baseball-stats-project`.`stg_ncaa_d1_baseball_stats`.`batting_stats`
where not (at_bats+walks+hit_by_pitch+sacrifice_flys+sacrifice_hits+runs+stolen_bases+caught_stealing=0 and position = 'P') #remove pitchers who did not bat;


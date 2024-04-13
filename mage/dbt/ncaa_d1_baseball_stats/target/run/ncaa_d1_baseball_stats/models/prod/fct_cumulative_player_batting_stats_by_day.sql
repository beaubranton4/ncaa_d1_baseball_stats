
  
    

    create or replace table `ncaa-d1-baseball-stats-project`.`prod_ncaa_d1_baseball_stats`.`fct_cumulative_player_batting_stats_by_day`
      
    
    

    OPTIONS()
    as (
      with daily_batting_stats as(
    select *
    from `ncaa-d1-baseball-stats-project`.`prod_ncaa_d1_baseball_stats`.`stg_all_batting_stats`
)

, date_spine as (
select * from `ncaa-d1-baseball-stats-project`.`prod_ncaa_d1_baseball_stats`.`dim_2024_season_date_spine`
)

, cumulative_stats as(
    select 
        date_trunc(d.date, DAY) as date,
        player,
        team,
        sum(games) as games_played,
        sum(at_bats) as at_bats,
        SAFE_DIVIDE(sum(hits),sum(at_bats)) as batting_average,
        SAFE_DIVIDE(sum(walks)+sum(hit_by_pitch)+sum(hits),sum(at_bats)) as on_base_percentage,
        sum(runs) as runs,
        sum(hits) as hits,
        sum(total_bases) as total_bases,
        sum(doubles) as doubles,
        sum(triples) as triples,
        sum(home_runs) as home_runs,
        sum(rbis) as rbis,
        sum(strikeouts) as strikeouts,
        sum(walks) as walks,
        sum(hit_by_pitch) as hit_by_pitch,
        sum(sacrifice_flys) as sacrifice_flys,
        sum(opp_double_play) as opp_double_play,
        sum(stolen_bases) as stolen_bases,
        sum(caught_stealing) as caught_stealing,
        sum(picked) as picked,
        sum(intentional_walks) as intentional_walks,
        sum(ground_into_double_play) as ground_into_double_play,
        sum(two_out_rbis) as two_out_rbis
    from date_spine d
    cross join daily_batting_stats s
    where DATE_TRUNC(d.date, DAY) >= s.date
    group by all
    
)

, final_w_rank as(
    select 
        *, 
        case 
            when rank() over (partition by player, team order by date desc) = 1 then true
            else false
        end as current_stats
    from cumulative_stats
)

select * 
    from final_w_rank
        -- order by team, player, date
    );
  
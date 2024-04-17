{{ config(
    materialized='table',
    partition_by={
        "field": "date",    
        "data_type": "date",      
        "granularity": "day"       
    },
    cluster_by=["team"]  
) }}

with daily_batting_stats as(
    select *
    from {{ ref('stg_all_batting_box_scores') }}
)

, record_by_day as(
    select 
        date,
        team,
        total_wins+total_losses as team_games_played
    from {{ ref('fct_team_win_loss_records_by_day') }}
)

, date_spine as (
select * from {{ ref('dim_2024_season_date_spine') }}
)

, cumulative_stats as(
    select 
        date_trunc(d.date, DAY) as date,
        player,
        team,
        sum(games) as games_played,
        sum(at_bats) as at_bats,
        SAFE_DIVIDE(sum(hits),sum(at_bats)) as batting_average,
        SAFE_DIVIDE(sum(walks)+sum(hit_by_pitch)+sum(hits),sum(at_bats)+sum(walks)+sum(hit_by_pitch)+sum(sacrifice_flys)+sum(sacrifice_hits)) as on_base_percentage,
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

select 
    a.*,
    b.team_games_played,
    case
        when a.at_bats/b.team_games_played > 2.7 then True
        else False
    end as stat_leader_minimum_at_bats --Player must have at least 2.7 AB's per team game played to qualify for stat leader considerations
from final_w_rank a
left join record_by_day b
    on a.team = b.team

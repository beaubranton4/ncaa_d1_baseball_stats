with daily_batting_stats as(
    select *
    from `ncaa-d1-baseball-stats-project`.`prod_d1_baseball_stats_prod`.`stg_all_batting_box_scores`
)

, team_game_sums as(
    select
        date,
        game_id,
        team,
        home_or_away,
        attendance,
        location, 
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
        sum(two_out_rbis) as two_out_rbis,
    from daily_batting_stats
    group by all
    order by game_id
)

, game_sums as(
    select distinct
        a.date,
        a.game_id,
        a.attendance,
        a.location,
        a.team as home_team,
        b.team as visiting_team,
        sum(a.runs) as home_team_runs,
        sum(a.hits) as home_team_hits,
        sum(a.total_bases) as home_team_total_bases,
        sum(a.doubles) as home_team_doubles,
        sum(a.triples) as home_team_triples,
        sum(a.home_runs) as home_team_home_runs,
        sum(a.rbis) as home_team_rbis,
        sum(a.strikeouts) as home_team_strikeouts,
        sum(a.walks) as home_team_walks,
        sum(a.hit_by_pitch) as home_team_hit_by_pitch,
        sum(a.sacrifice_flys) as home_team_sacrifice_flys,
        sum(a.opp_double_play) as home_team_opp_double_play,
        sum(a.stolen_bases) as home_team_stolen_bases,
        sum(a.caught_stealing) as home_team_caught_stealing,
        sum(a.picked) as home_team_picked,
        sum(a.intentional_walks) as home_team_intentional_walks,
        sum(a.ground_into_double_play) as home_team_ground_into_double_play,
        sum(a.two_out_rbis) as home_team_two_out_rbis,

        sum(b.runs) as visiting_team_runs,
        sum(b.hits) as visiting_team_hits,
        sum(b.total_bases) as visiting_team_total_bases,
        sum(b.doubles) as visiting_team_doubles,
        sum(b.triples) as visiting_team_triples,
        sum(b.home_runs) as visiting_team_home_runs,
        sum(b.rbis) as visiting_team_rbis,
        sum(b.strikeouts) as visiting_team_strikeouts,
        sum(b.walks) as visiting_team_walks,
        sum(b.hit_by_pitch) as visiting_team_hit_by_pitch,
        sum(b.sacrifice_flys) as visiting_team_sacrifice_flys,
        sum(b.opp_double_play) as visiting_team_opp_double_play,
        sum(b.stolen_bases) as visiting_team_stolen_bases,
        sum(b.caught_stealing) as visiting_team_caught_stealing,
        sum(b.picked) as visiting_team_picked,
        sum(b.intentional_walks) as visiting_team_intentional_walks,
        sum(b.ground_into_double_play) as visiting_team_ground_into_double_play,
        sum(b.two_out_rbis) as visiting_team_two_out_rbis
        
    from team_game_sums a
    left join team_game_sums b
        on a.game_id = b.game_id
    where a.team <> b.team
    and a.home_or_away = 'Home'
    and b.home_or_away = 'Visitor'
    group by all
)

,game_outcomes as(
    select distinct
        case
            when home_team_runs>visiting_team_runs then home_team
            else visiting_team
        end as winning_team,
        case
            when home_team_runs<visiting_team_runs then home_team
            else visiting_team
        end as losing_team,
        *
    from game_sums
)

select *
    from game_outcomes
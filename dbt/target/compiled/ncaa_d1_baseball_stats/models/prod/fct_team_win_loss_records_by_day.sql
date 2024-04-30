

with dim_date as (
  select * from `ncaa-d1-baseball-stats-project`.`prod_ncaa_d1_baseball_stats`.`dim_2024_season_date_spine`
)

,game_stats as(
    select *
    from `ncaa-d1-baseball-stats-project`.`prod_ncaa_d1_baseball_stats`.`fct_game_stats`
)

, wins as(
  select 
    team,
    date,
    sum(wins) over (partition by team order by date asc) as total_wins
  from(
    select
      winning_team as team,
      date,
      count(*) as wins
    from game_stats 
    group by all
  )
)

,cross_join_wins AS (
  SELECT 
    date,
    team
  FROM 
    dim_date
  CROSS JOIN 
    (SELECT DISTINCT team FROM wins)
)

, joined_wins AS (
  SELECT 
    cj.date,
    cj.team,
    d.total_wins
  FROM 
    cross_join_wins cj
  LEFT JOIN 
    wins d
  ON 
    cj.date = d.date 
    AND cj.team = d.team
)

, cumulative_wins as(
SELECT 
  date,
  team,
  IFNULL(total_wins, LAST_VALUE(total_wins IGNORE NULLS) OVER (PARTITION BY team ORDER BY date)) AS total_wins
FROM 
  joined_wins
)

, losses as(
  select 
    team,
    date,
    sum(losses) over (partition by team order by date asc) as total_losses
  from(
    select
      losing_team as team,
      date,
      count(*) as losses
    from game_stats
    group by all
  )
)

,cross_join_losses AS (
  SELECT 
    date,
    team
  FROM 
    dim_date
  CROSS JOIN 
    (SELECT DISTINCT team FROM losses)
)

, joined_losses AS (
  SELECT 
    cj.date,
    cj.team,
    d.total_losses
  FROM 
    cross_join_losses cj
  LEFT JOIN 
    losses d
  ON 
    cj.date = d.date 
    AND cj.team = d.team
)

, cumulative_losses as(
SELECT 
  date,
  team,
  IFNULL(total_losses, LAST_VALUE(total_losses IGNORE NULLS) OVER (PARTITION BY team ORDER BY date)) AS total_losses
FROM 
  joined_losses
)

select 
  w.*, 
  l.total_losses,
  w.total_wins/(w.total_wins+l.total_losses) as win_percentage,
  rank() over (partition by w.date order by w.total_wins/(w.total_wins+l.total_losses) desc) as win_pct_rank,
  case 
    when w.date = (select max(date) from dim_date) then true
    else false
  end as current_record_flag
from cumulative_wins w
join cumulative_losses l
  on l.team = w.team
  and l.date = w.date
-- to merge all 4 table data(ipl1,2,3,4) into single temp table #ipl

drop table if exists #ipl;

create table #ipl
(
id float,
inning float,
overr float,
ball float,
batsman nvarchar(255),
non_stricker nvarchar(255),
bowler nvarchar(255),
batsman_run float,
extra_runs float,
total_runs float,
non_boundry float,
is_wicket float,
dismissal_kind nvarchar(255),
player_dismissed nvarchar(255),
fielder nvarchar(255),
extras_type nvarchar(255),
batting_team nvarchar(255),
bowling_team nvarchar(255),
)

insert into #ipl
select * from IPLdataanalysis.dbo.ipl1
union
select * from IPLdataanalysis.dbo.ipl2
union
select * from IPLdataanalysis.dbo.ipl3
union
select * from IPLdataanalysis.dbo.ipl4

select COUNT(*) from #ipl

select COUNT(*) from IPLdataanalysis.dbo.ipl1
select COUNT(*) from IPLdataanalysis.dbo.ipl2
select COUNT(*) from IPLdataanalysis.dbo.ipl3
select COUNT(*) from IPLdataanalysis.dbo.ipl4

__________________________________________________________________________________________


select * from #ipl --- ball by ball information of matches 
select * from IPLdataanalysis.dbo.ipl ----  match information

______________________________________________________________________________________________
-- to count no of matches played every year

select YEAR(date) as year_match,count(YEAR(date)) as no_of_matches
from IPLdataanalysis.dbo.ipl
group by YEAR(date)
order by year_match

-------------------------------------------------------------------------------------------

-- Highest player of the match

select player_of_match,count(player_of_match) as times from IPLdataanalysis.dbo.ipl
group by player_of_match
order by times desc

---------------------------------------------------------------------------------
--highest player of match over different season

select year(date),player_of_match,count(player_of_match) as times from IPLdataanalysis.dbo.ipl
group by year(date),player_of_match
order by year(date), count(player_of_match) desc


select * from 
(select player_of_match, ye,times,RANK() over(partition by ye order by times desc) rnk
from
(select year(date) ye,player_of_match,count(player_of_match) as times from IPLdataanalysis.dbo.ipl
 group by year(date),player_of_match) a) b
 where rnk = 1

 -------------------------------------------------------------------
-- Most win by any teams

select winner, COUNT(winner) no_of_wins 
from IPLdataanalysis..ipl
group by winner

select winner,no_of_wins, DENSE_RANK() over (order by no_of_wins desc)
from
(select winner, COUNT(winner) no_of_wins 
from IPLdataanalysis..ipl
group by winner) a

-------------------------------------------------------------------

--- top 5 venue where matches are played 

select top 5 venue,count(venue) no_of_times
from IPLdataanalysis..ipl
group by venue
order by no_of_times desc


----------------------------------------------------------------------

--most run by any batsman

select batsman,sum(batsman_run)as total from #ipl
group by batsman
order by total desc

select  top 1 batsman,sum(batsman_run)as total from #ipl
group by batsman
order by total desc

-----------------------------------------------------------------------

-- total runs scored in ipl

select sum(total_runs) from #ipl
select count(total_runs) from #ipl

----------------------------------------------------------------------

-- percent run scored by each batsmann

select *, sum(total_runs) over  (order by total_runs rows between unbounded preceding and unbounded following) runs
from
(select batsman, sum(total_runs) total_runs from #ipl
group by batsman) a

-- just divide and we will get percent runs
---------------------------------------------------------------------


-- Most 6 by any batsman

select batsman, COUNT(batsman_run) total_sixes
from
(select * from #ipl where batsman_run = 6) a
group by batsman
order by total_sixes desc

select Top 1 batsman, COUNT(batsman_run) total_sixes
from
(select * from #ipl where batsman_run = 6) a
group by batsman
order by total_sixes desc

-----------------------------------------------------------------------

-- most 4 by any batsman

select Top 1 batsman, COUNT(batsman_run) total_sixes
from
(select * from #ipl where batsman_run = 4) a
group by batsman
order by total_sixes desc

----------------------------------------------------------------------

-- highest strikrate of player who has scored more than 3000 runs

select * from #ipl

select batsman, sum(batsman_run) total, count(batsman) no_of_balls,((sum(batsman_run)/count(batsman))*100) strikerate 
from #ipl
group by batsman
having sum(batsman_run) > 3000
order by strikerate desc

select  top 1 batsman, sum(batsman_run) total, count(batsman) no_of_balls,((sum(batsman_run)/count(batsman))*100) strikerate 
from #ipl
group by batsman
having sum(batsman_run) > 3000
order by strikerate desc

---------------------------------------------------------------------

--- lowest economy bowler who have bowled atleast 50 0ver

select * from #ipl

select bowler,count(bowler) no_of_bowls, sum(total_runs) runs_scored,
(sum(total_runs)/count(bowler)) economy
from  #ipl
where extras_type != 'byes' or extras_type = 'legbyes'
group by bowler
having count(bowler) >= 300
order by economy 

select top 1 bowler,count(bowler) no_of_bowls, sum(total_runs) runs_scored,
(sum(total_runs)/count(bowler)) economy
from  #ipl
where extras_type != 'byes' or extras_type = 'legbyes'
group by bowler
having count(bowler) >= 300
order by economy

--------------------------------------------------------------------

--- Total no of matches till 2020

select count(distinct id)
from IPLdataanalysis..ipl


------------------------------------------------------------------------

--- no of matches win by each team

select winner, count(winner) from IPLdataanalysis..ipl
group by winner
order by count(winner) desc

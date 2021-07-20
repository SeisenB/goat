--create grid_population
create table grid_population as
select grid_id, geom, population from grid_heatmap;

--add origin to grid_population
drop table pop_origin;
create temp table pop_origin as
select p.gid, a.vi_nummer, p.building_gid, p.population, p.geom, 
a.sh_nomigr*p.population as nomigr,  
a.sh_migr*p.population as migr,  
a.sh_foreign*p.population as foreigner from muc_origin a, 
population p where st_within(p.geom, a.geom) and a.complete = 1;
alter table pop_origin
add primary key (gid);

ALTER TABLE grid_population 
	add column nomigr integer, 
	add column migr integer, 
	add column foreigner integer;
WITH sum_pop AS (
	SELECT g.grid_id, sum(p.nomigr)::integer AS nomigr, sum(p.migr)::integer AS migr, sum(p.foreigner)::integer AS foreigner     
	FROM grid_population g, pop_origin p
	WHERE ST_within(p.geom,g.geom)
	GROUP BY grid_id
)
UPDATE grid_population SET nomigr=s.nomigr, migr=s.migr, foreigner=s.foreigner
FROM sum_pop s 
WHERE grid_population.grid_id = s.grid_id;

--add age to grid_population
drop table pop_age;
create temp table pop_age as
select p.gid, p.building_gid, p.population, p.geom, 
a.sh_0_2*p.population as "0_2",  
a.sh_3_5*p.population as "3_5",  
a.sh_6_14*p.population as "6_14", 
a.sh_15_64*p.population as "15_64",
a.sh_65_74*p.population as "65_74",
a.sh_75_ov*p.population as "75_ov"
from muc_age a, 
population p where st_within(p.geom, a.geom);
alter table pop_age
add primary key (gid);

ALTER TABLE grid_population  
	add column "0_2" integer,  
	add column "3_5" integer,  
	add column "6_14" integer, 
	add column "15_64" integer,
	add column "65_74" integer,
	add column "75_ov" integer;
WITH sum_pop AS (
	SELECT g.grid_id, 
	sum(p."0_2")::integer AS "0_2", 
	sum(p."3_5")::integer AS "3_5", 
	sum(p."6_14")::integer AS "6_14",
	sum(p."15_64")::integer as "15_64",
	sum(p."65_74")::integer as "65_74",
	sum(p."75_ov")::integer as "75_ov"
	FROM grid_population g, pop_age p
	WHERE ST_within(p.geom,g.geom)
	GROUP BY grid_id
)
UPDATE grid_population SET 
"0_2"=s."0_2", "3_5"=s."3_5", "6_14"=s."6_14", "15_64"=s."15_64", 
"65_74"=s."65_74", "75_ov"=s."75_ov"
FROM sum_pop s 
WHERE grid_population.grid_id = s.grid_id;

--create column userGroups for grid_heatmap and add data from grid_population
alter table grid_heatmap 
add column userGroups integer[];
update grid_heatmap h
set userGroups = (select array[g.population,g."0_2",g."3_5",g."6_14",g."15_64",g."65_74",g."75_ov",g.nomigr,g.migr,g.foreigner]
from grid_population g where g.grid_id = h.grid_id); 

--add households to grid population
create temp table hh as
select p.gid, a.vi_nummer, p.building_gid, p.households, p.geom, 
a.sh_nochild*p.households as "hh_nochild",  
a.sh_child*p.households as "hh_child",  
a.sh_sp*p.households as "hh_sp",
a.sh_tp*p.households as "hh_tp"
from muc_households a, 
households p where st_within(p.geom, a.geom);

alter table hh
add primary key (gid);
ALTER TABLE grid_population  
	add column "households" integer,
	add column "hh_nochild" integer,  
	add column "hh_child" integer,  
	add column "hh_sp" integer, 
	add column "hh_tp" integer;
WITH sum_pop AS (
	SELECT g.grid_id,
	sum(p."households")::integer as "households",
	sum(p."hh_nochild")::integer AS "hh_nochild", 
	sum(p."hh_child")::integer AS "hh_child", 
	sum(p."hh_sp")::integer AS "hh_sp",
	sum(p."hh_tp")::integer as "hh_tp"
	FROM grid_population g, hh p
	WHERE ST_within(p.geom,g.geom)
	GROUP BY grid_id
)
UPDATE grid_population SET 
"households"=s."households", "hh_nochild"=s."hh_nochild", "hh_child"=s."hh_child", "hh_sp"=s."hh_sp", 
"hh_tp"=s."hh_tp"
FROM sum_pop s 
WHERE grid_population.grid_id = s.grid_id;

create table grid_access (
	grid_id integer,
	population integer,
	geom geometry);
insert into grid_access (grid_id, population, geom)
select grid_id, population, geom from grid_heatmap;
ALTER TABLE grid_access add primary key (grid_id);

--grocery shops
alter table grid_access 
add column supermarket integer;
update grid_access g
set supermarket = (select h.accessibility_index
FROM heatmap_dynamic('{"supermarket":{"sensitivity":650000,"weight":1,"userGroup":"Gesamtbevölkerung"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);
alter table grid_access 
add column discount_supermarket integer;
update grid_access g 
set discount_supermarket = (select h.accessibility_index
FROM heatmap_dynamic('{"discount_supermarket":{"sensitivity":650000,"weight":1,"userGroup":"Gesamtbevölkerung"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);
alter table grid_access 
add column hypermarket integer;
update grid_access g 
set hypermarket = (select h.accessibility_index
FROM heatmap_dynamic('{"hypermarket":{"sensitivity":650000,"weight":1,"userGroup":"Gesamtbevölkerung"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);
alter table grid_access 
add column organic integer;
update grid_access g 
set organic = (select h.accessibility_index
FROM heatmap_dynamic('{"organic":{"sensitivity":650000,"weight":1,"userGroup":"Gesamtbevölkerung"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);
update grid_access g
set grocery_shops = coalesce(a.supermarket,0)+coalesce(a.discount_supermarket,0)+coalesce(a.hypermarket,0)
from grid_access a 
where g.grid_id = a.grid_id;
--health
alter table grid_access 
add column general_practitioner integer;
update grid_access g 
set general_practitioner = (select h.accessibility_index
FROM heatmap_dynamic('{"general_practitioner":{"sensitivity":650000,"weight":1,"userGroup":"Gesamtbevölkerung"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);
alter table grid_access 
add column paediatrician integer;
update grid_access g 
set paediatrician = (select h.accessibility_index
FROM heatmap_dynamic('{"paediatrician":{"sensitivity":650000,"weight":1,"userGroup":"Gesamtbevölkerung"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);
alter table grid_access 
add column gynaecologist integer;
update grid_access g 
set gynaecologist = (select h.accessibility_index
FROM heatmap_dynamic('{"gynaecologist":{"sensitivity":650000,"weight":1,"userGroup":"Gesamtbevölkerung"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);
alter table grid_access 
add column dentist integer;
update grid_access g 
set dentist = (select h.accessibility_index
FROM heatmap_dynamic('{"dentist":{"sensitivity":650000,"weight":1,"userGroup":"Gesamtbevölkerung"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);
alter table grid_access 
add column pharmacy integer;
update grid_access g 
set pharmacy = (select h.accessibility_index
FROM heatmap_dynamic('{"pharmacy":{"sensitivity":650000,"weight":1,"userGroup":"Gesamtbevölkerung"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);
alter table grid_access 
add column psychotherapist integer;
update grid_access g 
set psychotherapist = (select h.accessibility_index
FROM heatmap_dynamic('{"psychotherapist":{"sensitivity":650000,"weight":1,"userGroup":"Gesamtbevölkerung"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);
--education
alter table grid_access 
add column nursery integer;
update grid_access g 
set nursery = (select h.accessibility_index
FROM heatmap_dynamic('{"nursery":{"sensitivity":550000,"weight":1,"userGroup":"Gesamtbevölkerung"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);
alter table grid_access 
add column kindergarten integer;
update grid_access g 
set kindergarten = (select h.accessibility_index
FROM heatmap_dynamic('{"kindergarten":{"sensitivity":550000,"weight":1,"userGroup":"Gesamtbevölkerung"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);
alter table grid_access 
add column after_school integer;
update grid_access g 
set after_school = (select h.accessibility_index
FROM heatmap_dynamic('{"after_school":{"sensitivity":550000,"weight":1,"userGroup":"Gesamtbevölkerung"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);
alter table grid_access 
add column grundschule integer;
update grid_access g 
set grundschule = (select h.accessibility_index
FROM heatmap_dynamic('{"grundschule":{"sensitivity":550000,"weight":1,"userGroup":"Gesamtbevölkerung"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);
alter table grid_access 
add column hauptschule_mittelschule integer;
update grid_access g 
set hauptschule_mittelschule = (select h.accessibility_index
FROM heatmap_dynamic('{"hauptschule_mittelschule":{"sensitivity":550000,"weight":1,"userGroup":"Gesamtbevölkerung"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);
alter table grid_access 
add column realschule integer;
update grid_access g 
set realschule = (select h.accessibility_index
FROM heatmap_dynamic('{"realschule":{"sensitivity":550000,"weight":1,"userGroup":"Gesamtbevölkerung"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);
alter table grid_access 
add column gymnasium integer;
update grid_access g 
set gymnasium = (select h.accessibility_index
FROM heatmap_dynamic('{"gymnasium":{"sensitivity":550000,"weight":1,"userGroup":"Gesamtbevölkerung"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);
--transport
alter table grid_access 
add column bus_stop integer;
update grid_access g 
set bus_stop = (select h.accessibility_index
FROM heatmap_dynamic('{"bus_stop":{"sensitivity":300000,"weight":1,"userGroup":"Gesamtbevölkerung"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);
alter table grid_access 
add column tram_stop integer;
update grid_access g 
set tram_stop = (select h.accessibility_index
FROM heatmap_dynamic('{"tram_stop":{"sensitivity":300000,"weight":1,"userGroup":"Gesamtbevölkerung"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);
alter table grid_access 
add column subway_entrance integer;
update grid_access g 
set subway_entrance = (select h.accessibility_index
FROM heatmap_dynamic('{"subway_entrance":{"sensitivity":300000,"weight":1,"userGroup":"Gesamtbevölkerung"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);
alter table grid_access 
add column rail_station integer;
update grid_access g 
set rail_station = (select h.accessibility_index
FROM heatmap_dynamic('{"rail_station":{"sensitivity":300000,"weight":1,"userGroup":"Gesamtbevölkerung"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);

--grid_access_comp
create table grid_access_comp (
	grid_id integer,
	population integer,
	geom geometry);
insert into grid_access_comp (grid_id, population, geom)
select grid_id, population, geom from grid_heatmap;
ALTER TABLE grid_access_comp add primary key (grid_id);
select * from grid_access_comp;

alter table grid_access_comp
add column nursery float;
update grid_access_comp g
set nursery = (select h.ai_pop
FROM heatmap_dynamic_population('{"nursery":{"sensitivity":550000,"weight":1,"userGroup":"Unter 3 Jahren"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);

alter table grid_access_comp
add column kindergarten float;
update grid_access_comp g 
set kindergarten = (select h.ai_pop
FROM heatmap_dynamic_population('{"kindergarten":{"sensitivity":550000,"weight":1,"userGroup":"3 bis 5 Jahre"}}'::jsonb,'default',0) h
WHERE h.grid_id = g.grid_id);

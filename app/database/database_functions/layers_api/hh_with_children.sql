CREATE OR REPLACE FUNCTION hh_with_children()
RETURNS TABLE (vi_nummer TEXT, share integer, score text, geom geometry) AS
$$
select m.vi_nummer, m.child::integer, 
case 
	when m.child = 0 then 0::text
	when m.child = 999999 then 'nodata'::text
	when m.child > 0 and m.child < 999999 then p.score::text
end as score,
m.geom
from muc_households m
full outer join
(select vi_nummer, child, 
case WHEN child < 300 THEN 1 
WHEN child  BETWEEN 300 AND 599 THEN 2
WHEN child  BETWEEN 600 AND 899 THEN 3 
WHEN child > 899 THEN 4 
end as score, geom
from muc_households where child > 0 and child < 99999) p 
on p.vi_nummer = m.vi_nummer
order by score;
$$
LANGUAGE sql;

COMMENT ON FUNCTION hh_with_children() 
IS '**FOR-API-FUNCTION** RETURNS col_names[vi_nummer,share,score,geom] **FOR-API-FUNCTION**';


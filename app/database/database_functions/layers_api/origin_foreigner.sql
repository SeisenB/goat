CREATE OR REPLACE FUNCTION origin_foreigner()
RETURNS TABLE (vi_nummer TEXT, share integer, score text, geom geometry) AS
$$
select m.vi_nummer,cast(m.foreigner as integer) as share, 
case 
	when m.foreigner = 0 then 0::text
	when m.foreigner = 999999 then 'nodata'::text
	when m.foreigner > 0 and m.foreigner < 999999 then p.score::text
end as score,
m.geom
from muc_origin m
full outer join
(select vi_nummer, o.foreigner as share, 
case WHEN o.foreigner < 500 THEN 1 
WHEN o.foreigner  BETWEEN 500 AND 999 THEN 2
WHEN o.foreigner  BETWEEN 1000 AND 1999 THEN 3
WHEN o.foreigner  > 1999 THEN 4 END AS score, geom 
from muc_origin o where o.foreigner > 0 and o.foreigner < 99999) p 
on p.vi_nummer = m.vi_nummer
order by score, share;
$$
LANGUAGE sql;

COMMENT ON FUNCTION origin_foreigner() 
IS '**FOR-API-FUNCTION** RETURNS col_names[vi_nummer,share,score,geom] **FOR-API-FUNCTION**';

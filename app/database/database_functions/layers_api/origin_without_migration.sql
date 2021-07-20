CREATE OR REPLACE FUNCTION origin_without_migration()
RETURNS TABLE (vi_nummer_nummer TEXT, share integer, score text, geom geometry) AS
$$
select m.vi_nummer,cast(m.nomigr as integer) as share, 
case 
	when m.nomigr = 0 then 0::text
	when m.nomigr = 999999 then 'nodata'::text
	when m.nomigr > 0 and m.nomigr < 999999 then p.score::text
end as score,
m.geom
from muc_origin m
full outer join
(select vi_nummer, nomigr as share, 
case WHEN nomigr < 1000 THEN 1 
WHEN nomigr  BETWEEN 1000 AND 1999 THEN 2
WHEN nomigr  BETWEEN 2000 AND 2999 THEN 3  
WHEN nomigr  > 2999 THEN 4 END AS score, geom 
from muc_origin where nomigr > 0 and nomigr < 99999) p 
on p.vi_nummer = m.vi_nummer
order by score, share;
$$
LANGUAGE sql;

COMMENT ON FUNCTION origin_without_migration() 
IS '**FOR-API-FUNCTION** RETURNS col_names[vi_nummer_nummer,share,score,geom] **FOR-API-FUNCTION**';


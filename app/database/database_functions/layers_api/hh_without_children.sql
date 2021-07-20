CREATE OR REPLACE FUNCTION hh_without_nochildren()
RETURNS TABLE (vi_nummer TEXT, share integer, score text, geom geometry) AS
$$
select m.vi_nummer, m.nochild::integer, 
case 
	when m.nochild = 0 then 0::text
	when m.nochild = 999999 then 'nodata'::text
	when m.nochild > 0 and m.nochild < 999999 then p.score::text
end as score,
m.geom
from muc_households m
full outer join
(select vi_nummer, nochild, 
case WHEN nochild < 1000 THEN 1 
WHEN nochild  BETWEEN 1000 AND 1999 THEN 2
WHEN nochild  BETWEEN 2000 AND 2999 THEN 3 
WHEN nochild > 2999 THEN 4 
end as score, geom
from muc_households where nochild > 0 and nochild < 99999) p 
on p.vi_nummer = m.vi_nummer
order by score;
$$
LANGUAGE sql;

COMMENT ON FUNCTION hh_without_nochildren() 
IS '**FOR-API-FUNCTION** RETURNS col_names[vi_nummer,share,score,geom] **FOR-API-FUNCTION**';


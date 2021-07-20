CREATE OR REPLACE FUNCTION age_15_64()
RETURNS TABLE (vi_nummer TEXT, pop integer, score text, geom geometry) AS
$$
select m.vi_nummer,m."15_65"::integer as pop, 
case 
	when m."15_65" = 0 then 0::text
	when m."15_65" > 999998 then 'nodata'::text
	when m."15_65" > 0 and m."15_65" < 999999 then p.score::text
end as score,
m.geom
from muc_age m
full outer join
(select vi_nummer, "15_65", 
case WHEN "15_65" < 1500 THEN 1 
WHEN "15_65"  BETWEEN 1500 AND 2999 THEN 2
WHEN "15_65"  BETWEEN 3000 AND 4499 THEN 3 
WHEN "15_65"  BETWEEN 4500 AND 10000 THEN 4 
end as score
from muc_age where "15_65" > 0 and "15_65" < 99999) p 
on p.vi_nummer = m.vi_nummer
order by score, pop;
$$
LANGUAGE sql;

COMMENT ON FUNCTION age_15_64() 
IS '**FOR-API-FUNCTION** RETURNS col_names[vi_nummer,pop,score,geom] **FOR-API-FUNCTION**';

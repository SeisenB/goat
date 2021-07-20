CREATE OR REPLACE FUNCTION age_14_under()
RETURNS TABLE (vi_nummer TEXT, pop integer, score text, geom geometry) AS
$$
select m.vi_nummer,(m."0_2"+m."3_5"+m."6_14")::integer as pop, 
case 
	when (m."0_2"+m."3_5"+m."6_14") = 0 then 0::text
	when (m."0_2"+m."3_5"+m."6_14") > 999998 then 'nodata'::text
	when (m."0_2"+m."3_5"+m."6_14") > 0 and (m."0_2"+m."3_5"+m."6_14") < 999999 then p.score::text
end as score,
m.geom
from muc_age m
full outer join
(select vi_nummer, ("0_2"+"3_5"+"6_14") as "0_14", 
case WHEN ("0_2"+"3_5"+"6_14") < 500 THEN 1 
WHEN ("0_2"+"3_5"+"6_14")  BETWEEN 500 AND 999 THEN 2
WHEN ("0_2"+"3_5"+"6_14")  BETWEEN 1000 AND 1499 THEN 3 
WHEN ("0_2"+"3_5"+"6_14")  BETWEEN 1500 AND 2300 THEN 4 
end as score
from muc_age where ("0_2"+"3_5"+"6_14") > 0 and ("0_2"+"3_5"+"6_14") < 99999) p 
on p.vi_nummer = m.vi_nummer
order by score, pop;
$$
LANGUAGE sql;

COMMENT ON FUNCTION age_14_under() 
IS '**FOR-API-FUNCTION** RETURNS col_names[vi_nummer,pop,score,geom] **FOR-API-FUNCTION**';

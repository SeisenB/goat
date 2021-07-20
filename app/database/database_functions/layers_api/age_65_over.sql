CREATE OR REPLACE FUNCTION age_65_over()
RETURNS TABLE (vi_nummer TEXT, pop integer, score text, geom geometry) AS
$$
select m.vi_nummer,(m."65_74"+m."75_ov")::integer as pop, 
case 
	when (m."65_74"+m."75_ov") = 0 then 0::text
	when (m."65_74"+m."75_ov") > 999998 then 'nodata'::text
	when (m."65_74"+m."75_ov") > 0 and (m."65_74"+m."75_ov") < 999999 then p.score::text
end as score,
m.geom
from muc_age m
full outer join
(select vi_nummer, ("65_74"+"75_ov") as "0_14", 
case WHEN ("65_74"+"75_ov") < 500 THEN 1 
WHEN ("65_74"+"75_ov")  BETWEEN 500 AND 999 THEN 2
WHEN ("65_74"+"75_ov")  BETWEEN 1000 AND 1499 THEN 3 
WHEN ("65_74"+"75_ov")  BETWEEN 1500 AND 3000 THEN 4 
end as score
from muc_age where ("65_74"+"75_ov") > 0 and ("65_74"+"75_ov") < 99999) p 
on p.vi_nummer = m.vi_nummer
order by score, pop;
$$
LANGUAGE sql;

COMMENT ON FUNCTION age_65_over() 
IS '**FOR-API-FUNCTION** RETURNS col_names[vi_nummer,pop,score,geom] **FOR-API-FUNCTION**';

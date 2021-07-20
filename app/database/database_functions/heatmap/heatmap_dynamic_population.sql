DROP FUNCTION IF EXISTS heatmap_dynamic_population;
CREATE OR REPLACE FUNCTION public.heatmap_dynamic_population(amenities_json jsonb, modus_input text DEFAULT 'default', scenario_id_input integer DEFAULT 0)
 RETURNS TABLE(grid_id integer, accessibility_index bigint, ai_pop float)
 LANGUAGE plpgsql
AS $function$
DECLARE
	array_amenities text[];
	pois_one_entrance text[] := select_from_variable_container('pois_one_entrance');
	pois_more_entrances text[] := select_from_variable_container('pois_more_entrances');
	sensitivities integer[] := select_from_variable_container('heatmap_sensitivities')::integer[];
	translation_sensitivities jsonb;
	excluded_pois_id integer[];
	user_groups text[] := select_from_variable_container('userGroups')::text[];
	translation_user_groups jsonb;
BEGIN
  	
	SELECT array_agg(_keys)
	INTO array_amenities
	FROM (SELECT jsonb_object_keys(amenities_json) _keys) x;
	
	SELECT jsonb_object_agg(k, (sensitivities  # (v ->> 'sensitivity')::integer)::smallint)
	INTO translation_sensitivities
	FROM jsonb_each(amenities_json) AS u(k, v);

	SELECT jsonb_object_agg(k, array_position(user_groups, (v ->> 'userGroup'))::smallint)
	INTO translation_user_groups
	FROM jsonb_each(amenities_json) AS u(k, v);

	/*IF modus_input = 'default' THEN*/
		if 'nursery' in (select unnest(array_amenities)) and 'Unter 3 Jahren' in (select unnest(user_groups)) then
			RETURN query
			select y.grid_id, sum(y.accessibility_index*(1)) as accessibility_index, sum(y.ai_pop*(1)) as accessibility_index_population from
			(SELECT x.gid, u.grid_id, x.amenity, u.accessibility_index*((amenities_json -> x.amenity ->> 'weight')::integer)::SMALLINT AS accessibility_index, (u.accessibility_index*x.capacity* ((amenities_json -> x.amenity ->> 'weight')::integer)) / z.ai_pop::FLOAT(16) AS ai_pop  
				FROM (
					SELECT h.gid, h.gridids, h.amenity, h.accessibility_indices[(translation_sensitivities ->> h.amenity)::integer:(translation_sensitivities ->> h.amenity)::integer][1:], s.capacity
					FROM reached_pois_heatmap h, pois s
					WHERE h.amenity IN (SELECT UNNEST(pois_one_entrance))
					AND h.amenity IN (SELECT UNNEST(array_amenities))
					AND h.scenario_id = 0
					and h.gid = s.gid
				)x, UNNEST(x.gridids, x.accessibility_indices) AS u(grid_id, accessibility_index),
				(select p.gid, sum(p.accessibility_pop) as ai_pop from (
					select r.gid, r.gridid, r.accessibility_index*((amenities_json -> r.amenity ->> 'weight')::integer)*unnest(g.usergroups[(translation_user_groups ->> r.amenity)::integer:(translation_user_groups ->> r.amenity)::integer])*0.6 as accessibility_pop from (
					select gid, amenity, unnest(gridids) as gridid, unnest(accessibility_indices[(translation_sensitivities ->> m.amenity)::integer:(translation_sensitivities ->> m.amenity)::integer][1:]) as accessibility_index 
					from reached_pois_heatmap m
					WHERE m.amenity IN (SELECT UNNEST(pois_one_entrance))
					AND m.amenity IN (SELECT UNNEST(array_amenities))
					AND scenario_id = 0) r, 
					grid_heatmap g, unnest(g.usergroups[(translation_user_groups ->> r.amenity)::integer:(translation_user_groups ->> r.amenity)::integer]) as userGroup where r.gridid = g.grid_id and userGroup > 0) p group by p.gid) z
				where x.gid = z.gid) y group by y.grid_id;
		else 
			RETURN query
			select y.grid_id, sum(y.accessibility_index*(1)) as accessibility_index, sum(y.ai_pop*(1)) as accessibility_index_population from
			(SELECT x.gid, u.grid_id, x.amenity, u.accessibility_index*((amenities_json -> x.amenity ->> 'weight')::integer)::SMALLINT AS accessibility_index, (u.accessibility_index*x.capacity* (amenities_json -> x.amenity ->> 'weight')) / z.ai_pop::FLOAT(16) AS ai_pop  
				FROM (
					SELECT h.gid, h.gridids, h.amenity, h.accessibility_indices[(translation_sensitivities ->> h.amenity)::integer:(translation_sensitivities ->> h.amenity)::integer][1:], s.capacity
					FROM reached_pois_heatmap h, pois s
					WHERE h.amenity IN (SELECT UNNEST(pois_one_entrance))
					AND h.amenity IN (SELECT UNNEST(array_amenities))
					AND h.scenario_id = 0
					and h.gid = s.gid
				)x, UNNEST(x.gridids, x.accessibility_indices) AS u(grid_id, accessibility_index),
				(select p.gid, sum(p.accessibility_pop) as ai_pop from (
					select r.gid, r.gridid, r.accessibility_index*((amenities_json -> r.amenity ->> 'weight')::integer)*unnest(g.usergroups[(translation_user_groups ->> r.amenity)::integer:(translation_user_groups ->> r.amenity)::integer]) as accessibility_pop from (
					select gid, amenity, unnest(gridids) as gridid, unnest(accessibility_indices[(translation_sensitivities ->> m.amenity)::integer:(translation_sensitivities ->> m.amenity)::integer][1:]) as accessibility_index 
					from reached_pois_heatmap m
					WHERE m.amenity IN (SELECT UNNEST(pois_one_entrance))
					AND m.amenity IN (SELECT UNNEST(array_amenities))
					AND scenario_id = 0) r, 
					grid_heatmap g, unnest(g.usergroups[(translation_user_groups ->> r.amenity)::integer:(translation_user_groups ->> r.amenity)::integer]) as userGroup where r.gridid = g.grid_id and userGroup > 0) p group by p.gid) z
				where x.gid = z.gid) y group by y.grid_id;
		end if;

		/*SELECT s.grid_id, s.amenity, sum(s.accessibility_index) AS accessibility_index 
		FROM 
		(
			SELECT u.grid_id, x.amenity, u.accessibility_index * (amenities_json -> x.amenity ->> 'weight')::SMALLINT AS accessibility_index  
			FROM (
				SELECT gridids, amenity, accessibility_indices[(translation_sensitivities ->> amenity)::integer:(translation_sensitivities ->> amenity)::integer][1:]
				FROM reached_pois_heatmap 
				WHERE amenity IN (SELECT UNNEST(pois_one_entrance))
				AND amenity IN (SELECT UNNEST(array_amenities))
				AND scenario_id = 0
			)x, UNNEST(x.gridids, x.accessibility_indices) AS u(grid_id, accessibility_index)
			UNION ALL 
			SELECT u.grid_id, x.amenity, max(u.accessibility_index) * (amenities_json -> x.amenity ->> 'weight')::SMALLINT AS accessibility_index
			FROM (
				SELECT gridids, amenity, name,  accessibility_indices[(translation_sensitivities ->> amenity)::integer:(translation_sensitivities ->> amenity)::integer][1:]
				FROM reached_pois_heatmap
				WHERE amenity IN (SELECT UNNEST(pois_more_entrances))
				AND amenity IN (SELECT UNNEST(array_amenities))
				AND scenario_id = 0
			)x, UNNEST(x.gridids, x.accessibility_indices) AS u(grid_id, accessibility_index)
			GROUP BY u.grid_id, x.name, x.amenity
		) s
		GROUP BY s.grid_id, s.amenity;*/
	/*ELSE
		excluded_pois_id = ids_modified_features(scenario_id_input,'pois');
		RETURN query 
		WITH null_grids AS 
		(
			SELECT DISTINCT UNNEST(gridids) grid_id, amenity,0 accessibility_index
			FROM reached_pois_heatmap 
			WHERE gid IN (SELECT UNNEST(excluded_pois_id))
		),
		grouped_grids AS 
		(
			SELECT s.grid_id, s.amenity, sum(s.accessibility_index) AS accessibility_index 
			FROM 
			(
				SELECT u.grid_id, x.amenity, u.accessibility_index * (amenities_json -> x.amenity ->> 'weight')::SMALLINT AS accessibility_index  
				FROM (
					SELECT r.gridids, r.amenity, accessibility_indices[(translation_sensitivities ->> amenity)::integer:(translation_sensitivities ->> amenity)::integer][1:]
					FROM reached_pois_heatmap r
					LEFT JOIN 
					(	
						SELECT gid FROM reached_pois_heatmap 
						WHERE scenario_id = scenario_id_input 
						AND amenity IN (SELECT UNNEST(pois_one_entrance))
						AND amenity IN (SELECT UNNEST(array_amenities))
					) s
					ON r.gid = s.gid 
					WHERE s.gid IS NULL 
					AND r.scenario_id = 0
					AND amenity IN (SELECT UNNEST(pois_one_entrance))
					AND amenity IN (SELECT UNNEST(array_amenities))
					AND r.gid NOT IN (SELECT UNNEST(excluded_pois_id))
					UNION ALL 				
					SELECT gridids, amenity, accessibility_indices[(translation_sensitivities ->> amenity)::integer:(translation_sensitivities ->> amenity)::integer][1:]
					FROM reached_pois_heatmap 
					WHERE amenity IN (SELECT UNNEST(pois_one_entrance))
					AND amenity IN (SELECT UNNEST(array_amenities))
					AND scenario_id = scenario_id_input 
				)x, UNNEST(x.gridids, x.accessibility_indices) AS u(grid_id, accessibility_index)
				UNION ALL 
				SELECT u.grid_id, x.amenity, max(u.accessibility_index) * (amenities_json -> x.amenity ->> 'weight')::SMALLINT AS accessibility_index
				FROM (
					SELECT gridids, amenity, name, accessibility_indices[(translation_sensitivities ->> amenity)::integer:(translation_sensitivities ->> amenity)::integer][1:]
					FROM reached_pois_heatmap r
					LEFT JOIN 
					(
						SELECT gid 
						FROM reached_pois_heatmap 
						WHERE scenario_id = scenario_id_input
						AND amenity IN (SELECT UNNEST(pois_more_entrances))
						AND amenity IN (SELECT UNNEST(array_amenities))
					) s
					ON r.gid = s.gid 
					WHERE s.gid IS NULL
					AND r.scenario_id = 0
					AND amenity IN (SELECT UNNEST(array_amenities))
					AND amenity IN (SELECT UNNEST(pois_more_entrances))
					AND r.gid NOT IN (SELECT UNNEST(excluded_pois_id))
					UNION ALL 				
					SELECT gridids, amenity, name, accessibility_indices[(translation_sensitivities ->> amenity)::integer:(translation_sensitivities ->> amenity)::integer][1:]
					FROM reached_pois_heatmap 
					WHERE amenity IN (SELECT UNNEST(pois_more_entrances))
					AND amenity IN (SELECT UNNEST(array_amenities))
					AND scenario_id = scenario_id_input
				)x, UNNEST(x.gridids, x.accessibility_indices) AS u(grid_id, accessibility_index)
				GROUP BY u.grid_id, x.amenity, x.name	
			) s
			GROUP BY s.grid_id
		)
		SELECT n.grid_id, n.amenity, n.accessibility_index
		FROM null_grids n 
		LEFT JOIN grouped_grids g
		ON n.grid_id = g.grid_id 
		WHERE g.grid_id IS NULL
		UNION ALL 
		SELECT * FROM grouped_grids; 
	END IF;*/
END;
$function$;
/*
DROP TABLE scenario;
CREATE TABLE scenario AS 
SELECT h.*, g.geom  
FROM heatmap_dynamic('{"kindergarten":{"sensitivity":250000,"weight":1}}'::jsonb,'scenario',13) h, grid_heatmap g
WHERE h.grid_id = g.grid_id; 

DROP TABLE default_;
CREATE TABLE default_ AS 
SELECT h.*, g.geom  
FROM heatmap_dynamic('{"kindergarten":{"sensitivity":250000,"weight":1}}'::jsonb,'default',13) h, grid_heatmap g
WHERE h.grid_id = g.grid_id; 
*/




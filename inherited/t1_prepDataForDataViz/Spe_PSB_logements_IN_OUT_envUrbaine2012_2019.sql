DROP INDEX IF EXISTS "ff_2020".idx_fftp_2020_pb0010_local;
CREATE INDEX idx_fftp_2020_pb0010_local ON "ff_2020".fftp_2020_pb0010_local USING gist(geomloc);

DROP TABLE IF EXISTS "ff_2020"."spe_DEN_densite_log_evol2012_2020";
CREATE TABLE "ff_2020"."spe_DEN_densite_log_evol2012_2020" AS (
	--Before 2012
	-- Nombre total de locaux par commune. Les communes sans locaux n'apparaitront pas dans la table finale
	 with total_by_com AS ( 
		SELECT t.insee insee, Count(a.geomloc) "Count_ENTITIES"
		FROM "ff_2020"."fftp_2020_pb0010_local" a, public."communes_PSB_scot_2015" t
		WHERE ST_Intersects(a.geomloc,t.geom)
		and jannath < 2012 AND dteloc IN ('1','2')
		GROUP BY t.insee
	),
	-- Nombre de locaux dans la centralité par commune
	total_by_com_in_env AS (
		SELECT t.insee insee, Count(a.geomloc) "Count_ENTITIES",'IN' "Location"
		FROM "ff_2020"."fftp_2020_pb0010_local" a, public."communes_PSB_scot_2015" t, public."Env_Urbaine_2012_pourCalcul" env
		WHERE ST_Intersects(a.geomloc,t.geom) AND ST_Intersects(a.geomloc,env.geom)
		and jannath < 2012 AND dteloc IN ('1','2')
		GROUP BY t.insee, "Location"
	),
	-- Nombre de locaux hors centralités par commune
	total_by_com_out_env AS (
		SELECT total_by_com.insee insee, SUM(total_by_com."Count_ENTITIES" - COALESCE(total_by_com_in_env."Count_ENTITIES",0)) "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com, total_by_com_in_env
		WHERE total_by_com.insee = total_by_com_in_env.insee
		GROUP BY total_by_com.insee, "Location"
		UNION 
		-- Ça c'est pour gérer les communes qui auraient des locaux, mais aucun dans le périmètre de centralité
		-- Attention à cette étape, si la commune est multi-partie on aura sans doute un problème
		SELECT total_by_com.insee insee, total_by_com."Count_ENTITIES" "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com, total_by_com_in_env
		WHERE total_by_com.insee NOT IN (SELECT insee FROM total_by_com_in_env)
		GROUP BY total_by_com.insee, total_by_com."Count_ENTITIES", "Location"
	),
	-- Union par commune du nombre de locaux dans/hors la centralité
	before as(
	SELECT insee::text, "Count_ENTITIES"::int "Count_ENTITIES%_11", "Location"::text "Location%_11" FROM total_by_com_in_env
	UNION
	SELECT insee::text, "Count_ENTITIES"::int "Count_ENTITIES%_11", "Location"::text "Location%_11" FROM total_by_com_out_env
	ORDER BY insee, "Location%_11"
	),

---------
--- after 2012
---------
    total_by_com20 AS ( 
		SELECT t.insee insee, Count(a.geomloc) "Count_ENTITIES"
		FROM "ff_2020"."fftp_2020_pb0010_local" a, public."communes_PSB_scot_2015" t
		WHERE ST_Intersects(a.geomloc,t.geom)
		and jannath>= 2012 AND dteloc IN ('1','2')
		GROUP BY t.insee
	),
	-- Nombre de locaux dans la centralité par commune
	total_by_com20_in_env AS (
		SELECT t.insee insee, Count(a.geomloc) "Count_ENTITIES",'IN' "Location"
		FROM "ff_2020"."fftp_2020_pb0010_local" a, public."communes_PSB_scot_2015" t, public."Env_Urbaine_2012_pourCalcul" env
		WHERE ST_Intersects(a.geomloc,t.geom) AND ST_Intersects(a.geomloc,env.geom)
		and jannath>= 2012 AND dteloc IN ('1','2')
		GROUP BY t.insee, "Location"
	),
	-- Nombre de locaux hors centralités par commune
	total_by_com20_out_env AS (
		SELECT total_by_com20.insee insee, SUM(total_by_com20."Count_ENTITIES" - COALESCE(total_by_com20_in_env."Count_ENTITIES",0)) "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com20, total_by_com20_in_env
		WHERE total_by_com20.insee = total_by_com20_in_env.insee
		GROUP BY total_by_com20.insee, "Location"
		UNION 
		-- Ça c'est pour gérer les communes qui auraient des locaux, mais aucun dans le périmètre de centralité
		-- Attention à cette étape, si la commune est multi-partie on aura sans doute un problème
		SELECT total_by_com20.insee insee, total_by_com20."Count_ENTITIES" "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com20, total_by_com20_in_env
		WHERE total_by_com20.insee NOT IN (SELECT insee FROM total_by_com20_in_env)
		GROUP BY total_by_com20.insee, total_by_com20."Count_ENTITIES", "Location"
	),
	after as(
	-- Union par commune du nombre de locaux dans/hors la centralité
	SELECT insee::text, "Count_ENTITIES"::int "Count_ENTITIES12_19", "Location"::text "Location12_19" FROM total_by_com20_in_env
	UNION
	SELECT insee::text, "Count_ENTITIES"::int "Count_ENTITIES12_19", "Location"::text "Location12_19" FROM total_by_com20_out_env
	ORDER BY insee, "Location12_19"
	)
	select c.geom,b.insee,b."Location%_11",coalesce(b."Count_ENTITIES%_11"::int,0) "Count_%_11", coalesce(a."Count_ENTITIES12_19"::int,0) "Count_12_19" 
	from before b
	left join after a
	on a.insee=b.insee
	and a."Location12_19"=b."Location%_11"
	left join public."territory_table_PSB2015" c 
	on
	c.insee = a.insee
	where c.rank=1
	
	);


drop table if exists "spe_DEN_densite_log_evol2012_2020"."spe_DEN_densite_log_evol2012_2020_SCoT";
create table "spe_DEN_densite_log_evol2012_2020"."spe_DEN_densite_log_evol2012_2020_SCoT" as(

with t1 as (
select geom,insee,"Location%_11","Count_%_11","Count_12_19" from "ff_2020"."spe_DEN_densite_log_evol2012_2020"
order by insee
),
	rank2 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."territory_table_PSB2015"
			WHERE rank = 2
			GROUP BY id_geom
	),
	--Niv 2 : Polarités
	t2 as (
		select rank2.geom,rank2.id_geom as insee,"Location%_11",sum("Count_%_11")"Count_%_11",sum("Count_12_19") "Count_12_19"
		from rank2
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank2.geom)
		GROUP BY rank2.id_geom,rank2.geom,"Location%_11"
	),
	-- Géométries niveau 3 de la table territoire
	rank3 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."territory_table_PSB2015"
			WHERE rank = 3
			GROUP BY id_geom
	),
	-- Données à l'EPCI
	t3 as (
		select rank3.geom,rank3.id_geom as insee,"Location%_11",sum("Count_%_11")"Count_%_11",sum("Count_12_19") "Count_12_19"
		from rank3
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank3.geom)
		GROUP BY rank3.id_geom,rank3.geom,"Location%_11"
	)
	select insee,"Location%_11","Count_%_11","Count_12_19" from t1
	union all
	select insee,"Location%_11","Count_%_11","Count_12_19" from t2
	union all
	select insee,"Location%_11","Count_%_11","Count_12_19" from t3)



--F1_MOB_Isochrone_Gares_LogementsSociaux


--/--/--/--/--/-
--/-- 2021 --/--
--/--/--/--/--/-

DROP TABLE IF EXISTS "F1_MOB_Isochrone_Gares_LogementsSociaux".F1_MOB_Isochrone_Gares_LogementsSociaux_2021;
CREATE TABLE "F1_MOB_Isochrone_Gares_LogementsSociaux".F1_MOB_Isochrone_Gares_LogementsSociaux_2021 AS (
	-- Nombre total de rpls par commune. Les communes sans rpls n'apparaitront pas dans la table finale
	WITH total_by_com AS ( 
		SELECT t.id_geom id_geom, Count(rpls.geom) "Count_ENTITIES"
		FROM "F1_MOB_Isochrone_Gares_LogementsSociaux"."geo_BANonly_RPLS2021" rpls, public."TerritoryTable_PST_2020_2154" t
		WHERE ST_Intersects(rpls.geom,t.geom)
		GROUP BY id_geom
	),
	-- Nombre de rpls dans la centralité par commune
	total_by_com_in_iso AS (
		SELECT t.id_geom id_geom, iso."time", Count(rpls.geom) "Count_ENTITIES",'IN' "Location"
		FROM "F1_MOB_Isochrone_Gares_LogementsSociaux"."geo_BANonly_RPLS2021" rpls, public."TerritoryTable_PST_2020_2154" t, "F1_MOB_Isochrone_Gares_LogementsSociaux"."Isochrones_5_10_15_pied_Gares_SGEvT" iso
		WHERE ST_Intersects(rpls.geom,t.geom) AND ST_Intersects(rpls.geom,iso.geom)
		GROUP BY id_geom, "time", "Location"
	),
	-- Nombre de rpls hors centralités par commune
	total_by_com_out_iso AS (
		SELECT total_by_com.id_geom id_geom, total_by_com_in_iso."time", SUM(total_by_com."Count_ENTITIES" - total_by_com_in_iso."Count_ENTITIES") "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com, total_by_com_in_iso
		WHERE total_by_com.id_geom = total_by_com_in_iso.id_geom
		GROUP BY total_by_com.id_geom, total_by_com_in_iso."time", "Location"
		UNION 
		-- Ça c'est pour gérer les communes qui auraient des rpls, mais aucun dans le périmètre de centralité
		-- Attention à cette étape, si la commune est multi-partie on aura sans doute un problème
		SELECT total_by_com.id_geom id_geom, total_by_com_in_iso."time", total_by_com."Count_ENTITIES" "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com, total_by_com_in_iso
		WHERE total_by_com.id_geom NOT IN (SELECT id_geom FROM total_by_com_in_iso)
		GROUP BY total_by_com.id_geom, total_by_com_in_iso."time", total_by_com."Count_ENTITIES", "Location"
	)
	-- Union par commune du nombre de rpls dans/hors la centralité
	SELECT id_geom::text, "time"::int, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_in_iso
	UNION
	SELECT id_geom::text, "time"::int, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_out_iso
	ORDER BY id_geom, "Location"
);
SELECT * FROM "F1_MOB_Isochrone_Gares_LogementsSociaux".F1_MOB_Isochrone_Gares_LogementsSociaux_2021;



--/--/--/--/--/-
--/-- 2019 --/--
--/--/--/--/--/-

DROP TABLE IF EXISTS "F1_MOB_Isochrone_Gares_LogementsSociaux".F1_MOB_Isochrone_Gares_LogementsSociaux_2019;
CREATE TABLE "F1_MOB_Isochrone_Gares_LogementsSociaux".F1_MOB_Isochrone_Gares_LogementsSociaux_2019 AS (
	-- Nombre total de rpls par commune. Les communes sans rpls n'apparaitront pas dans la table finale
	WITH total_by_com AS ( 
		SELECT t.id_geom id_geom, Count(rpls.geom) "Count_ENTITIES"
		FROM "F1_MOB_Isochrone_Gares_LogementsSociaux"."geo_BANonly_RPLS2019_detail_PST" rpls, public."TerritoryTable_PST_2019_maj_2020.01.14" t
		WHERE ST_Intersects(rpls.geom,t.geom)
		GROUP BY id_geom
	),
	-- Nombre de rpls dans la centralité par commune
	total_by_com_in_iso AS (
		SELECT t.id_geom id_geom, iso."time", Count(rpls.geom) "Count_ENTITIES",'IN' "Location"
		FROM "F1_MOB_Isochrone_Gares_LogementsSociaux"."geo_BANonly_RPLS2019_detail_PST" rpls, public."TerritoryTable_PST_2019_maj_2020.01.14" t, "F1_MOB_Isochrone_Gares_LogementsSociaux"."Isochrones_5_10_15_pied_Gares_SGEvT" iso
		WHERE ST_Intersects(rpls.geom,t.geom) AND ST_Intersects(rpls.geom,iso.geom)
		GROUP BY id_geom, "time", "Location"
	),
	-- Nombre de rpls hors centralités par commune
	total_by_com_out_iso AS (
		SELECT total_by_com.id_geom id_geom, total_by_com_in_iso."time", SUM(total_by_com."Count_ENTITIES" - total_by_com_in_iso."Count_ENTITIES") "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com, total_by_com_in_iso
		WHERE total_by_com.id_geom = total_by_com_in_iso.id_geom
		GROUP BY total_by_com.id_geom, total_by_com_in_iso."time", "Location"
		UNION 
		-- Ça c'est pour gérer les communes qui auraient des rpls, mais aucun dans le périmètre de centralité
		-- Attention à cette étape, si la commune est multi-partie on aura sans doute un problème
		SELECT total_by_com.id_geom id_geom, total_by_com_in_iso."time", total_by_com."Count_ENTITIES" "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com, total_by_com_in_iso
		WHERE total_by_com.id_geom NOT IN (SELECT id_geom FROM total_by_com_in_iso)
		GROUP BY total_by_com.id_geom, total_by_com_in_iso."time", total_by_com."Count_ENTITIES", "Location"
	)
	-- Union par commune du nombre de rpls dans/hors la centralité
	SELECT id_geom::text, "time"::int, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_in_iso
	UNION
	SELECT id_geom::text, "time"::int, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_out_iso
	ORDER BY id_geom, "Location"
);
SELECT * FROM "F1_MOB_Isochrone_Gares_LogementsSociaux".F1_MOB_Isochrone_Gares_LogementsSociaux_2019;


--/--/--/--/--/-
--/-- 2016 --/--
--/--/--/--/--/-

DROP TABLE IF EXISTS "F1_MOB_Isochrone_Gares_LogementsSociaux".F1_MOB_Isochrone_Gares_LogementsSociaux_2016;
CREATE TABLE "F1_MOB_Isochrone_Gares_LogementsSociaux".F1_MOB_Isochrone_Gares_LogementsSociaux_2016 AS (
	-- Nombre total de rpls par commune. Les communes sans rpls n'apparaitront pas dans la table finale
	WITH total_by_com AS ( 
		SELECT t.id_geom id_geom, Count(rpls.geom) "Count_ENTITIES"
		FROM "F1_MOB_Isochrone_Gares_LogementsSociaux"."F1_MOB_Isochrone_Gares_LogementsSociaux_rpls_2016" rpls, public."TerritoryTable_PST_2019_maj_2020.01.14" t
		WHERE ST_Intersects(rpls.geom,t.geom)
		GROUP BY id_geom
	),
	-- Nombre de rpls dans la centralité par commune
	total_by_com_in_iso AS (
		SELECT t.id_geom id_geom, iso."time", Count(rpls.geom) "Count_ENTITIES",'IN' "Location"
		FROM "F1_MOB_Isochrone_Gares_LogementsSociaux"."F1_MOB_Isochrone_Gares_LogementsSociaux_rpls_2016" rpls, public."TerritoryTable_PST_2019_maj_2020.01.14" t, "F1_MOB_Isochrone_Gares_LogementsSociaux"."Isochrones_5_10_15_pied_Gares_SGEvT" iso
		WHERE ST_Intersects(rpls.geom,t.geom) AND ST_Intersects(rpls.geom,iso.geom)
		GROUP BY id_geom, "time", "Location"
	),
	-- Nombre de rpls hors centralités par commune
	total_by_com_out_iso AS (
		SELECT total_by_com.id_geom id_geom, total_by_com_in_iso."time", SUM(total_by_com."Count_ENTITIES" - total_by_com_in_iso."Count_ENTITIES") "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com, total_by_com_in_iso
		WHERE total_by_com.id_geom = total_by_com_in_iso.id_geom
		GROUP BY total_by_com.id_geom, total_by_com_in_iso."time", "Location"
		UNION 
		-- Ça c'est pour gérer les communes qui auraient des rpls, mais aucun dans le périmètre de centralité
		-- Attention à cette étape, si la commune est multi-partie on aura sans doute un problème
		SELECT total_by_com.id_geom id_geom, total_by_com_in_iso."time", total_by_com."Count_ENTITIES" "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com, total_by_com_in_iso
		WHERE total_by_com.id_geom NOT IN (SELECT id_geom FROM total_by_com_in_iso)
		GROUP BY total_by_com.id_geom, total_by_com_in_iso."time", total_by_com."Count_ENTITIES", "Location"
	)
	-- Union par commune du nombre de rpls dans/hors la centralité
	SELECT id_geom::text, "time"::int, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_in_iso
	UNION
	SELECT id_geom::text, "time"::int, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_out_iso
	ORDER BY id_geom, "Location"
);
SELECT * FROM "F1_MOB_Isochrone_Gares_LogementsSociaux".F1_MOB_Isochrone_Gares_LogementsSociaux_2016;
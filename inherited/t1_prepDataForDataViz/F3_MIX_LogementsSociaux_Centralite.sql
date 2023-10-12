-- F3_MIX_LogementsSociaux_Centralite


-- Variables à remplacer:
-- le nom du schema:		"F3_MIX_LogementsSociaux_Centralite"
-- le nom du 2ème schéma 	public
-- la table de centralité 	centralite
-- RPLS 2020:				geoRPLS_2020_PF
-- RPLS 2019:				geoRPLS_2019_PF
-- RPLS 2018:				geoRPLS_2018_PF
-- RPLS 2017:				geoRPLS_2017_PF


--/--/--/--/--/-
--/-- 2021 --/--
--/--/--/--/--/-

DROP TABLE IF EXISTS "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2021;
CREATE TABLE "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2021 AS (
	-- Nombre total de locaux par commune. Les communes sans locaux n'apparaitront pas dans la table finale
	WITH total_by_com AS ( 
		SELECT t.id_geom id_geom, Count(a.geom) "Count_ENTITIES"
		FROM "F3_MIX_LogementsSociaux_Centralite"."F3_MIX_LogementsSociaux_points_2021" a, public."territory_table_CAP20" t
		WHERE ST_Intersects(a.geom,t.geom)
		GROUP BY id_geom
	),
	-- Nombre de locaux dans la centralité par commune
	total_by_com_in_env AS (
		SELECT t.id_geom id_geom, Count(a.geom) "Count_ENTITIES",'IN' "Location"
		FROM "F3_MIX_LogementsSociaux_Centralite"."F3_MIX_LogementsSociaux_points_2021" a, public."territory_table_CAP20" t, public."centralite_cap_2022_postprocessed" env
		WHERE ST_Intersects(a.geom,t.geom) AND ST_Intersects(a.geom,env.geom)
		GROUP BY id_geom, "Location"
	),
	-- Nombre de locaux hors centralités par commune
	total_by_com_out_env AS (
		SELECT total_by_com.id_geom id_geom, SUM(total_by_com."Count_ENTITIES" - total_by_com_in_env."Count_ENTITIES") "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com, total_by_com_in_env
		WHERE total_by_com.id_geom = total_by_com_in_env.id_geom
		GROUP BY total_by_com.id_geom, "Location"
		UNION 
		-- Ça c'est pour gérer les communes qui auraient des locaux, mais aucun dans le périmètre de centralité
		-- Attention à cette étape, si la commune est multi-partie on aura sans doute un problème
		SELECT total_by_com.id_geom id_geom, total_by_com."Count_ENTITIES" "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com, total_by_com_in_env
		WHERE total_by_com.id_geom NOT IN (SELECT id_geom FROM total_by_com_in_env)
		GROUP BY total_by_com.id_geom, total_by_com."Count_ENTITIES", "Location"
	)
	-- Union par commune du nombre de locaux dans/hors la centralité
	SELECT id_geom::text, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_in_env
	UNION
	SELECT id_geom::text, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_out_env
	ORDER BY id_geom, "Location"
);
DELETE FROM "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2021
WHERE "Count_ENTITIES" = 0; -- On supprime les lignes avec un compte à zéro, c'est pour coller au code de la dataviz.
SELECT * FROM "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2021;


--/--/--/--/--/-
--/-- 2020 --/--
--/--/--/--/--/-

DROP TABLE IF EXISTS "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2020;
CREATE TABLE "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2020 AS (
	-- Nombre total de locaux par commune. Les communes sans locaux n'apparaitront pas dans la table finale
	WITH total_by_com AS ( 
		SELECT t.id_geom id_geom, Count(a.geom) "Count_ENTITIES"
		FROM "F3_MIX_LogementsSociaux_Centralite"."geoRPLS_2020_PF" a, public."TerritoryTable_PF_2019" t
		WHERE ST_Intersects(a.geom,t.geom)
		GROUP BY id_geom
	),
	-- Nombre de locaux dans la centralité par commune
	total_by_com_in_env AS (
		SELECT t.id_geom id_geom, Count(a.geom) "Count_ENTITIES",'IN' "Location"
		FROM "F3_MIX_LogementsSociaux_Centralite"."geoRPLS_2020_PF" a, public."TerritoryTable_PF_2019" t, public."centralite" env
		WHERE ST_Intersects(a.geom,t.geom) AND ST_Intersects(a.geom,env.geom)
		GROUP BY id_geom, "Location"
	),
	-- Nombre de locaux hors centralités par commune
	total_by_com_out_env AS (
		SELECT total_by_com.id_geom id_geom, SUM(total_by_com."Count_ENTITIES" - total_by_com_in_env."Count_ENTITIES") "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com, total_by_com_in_env
		WHERE total_by_com.id_geom = total_by_com_in_env.id_geom
		GROUP BY total_by_com.id_geom, "Location"
		UNION 
		-- Ça c'est pour gérer les communes qui auraient des locaux, mais aucun dans le périmètre de centralité
		-- Attention à cette étape, si la commune est multi-partie on aura sans doute un problème
		SELECT total_by_com.id_geom id_geom, total_by_com."Count_ENTITIES" "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com, total_by_com_in_env
		WHERE total_by_com.id_geom NOT IN (SELECT id_geom FROM total_by_com_in_env)
		GROUP BY total_by_com.id_geom, total_by_com."Count_ENTITIES", "Location"
	)
	-- Union par commune du nombre de locaux dans/hors la centralité
	SELECT id_geom::text, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_in_env
	UNION
	SELECT id_geom::text, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_out_env
	ORDER BY id_geom, "Location"
);
DELETE FROM "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2020
WHERE "Count_ENTITIES" = 0; -- On supprime les lignes avec un compte à zéro, c'est pour coller au code de la dataviz.
SELECT * FROM "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2020;


--/--/--/--/--/-
--/-- 2019 --/--
--/--/--/--/--/-

DROP TABLE IF EXISTS "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2019;
CREATE TABLE "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2019 AS (
	-- Nombre total de locaux par commune. Les communes sans locaux n'apparaitront pas dans la table finale
	WITH total_by_com AS ( 
		SELECT t.id_geom id_geom, Count(a.geom) "Count_ENTITIES"
		FROM "F3_MIX_LogementsSociaux_Centralite"."geoRPLS_2019_PF" a, public."TerritoryTable_PF_2019" t
		WHERE ST_Intersects(a.geom,t.geom)
		GROUP BY id_geom
	),
	-- Nombre de locaux dans la centralité par commune
	total_by_com_in_env AS (
		SELECT t.id_geom id_geom, Count(a.geom) "Count_ENTITIES",'IN' "Location"
		FROM "F3_MIX_LogementsSociaux_Centralite"."geoRPLS_2019_PF" a, public."TerritoryTable_PF_2019" t, public."centralite" env
		WHERE ST_Intersects(a.geom,t.geom) AND ST_Intersects(a.geom,env.geom)
		GROUP BY id_geom, "Location"
	),
	-- Nombre de locaux hors centralités par commune
	total_by_com_out_env AS (
		SELECT total_by_com.id_geom id_geom, SUM(total_by_com."Count_ENTITIES" - total_by_com_in_env."Count_ENTITIES") "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com, total_by_com_in_env
		WHERE total_by_com.id_geom = total_by_com_in_env.id_geom
		GROUP BY total_by_com.id_geom, "Location"
		UNION 
		-- Ça c'est pour gérer les communes qui auraient des locaux, mais aucun dans le périmètre de centralité
		-- Attention à cette étape, si la commune est multi-partie on aura sans doute un problème
		SELECT total_by_com.id_geom id_geom, total_by_com."Count_ENTITIES" "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com, total_by_com_in_env
		WHERE total_by_com.id_geom NOT IN (SELECT id_geom FROM total_by_com_in_env)
		GROUP BY total_by_com.id_geom, total_by_com."Count_ENTITIES", "Location"
	)
	-- Union par commune du nombre de locaux dans/hors la centralité
	SELECT id_geom::text, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_in_env
	UNION
	SELECT id_geom::text, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_out_env
	ORDER BY id_geom, "Location"
);
DELETE FROM "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2019
WHERE "Count_ENTITIES" = 0; -- On supprime les lignes avec un compte à zéro, c'est pour coller au code de la dataviz.
SELECT * FROM "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2019;


--/--/--/--/--/-
--/-- 2018 --/--
--/--/--/--/--/-

DROP TABLE IF EXISTS "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2018;
CREATE TABLE "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2018 AS (
	-- Nombre total de locaux par commune. Les communes sans locaux n'apparaitront pas dans la table finale
	WITH total_by_com AS ( 
		SELECT t.id_geom id_geom, Count(a.geom) "Count_ENTITIES"
		FROM "F3_MIX_LogementsSociaux_Centralite"."geoRPLS_2018_PF" a, public."TerritoryTable_PF_2019" t
		WHERE ST_Intersects(a.geom,t.geom)
		GROUP BY id_geom
	),
	-- Nombre de locaux dans la centralité par commune
	total_by_com_in_env AS (
		SELECT t.id_geom id_geom, Count(a.geom) "Count_ENTITIES",'IN' "Location"
		FROM "F3_MIX_LogementsSociaux_Centralite"."geoRPLS_2018_PF" a, public."TerritoryTable_PF_2019" t, public."centralite" env
		WHERE ST_Intersects(a.geom,t.geom) AND ST_Intersects(a.geom,env.geom)
		GROUP BY id_geom, "Location"
	),
	-- Nombre de locaux hors centralités par commune
	total_by_com_out_env AS (
		SELECT total_by_com.id_geom id_geom, SUM(total_by_com."Count_ENTITIES" - COALESCE(total_by_com_in_env."Count_ENTITIES",0)) "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com, total_by_com_in_env
		WHERE total_by_com.id_geom = total_by_com_in_env.id_geom
		GROUP BY total_by_com.id_geom, "Location"
		UNION 
		-- Ça c'est pour gérer les communes qui auraient des locaux, mais aucun dans le périmètre de centralité
		-- Attention à cette étape, si la commune est multi-partie on aura sans doute un problème
		SELECT total_by_com.id_geom id_geom, total_by_com."Count_ENTITIES" "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com, total_by_com_in_env
		WHERE total_by_com.id_geom NOT IN (SELECT id_geom FROM total_by_com_in_env)
		GROUP BY total_by_com.id_geom, total_by_com."Count_ENTITIES", "Location"
	)
	-- Union par commune du nombre de locaux dans/hors la centralité
	SELECT id_geom::text, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_in_env
	UNION
	SELECT id_geom::text, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_out_env
	ORDER BY id_geom, "Location"
);
DELETE FROM "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2018
WHERE "Count_ENTITIES" = 0; -- On supprime les lignes avec un compte à zéro, c'est pour coller au code de la dataviz.
SELECT * FROM "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2018;


--/--/--/--/--/-
--/-- 2017 --/--
--/--/--/--/--/-

DROP TABLE IF EXISTS "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2017;
CREATE TABLE "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2017 AS (
	-- Nombre total de locaux par commune. Les communes sans locaux n'apparaitront pas dans la table finale
	WITH total_by_com AS ( 
		SELECT t.id_geom id_geom, Count(a.geom) "Count_ENTITIES"
		FROM "F3_MIX_LogementsSociaux_Centralite"."geoRPLS_2017_PF" a, public."TerritoryTable_PF_2019" t
		WHERE ST_Intersects(a.geom,t.geom)
		GROUP BY id_geom
	),
	-- Nombre de locaux dans la centralité par commune
	total_by_com_in_env AS (
		SELECT t.id_geom id_geom, Count(a.geom) "Count_ENTITIES",'IN' "Location"
		FROM "F3_MIX_LogementsSociaux_Centralite"."geoRPLS_2017_PF" a, public."TerritoryTable_PF_2019" t, public."centralite" env
		WHERE ST_Intersects(a.geom,t.geom) AND ST_Intersects(a.geom,env.geom)
		GROUP BY id_geom, "Location"
	),
	-- Nombre de locaux hors centralités par commune
	total_by_com_out_env AS (
		SELECT total_by_com.id_geom id_geom, SUM(total_by_com."Count_ENTITIES" - COALESCE(total_by_com_in_env."Count_ENTITIES",0)) "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com, total_by_com_in_env
		WHERE total_by_com.id_geom = total_by_com_in_env.id_geom
		GROUP BY total_by_com.id_geom, "Location"
		UNION 
		-- Ça c'est pour gérer les communes qui auraient des locaux, mais aucun dans le périmètre de centralité
		-- Attention à cette étape, si la commune est multi-partie on aura sans doute un problème
		SELECT total_by_com.id_geom id_geom, total_by_com."Count_ENTITIES" "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com, total_by_com_in_env
		WHERE total_by_com.id_geom NOT IN (SELECT id_geom FROM total_by_com_in_env)
		GROUP BY total_by_com.id_geom, total_by_com."Count_ENTITIES", "Location"
	)
	-- Union par commune du nombre de locaux dans/hors la centralité
	SELECT id_geom::text, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_in_env
	UNION
	SELECT id_geom::text, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_out_env
	ORDER BY id_geom, "Location"
);
DELETE FROM "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2017
WHERE "Count_ENTITIES" = 0; -- On supprime les lignes avec un compte à zéro, c'est pour coller au code de la dataviz.
SELECT * FROM "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2017;


--/--/--/--/--/-
--/-- 2016 --/--
--/--/--/--/--/-

DROP TABLE IF EXISTS "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2016;
CREATE TABLE "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2016 AS (
	-- Nombre total de locaux par commune. Les communes sans locaux n'apparaitront pas dans la table finale
	WITH total_by_com AS ( 
		SELECT t.id_geom id_geom, Count(a.geom) "Count_ENTITIES"
		FROM "F3_MIX_LogementsSociaux_Centralite"."geoRPLS_2016_PF" a, public."TerritoryTable_PF_2019" t
		WHERE ST_Intersects(a.geom,t.geom)
		GROUP BY id_geom
	),
	-- Nombre de locaux dans la centralité par commune
	total_by_com_in_env AS (
		SELECT t.id_geom id_geom, Count(a.geom) "Count_ENTITIES",'IN' "Location"
		FROM "F3_MIX_LogementsSociaux_Centralite"."geoRPLS_2016_PF" a, public."TerritoryTable_PF_2019" t, public."centralite" env
		WHERE ST_Intersects(a.geom,t.geom) AND ST_Intersects(a.geom,env.geom)
		GROUP BY id_geom, "Location"
	),
	-- Nombre de locaux hors centralités par commune
	total_by_com_out_env AS (
		SELECT total_by_com.id_geom id_geom, SUM(total_by_com."Count_ENTITIES" - COALESCE(total_by_com_in_env."Count_ENTITIES",0)) "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com, total_by_com_in_env
		WHERE total_by_com.id_geom = total_by_com_in_env.id_geom
		GROUP BY total_by_com.id_geom, "Location"
		UNION 
		-- Ça c'est pour gérer les communes qui auraient des locaux, mais aucun dans le périmètre de centralité
		-- Attention à cette étape, si la commune est multi-partie on aura sans doute un problème
		SELECT total_by_com.id_geom id_geom, total_by_com."Count_ENTITIES" "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com, total_by_com_in_env
		WHERE total_by_com.id_geom NOT IN (SELECT id_geom FROM total_by_com_in_env)
		GROUP BY total_by_com.id_geom, total_by_com."Count_ENTITIES", "Location"
	)
	-- Union par commune du nombre de locaux dans/hors la centralité
	SELECT id_geom::text, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_in_env
	UNION
	SELECT id_geom::text, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_out_env
	ORDER BY id_geom, "Location"
);
DELETE FROM "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2016
WHERE "Count_ENTITIES" = 0; -- On supprime les lignes avec un compte à zéro, c'est pour coller au code de la dataviz.
SELECT * FROM "F3_MIX_LogementsSociaux_Centralite".F3_MIX_LogementsSociaux_Centralite_2016;

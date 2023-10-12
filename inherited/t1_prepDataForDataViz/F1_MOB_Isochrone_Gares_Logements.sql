-- F1_MOB_Isochrone_Gares_Logements

-- L'indicateur existait déjà avant mais y'avait pas de chiffres clés
-- Je repars sur le principe du calcul d'une évolution avec un seul millésime de fichiers fonciers, commme pour l'évolution de la densité carroyée, en utilisant le champ jannath des fichiers fonciers


--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/
--/--/--/--/-- PREPARATION LOGEMENTS --/--/--/--/--
--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/

-- On met de côté les logements WHERE jannath < 2016, ce sont les logements de référence
-- 5 secs 767 msec.
DROP TABLE IF EXISTS "F1_MOB_Isochrone_Gares_Logements"."_dataviz_logt_reference";
CREATE TABLE "F1_MOB_Isochrone_Gares_Logements"."_dataviz_logt_reference" AS (
	SELECT *
	FROM public.fftp_2018_pb0010_local
	WHERE jannath < 2016 AND dteloc IN ('1','2')
);


-- On met de côté les logements WHERE jannath < 2017, ce sont les logements à date d'actualisation  4 secs 74 msec.
DROP TABLE IF EXISTS "F1_MOB_Isochrone_Gares_Logements"."_dataviz_logt_actualisation";
CREATE TABLE "F1_MOB_Isochrone_Gares_Logements"."_dataviz_logt_actualisation" AS (
	SELECT *
	FROM public.fftp_2018_pb0010_local
	WHERE jannath < 2017 AND dteloc IN ('1','2')
);

-- On met de côté les logements WHERE jannath = 2016, ce sont les logements nouvellement produits 543 msec.
DROP TABLE IF EXISTS "F1_MOB_Isochrone_Gares_Logements"."_dataviz_logt_evolution";
CREATE TABLE "F1_MOB_Isochrone_Gares_Logements"."_dataviz_logt_evolution" AS (
	SELECT *
	FROM public.fftp_2018_pb0010_local
	WHERE jannath = 2016 AND dteloc IN ('1','2')
);

-- On met de côté les logements WHERE jannath > 2016 pour simple affichage  470 msec.
DROP TABLE IF EXISTS "F1_MOB_Isochrone_Gares_Logements"."_dataviz_logt_simple_affichage";
CREATE TABLE "F1_MOB_Isochrone_Gares_Logements"."_dataviz_logt_simple_affichage" AS (
	SELECT *
	FROM public.fftp_2018_pb0010_local
	WHERE jannath > 2016 AND dteloc IN ('1','2')
);




--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
--/--/--/--/-- CHIFFRES CLES REFERENCE --/--/--/--/--
--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--

-- Pour pas se planter dans les calculs de chiffres clés IN/OUT, le plus simple est de créer une 1ère table avec uniquement les logements IN par territoire. Puis y ajouter le nombre total de logements par territoire. Et enfin obtenir le nombre de logements OUT par soustraction des deux colonnes précédentes. (Au début j'étais parti sur qq chose genre "SELECT * WHERE ST_Intersects(env_urbaine) + SELECT * WHERE NOT ST_Intersects(env_urbaine)", mais selon les géométries, les cas particuliers, les points en dehors du territoire, y'a un risque de se planter. Là ça tient la route partout.

--  2 min 52 secs.
DROP TABLE IF EXISTS "F1_MOB_Isochrone_Gares_Logements".chiffres_cles_reference;
CREATE TABLE "F1_MOB_Isochrone_Gares_Logements".chiffres_cles_reference AS (
	-- Nombre total de locaux par commune. Les communes sans locaux n'apparaitront pas dans la table finale
	WITH total_by_com AS ( 
		SELECT t.id_geom id_geom, Count(loc.geom) "Count_ENTITIES"
		FROM "F1_MOB_Isochrone_Gares_Logements"."_dataviz_logt_reference" loc, public."TerritoryTable_PST_2019_maj_2020.01.14" t
		WHERE ST_Intersects(loc.geom,t.geom)
		GROUP BY id_geom
	),
	-- Nombre de locaux dans la centralité par commune
	total_by_com_in_iso AS (
		SELECT t.id_geom id_geom, iso."time", Count(loc.geom) "Count_ENTITIES",'IN'::text "Location"
		FROM
		"F1_MOB_Isochrone_Gares_Logements"."_dataviz_logt_reference" loc, 
		public."TerritoryTable_PST_2019_maj_2020.01.14" t,
		"F1_MOB_Isochrone_Gares_Logements"."Isochrones_5_10_15_pied_Gares_SGEvT" iso
		WHERE ST_Intersects(loc.geom,t.geom) AND ST_Intersects(loc.geom,iso.geom)
		GROUP BY id_geom, "time", "Location"
	),
	-- Nombre de locaux hors centralités par commune
	total_by_com_out_iso AS (
		SELECT total_by_com.id_geom id_geom, total_by_com_in_iso."time", SUM(total_by_com."Count_ENTITIES" - total_by_com_in_iso."Count_ENTITIES") "Count_ENTITIES", 'OUT'::text "Location"
		FROM total_by_com, total_by_com_in_iso
		WHERE total_by_com.id_geom = total_by_com_in_iso.id_geom
		GROUP BY total_by_com.id_geom, total_by_com_in_iso."time", "Location"
		UNION 
		-- Ça c'est pour gérer les communes qui auraient des locaux, mais aucun dans le périmètre de centralité
		-- Attention à cette étape, si la commune est multi-partie on aura sans doute un problème
		SELECT total_by_com.id_geom id_geom, total_by_com_in_iso."time", total_by_com."Count_ENTITIES" "Count_ENTITIES", 'OUT'::text "Location"
		FROM total_by_com, total_by_com_in_iso
		WHERE total_by_com.id_geom NOT IN (SELECT id_geom FROM total_by_com_in_iso)
		GROUP BY total_by_com.id_geom, total_by_com_in_iso."time", total_by_com."Count_ENTITIES", "Location"
	)
	-- Union par commune du nombre de locaux dans/hors la centralité
	SELECT id_geom::text, "time"::int, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_in_iso
	UNION
	SELECT id_geom::text, "time"::int, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_out_iso
	ORDER BY id_geom, "Location"
);
SELECT * FROM "F1_MOB_Isochrone_Gares_Logements".chiffres_cles_reference;


--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
--/--/--/--/-- CHIFFRES CLES ACTUALISATION --/--/--/-
--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--

DROP TABLE IF EXISTS "F1_MOB_Isochrone_Gares_Logements".chiffres_cles_actualisation;
CREATE TABLE "F1_MOB_Isochrone_Gares_Logements".chiffres_cles_actualisation AS (
	-- Nombre total de locaux par commune. Les communes sans locaux n'apparaitront pas dans la table finale
	WITH total_by_com AS ( 
		SELECT t.id_geom id_geom, Count(loc.geom) "Count_ENTITIES"
		FROM "F1_MOB_Isochrone_Gares_Logements"."_dataviz_logt_actualisation" loc, public."TerritoryTable_PST_2019_maj_2020.01.14" t
		WHERE ST_Intersects(loc.geom,t.geom)
		GROUP BY id_geom
	),
	-- Nombre de locaux dans la centralité par commune
	total_by_com_in_iso AS (
		SELECT t.id_geom id_geom, iso."time", Count(loc.geom) "Count_ENTITIES",'IN'::text "Location"
		FROM "F1_MOB_Isochrone_Gares_Logements"."_dataviz_logt_actualisation" loc, public."TerritoryTable_PST_2019_maj_2020.01.14" t, "F1_MOB_Isochrone_Gares_Logements"."Isochrones_5_10_15_pied_Gares_SGEvT" iso
		WHERE ST_Intersects(loc.geom,t.geom) AND ST_Intersects(loc.geom,iso.geom)
		GROUP BY id_geom, "time", "Location"
	),
	-- Nombre de locaux hors centralités par commune
	total_by_com_out_iso AS (
		SELECT total_by_com.id_geom id_geom, total_by_com_in_iso."time", SUM(total_by_com."Count_ENTITIES" - total_by_com_in_iso."Count_ENTITIES") "Count_ENTITIES", 'OUT'::text "Location"
		FROM total_by_com, total_by_com_in_iso
		WHERE total_by_com.id_geom = total_by_com_in_iso.id_geom
		GROUP BY total_by_com.id_geom, total_by_com_in_iso."time", "Location"
		UNION 
		-- Ça c'est pour gérer les communes qui auraient des locaux, mais aucun dans le périmètre de centralité
		-- Attention à cette étape, si la commune est multi-partie on aura sans doute un problème
		SELECT total_by_com.id_geom id_geom, total_by_com_in_iso."time", total_by_com."Count_ENTITIES" "Count_ENTITIES", 'OUT'::text "Location"
		FROM total_by_com, total_by_com_in_iso
		WHERE total_by_com.id_geom NOT IN (SELECT id_geom FROM total_by_com_in_iso)
		GROUP BY total_by_com.id_geom, total_by_com_in_iso."time", total_by_com."Count_ENTITIES", "Location"
	)
	-- Union par commune du nombre de locaux dans/hors la centralité
	SELECT id_geom::text, "time"::int, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_in_iso
	UNION
	SELECT id_geom::text, "time"::int, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_out_iso
	ORDER BY id_geom, "Location"
);
SELECT * FROM "F1_MOB_Isochrone_Gares_Logements".chiffres_cles_actualisation;
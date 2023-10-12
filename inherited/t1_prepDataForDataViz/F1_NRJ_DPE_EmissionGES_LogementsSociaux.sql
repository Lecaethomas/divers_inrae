-- On utilise les tables brutes du geo rpls de QUest pour 2016 et 2017 (ici on les a format géographique, mais on les a extrait de la table départemnentale par sélection attributaire sur le CODGEO, donc c'est bon on a tous les logements)
-- Normalement on a déjà un fichier csv de résultat pour 2016, mais comme la dataviz a changé de format, que le territoire a connu des fusions de communes etc, on recommence tout.

-- Variables:
-- schema:				"F1_NRJ_DPE_EmissionGES_LogementsSociaux"
-- RPLS: 				geoRPLS_2019_PF
-- couche en sortie: 	F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2019

-- Pour cette partie de l'indicateur j'ai aucune trace d'une production précédente. J'imagine qu'il suffit de changer la colonne dpeenergie à dpeserre

--/--/--/--/--/-
--/-- 2021 --/--
--/--/--/--/--/-

-- 15 secs 396 msec.
DROP TABLE IF EXISTS "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux";
CREATE TABLE "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux" AS (
	SELECT 	t.id_geom id_geom,
		'2021' lot,
		(
			-- Ça pourrait être bien d'avoir une valeur NR ici aussi
			CASE 
			WHEN a.construct<1949 THEN 'avant 1949'
			WHEN a.construct>=1949 AND a.construct<=1974 THEN '1949-1974'
			WHEN a.construct>=1975 AND a.construct<=1981 THEN '1975-1981'
			WHEN a.construct>=1982 AND a.construct<=1989 THEN '1982-1989'
			WHEN a.construct>=1990 AND a.construct<=2000 THEN '1990-2000'
			WHEN a.construct>=2001 AND a.construct<=2012 THEN '2001-2012' 
			ELSE '2013 à aujourd hui'
			END
		) period,
		(
			CASE
			-- Rajout de la condition NOT IN () pour gérer les valeurs à 'nan' et éventuels décalages de colonne
			WHEN a.dpeserre is NULL OR a.dpeserre NOT IN ('A','B','C','D','E','F','G') THEN 'Non Renseigné' 
			ELSE a.dpeserre
			END
		) dpe,
		Count(a.geom) "Count_ENTITES",
		(
			CASE 
			WHEN a.construct<1949 THEN '1'
			WHEN a.construct>=1949 AND a.construct<=1974 THEN '2'
			WHEN a.construct>=1975 AND a.construct<=1981 THEN '3'
			WHEN a.construct>=1982 AND a.construct<=1989 THEN '4'
			WHEN a.construct>=1990 AND a.construct<=2000 THEN '5'
			WHEN a.construct>=2001 AND a.construct<=2012 THEN '6' 
			ELSE '7'
			END
		) period_code,
		(
			CASE 
			--WHEN a.dpeserre is NULL THEN 'Non Renseigné' --Alors ça c'est rigolo parce qu'en fait ça fait planter la dataviz (la heatMap). C'était bien dans le code de base mais je sais pas, comme j'ai ré-écrit la requête pour qu'elle soit plus simple, peut-être que ça marchait pas avant. En tout cas les logements sans dpeserre doivent avoir un dpe_code à '8' et pas 'Non Renseigné'.
			WHEN a.dpeserre='A' THEN '1'
			WHEN a.dpeserre='B' THEN '2'
			WHEN a.dpeserre='C' THEN '3'
			WHEN a.dpeserre='D' THEN '4'
			WHEN a.dpeserre='E' THEN '5'
			WHEN a.dpeserre='F' THEN '6'
			WHEN a.dpeserre='G' THEN '7' 
			ELSE '8'
			END
		) dpe_code,
		'EffetDeSerre' type_dpe
	FROM "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F3_MIX_LogementsSociaux_points_2021" a, public."TerritoryTable_PF_2019" t
	WHERE ST_Intersects(a.geom,t.geom)
	GROUP BY id_geom, lot, period, dpe, period_code, dpe_code, type_dpe
);
SELECT * FROM "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux";


--/--/--/--/--/-
--/-- 2019 --/--
--/--/--/--/--/-

-- 15 secs 396 msec.
DROP TABLE IF EXISTS "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2019";
CREATE TABLE "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2019" AS (
	SELECT 	t.id_geom id_geom,
		'2019' lot,
		(
			-- Ça pourrait être bien d'avoir une valeur NR ici aussi
			CASE 
			WHEN a.construct<1949 THEN 'avant 1949'
			WHEN a.construct>=1949 AND a.construct<=1974 THEN '1949-1974'
			WHEN a.construct>=1975 AND a.construct<=1981 THEN '1975-1981'
			WHEN a.construct>=1982 AND a.construct<=1989 THEN '1982-1989'
			WHEN a.construct>=1990 AND a.construct<=2000 THEN '1990-2000'
			WHEN a.construct>=2001 AND a.construct<=2012 THEN '2001-2012' 
			ELSE '2013 à aujourd hui'
			END
		) period,
		(
			CASE
			-- Rajout de la condition NOT IN () pour gérer les valeurs à 'nan' et éventuels décalages de colonne
			WHEN a.dpeserre is NULL OR a.dpeserre NOT IN ('A','B','C','D','E','F','G') THEN 'Non Renseigné' 
			ELSE a.dpeserre
			END
		) dpe,
		Count(a.geom) "Count_ENTITES",
		(
			CASE 
			WHEN a.construct<1949 THEN '1'
			WHEN a.construct>=1949 AND a.construct<=1974 THEN '2'
			WHEN a.construct>=1975 AND a.construct<=1981 THEN '3'
			WHEN a.construct>=1982 AND a.construct<=1989 THEN '4'
			WHEN a.construct>=1990 AND a.construct<=2000 THEN '5'
			WHEN a.construct>=2001 AND a.construct<=2012 THEN '6' 
			ELSE '7'
			END
		) period_code,
		(
			CASE 
			--WHEN a.dpeserre is NULL THEN 'Non Renseigné' --Alors ça c'est rigolo parce qu'en fait ça fait planter la dataviz (la heatMap). C'était bien dans le code de base mais je sais pas, comme j'ai ré-écrit la requête pour qu'elle soit plus simple, peut-être que ça marchait pas avant. En tout cas les logements sans dpeserre doivent avoir un dpe_code à '8' et pas 'Non Renseigné'.
			WHEN a.dpeserre='A' THEN '1'
			WHEN a.dpeserre='B' THEN '2'
			WHEN a.dpeserre='C' THEN '3'
			WHEN a.dpeserre='D' THEN '4'
			WHEN a.dpeserre='E' THEN '5'
			WHEN a.dpeserre='F' THEN '6'
			WHEN a.dpeserre='G' THEN '7' 
			ELSE '8'
			END
		) dpe_code,
		'EffetDeSerre' type_dpe
	FROM "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."geoRPLS_2019_PF" a, public."TerritoryTable_PF_2019" t
	WHERE ST_Intersects(a.geom,t.geom)
	GROUP BY id_geom, lot, period, dpe, period_code, dpe_code, type_dpe
);
SELECT * FROM "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2019";





--/--/--/--/--/-
--/-- 2018 --/--
--/--/--/--/--/-

-- 15 secs 396 msec.
DROP TABLE IF EXISTS "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2018";
CREATE TABLE "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2018" AS (
	SELECT 	t.id_geom id_geom,
		'2018' lot,
		(
			-- Ça pourrait être bien d'avoir une valeur NR ici aussi
			CASE 
			WHEN a.construct<1949 THEN 'avant 1949'
			WHEN a.construct>=1949 AND a.construct<=1974 THEN '1949-1974'
			WHEN a.construct>=1975 AND a.construct<=1981 THEN '1975-1981'
			WHEN a.construct>=1982 AND a.construct<=1989 THEN '1982-1989'
			WHEN a.construct>=1990 AND a.construct<=2000 THEN '1990-2000'
			WHEN a.construct>=2001 AND a.construct<=2012 THEN '2001-2012' 
			ELSE '2013 à aujourd hui'
			END
		) period,
		(
			CASE
			-- Rajout de la condition NOT IN () pour gérer les valeurs à 'nan' et éventuels décalages de colonne
			WHEN a.dpeserre is NULL OR a.dpeserre NOT IN ('A','B','C','D','E','F','G') THEN 'Non Renseigné' 
			ELSE a.dpeserre
			END
		) dpe,
		Count(a.geom) "Count_ENTITES",
		(
			CASE 
			WHEN a.construct<1949 THEN '1'
			WHEN a.construct>=1949 AND a.construct<=1974 THEN '2'
			WHEN a.construct>=1975 AND a.construct<=1981 THEN '3'
			WHEN a.construct>=1982 AND a.construct<=1989 THEN '4'
			WHEN a.construct>=1990 AND a.construct<=2000 THEN '5'
			WHEN a.construct>=2001 AND a.construct<=2012 THEN '6' 
			ELSE '7'
			END
		) period_code,
		(
			CASE 
			--WHEN a.dpeserre is NULL THEN 'Non Renseigné' --Alors ça c'est rigolo parce qu'en fait ça fait planter la dataviz (la heatMap). C'était bien dans le code de base mais je sais pas, comme j'ai ré-écrit la requête pour qu'elle soit plus simple, peut-être que ça marchait pas avant. En tout cas les logements sans dpeserre doivent avoir un dpe_code à '8' et pas 'Non Renseigné'.
			WHEN a.dpeserre='A' THEN '1'
			WHEN a.dpeserre='B' THEN '2'
			WHEN a.dpeserre='C' THEN '3'
			WHEN a.dpeserre='D' THEN '4'
			WHEN a.dpeserre='E' THEN '5'
			WHEN a.dpeserre='F' THEN '6'
			WHEN a.dpeserre='G' THEN '7' 
			ELSE '8'
			END
		) dpe_code,
		'EffetDeSerre' type_dpe
	FROM "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."geoRPLS_2018_PF" a, public."TerritoryTable_PF_2019" t
	WHERE ST_Intersects(a.geom,t.geom)
	GROUP BY id_geom, lot, period, dpe, period_code, dpe_code, type_dpe
);
SELECT * FROM "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2018";


--/--/--/--/--/-
--/-- 2017 --/--
--/--/--/--/--/-

-- À partir de 2017 et avant, on est obligés de fonctionner en jointure attributaire en tenant compte des fusions de communes:
-- La requête marche sans table territoire de PF parce que le RPLS est déjà filtré sur les communes du territoire. Sans ça on devait faire un filtre avant.

DROP TABLE IF EXISTS "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2017";
CREATE TABLE "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2017" AS (
	SELECT	t."CODGEO_2019" id_geom,
		'2017' lot,
		(
			-- Ça pourrait être bien d'avoir une valeur NR ici aussi
			CASE 
			WHEN a.construct<1949 THEN 'avant 1949'
			WHEN a.construct>=1949 AND a.construct<=1974 THEN '1949-1974'
			WHEN a.construct>=1975 AND a.construct<=1981 THEN '1975-1981'
			WHEN a.construct>=1982 AND a.construct<=1989 THEN '1982-1989'
			WHEN a.construct>=1990 AND a.construct<=2000 THEN '1990-2000'
			WHEN a.construct>=2001 AND a.construct<=2012 THEN '2001-2012' 
			ELSE '2013 à aujourd hui'
			END
		) period,
		(
			CASE
			-- Rajout de la condition NOT IN () pour gérer les valeurs à 'nan' et éventuels décalages de colonne
			WHEN a.dpeserre is NULL OR a.dpeserre NOT IN ('A','B','C','D','E','F','G') THEN 'Non Renseigné' 
			ELSE a.dpeserre
			END
		) dpe,
		Count(a.*) "Count_ENTITES",
		(
			CASE 
			WHEN a.construct<1949 THEN '1'
			WHEN a.construct>=1949 AND a.construct<=1974 THEN '2'
			WHEN a.construct>=1975 AND a.construct<=1981 THEN '3'
			WHEN a.construct>=1982 AND a.construct<=1989 THEN '4'
			WHEN a.construct>=1990 AND a.construct<=2000 THEN '5'
			WHEN a.construct>=2001 AND a.construct<=2012 THEN '6' 
			ELSE '7'
			END
		) period_code,
		(
			CASE 
			WHEN a.dpeserre='A' THEN '1'
			WHEN a.dpeserre='B' THEN '2'
			WHEN a.dpeserre='C' THEN '3'
			WHEN a.dpeserre='D' THEN '4'
			WHEN a.dpeserre='E' THEN '5'
			WHEN a.dpeserre='F' THEN '6'
			WHEN a.dpeserre='G' THEN '7' 
			ELSE '8'
			END
		) dpe_code,
		'EffetDeSerre' type_dpe
	FROM "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."GeoRPLS_2017_PF_parSelectionAttributaire" a
	LEFT JOIN public."table_passage_annuelle_2020" t
	ON t."CODGEO_2016" = a.depcom::text
	GROUP BY id_geom, lot, period, dpe, period_code, dpe_code, type_dpe
);
SELECT * FROM "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2017";

-- Et ensuite il faut aggréger manuellement les résultats aux EPCI et au Territoire. Le plus simple est de refaire une jointure attributaire avec la table territoire: 

DROP TABLE IF EXISTS "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2017_epci";
CREATE TABLE "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2017_epci" AS (
	SELECT a.*, b."TYPE_EPCI"
	FROM "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2017" a
	LEFT JOIN ( -- SQ parce qu'il y a des "doublons" dans la table
		SELECT "INSEE_COM2", "TYPE_EPCI"
		FROM public."FOUGERES_Communes_EPCI_ante2019"
		GROUP BY "INSEE_COM2", "TYPE_EPCI"
	) b
	ON a.id_geom = b."INSEE_COM2"::text
);

-- Et rajouter les valeurs avec les bons codes en faisant du Group by:
	-- Pour le SCoT
	INSERT INTO "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2017_epci"
	SELECT '248' id_geom, lot, period, dpe, SUM("Count_ENTITES") "Count_ENTITES",  period_code, dpe_code, type_dpe
	FROM "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2017_epci"
	GROUP BY lot, period, dpe, period_code, dpe_code, type_dpe;

	-- Pour l'EPCI n°200070688
	INSERT INTO "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2017_epci"
	SELECT '200070688' id_geom, lot, period, dpe, SUM("Count_ENTITES") "Count_ENTITES",  period_code, dpe_code, type_dpe
	FROM "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2017_epci"
	WHERE "TYPE_EPCI" LIKE 'CC Couesnon Marches de Bretagne'
	GROUP BY lot, period, dpe, period_code, dpe_code, type_dpe;

	-- Pour l'autre EPCI
	INSERT INTO "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2017_epci"
	SELECT '200072452' id_geom, lot, period, dpe, SUM("Count_ENTITES") "Count_ENTITES",  period_code, dpe_code, type_dpe
	FROM "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2017_epci"
	WHERE "TYPE_EPCI" LIKE 'CA Fougères Agglomération'
	GROUP BY lot, period, dpe, period_code, dpe_code, type_dpe;





--/--/--/--/--/-
--/-- 2016 --/--
--/--/--/--/--/-

-- À partir de 2017 et avant, on est obligés de fonctionner en jointure attributaire en tenant compte des fusions de communes:
-- La requête marche sans table territoire de PF parce que le RPLS est déjà filtré sur les communes du territoire. Sans ça on devait faire un filtre avant.

DROP TABLE IF EXISTS "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2016";
CREATE TABLE "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2016" AS (
	SELECT	t."CODGEO_2019" id_geom,
		'2017' lot,
		(
			-- Ça pourrait être bien d'avoir une valeur NR ici aussi
			CASE 
			WHEN a.construct<1949 THEN 'avant 1949'
			WHEN a.construct>=1949 AND a.construct<=1974 THEN '1949-1974'
			WHEN a.construct>=1975 AND a.construct<=1981 THEN '1975-1981'
			WHEN a.construct>=1982 AND a.construct<=1989 THEN '1982-1989'
			WHEN a.construct>=1990 AND a.construct<=2000 THEN '1990-2000'
			WHEN a.construct>=2001 AND a.construct<=2012 THEN '2001-2012' 
			ELSE '2013 à aujourd hui'
			END
		) period,
		(
			CASE
			-- Rajout de la condition NOT IN () pour gérer les valeurs à 'nan' et éventuels décalages de colonne
			WHEN a.dpeserre is NULL OR a.dpeserre NOT IN ('A','B','C','D','E','F','G') THEN 'Non Renseigné' 
			ELSE a.dpeserre
			END
		) dpe,
		Count(a.*) "Count_ENTITES",
		(
			CASE 
			WHEN a.construct<1949 THEN '1'
			WHEN a.construct>=1949 AND a.construct<=1974 THEN '2'
			WHEN a.construct>=1975 AND a.construct<=1981 THEN '3'
			WHEN a.construct>=1982 AND a.construct<=1989 THEN '4'
			WHEN a.construct>=1990 AND a.construct<=2000 THEN '5'
			WHEN a.construct>=2001 AND a.construct<=2012 THEN '6' 
			ELSE '7'
			END
		) period_code,
		(
			CASE 
			WHEN a.dpeserre='A' THEN '1'
			WHEN a.dpeserre='B' THEN '2'
			WHEN a.dpeserre='C' THEN '3'
			WHEN a.dpeserre='D' THEN '4'
			WHEN a.dpeserre='E' THEN '5'
			WHEN a.dpeserre='F' THEN '6'
			WHEN a.dpeserre='G' THEN '7' 
			ELSE '8'
			END
		) dpe_code,
		'EffetDeSerre' type_dpe
	FROM "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."GeoRPLS_2016_PF_parSelectionAttributaire" a
	LEFT JOIN public."table_passage_annuelle_2020" t
	ON t."CODGEO_2015" = a.depcom::text
	GROUP BY id_geom, lot, period, dpe, period_code, dpe_code, type_dpe
);
SELECT * FROM "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2016";

-- Et ensuite il faut aggréger manuellement les résultats aux EPCI et au Territoire. Le plus simple est de refaire une jointure attributaire avec la table territoire: 

DROP TABLE IF EXISTS "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2016_epci";
CREATE TABLE "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2016_epci" AS (
	SELECT a.*, b."TYPE_EPCI"
	FROM "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2016" a
	LEFT JOIN ( -- SQ parce qu'il y a des "doublons" dans la table
		SELECT "INSEE_COM2", "TYPE_EPCI"
		FROM public."FOUGERES_Communes_EPCI_ante2019"
		GROUP BY "INSEE_COM2", "TYPE_EPCI"
	) b
	ON a.id_geom = b."INSEE_COM2"::text
);

-- Et rajouter les valeurs avec les bons codes en faisant du Group by:
	-- Pour le SCoT
	INSERT INTO "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2016_epci"
	SELECT '248' id_geom, lot, period, dpe, SUM("Count_ENTITES") "Count_ENTITES",  period_code, dpe_code, type_dpe
	FROM "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2016_epci"
	GROUP BY lot, period, dpe, period_code, dpe_code, type_dpe;

	-- Pour l'EPCI n°200070688
	INSERT INTO "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2016_epci"
	SELECT '200070688' id_geom, lot, period, dpe, SUM("Count_ENTITES") "Count_ENTITES",  period_code, dpe_code, type_dpe
	FROM "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2016_epci"
	WHERE "TYPE_EPCI" LIKE 'CC Couesnon Marches de Bretagne'
	GROUP BY lot, period, dpe, period_code, dpe_code, type_dpe;

	-- Pour l'autre EPCI
	INSERT INTO "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2016_epci"
	SELECT '200072452' id_geom, lot, period, dpe, SUM("Count_ENTITES") "Count_ENTITES",  period_code, dpe_code, type_dpe
	FROM "F1_NRJ_DPE_EmissionGES_LogementsSociaux"."F1_NRJ_DPE_EffetDeSerre_LogementsSociaux_2016_epci"
	WHERE "TYPE_EPCI" LIKE 'CA Fougères Agglomération'
	GROUP BY lot, period, dpe, period_code, dpe_code, type_dpe;
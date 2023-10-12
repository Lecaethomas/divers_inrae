-- F4_EQU_EvolServicesEquipements_Centralite_carto

-- Source sirene: http://data.cquest.org/geo_sirene/v2019/2020-03/dep/

-- J'importe la table dans postgis (en 2154) pour faire la jointure avec le fichier "Categorie_Equipement_Ponderation_UTF8_V3_ForJointure.csv" et garder la donnée sur PF uniquement
-- J'importe "Categorie_Equipement_Ponderation_UTF8_V3_ForJointure.csv" aussi, la table territoire est déjà dans le schéma public
-- Le périmètre de centralité est dans le schema public


ALTER TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto"."geo_siret_35_202204" 
  ALTER COLUMN geom 
  TYPE Geometry(MultiPoint, 2154) 
  USING ST_Transform(geom, 2154);


-- Select sur l'emprise de PF 24 secs 444 msec.
DROP TABLE IF EXISTS "F4_EQU_EvolServicesEquipements_Centralites_carto"."geo_siret_35_202204_PF";
CREATE TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto"."geo_siret_35_202204_PF" AS (
	SELECT sirene.* 
	FROM "F4_EQU_EvolServicesEquipements_Centralites_carto"."geo_siret_35_202204" sirene, public."TerritoryTable_PF_2019" t
	WHERE ST_Intersects(t.geom, sirene.geom)
	AND t.rank = '3'
);

-- Select sur les établissements actifs
DROP TABLE IF EXISTS "F4_EQU_EvolServicesEquipements_Centralites_carto"."geo_siret_35_202204_PF_actif";
CREATE TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto"."geo_siret_35_202204_PF_actif" AS (
	SELECT *
	FROM "F4_EQU_EvolServicesEquipements_Centralites_carto"."geo_siret_35_202204_PF"
	WHERE "etatAdministratifEtablissement" = 'A'
);


-- Jointure avec la table de jointure
DROP TABLE IF EXISTS "F4_EQU_EvolServicesEquipements_Centralites_carto"."F4_EQU_EvolServicesEquipements_equipements";
CREATE TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto"."F4_EQU_EvolServicesEquipements_equipements" AS (
	SELECT REPLACE(sirene."activitePrincipaleEtablissement",'.','') "CODE_EQU", sirene.geom, join_table."CodeService", join_table."LABEL"
	FROM "F4_EQU_EvolServicesEquipements_Centralites_carto"."geo_siret_35_202204_PF_actif" sirene
	FULL JOIN public."Categorie_Equipement_Ponderation_UTF8_V3_ForJointure" join_table
	ON REPLACE(sirene."activitePrincipaleEtablissement",'.','') = join_table."TYPE"
	WHERE join_table."CodeService" IS NOT NULL
);



-- Creation des chiffres clés
--D:\_CLIENT\PSB_2017\_TRAVAIL\F4_EQU_EvolServicesEquipements_carto\travail\__F4_EQU_EvolServicesEquipements_carto_CONFIG.json

------------------------
----- 2020
------------------------
-- En sortie du script Descripteurs_CommercesEquipements on a trois tables de points, je les ai fusionnées avec un UNION ALL

drop table if exists "F4_EQU_EvolServicesEquipements_carto_equipements2020_ALL";
create table "F4_EQU_EvolServicesEquipements_carto_equipements2020_ALL" as (
WITH t1 AS (
select * from "F4_EQU_EvolServicesEquipements_carto_equipements2020"
UNION ALL
SELECT * FROM "F4_EQU_EvolServicesEquipements_carto_commerces2020"
UNION ALL
SELECT * FROM "F4_EQU_EvolServicesEquipements_carto_sociabilite2020"
)
SELECT t1.*, t2."LABEL"  FROM t1
LEFT JOIN categorie_equipement_ponderation_utf8_v3_forjointure_csv t2
ON t1.code_equ = t2."TYPE"
WHERE t2.codeservice IN ('1','2','3')
)

--Au besoin, on peut les redispatcher :

DROP TABLE IF EXISTS "F4_EQU_EvolServicesEquipements_Centralites_carto"."F4_EQU_EvolServicesEquipements_carto_commerces2021";
CREATE TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto"."F4_EQU_EvolServicesEquipements_carto_commerces2021" AS (
	SELECT *
	FROM "F4_EQU_EvolServicesEquipements_Centralites_carto"."F4_EQU_EvolServicesEquipements_carto_equipements2021_ALL"
	WHERE "CodeService" = 1
);

DROP TABLE IF EXISTS "F4_EQU_EvolServicesEquipements_Centralites_carto"."F4_EQU_EvolServicesEquipements_carto_sociabilite2021";
CREATE TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto"."F4_EQU_EvolServicesEquipements_carto_sociabilite2021" AS (
	SELECT *
	FROM "F4_EQU_EvolServicesEquipements_Centralites_carto"."F4_EQU_EvolServicesEquipements_carto_equipements2021_ALL"
	WHERE "CodeService" = 2
);

DROP TABLE IF EXISTS "F4_EQU_EvolServicesEquipements_Centralites_carto"."F4_EQU_EvolServicesEquipements_carto_equipements2021";
CREATE TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto"."F4_EQU_EvolServicesEquipements_carto_equipements2021" AS (
	SELECT *
	FROM "F4_EQU_EvolServicesEquipements_Centralites_carto"."F4_EQU_EvolServicesEquipements_carto_equipements2021_ALL"
	WHERE "CodeService" = 3
);

-- Creation des chiffres clés
--D:\_CLIENT\PSB_2017\_TRAVAIL\F4_EQU_EvolServicesEquipements_carto\travail\__F4_EQU_EvolServicesEquipements_carto_CONFIG.json

-- Pour le SCoT PF
DROP TABLE IF EXISTS "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles2021;
CREATE TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles2021 AS (
	-- Nombre total de locaux par commune. Les communes sans locaux n'apparaitront pas dans la table finale
	WITH total_by_com AS ( 
		SELECT t.id_geom id_geom, a."CodeService" "Categorie", Count(a.geom) "Count_ENTITIES"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto"."F4_EQU_EvolServicesEquipements_carto_equipements2021_ALL" a, public."TerritoryTable_PF_2019" t
		WHERE ST_Intersects(a.geom,t.geom)
		GROUP BY id_geom, "Categorie"
	),
	-- Nombre de locaux dans la centralité par commune
	total_by_com_in_env AS (
		SELECT t.id_geom id_geom, a."CodeService" "Categorie", Count(a.geom) "Count_ENTITIES",'IN' "Location"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto"."F4_EQU_EvolServicesEquipements_carto_equipements2021_ALL" a, public."TerritoryTable_PF_2019" t, public."centralites" env
		WHERE ST_Intersects(a.geom,t.geom) AND ST_Intersects(a.geom,env.geom)
		GROUP BY id_geom, "Categorie", "Location"
	),
	-- Nombre de locaux hors centralités par commune
	total_by_com_out_env AS (
		SELECT total_by_com.id_geom id_geom, total_by_com."Categorie", COALESCE(SUM(total_by_com."Count_ENTITIES" - COALESCE(total_by_com_in_env."Count_ENTITIES",0)),0) "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com 
		LEFT JOIN total_by_com_in_env
		ON total_by_com.id_geom = total_by_com_in_env.id_geom
		AND total_by_com."Categorie" = total_by_com_in_env."Categorie"
		GROUP BY total_by_com.id_geom, total_by_com."Categorie", "Location" 
	)
	-- Union par commune du nombre de locaux dans/hors la centralité
	SELECT id_geom::text, "Count_ENTITIES"::int, "Categorie", "Location"::text FROM total_by_com_in_env
	UNION
	SELECT id_geom::text, "Count_ENTITIES"::int, "Categorie", "Location"::text FROM total_by_com_out_env
	ORDER BY id_geom, "Location"
);

ALTER TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles2021
DROP COLUMN IF EXISTS "Categorie_format";
ALTER TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles2021
ADD COLUMN "Categorie_format" varchar;

UPDATE "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles2021
SET "Categorie_format" = (
	CASE 
	WHEN "Categorie" = 1 THEN 'Commerces'
	WHEN "Categorie" = 2 THEN 'Espaces de convivialité'
	WHEN "Categorie" = 3 THEN 'Equipements d''intérêt collectif'
	END
);
SELECT * FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles2021;

------------------------
-----  2018
------------------------

-- Creation des tables pour les dataviz et la livraison

drop table if exists "F4_EQU_EvolServicesEquipements_carto_equipements2018_ALL";
create table "F4_EQU_EvolServicesEquipements_carto_equipements2018_ALL" as (
select * from "F4_EQU_EvolServicesEquipements_carto_commerces2018"
union all
select * from "F4_EQU_EvolServicesEquipements_carto_equipements2018"
union all
select * from "F4_EQU_EvolServicesEquipements_carto_sociabilite2018"
)

DROP TABLE IF EXISTS "F4_EQU_EvolEquCentralites"."F4_EQU_EvolServicesEquipements_carto_commerces2018";
CREATE TABLE "F4_EQU_EvolEquCentralites"."F4_EQU_EvolServicesEquipements_carto_commerces2018" AS (
	SELECT *
	FROM "F4_EQU_EvolEquCentralites"."F4_EQU_EvolServicesEquipements_carto_equipements2018_ALL"
	WHERE "CodeService" = '1'
);

DROP TABLE IF EXISTS "F4_EQU_EvolEquCentralites"."F4_EQU_EvolServicesEquipements_carto_sociabilite2018";
CREATE TABLE "F4_EQU_EvolEquCentralites"."F4_EQU_EvolServicesEquipements_carto_sociabilite2018" AS (
	SELECT *
	FROM "F4_EQU_EvolEquCentralites"."F4_EQU_EvolServicesEquipements_carto_equipements2018_ALL"
	WHERE "CodeService" = '2'
);

DROP TABLE IF EXISTS "F4_EQU_EvolEquCentralites"."F4_EQU_EvolServicesEquipements_carto_equipements2018";
CREATE TABLE "F4_EQU_EvolEquCentralites"."F4_EQU_EvolServicesEquipements_carto_equipements2018" AS (
	SELECT *
	FROM "F4_EQU_EvolEquCentralites"."F4_EQU_EvolServicesEquipements_carto_equipements2018_ALL"
	WHERE "CodeService" = '3'
);

-- Pour le SCoT PF
DROP TABLE IF EXISTS "F4_EQU_EvolEquCentralites".chiffres_cles2018;
CREATE TABLE "F4_EQU_EvolEquCentralites".chiffres_cles2018 AS (
	-- Nombre total de locaux par commune. Les communes sans locaux n'apparaitront pas dans la table finale
	WITH total_by_com AS ( 
		SELECT t.id_geom id_geom, a."CodeService" "Categorie", Count(a.geom) "Count_ENTITIES"
		FROM "F4_EQU_EvolEquCentralites"."F4_EQU_EvolServicesEquipements_carto_equipements2018_ALL" a, public."territory_table_CAP20" t
		WHERE ST_Intersects(a.geom,t.geom)
		GROUP BY id_geom, "Categorie"
	),
	-- Nombre de locaux dans la centralité par commune
	total_by_com_in_env AS (
		SELECT t.id_geom id_geom, a."CodeService" "Categorie", Count(a.geom) "Count_ENTITIES",'IN' "Location"
		FROM "F4_EQU_EvolEquCentralites"."F4_EQU_EvolServicesEquipements_carto_equipements2018_ALL" a, public."territory_table_CAP20" t, public."centralites" env
		WHERE ST_Intersects(a.geom,t.geom) AND ST_Intersects(a.geom,env.geom)
		GROUP BY id_geom, "Categorie", "Location"
	),
	-- Nombre de locaux hors centralités par commune
	total_by_com_out_env AS (
		SELECT total_by_com.id_geom id_geom, total_by_com."Categorie", COALESCE(SUM(total_by_com."Count_ENTITIES" - COALESCE(total_by_com_in_env."Count_ENTITIES",0)),0) "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com 
		LEFT JOIN total_by_com_in_env
		ON total_by_com.id_geom = total_by_com_in_env.id_geom
		AND total_by_com."Categorie" = total_by_com_in_env."Categorie"
		GROUP BY total_by_com.id_geom, total_by_com."Categorie", "Location" 
	)
	-- Union par commune du nombre de locaux dans/hors la centralité
	SELECT id_geom::text, "Count_ENTITIES"::int, "Categorie", "Location"::text FROM total_by_com_in_env
	UNION
	SELECT id_geom::text, "Count_ENTITIES"::int, "Categorie", "Location"::text FROM total_by_com_out_env
	ORDER BY id_geom, "Location"
);

ALTER TABLE "F4_EQU_EvolEquCentralites".chiffres_cles2018
DROP COLUMN IF EXISTS "Categorie_format";
ALTER TABLE "F4_EQU_EvolEquCentralites".chiffres_cles2018
ADD COLUMN "Categorie_format" varchar;

UPDATE "F4_EQU_EvolEquCentralites".chiffres_cles2018
SET "Categorie_format" = (
	CASE 
	WHEN "Categorie" = '1' THEN 'Commerces'
	WHEN "Categorie" = '2' THEN 'Espaces de convivialité'
	WHEN "Categorie" = '3' THEN 'Equipements d''intérêt collectif'
	END
);
SELECT * FROM "F4_EQU_EvolEquCentralites".chiffres_cles2018;


-- Pour spliter les data aux EPCI, plutôt que d'utiliser une sélection par attribut un peu manuelle comme ci dessous, on peut utiliser le script "SplitData_EPCI"

/*-- Pour les sorties avec l'EPCI, pour pouvoir sortir les fichiers de livraison
DROP TABLE IF EXISTS "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_epci;
CREATE TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_epci AS (
	WITH territory_table_with_epci_labels AS (
		SELECT a.*, b.label typo
		FROM "TerritoryTable_PF_2019" a
		LEFT JOIN "TerritoryTable_PF_2019" b
		ON ST_Intersects(ST_PointOnSurface(a.geom),b.geom)
		WHERE a.rank = '1' AND b.rank = '2'
		GROUP BY a.id, a.geom, b.label
		UNION ALL
		SELECT *, '' typo
		FROM "TerritoryTable_PF_2019"
		WHERE rank = '2' OR rank = '3'
	),
	-- Nombre total de locaux par commune. Les communes sans locaux n'apparaitront pas dans la table finale
	total_by_com AS ( 
		SELECT t.id_geom id_geom, a."CodeService" "Categorie", Count(a.geom) "Count_ENTITIES", t.typo
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto"."F4_EQU_EvolServicesEquipements_equipements" a, territory_table_with_epci_labels t
		WHERE ST_Intersects(a.geom,t.geom)
		GROUP BY id_geom, "Categorie"
	),
	-- Nombre de locaux dans la centralité par commune
	total_by_com_in_env AS (
		SELECT t.id_geom id_geom, a."CodeService" "Categorie", Count(a.geom) "Count_ENTITIES",'IN' "Location", t.typo
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto"."F4_EQU_EvolServicesEquipements_equipements" a, territory_table_with_epci_labels t, public."centralites" env
		WHERE ST_Intersects(a.geom,t.geom) AND ST_Intersects(a.geom,env.geom)
		GROUP BY id_geom, "Categorie", "Location"
	),
	-- Nombre de locaux hors centralités par commune
	total_by_com_out_env AS (
		SELECT total_by_com.id_geom id_geom, total_by_com."Categorie", COALESCE(SUM(total_by_com."Count_ENTITIES" - total_by_com_in_env."Count_ENTITIES"),0) "Count_ENTITIES", 'OUT' "Location", t.typo
		FROM total_by_com 
		LEFT JOIN total_by_com_in_env
		ON total_by_com.id_geom = total_by_com_in_env.id_geom
		AND total_by_com."Categorie" = total_by_com_in_env."Categorie"
		GROUP BY total_by_com.id_geom, total_by_com."Categorie", "Location" 
	)
	-- Union par commune du nombre de locaux dans/hors la centralité
	SELECT id_geom::text, "Count_ENTITIES"::int, "Categorie", "Location"::text, typo::text FROM total_by_com_in_env
	UNION
	SELECT id_geom::text, "Count_ENTITIES"::int, "Categorie", "Location"::text, typo::text FROM total_by_com_out_env
	ORDER BY id_geom, "Location"
);

ALTER TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_epci
DROP COLUMN IF EXISTS "Categorie_format";
ALTER TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_epci 
ADD COLUMN "Categorie_format" varchar;

UPDATE "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_epci
SET "Categorie_format" = (
	CASE 
	WHEN "Categorie" = 1 THEN 'Commerces'
	WHEN "Categorie" = 2 THEN 'Espaces de convivialité'
	WHEN "Categorie" = 3 THEN 'Equipements d''intérêt collectif'
	END
);
SELECT * FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_epci;*/





--/--/--/--/--/--/--/--/--/--/--/--/
-- Pour la vieille donnée de 2017 --
--/--/--/--/--/--/--/--/--/--/--/--/

-- Jointure avec la table de jointure
DROP TABLE IF EXISTS "F4_EQU_EvolServicesEquipements_Centralites_carto"."F4_EQU_EvolServicesEquipements_equipements_2017";
CREATE TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto"."F4_EQU_EvolServicesEquipements_equipements_2017" AS (
	SELECT REPLACE(sirene."apet700",'.','') "CODE_EQU", sirene.geom, join_table."CodeService", join_table."LABEL"
	FROM "F4_EQU_EvolServicesEquipements_Centralites_carto"."geo_sirene_35_LOCALISED_JOINED_2017" sirene
	FULL JOIN public."Categorie_Equipement_Ponderation_UTF8_V3_ForJointure" join_table
	ON REPLACE(sirene."apet700",'.','') = join_table."TYPE"
	WHERE join_table."CodeService" IS NOT NULL
);



-- Creation des chiffres clés
--D:\_CLIENT\PSB_2017\_TRAVAIL\F4_EQU_EvolServicesEquipements_carto\travail\__F4_EQU_EvolServicesEquipements_carto_CONFIG.json

-- Pour le SCoT PF
DROP TABLE IF EXISTS "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_2017;
CREATE TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_2017 AS (
	-- Nombre total de locaux par commune. Les communes sans locaux n'apparaitront pas dans la table finale
	WITH total_by_com AS ( 
		SELECT t.id_geom id_geom, a."CodeService" "Categorie", Count(a.geom) "Count_ENTITIES"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto"."F4_EQU_EvolServicesEquipements_equipements_2017" a, public."TerritoryTable_PF_2019" t
		WHERE ST_Intersects(a.geom,t.geom)
		GROUP BY id_geom, "Categorie"
	),
	-- Nombre de locaux dans la centralité par commune
	total_by_com_in_env AS (
		SELECT t.id_geom id_geom, a."CodeService" "Categorie", Count(a.geom) "Count_ENTITIES",'IN' "Location"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto"."F4_EQU_EvolServicesEquipements_equipements_2017" a, public."TerritoryTable_PF_2019" t, public."centralites" env
		WHERE ST_Intersects(a.geom,t.geom) AND ST_Intersects(a.geom,env.geom)
		GROUP BY id_geom, "Categorie", "Location"
	),
	-- Nombre de locaux hors centralités par commune
	total_by_com_out_env AS (
		SELECT total_by_com.id_geom id_geom, total_by_com."Categorie", COALESCE(SUM(total_by_com."Count_ENTITIES" - COALESCE(total_by_com_in_env."Count_ENTITIES",0)),0) "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com 
		LEFT JOIN total_by_com_in_env
		ON total_by_com.id_geom = total_by_com_in_env.id_geom
		AND total_by_com."Categorie" = total_by_com_in_env."Categorie"
		GROUP BY total_by_com.id_geom, total_by_com."Categorie", "Location" 
	)
	-- Union par commune du nombre de locaux dans/hors la centralité
	SELECT id_geom::text, "Count_ENTITIES"::int, "Categorie", "Location"::text FROM total_by_com_in_env
	UNION
	SELECT id_geom::text, "Count_ENTITIES"::int, "Categorie", "Location"::text FROM total_by_com_out_env
	ORDER BY id_geom, "Location"
);

ALTER TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_2017
DROP COLUMN IF EXISTS "Categorie_format";
ALTER TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_2017 
ADD COLUMN "Categorie_format" varchar;

UPDATE "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_2017
SET "Categorie_format" = (
	CASE 
	WHEN "Categorie" = 1 THEN 'Commerces'
	WHEN "Categorie" = 2 THEN 'Espaces de convivialité'
	WHEN "Categorie" = 3 THEN 'Equipements d''intérêt collectif'
	END
);
SELECT * FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_2017;
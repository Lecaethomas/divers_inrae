-- ! UPDATE THL 20-07-2021 -> j'ai changé le modeleur afin qu'il prenne les terrains de sport et les cimetières j'ai donc duppliquer des elements de calculs ci dessous pour des tests 

-- Utilisation du modeler "C:\Users\sgevt\.qgis2\processing\scripts\SCRIPTS_FROM_PC_ADS\models\FX_OCS\FX_OCS_TacheUrbaine\_IndicateurTacheUrbaineGLOBAL_V2bis_ADS_2017.04.04.model"

-- Visiblement le modeleur n'a pas de problèmes avec les géométries 3D etc.

-- Il faut créer un champ (par exemple "buff_dist") dans les routes pour indiquer la largeur.
-- Créer le champ directement dans la calculatrice de QGis:

/*CASE
WHEN "NATURE" LIKE  'Type autoroutier'  THEN 10
WHEN "NATURE" LIKE  'Route à 2 chaussées' THEN 6
WHEN "NATURE" LIKE  'Route à 1 chaussée' THEN 3
WHEN "NATURE" LIKE  'Bretelle' THEN 3
WHEN "NATURE" LIKE  'Piste cyclable' THEN 1.5
WHEN "NATURE" LIKE  'Escalier' THEN 1
ELSE 0
END*/
-- (source: https://geo.data.gouv.fr/fr/datasets/bab7db4c172c916eb95c5031388891c599cd11ba)

-- En comparant les 2 couches en sortie, on se rend compte qu'il y a des types de voies qui ne sont pas prises en comptes, alors qu'elles l'étaient dans les couches précédentes de la tache infrastructure. On a gardé les anciens réseaux, donc en les comparant on peut voir que ces catégories sont manquantes, la doc au dessus est sans doute dépassée (le fait qu'on n'ait pas fait de buffer dessus n'est pas lié à un changement récent des attributs) :
	-- les ronds-points 3
	-- les routes empierrées 1
	-- les sentiers 1
	-- chemin 1

-- Nouvelle requête:

/*CASE
WHEN "NATURE" LIKE  'Type autoroutier'  THEN 10
WHEN "NATURE" LIKE  'Route à 2 chaussées' THEN 6
WHEN "NATURE" LIKE  'Route à 1 chaussée' THEN 3
WHEN "NATURE" LIKE  'Bretelle' THEN 3
WHEN "NATURE" LIKE  'Piste cyclable' THEN 1.5
WHEN "NATURE" LIKE  'Rond-point' THEN 3
ELSE 1
END*/

-- On importe le résultat dans une base PostGIS, puis:


--/--/--/--/
--/ 2022 --/
--/--/--/--/

-- 25min16s

DROP TABLE IF EXISTS "F1_OCS_TacheUrbaine".chiffres_cles_2022;
CREATE TABLE "F1_OCS_TacheUrbaine".chiffres_cles_2022 AS (
	SELECT t.id_geom, SUM(ST_Area(ST_Intersection(t.geom,st_makevalid(tu.geom)))) AS "Area_ENTITIES", ST_Area(t.geom) AS "Area_TERRITORIES"
	FROM public."TerritoryTable_PF_2019" t, "F1_OCS_TacheUrbaine"."Indicateur_TacheUrbaine" tu
	WHERE ST_Intersects(t.geom,tu.geom)
	GROUP BY t.id_geom, t.geom
);


--/--/--/--/
--/ 2021 --/
--/--/--/--/

-- 25min16s

DROP TABLE IF EXISTS "F1_OCS_TacheUrbaine".chiffres_cles_2021;
CREATE TABLE "F1_OCS_TacheUrbaine".chiffres_cles_2021 AS (
	SELECT t.id_geom, SUM(ST_Area(ST_Intersection(t.geom,st_makevalid(tu.geom)))) AS "Area_ENTITIES", ST_Area(t.geom) AS "Area_TERRITORIES"
	FROM public."TerritoryTable_PF_2019" t, "F1_OCS_TacheUrbaine"."Indicateur_TacheUrbaine_2021" tu
	WHERE ST_Intersects(t.geom,tu.geom)
	GROUP BY t.id_geom, t.geom
);


-- element modifié pour les test concernant l'adaptation de la méthodologie (intégration des terrains de sport + cimetières)
--/--/--/--/
--/ 2019_new --/
--/--/--/--/

DROP TABLE IF EXISTS "F1_OCS_TacheUrbaine".chiffres_cles_2020_new;
CREATE TABLE "F1_OCS_TacheUrbaine".chiffres_cles_2020_new AS (
	SELECT t.id_geom, SUM(ST_Area(ST_Intersection(t.geom,tu.geom))) AS "Area_ENTITIES", ST_Area(t.geom) AS "Area_TERRITORIES"
	FROM public."TerritoryTable_PF_2019" t, "F1_OCS_TacheUrbaine"."indicateur_tache_urbaine_2020_new" tu
	WHERE ST_Intersects(t.geom,tu.geom)
	GROUP BY t.id_geom, t.geom
);


--/--/--/--/
--/ 2020 --/
--/--/--/--/

-- 42min41s

DROP TABLE IF EXISTS "F1_OCS_TacheUrbaine".chiffres_cles_2020;
CREATE TABLE "F1_OCS_TacheUrbaine".chiffres_cles_2020 AS (
	SELECT t.id_geom, SUM(ST_Area(ST_Intersection(t.geom,st_makevalid(tu.geom)))) AS "Area_ENTITIES", ST_Area(t.geom) AS "Area_TERRITORIES"
	FROM public."TerritoryTable_PF_2019" t, "F1_OCS_TacheUrbaine"."indicateur_tache_urbaine" tu
	WHERE ST_Intersects(t.geom,tu.geom)
	GROUP BY t.id_geom, t.geom
);


-- element modifié pour les test concernant l'adaptation de la méthodologie (intégration des terrains de sport + cimetières)
--/--/--/--/
--/ 2019_new --/
--/--/--/--/

DROP TABLE IF EXISTS "F1_OCS_TacheUrbaine".chiffres_cles_2019_new;
CREATE TABLE "F1_OCS_TacheUrbaine".chiffres_cles_2019_new AS (
	SELECT t.id_geom, SUM(ST_Area(ST_Intersection(t.geom,tu.geom))) AS "Area_ENTITIES", ST_Area(t.geom) AS "Area_TERRITORIES"
	FROM public."TerritoryTable_PF_2019" t, "F1_OCS_TacheUrbaine"."indicateur_tache_urbaine_2019_new" tu
	WHERE ST_Intersects(t.geom,tu.geom)
	GROUP BY t.id_geom, t.geom
);


--/--/--/--/
--/ 2019 --/
--/--/--/--/

DROP TABLE IF EXISTS "F1_OCS_TacheUrbaine".chiffres_cles_2019;
CREATE TABLE "F1_OCS_TacheUrbaine".chiffres_cles_2019 AS (
	SELECT t.id_geom, SUM(ST_Area(ST_Intersection(t.geom,tu.geom))) AS "Area_ENTITIES", ST_Area(t.geom) AS "Area_TERRITORIES"
	FROM public."TerritoryTable_PV_BDTopo_2020.08" t, "F1_OCS_TacheUrbaine"."Indicateur_TacheUrbaine" tu
	WHERE ST_Intersects(t.geom,tu.geom)
	GROUP BY t.id_geom, t.geom
);



--/--/--/--/
--/ 2016 --/
--/--/--/--/

/*DROP TABLE IF EXISTS "F1_OCS_TacheUrbaine".chiffres_cles_2016;
CREATE TABLE "F1_OCS_TacheUrbaine".chiffres_cles_2016 AS (
	SELECT t.id_geom, SUM(ST_Area(ST_Intersection(t.geom,tu.geom))) Area_ENTITIES, ST_Area(t.geom) Area_TERRITORIES
	FROM public."TerritoryTable_PF_2019" t, "F1_OCS_TacheUrbaine"."_Indicateur_TacheUrbaine_BdTopo2016_Fougeres" tu
	WHERE ST_Intersects(t.geom,tu.geom)
	GROUP BY t.id_geom, t.geom
);




--/--/--/--/
--/ 2014 --/
--/--/--/--/

DROP TABLE IF EXISTS "F1_OCS_TacheUrbaine".chiffres_cles_2014;
CREATE TABLE "F1_OCS_TacheUrbaine".chiffres_cles_2014 AS (
	SELECT t.id_geom, SUM(ST_Area(ST_Intersection(t.geom,tu.geom))) Area_ENTITIES, ST_Area(t.geom) Area_TERRITORIES
	FROM public."TerritoryTable_PF_2019" t, "F1_OCS_TacheUrbaine"."_Indicateur_TacheUrbaine_BdTopo2014_Fougeres" tu
	WHERE ST_Intersects(t.geom,tu.geom)
	GROUP BY t.id_geom, t.geom
);


--/--/--/--/
--/ 2013 --/
--/--/--/--/

*/
DROP TABLE IF EXISTS "F1_OCS_TacheUrbaine".chiffres_cles_2013;
CREATE TABLE "F1_OCS_TacheUrbaine".chiffres_cles_2013 AS (
	SELECT t.id_geom, SUM(ST_Area(ST_Intersection(t.geom,tu.geom))) Area_ENTITIES, ST_Area(t.geom) Area_TERRITORIES
	FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154" t, "F1_OCS_TacheUrbaine"."Indicateur_TacheUrbaine_2013" tu
	WHERE ST_Intersects(t.geom,tu.geom)
	GROUP BY t.id_geom, t.geom
);

/*
--/--/--/--/
--/ 2011 --/
--/--/--/--/

DROP TABLE IF EXISTS "F1_OCS_TacheUrbaine".chiffres_cles_2011;
CREATE TABLE "F1_OCS_TacheUrbaine".chiffres_cles_2011 AS (
	SELECT t.id_geom, SUM(ST_Area(ST_Intersection(t.geom,tu.geom))) Area_ENTITIES, ST_Area(t.geom) Area_TERRITORIES
	FROM public."TerritoryTable_PF_2019" t, "F1_OCS_TacheUrbaine"."_Indicateur_TacheUrbaine_BdTopo2011_Fougeres" tu
	WHERE ST_Intersects(t.geom,tu.geom)
	GROUP BY t.id_geom, t.geom
);


-- Pour la dataviz, sur la tache urbaine, on a un système qui filtre les taches sur leur code insee. C'est pas terrible en cas de fusion de commune, mais surtout c'et fait pour fonctionner avec un champ "insee_1". Comme j'ai déjà fait les geoJSON pour les MBTiles je renomme le champ directement à l'intérieur.
-- Pour la tache bâtie par contre j'avais enlevé le système, il faudra faire des MBTiles individuels pour les sous-territoires.
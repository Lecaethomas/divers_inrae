-- ! Données: FFonciers 2019 (reçus en 2020)
-- Variables à remplacer: 

-- Le nom de la base			PSB_Actualisation_2019
-- Le nom du schema 			F1_DEN_Densite_Logements
-- La table de locaux			fftp_2019_pb0010_local
-- La table de parcelles		"fftp_2018_pnb10_parcelle.geompar" * a priori pas besoin de cette table
-- La table de carroyage 		_CarroyageMicro_PST_EPSG2154
-- la territory table           TerritoryTable_PST_2020_2154

-- Les années, avec le millésime 2016: 
	-- la densité de référence est calculée sur la base de tous les logements construits avant le 31 décembre 2013	
	-- on étudie l'évolution entre le 1er janvier et 31 décembre 2017
	-- on affiche à titre d'information les locaux construits à partir du 1er janvier 2015: ce sont des données encore incomplètes qui seront mises à jour au prochain millésime

-- * Update THL (20-04-2021): 
-- J'ai remplacé "densite_class" par "densite_cl" pour que les fichiers en sortie
-- collent aux besoins de la dataviz

--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/
--/--/--/--/-- PREPARATION LOGEMENTS --/--/--/--/--
--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/

-- On met de côté les logements WHERE jannath < 2017 pour calculer la densité de référence
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements"."01_logt_reference";
CREATE TABLE "F1_DEN_Densite_Logements"."01_logt_reference" AS (
	SELECT idlocal, geomloc
	FROM public.fftp_2019_pb0010_local
	WHERE jannath < 2017 AND dteloc IN ('1','2')
);

-- On met de côté les logements WHERE jannath < 2018 pour calculer la densité de référence
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements"."02_logt_actualisation";
CREATE TABLE "F1_DEN_Densite_Logements"."02_logt_actualisation" AS (
	SELECT idlocal, geomloc
	FROM public.fftp_2019_pb0010_local
	WHERE jannath < 2018 AND dteloc IN ('1','2')
);

-- On met de côté les logements WHERE jannath = 2017 pour calculer l'évolution
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements"."03_logt_evolution";
CREATE TABLE "F1_DEN_Densite_Logements"."03_logt_evolution" AS (
	SELECT idlocal, geomloc
	FROM public.fftp_2019_pb0010_local
	WHERE jannath = 2017 AND dteloc IN ('1','2')
);

-- On met de côté les logements WHERE jannath > 2017 pour simple affichage
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements"."_dataviz_simple_affichage";
CREATE TABLE "F1_DEN_Densite_Logements"."_dataviz_simple_affichage" AS (
	SELECT idlocal, geomloc
	FROM public.fftp_2019_pb0010_local
	WHERE jannath > 2017 AND dteloc IN ('1','2')
);


--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/
--/--/--/--/-- PREPARATION CARROYAGE --/--/--/--/--
--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/

-- 24 min 5 secs sur CAP (SIL)
-- 1min 11s sur PSB (THL)

-- À partir de:
	-- La couche de carroyage complète 		_CarroyageMicro_PST_EPSG2154
	-- La table territoire 					TerritoryTable_PST_2020_2154
	-- La couche d'enveloppe urbaine		_PST_EnveloppeUrbaine_2017.05.26
	-- (Toutes ces couches sont dans le schema public)


-- On ne garde que les carreaux qui intersectent le territoire
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements".carroyage_intersects;
CREATE TABLE "F1_DEN_Densite_Logements".carroyage_intersects AS (
	WITH main_territoire AS (
		SELECT * 
		FROM public."TerritoryTable_PST_2020_2154"
		WHERE rank = 3
	)
	SELECT car."id_car", car.geom
	FROM public."_CarroyageMicro_PST_EPSG2154" car
	LEFT JOIN main_territoire
	ON ST_Intersects(car.geom, main_territoire.geom)
	WHERE main_territoire.id_geom IS NOT NULL
);
DROP INDEX IF EXISTS "F1_DEN_Densite_Logements".carroyage_intersects_geom_idx;
CREATE INDEX carroyage_intersects_geom_idx ON "F1_DEN_Densite_Logements".carroyage_intersects USING GIST (geom);

-- ! COMMENTAIRE de SIL:
-- Sur PSB cette étape est beaucoup trop longue dans PostGIS à cause du ST_Union, il faudrait vraiment que je change ma version de postGIS pour pas avoir à faire ça en utilisant ST_Split(). 
-- En attendant je prends la couche "carroyage_intersects" dans QGis, et je fais une intersection avec la couche de Communes ("TerritoryTable_PST_2020_2154".rank = 1). 
-- Et je redépose le résultat dans le schema "F1_DEN_Densite_Logements" sous le nom "carroyage_final". Ensuite on peut reprendre à l'étape de création de la couche carroyage_final_format
-- ! COMMENTAIRE de THL:
-- si l'on suit les instructions de SIL lors de l'import de la table carroyage_final et du lancement de la création de carroyage_final_format, il nous manque le new_id_car qui est un row_number()
--  over() normalement (si l'on fait la phace automatique).
-- pour remplacer ça, à l'import de la table carroyage_final je passe ce nom comme clé primaire "new_id_car"

--Temps pour la phase manuelle (intersection communes/carroyage + env urbaine/carroyage) ( pas représentatif, j'ai deux instances PG en cours ): début_10:54

/*-- Pour découper les carreaux selon les limites des communes et des enveloppes urbaines, je suis un peu coincé par le fait que j'utilise la version 2.3 de PostGIS. Apparement il y a des màj dans la 2.4 qui font qu'on peut utiliser ST_Split() avec des MultilinesStrings maintenant. En attendant je suis obligé de contourner un peu le problème, en 4 étapes, avec des conversions de géométries, mais c'est assez simple et ça marche bien.

	-- 1. On regroupe dans une même couche les carreaux, les limites communales, et les l'enveloppe urbaine, sous forme de lignes
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements".carroyage_intersects_split;
	CREATE TABLE "F1_DEN_Densite_Logements".carroyage_intersects_split AS (
		WITH t AS (
			SELECT geom
			FROM "F1_DEN_Densite_Logements".carroyage_intersects car
			UNION ALL
			SELECT geom
			FROM public."TerritoryTable_PST_2020_2154"
			WHERE rank = 1
			--UNION ALL
			--SELECT geom
			--FROM public."Cap_Atlantique_EnvUrbaine_PourCalculs_2018"
		)
		SELECT (ST_Dump(ST_Boundary(geom))).geom geom
		FROM t
	);
	DROP INDEX IF EXISTS "F1_DEN_Densite_Logements".carroyage_intersects_split_geom_idx;
	CREATE INDEX carroyage_intersects_split_geom_idx ON "F1_DEN_Densite_Logements"."carroyage_intersects_split" USING GIST (geom);

	-- 2. On fusionne toutes ces lignes
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements".carroyage_intersects_split_lines;
	CREATE TABLE "F1_DEN_Densite_Logements".carroyage_intersects_split_lines AS (
		SELECT ST_Union(geom) geom
		FROM "F1_DEN_Densite_Logements".carroyage_intersects_split
	);

	-- 3. On recrée des polygones à partir des lignes
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements".carroyage_intersects_split_poly;
	CREATE TABLE "F1_DEN_Densite_Logements".carroyage_intersects_split_poly AS (
		SELECT (ST_Dump(ST_Polygonize(geom))).geom geom 
		FROM "F1_DEN_Densite_Logements".carroyage_intersects_split_lines
	);

	-- 4. On rattache l'ID_CAR aux nouveaux carreaux découpés
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements".carroyage_intersects_split_poly_id;
	CREATE TABLE "F1_DEN_Densite_Logements".carroyage_intersects_split_poly_id AS (
		SELECT b.id_car "ID_CAR", a.geom
		FROM "F1_DEN_Densite_Logements".carroyage_intersects_split_poly a
		LEFT JOIN public."_CarroyageMicro_PST_EPSG2154" b
		ON ST_Intersects(ST_PointOnSurface(a.geom),b.geom) --AND ST_Area(ST_Intersection(a.geom,b.geom)) > 1
	);
	DROP INDEX IF EXISTS "F1_DEN_Densite_Logements".carroyage_intersects_split_poly_id_geom_idx;
	CREATE INDEX carroyage_intersects_split_poly_id_geom_idx ON "F1_DEN_Densite_Logements".carroyage_intersects_split_poly_id USING GIST (geom);

-- 4 min 47 secs.
-- Pour finir on ne garde que les carreaux qui intersectent les territoires
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements".carroyage_final;
CREATE TABLE "F1_DEN_Densite_Logements".carroyage_final AS (
	WITH main_territoire AS (
		SELECT * 
		FROM public."TerritoryTable_PST_2020_2154"
		WHERE rank = 1
	)
	SELECT car."ID_CAR", row_number() OVER () as new_id_car, car.geom
	FROM "F1_DEN_Densite_Logements".carroyage_intersects_split_poly_id car
	LEFT JOIN main_territoire
	ON ST_Intersects(ST_PointOnSurface(car.geom), main_territoire.geom)
	WHERE main_territoire.id_geom IS NOT NULL
);
DROP INDEX IF EXISTS "F1_DEN_Densite_Logements".carroyage_final_geom_idx;
CREATE INDEX carroyage_final_geom_idx ON "F1_DEN_Densite_Logements".carroyage_final USING GIST (geom);*/


-- On crée une nouvelle colonne d'ID avec le rownum et la position du carreau par rapport à l'enveloppe urbaine
/*ALTER TABLE "F1_DEN_Densite_Logements".carroyage_final 
DROP COLUMN IF EXISTS location;
ALTER TABLE "F1_DEN_Densite_Logements".carroyage_final 
ADD COLUMN location varchar;
SET location = (
	CASE
	WHEN ST_Intersects(Poi)
)*/

-- Formatage de la table de carreaux
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements".carroyage_final_format;
CREATE TABLE "F1_DEN_Densite_Logements".carroyage_final_format AS (
	SELECT carr.new_id_car, terr.id_geom id_geom, ST_Area(carr.geom) "Count_ENTITIES_ref", ST_Union(carr.geom) geom
	FROM "F1_DEN_Densite_Logements".carroyage_final carr
	LEFT JOIN public."TerritoryTable_PST_2020_2154" terr
	ON ST_Intersects(terr.geom, ST_PointOnSurface(carr.geom))
	WHERE terr.rank = 1
	GROUP BY carr.new_id_car, terr.id_geom
);
DROP INDEX IF EXISTS "F1_DEN_Densite_Logements".carroyage_final_format_geom_idx;
CREATE INDEX carroyage_final_format_geom_idx ON "F1_DEN_Densite_Logements"."carroyage_final_format" USING GIST (geom);



--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
--/--/--/--/-- CHIFFRES CLES REFERENCE --/--/--/--/--
--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--

-- Couche pour MBTile
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements"._dataviz_carreaux_reference;
CREATE TABLE "F1_DEN_Densite_Logements"._dataviz_carreaux_reference AS (
	SELECT carr.new_id_car, carr.id_geom, Count(logt.*) "Count_ENTITIES", carr."Count_ENTITIES_ref", carr.geom
	FROM "F1_DEN_Densite_Logements".carroyage_final_format carr
	LEFT JOIN "F1_DEN_Densite_Logements"."01_logt_reference" logt
	ON ST_Intersects(carr.geom, logt.geomloc)
	WHERE logt.idlocal IS NOT NULL
	GROUP BY carr.new_id_car, carr.id_geom, carr."Count_ENTITIES_ref", carr.geom
);
DROP INDEX IF EXISTS "F1_DEN_Densite_Logements"._dataviz_carreaux_reference_geom_idx;
CREATE INDEX _dataviz_carreaux_reference_geom_idx ON "F1_DEN_Densite_Logements"."_dataviz_carreaux_reference" USING GIST (geom);

-- On ajoute la colonne de moyenne _avg
ALTER TABLE "F1_DEN_Densite_Logements"._dataviz_carreaux_reference
DROP COLUMN IF EXISTS "Count_ENTITIES_avg";
ALTER TABLE "F1_DEN_Densite_Logements"._dataviz_carreaux_reference 
ADD COLUMN "Count_ENTITIES_avg" float;
UPDATE "F1_DEN_Densite_Logements"._dataviz_carreaux_reference 
SET "Count_ENTITIES_avg" = ROUND((CAST("Count_ENTITIES" as float)/(ST_Area(geom)/10000))::numeric, 1);

-- On ajoute la colonne pour la classe pour la dataviz
ALTER TABLE "F1_DEN_Densite_Logements"._dataviz_carreaux_reference
DROP COLUMN IF EXISTS "densite_cl";
ALTER TABLE "F1_DEN_Densite_Logements"._dataviz_carreaux_reference 
ADD COLUMN "densite_cl" varchar;
UPDATE "F1_DEN_Densite_Logements"._dataviz_carreaux_reference 
SET "densite_cl" = (
	CASE
	WHEN  "Count_ENTITIES_avg" >= 1 AND "Count_ENTITIES_avg" <= 2 THEN '[1 - 2]'
	WHEN  "Count_ENTITIES_avg" > 2 AND "Count_ENTITIES_avg" <= 6 THEN ']2 - 6]'
	WHEN  "Count_ENTITIES_avg" > 6 AND "Count_ENTITIES_avg" <= 12 THEN ']6 - 12]'
	WHEN  "Count_ENTITIES_avg" > 12 AND "Count_ENTITIES_avg" <= 21 THEN ']12 - 21]'
	WHEN  "Count_ENTITIES_avg" > 21 AND "Count_ENTITIES_avg" <= 31 THEN ']21 - 31]'
	WHEN  "Count_ENTITIES_avg" > 31 AND "Count_ENTITIES_avg" <= 47 THEN ']31 - 47]'
	WHEN  "Count_ENTITIES_avg" > 47 AND "Count_ENTITIES_avg" <= 86 THEN ']47 - 86]'
	WHEN  "Count_ENTITIES_avg" > 86 AND "Count_ENTITIES_avg" <= 311 THEN ']86 - 154]'
	ELSE '999'
	END
);


-- Table de chiffres clés
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements".chiffres_cles_reference;
CREATE TABLE "F1_DEN_Densite_Logements".chiffres_cles_reference AS (
	SELECT terr.id_geom, SUM(carr."Count_ENTITIES") "Count_ENTITIES", SUM(ST_Area(carr.geom))/10000 "Count_ENTITIES_ref"
	FROM "F1_DEN_Densite_Logements"._dataviz_carreaux_reference carr
	LEFT JOIN public."TerritoryTable_PST_2020_2154" terr
	ON ST_Intersects(ST_PointOnSurface(carr.geom), terr.geom)
	WHERE terr.id IS NOT NULL
	GROUP BY terr.id_geom
);

-- On ajoute la colonne de moyenne _avg
ALTER TABLE "F1_DEN_Densite_Logements".chiffres_cles_reference
DROP COLUMN IF EXISTS "Count_ENTITIES_avg";
ALTER TABLE "F1_DEN_Densite_Logements".chiffres_cles_reference 
ADD COLUMN "Count_ENTITIES_avg" float;
UPDATE "F1_DEN_Densite_Logements".chiffres_cles_reference 
SET "Count_ENTITIES_avg" = CAST("Count_ENTITIES" as float)/"Count_ENTITIES_ref";
SELECT * FROM "F1_DEN_Densite_Logements".chiffres_cles_reference;




--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
--/--/--/--/-- CHIFFRES CLES ACTUALISATION --/--/--/-
--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--

-- Couche pour MBTile
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements"._dataviz_carreaux_actualisation;
CREATE TABLE "F1_DEN_Densite_Logements"._dataviz_carreaux_actualisation AS (
	SELECT carr.new_id_car, carr.id_geom, Count(logt.*) "Count_ENTITIES", carr."Count_ENTITIES_ref", carr.geom
	FROM "F1_DEN_Densite_Logements".carroyage_final_format carr
	LEFT JOIN "F1_DEN_Densite_Logements"."02_logt_actualisation" logt
	ON ST_Intersects(carr.geom, logt.geomloc)
	WHERE logt.idlocal IS NOT NULL
	GROUP BY carr.new_id_car, carr.id_geom, carr."Count_ENTITIES_ref", carr.geom
);
DROP INDEX IF EXISTS "F1_DEN_Densite_Logements"._dataviz_carreaux_actualisation_geom_idx;
CREATE INDEX _dataviz_carreaux_actualisation_geom_idx ON "F1_DEN_Densite_Logements"."_dataviz_carreaux_actualisation" USING GIST (geom);

-- On ajoute la colonne de moyenne _avg
ALTER TABLE "F1_DEN_Densite_Logements"._dataviz_carreaux_actualisation
DROP COLUMN IF EXISTS "Count_ENTITIES_avg";
ALTER TABLE "F1_DEN_Densite_Logements"._dataviz_carreaux_actualisation 
ADD COLUMN "Count_ENTITIES_avg" float;
UPDATE "F1_DEN_Densite_Logements"._dataviz_carreaux_actualisation 
SET "Count_ENTITIES_avg" = ROUND((CAST("Count_ENTITIES" as float)/(ST_Area(geom)/10000))::numeric, 1);

-- On ajoute la colonne pour la classe pour la dataviz
ALTER TABLE "F1_DEN_Densite_Logements"._dataviz_carreaux_actualisation
DROP COLUMN IF EXISTS "densite_cl";
ALTER TABLE "F1_DEN_Densite_Logements"._dataviz_carreaux_actualisation 
ADD COLUMN "densite_cl" varchar;
UPDATE "F1_DEN_Densite_Logements"._dataviz_carreaux_actualisation 
SET "densite_cl" = (
	CASE
	WHEN  "Count_ENTITIES_avg" >= 1 AND "Count_ENTITIES_avg" <= 2 THEN '[1 - 2]'
	WHEN  "Count_ENTITIES_avg" > 2 AND "Count_ENTITIES_avg" <= 6 THEN ']2 - 6]'
	WHEN  "Count_ENTITIES_avg" > 6 AND "Count_ENTITIES_avg" <= 12 THEN ']6 - 12]'
	WHEN  "Count_ENTITIES_avg" > 12 AND "Count_ENTITIES_avg" <= 21 THEN ']12 - 21]'
	WHEN  "Count_ENTITIES_avg" > 21 AND "Count_ENTITIES_avg" <= 31 THEN ']21 - 31]'
	WHEN  "Count_ENTITIES_avg" > 31 AND "Count_ENTITIES_avg" <= 47 THEN ']31 - 47]'
	WHEN  "Count_ENTITIES_avg" > 47 AND "Count_ENTITIES_avg" <= 86 THEN ']47 - 86]'
	WHEN  "Count_ENTITIES_avg" > 86 AND "Count_ENTITIES_avg" <= 311 THEN ']86 - 154]'
	ELSE '999'
	END
);


-- Table chiffres clés
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements".chiffres_cles_actualisation;
CREATE TABLE "F1_DEN_Densite_Logements".chiffres_cles_actualisation AS (
	SELECT terr.id_geom, SUM(carr."Count_ENTITIES") "Count_ENTITIES", SUM(ST_Area(carr.geom))/10000 "Count_ENTITIES_ref"
	FROM "F1_DEN_Densite_Logements"._dataviz_carreaux_actualisation carr
	LEFT JOIN public."TerritoryTable_PST_2020_2154" terr
	ON ST_Intersects(ST_PointOnSurface(carr.geom), terr.geom)
	WHERE terr.id IS NOT NULL
	GROUP BY terr.id_geom
);

-- On ajoute la colonne de moyenne _avg
ALTER TABLE "F1_DEN_Densite_Logements".chiffres_cles_actualisation
DROP COLUMN IF EXISTS "Count_ENTITIES_avg";
ALTER TABLE "F1_DEN_Densite_Logements".chiffres_cles_actualisation 
ADD COLUMN "Count_ENTITIES_avg" float;
UPDATE "F1_DEN_Densite_Logements".chiffres_cles_actualisation 
SET "Count_ENTITIES_avg" = CAST("Count_ENTITIES" as float)/"Count_ENTITIES_ref";
SELECT * FROM "F1_DEN_Densite_Logements".chiffres_cles_actualisation;




--/--/--/--/--/--/--/--/--/--/--/--/--/--/
--/--/--/--/-- CALCUL ÉVOLUTION --/--/--/-
--/--/--/--/--/--/--/--/--/--/--/--/--/--/

-- Couche pour geojson
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements"._dataviz_carreaux_evolution;
CREATE TABLE "F1_DEN_Densite_Logements"._dataviz_carreaux_evolution AS (
	SELECT carr.new_id_car, carr.id_geom, Count(logt.*) "Count_ENTITIES", ST_Union(geom) geom
	FROM "F1_DEN_Densite_Logements".carroyage_final_format carr
	LEFT JOIN "F1_DEN_Densite_Logements"."03_logt_evolution" logt
	ON ST_Intersects(logt.geomloc, carr.geom)
	WHERE logt.idlocal IS NOT NULL
	GROUP BY new_id_car, id_geom
);


-- Ajout du nombe de logement de l'année de référence
ALTER TABLE "F1_DEN_Densite_Logements"._dataviz_carreaux_evolution DROP COLUMN IF EXISTS "Count_ENTITIES_ref";
ALTER TABLE "F1_DEN_Densite_Logements"._dataviz_carreaux_evolution ADD COLUMN "Count_ENTITIES_ref" numeric;
UPDATE "F1_DEN_Densite_Logements"._dataviz_carreaux_evolution carr
SET "Count_ENTITIES_ref" = COALESCE(ref."Count_ENTITIES",0)
	FROM "F1_DEN_Densite_Logements"._dataviz_carreaux_reference ref
	WHERE carr.new_id_car = ref.new_id_car;
-- Il y a des valeurs nulles
UPDATE "F1_DEN_Densite_Logements"._dataviz_carreaux_evolution carr
SET "Count_ENTITIES_ref" = (
	CASE
	WHEN "Count_ENTITIES_ref" IS NULL THEN 0
	ELSE "Count_ENTITIES_ref"
	END
);

-- Ajout du nombe de logement de l'année d'actualisation (normalement pas de valeurs à zéro ici)
ALTER TABLE "F1_DEN_Densite_Logements"._dataviz_carreaux_evolution DROP COLUMN IF EXISTS "Count_ENTITIES_actu";
ALTER TABLE "F1_DEN_Densite_Logements"._dataviz_carreaux_evolution ADD COLUMN "Count_ENTITIES_actu" numeric;
UPDATE "F1_DEN_Densite_Logements"._dataviz_carreaux_evolution carr
SET "Count_ENTITIES_actu" = COALESCE(actu."Count_ENTITIES",0)
	FROM "F1_DEN_Densite_Logements"._dataviz_carreaux_actualisation actu
	WHERE carr.new_id_car = actu.new_id_car;


-- On ajoute la colonne pour la classe pour la dataviz
ALTER TABLE "F1_DEN_Densite_Logements"._dataviz_carreaux_evolution
DROP COLUMN IF EXISTS "densite_cl";
ALTER TABLE "F1_DEN_Densite_Logements"._dataviz_carreaux_evolution 
ADD COLUMN "densite_cl" varchar;
UPDATE "F1_DEN_Densite_Logements"._dataviz_carreaux_evolution 
SET "densite_cl" = (
	CASE
	WHEN  "Count_ENTITIES" >= 1 AND "Count_ENTITIES" <= 2 THEN '[1 - 2]'
	WHEN  "Count_ENTITIES" > 2 AND "Count_ENTITIES" <= 10 THEN ']2 - 10]'
	WHEN  "Count_ENTITIES" > 10 AND "Count_ENTITIES" <= 16 THEN ']10 - 16]'
	WHEN  "Count_ENTITIES" > 16 AND "Count_ENTITIES" <= 30 THEN ']16 - 30]'
	WHEN  "Count_ENTITIES" > 30 AND "Count_ENTITIES" <= 50 THEN ']30 - 52]'
	-- Pour PSB on n'a pas besoin de la dernière classe à + de 50, mais il faut pas l'oublier si on a un autre territoire
	-- WHEN  "Count_ENTITIES" > 50 AND "Count_ENTITIES" <= 47 THEN ']50 - 110]'
	ELSE '999'
	END
);



--/--/--/--/--/--/--/--/--/--/--/--/--/--/
--/--/--/--/-- DENSITE ZONES AU --/--/--/-
--/--/--/--/--/--/--/--/--/--/--/--/--/--/

-- la table zonesau est dans le schema public
ALTER TABLE public.zonesau DROP COLUMN IF EXISTS id;
ALTER TABLE public.zonesau ADD COLUMN id SERIAL PRIMARY KEY;

-- Compte des logements de référence
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements"._temp_densite_zonesau;
CREATE TABLE "F1_DEN_Densite_Logements"._temp_densite_zonesau AS (
	SELECT zau.id, zau.libelle, zau.typezone, zau.destdomi, ST_Area(zau.geom) area_zau, COALESCE(Count(ref.*), 0) "Count_ref", zau.geom 
	FROM public.zonesau zau
	LEFT JOIN "F1_DEN_Densite_Logements"."01_logt_reference" ref
	ON ST_Intersects(zau.geom, ref.geomloc)
	GROUP BY zau.id, zau.libelle, zau.typezone, zau.destdomi, zau.geom
);
DROP INDEX IF EXISTS "F1_DEN_Densite_Logements"._temp_densite_zonesau_geom_idx;
CREATE INDEX _temp_densite_zonesau_geom_idx ON "F1_DEN_Densite_Logements"."_temp_densite_zonesau" USING GIST (geom);


-- Compte des logements à l'actualisation
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements"._dataviz_densite_zonesau;
CREATE TABLE "F1_DEN_Densite_Logements"._dataviz_densite_zonesau AS (
	SELECT zau.id, zau.libelle, zau.typezone, zau.destdomi, ST_Area(zau.geom) area_zau,  zau."Count_ref", COALESCE(Count(actu.*), 0) "Count_actu", zau.geom 
	FROM "F1_DEN_Densite_Logements"._temp_densite_zonesau zau
	LEFT JOIN "F1_DEN_Densite_Logements"."02_logt_actualisation" actu
	ON ST_Intersects(zau.geom, actu.geomloc)
	GROUP BY zau.id, zau.libelle, zau.typezone, zau.destdomi, zau."Count_ref", zau.geom
);


-- On ajoute la colonne de densité pour chacune des années
	-- réfrérence
	ALTER TABLE "F1_DEN_Densite_Logements"._dataviz_densite_zonesau DROP COLUMN IF EXISTS "densite_ref";
	ALTER TABLE "F1_DEN_Densite_Logements"._dataviz_densite_zonesau ADD COLUMN "densite_ref" float;
	UPDATE "F1_DEN_Densite_Logements"._dataviz_densite_zonesau 
	SET "densite_ref" = ROUND((CAST("Count_ref" as float)/(CAST(area_zau as float)/10000))::numeric, 1);

	-- actualisation
	ALTER TABLE "F1_DEN_Densite_Logements"._dataviz_densite_zonesau DROP COLUMN IF EXISTS "densite_actu";
	ALTER TABLE "F1_DEN_Densite_Logements"._dataviz_densite_zonesau ADD COLUMN "densite_actu" float;
	UPDATE "F1_DEN_Densite_Logements"._dataviz_densite_zonesau 
	SET "densite_actu" = ROUND((CAST("Count_actu" as float)/(CAST(area_zau as float)/10000))::numeric, 1);




--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/-
--/--/--/--/-- POUR EXPORTS CARREAUX EPCI --/--/--/-
--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/-

-- Création de tables de carroyage avec un label EPCI pour séparer les couches et créer des MBTiles 
	-- Densité de référence
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements"._dataviz_carreaux_reference_EPCI;
	CREATE TABLE "F1_DEN_Densite_Logements"._dataviz_carreaux_reference_EPCI AS (
		SELECT carr.*, terr.label typo
		FROM "F1_DEN_Densite_Logements"._dataviz_carreaux_reference carr
		LEFT JOIN public."TerritoryTable_PST_2020_2154" terr
		ON ST_Intersects(terr.geom, ST_PointOnSurface(carr.geom))
		WHERE terr.rank = 2
	);

	-- Densité d'actualisation
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements"._dataviz_carreaux_actualisation_EPCI;
	CREATE TABLE "F1_DEN_Densite_Logements"._dataviz_carreaux_actualisation_EPCI AS (
		SELECT carr.*, terr.label typo
		FROM "F1_DEN_Densite_Logements"._dataviz_carreaux_actualisation carr
		LEFT JOIN public."TerritoryTable_PST_2020_2154" terr
		ON ST_Intersects(terr.geom, ST_PointOnSurface(carr.geom))
		WHERE terr.rank = 2
	);

	-- Evolution 
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements"._dataviz_carreaux_evolution_EPCI;
	CREATE TABLE "F1_DEN_Densite_Logements"._dataviz_carreaux_evolution_EPCI AS (
		SELECT carr.*, terr.label typo
		FROM "F1_DEN_Densite_Logements"._dataviz_carreaux_evolution carr
		LEFT JOIN public."TerritoryTable_PST_2020_2154" terr
		ON ST_Intersects(terr.geom, ST_PointOnSurface(carr.geom))
		WHERE terr.rank = 2
	);

	-- Zones AU 
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements"._dataviz_densite_zonesau_EPCI;
	CREATE TABLE "F1_DEN_Densite_Logements"._dataviz_densite_zonesau_EPCI AS (
		SELECT zau.*, terr.label typo
		FROM "F1_DEN_Densite_Logements"._dataviz_densite_zonesau zau
		LEFT JOIN public."TerritoryTable_PST_2020_2154" terr
		ON ST_Intersects(terr.geom, ST_PointOnSurface(zau.geom))
		WHERE terr.rank = 2
	);




























--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/-
--/--/--/--/-- RECOMMENCE CARROYAGE --/--/--/-
--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/-

-- On recommmence le carroyage pour finalement n'afficher que des carreaux entier. 
-- Les chiffres clés sont basés sur le carroyage, mais on fait le choix de ne pas les changer. Ils restent les mêmes c'est à dire qu'on continue de compter les surfaces de référence des carreau avec ST_Area (et non en partant du principe qu'un carreau = 1ha comme avant)
-- J'utilise la table _CarroyageMicro_PST_EPSG2154 qui est dans le public

-- Couche actualisation

	-- Couche pour MBTile
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements"._new_dataviz_carreaux_actualisation;
	CREATE TABLE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_actualisation AS (
		SELECT carr.id_car, Count(logt.*) "Count_ENTITIES", ST_Area(carr.geom) "Count_ENTITIES_ref", carr.geom
		FROM public."_CarroyageMicro_PST_EPSG2154" carr
		LEFT JOIN "F1_DEN_Densite_Logements"."02_logt_actualisation" logt
		ON ST_Intersects(carr.geom, logt.geomloc)
		WHERE logt.idlocal IS NOT NULL
		GROUP BY carr.id_car, carr.geom
	);
	DROP INDEX IF EXISTS "F1_DEN_Densite_Logements"._new_dataviz_carreaux_actualisation_geom_idx;
	CREATE INDEX _new_dataviz_carreaux_actualisation_geom_idx ON "F1_DEN_Densite_Logements"."_new_dataviz_carreaux_actualisation" USING GIST (geom);

	-- On ajoute la colonne de moyenne _avg
	ALTER TABLE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_actualisation
	DROP COLUMN IF EXISTS "Count_ENTITIES_avg";
	ALTER TABLE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_actualisation 
	ADD COLUMN "Count_ENTITIES_avg" float;
	UPDATE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_actualisation 
	SET "Count_ENTITIES_avg" = ROUND((CAST("Count_ENTITIES" as float)/(ST_Area(geom)/10000))::numeric, 1);

	-- On ajoute la colonne pour la classe pour la dataviz
	ALTER TABLE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_actualisation
	DROP COLUMN IF EXISTS "densite_cl";
	ALTER TABLE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_actualisation 
	ADD COLUMN "densite_cl" varchar;
	UPDATE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_actualisation 
	SET "densite_cl" = (
		CASE
		WHEN  "Count_ENTITIES_avg" >= 1 AND "Count_ENTITIES_avg" <= 2 THEN '[1 - 2]'
		WHEN  "Count_ENTITIES_avg" > 2 AND "Count_ENTITIES_avg" <= 6 THEN ']2 - 6]'
		WHEN  "Count_ENTITIES_avg" > 6 AND "Count_ENTITIES_avg" <= 12 THEN ']6 - 12]'
		WHEN  "Count_ENTITIES_avg" > 12 AND "Count_ENTITIES_avg" <= 21 THEN ']12 - 21]'
		WHEN  "Count_ENTITIES_avg" > 21 AND "Count_ENTITIES_avg" <= 31 THEN ']21 - 31]'
		WHEN  "Count_ENTITIES_avg" > 31 AND "Count_ENTITIES_avg" <= 47 THEN ']31 - 47]'
		WHEN  "Count_ENTITIES_avg" > 47 AND "Count_ENTITIES_avg" <= 86 THEN ']47 - 86]'
		WHEN  "Count_ENTITIES_avg" > 86 AND "Count_ENTITIES_avg" <= 311 THEN ']86 - 311]'
		ELSE '999'
		END
	);

-- Couche référence

	-- Couche pour MBTile
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements"._new_dataviz_carreaux_reference;
	CREATE TABLE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_reference AS (
		SELECT carr.id_car, Count(logt.*) "Count_ENTITIES", ST_Area(carr.geom) "Count_ENTITIES_ref", carr.geom
		FROM public."_CarroyageMicro_PST_EPSG2154" carr
		LEFT JOIN "F1_DEN_Densite_Logements"."01_logt_reference" logt
		ON ST_Intersects(carr.geom, logt.geomloc)
		WHERE logt.idlocal IS NOT NULL
		GROUP BY carr.id_car, carr.geom
	);
	DROP INDEX IF EXISTS "F1_DEN_Densite_Logements"._new_dataviz_carreaux_reference_geom_idx;
	CREATE INDEX _new_dataviz_carreaux_reference_geom_idx ON "F1_DEN_Densite_Logements"."_new_dataviz_carreaux_reference" USING GIST (geom);

	-- On ajoute la colonne de moyenne _avg
	ALTER TABLE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_reference
	DROP COLUMN IF EXISTS "Count_ENTITIES_avg";
	ALTER TABLE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_reference 
	ADD COLUMN "Count_ENTITIES_avg" float;
	UPDATE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_reference 
	SET "Count_ENTITIES_avg" = ROUND((CAST("Count_ENTITIES" as float)/(ST_Area(geom)/10000))::numeric, 1);

	-- On ajoute la colonne pour la classe pour la dataviz
	ALTER TABLE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_reference
	DROP COLUMN IF EXISTS "densite_cl";
	ALTER TABLE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_reference 
	ADD COLUMN "densite_cl" varchar;
	UPDATE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_reference 
	SET "densite_cl" = (
		CASE
		WHEN  "Count_ENTITIES_avg" >= 1 AND "Count_ENTITIES_avg" <= 2 THEN '[1 - 2]'
		WHEN  "Count_ENTITIES_avg" > 2 AND "Count_ENTITIES_avg" <= 6 THEN ']2 - 6]'
		WHEN  "Count_ENTITIES_avg" > 6 AND "Count_ENTITIES_avg" <= 12 THEN ']6 - 12]'
		WHEN  "Count_ENTITIES_avg" > 12 AND "Count_ENTITIES_avg" <= 21 THEN ']12 - 21]'
		WHEN  "Count_ENTITIES_avg" > 21 AND "Count_ENTITIES_avg" <= 31 THEN ']21 - 31]'
		WHEN  "Count_ENTITIES_avg" > 31 AND "Count_ENTITIES_avg" <= 47 THEN ']31 - 47]'
		WHEN  "Count_ENTITIES_avg" > 47 AND "Count_ENTITIES_avg" <= 86 THEN ']47 - 86]'
		WHEN  "Count_ENTITIES_avg" > 86 AND "Count_ENTITIES_avg" <= 311 THEN ']86 - 311]'
		ELSE '999'
		END
	);


-- Couche d'évolution
	-- Couche pour geojson
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements"._new_dataviz_carreaux_evolution;
	CREATE TABLE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_evolution AS (
		SELECT carr.id_car, Count(logt.*) "Count_ENTITIES", geom
		FROM public."_CarroyageMicro_PST_EPSG2154" carr
		LEFT JOIN "F1_DEN_Densite_Logements"."03_logt_evolution" logt
		ON ST_Intersects(logt.geomloc, carr.geom)
		WHERE logt.idlocal IS NOT NULL
		GROUP BY id_car, geom
	);

	-- Ajout du nombe de logement de l'année de référence
	ALTER TABLE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_evolution DROP COLUMN IF EXISTS "Count_ENTITIES_ref";
	ALTER TABLE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_evolution ADD COLUMN "Count_ENTITIES_ref" numeric;
	UPDATE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_evolution carr
	SET "Count_ENTITIES_ref" = COALESCE(ref."Count_ENTITIES",0)
		FROM "F1_DEN_Densite_Logements"._new_dataviz_carreaux_reference ref
		WHERE carr.id_car = ref.id_car;
	-- Il y a des valeurs nulles
	UPDATE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_evolution carr
	SET "Count_ENTITIES_ref" = (
		CASE
		WHEN "Count_ENTITIES_ref" IS NULL THEN 0
		ELSE "Count_ENTITIES_ref"
		END
	);

	-- Ajout du nombe de logement de l'année d'actualisation (normalement pas de valeurs à zéro ici)
	ALTER TABLE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_evolution DROP COLUMN IF EXISTS "Count_ENTITIES_actu";
	ALTER TABLE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_evolution ADD COLUMN "Count_ENTITIES_actu" numeric;
	UPDATE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_evolution carr
	SET "Count_ENTITIES_actu" = COALESCE(actu."Count_ENTITIES",0)
		FROM "F1_DEN_Densite_Logements"._new_dataviz_carreaux_actualisation actu
		WHERE carr.id_car = actu.id_car;


	-- On ajoute la colonne pour la classe pour la dataviz
	ALTER TABLE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_evolution
	DROP COLUMN IF EXISTS "densite_cl";
	ALTER TABLE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_evolution 
	ADD COLUMN "densite_cl" varchar;
	UPDATE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_evolution 
	SET "densite_cl" = (
		CASE
		WHEN  "Count_ENTITIES" >= 1 AND "Count_ENTITIES" <= 2 THEN '[1 - 2]'
		WHEN  "Count_ENTITIES" > 2 AND "Count_ENTITIES" <= 10 THEN ']2 - 10]'
		WHEN  "Count_ENTITIES" > 10 AND "Count_ENTITIES" <= 16 THEN ']10 - 16]'
		WHEN  "Count_ENTITIES" > 16 AND "Count_ENTITIES" <= 30 THEN ']16 - 30]'
		WHEN  "Count_ENTITIES" > 30 AND "Count_ENTITIES" <= 50 THEN ']30 - 50]'
		-- Pour PSB on n'a pas besoin de la dernière classe à + de 50, mais il faut pas l'oublier si on a un autre territoire
		-- WHEN  "Count_ENTITIES" > 50 AND "Count_ENTITIES" <= 47 THEN ']50 - 110]'
		ELSE '999'
		END
	);




-- Pour les EPCI
-- ! Attention, ici on est obligés d'utiliser le centroide des carreaux pour associer le carreau à un EPCI.
-- L'idéal ce serait de l'associer si : le carreau intersecte l'ecpi ET contient un logement dans l'epci, mais ça voudrait dire qu'un carreau peut apparaitre dans les deux EPCI à la fois
-- Et surout avec cette méthode on perd tous les carreaux entiers dont le centroïde n'intersecte pas le territoire
-- Ça veut dire qu'il manque des carreaux dans les dataviz aux EPCI

	-- Densité de référence
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements"._new_dataviz_carreaux_reference_EPCI;
	CREATE TABLE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_reference_EPCI AS (
		SELECT carr.*, terr.label typo
		FROM "F1_DEN_Densite_Logements"._new_dataviz_carreaux_reference carr
		LEFT JOIN public."TerritoryTable_PST_2020_2154" terr
		ON ST_Intersects(terr.geom, ST_Centroid(carr.geom))
		WHERE terr.rank = 2
	);

	-- Densité d'actualisation
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements"._new_dataviz_carreaux_actualisation_EPCI;
	CREATE TABLE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_actualisation_EPCI AS (
		SELECT carr.*, terr.label typo
		FROM "F1_DEN_Densite_Logements"._new_dataviz_carreaux_actualisation carr
		LEFT JOIN public."TerritoryTable_PST_2020_2154" terr
		ON ST_Intersects(terr.geom, ST_Centroid(carr.geom))
		WHERE terr.rank = 2
	);

	-- Evolution 
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements"._new_dataviz_carreaux_evolution_EPCI;
	CREATE TABLE "F1_DEN_Densite_Logements"._new_dataviz_carreaux_evolution_EPCI AS (
		SELECT carr.*, terr.label typo
		FROM "F1_DEN_Densite_Logements"._new_dataviz_carreaux_evolution carr
		LEFT JOIN public."TerritoryTable_PST_2020_2154" terr
		ON ST_Intersects(terr.geom, ST_Centroid(carr.geom))
		WHERE terr.rank = 2
	);
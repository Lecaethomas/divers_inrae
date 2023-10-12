-- Variables à remplacer:

-- Le nom de la base			vitre_initialisation
-- Le nom du schema 			F1_DEN_Densite_Logements_IN_OUT
-- La table de locaux			fftp_2021_pb0010_local
-- La table de carroyage 		_CarroyageMicro_PV_EPSG2154
-- L'enveloppe urbaine 			enveloppebourg2018

-- Les années, avec le millésime 2016:
	-- la densité de référence est calculée sur la base de tous les logements construits avant le 31 décembre 2013
	-- on étudie l'évolution entre le 1er janvier et 31 décembre 2016
	-- on affiche à titre d'information les locaux construits à partir du 1er janvier 2015: ce sont des données encore incomplètes qui seront mises à jour au prochain millésime

-- Deux millésimes se conjuguent avec les ffonciers: le millésime Majic (année de prod par la dgfip) et millésime Cerema (année de retraitement - souvent +1 par rapport à la dgfip)
-- Millesime_cerema = ff_YYYY donc millésime_dgfip = YYYY-1
-- Logements produits après le 1er janvier Millesime-1 => Millesime - 1
-- Évolution du 1er janvier au 31 décembre 2015 => année de référence
-- Densité au 31 décembre 2015 (année de référence = 2015)

-- UPDATE 2021-08-24 :
		-- En vue d erépondr eà une demande du SUPV on va produire d'autres "chiffres clés" qui seront représentés en choroplèthe/analyse thématique 
		--afin de permettre l'évaluation et la confrontation aux objectifs mentionnes dansle scot p.23

--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/
--/--/--/--/-- PREPARATION LOGEMENTS --/--/--/--/--
--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/

-- À remplacer : les années

-- On met de côté les logements WHERE jannath < 2016 pour calculer la densité de référence
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"."01_logt_reference";
CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT"."01_logt_reference" AS (
	SELECT idlocal, geom
	FROM "F1_DEN_Densite_Logements_IN_OUT".fftp_2021_pb0010_local
	WHERE jannath < 2016 AND dteloc IN ('1','2')
);

-- On met de côté les logements WHERE jannath < 2019 pour calculer la densité d'actualisation
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"."02_logt_actualisation";
CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT"."02_logt_actualisation" AS (
	SELECT idlocal, geom
	FROM "F1_DEN_Densite_Logements_IN_OUT".fftp_2021_pb0010_local
	WHERE jannath < 2019 AND dteloc IN ('1','2')
);

-- On met de côté les logements WHERE jannath = 2016 pour calculer l'évolution
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"."03_logt_evolution";
CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT"."03_logt_evolution" AS (
	SELECT idlocal, geom
	FROM "F1_DEN_Densite_Logements_IN_OUT".fftp_2021_pb0010_local
	WHERE jannath in(2018,2017,2016) AND dteloc IN ('1','2')
);

-- On met de côté les logements WHERE jannath > 2016 pour simple affichage
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"."_dataviz_simple_affichage";
CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT"."_dataviz_simple_affichage" AS (
	SELECT idlocal, geom
	FROM "F1_DEN_Densite_Logements_IN_OUT".fftp_2021_pb0010_local
	WHERE jannath > 2018 AND dteloc IN ('1','2')
);
-------------------------------///---------------------------------
-- Spe vitré : on a pas eu les ff 2020 mais ceux de 2021 donc on "simule" ceux de 2020 pour la couche d'affichage simple (on définit la fourchette pour les logements simple affichage)
-------------------------------///---------------------------------
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"."_dataviz_simple_affichage";
CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT"."_dataviz_simple_affichage" AS (
	SELECT idlocal, geom
	FROM "F1_DEN_Densite_Logements_IN_OUT".fftp_2021_pb0010_local
	WHERE jannath > 2018 and jannath < 2020 AND dteloc IN ('1','2')
);



--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/
--/--/--/--/-- PREPARATION CARROYAGE --/--/--/--/--
--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/

-- 24 min 5 secs sur CAP

-- À partir de:
	-- La couche de carroyage complète 		_CarroyageMicro_PV_EPSG2154
	-- La table territoire 					TerritoryTable_PV_BDTopo_2020.08_full_2154
	-- La couche d'enveloppe urbaine		enveloppebourg2018
	-- (Toutes ces couches sont dans le schema public)

	-- ++ ATTENTION AU RANK = 4 pour les territoire qui n'ont PAS QUE commune, epci et scot


-- !!!!!Attention le Champs "ID_CAR" doit être en minuscule!!!!!!!!!!!!!!!

-- À remplacer : le numéro de rank

-- On ne garde que les carreaux qui intersectent le territoire
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".carroyage_intersects;
CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT".carroyage_intersects AS (
	WITH main_territoire AS (
		SELECT *
		FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154"
		WHERE rank = 4
	)
	SELECT car."ID_CAR" AS id_car, car.geom
	FROM public."_CarroyageMicro_PV_EPSG2154" AS car
	LEFT JOIN main_territoire
	ON ST_Intersects(car.geom, main_territoire.geom)
	WHERE main_territoire.id_geom IS NOT NULL
);
DROP INDEX IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".carroyage_intersects_geom_idx;
CREATE INDEX carroyage_intersects_geom_idx ON "F1_DEN_Densite_Logements_IN_OUT".carroyage_intersects USING GIST (geom);

-- IMPORTANT (lire en entier) --
-- Sur PSB cette étape est beaucoup trop longue dans PostGIS à cause du ST_Union (pour Vitré c'est très long mais ça fini par marcher aussi, il faudrait que je change ma version de postGIS pour pouvoir faire ça en utilisant ST_Split() (cf paragraphe ci dessous). En attendant je prends la couche "carroyage_intersects" dans QGis, et je fais une intersection avec la couche de Communes ("TerritoryTable_PV_BDTopo_2020.08_full_2154".rank = 1), puis avec la couche d'enveloppe urbaine (sous forme de lignes, on peut utilliser clip polygon by lines dans QGis3+). Et je redépose le résultat dans le schema "F1_DEN_Densite_Logements_IN_OUT" sous le nom "carroyage_final". Ensuite on peut reprendre à l'étape de création de la couche "carroyage_final_format"

-- Pour découper les carreaux selon les limites des communes et des enveloppes urbaines, je suis un peu coincé par le fait que j'utilise la version 2.3 de PostGIS. Apparement il y a des màj dans la 2.5 qui font qu'on peut utiliser ST_Split() avec des MultilinesStrings maintenant. En attendant je suis obligé de contourner un peu le problème, en 4 étapes, avec des conversions de géométries, mais c'est assez simple et ça marche bien.

/*	-- 1. On regroupe dans une même couche les carreaux, les limites communales, et les l'enveloppe urbaine, sous forme de lignes
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".carroyage_intersects_split;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT".carroyage_intersects_split AS (
		WITH t AS (
			SELECT geom
			FROM "F1_DEN_Densite_Logements_IN_OUT".carroyage_intersects car
			UNION ALL
			SELECT geom
			FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154"
			WHERE rank = 4
			UNION ALL
			SELECT geom
			FROM public."enveloppebourg2018"
		)
		SELECT (ST_Dump(ST_Boundary(geom))).geom geom
		FROM t
	);
	DROP INDEX IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".carroyage_intersects_split_geom_idx;
	CREATE INDEX carroyage_intersects_split_geom_idx ON "F1_DEN_Densite_Logements_IN_OUT"."carroyage_intersects_split" USING GIST (geom);

	-- 2. On fusionne toutes ces lignes
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".carroyage_intersects_split_lines;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT".carroyage_intersects_split_lines AS (
		SELECT ST_Union(geom) geom
		FROM "F1_DEN_Densite_Logements_IN_OUT".carroyage_intersects_split
	);
	DROP INDEX IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".carroyage_intersects_split_lines_geom_idx;
	CREATE INDEX carroyage_intersects_split_lines_geom_idx ON "F1_DEN_Densite_Logements_IN_OUT"."carroyage_intersects_split_lines" USING GIST (geom);

	-- 3. On recrée des polygones à partir des lignes
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".carroyage_intersects_split_poly;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT".carroyage_intersects_split_poly AS (
		SELECT (ST_Dump(ST_Polygonize(geom))).geom geom
		FROM "F1_DEN_Densite_Logements_IN_OUT".carroyage_intersects_split_lines
	);

	-- 4. On rattache l'ID_CAR aux nouveaux carreaux découpés
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".carroyage_intersects_split_poly_id;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT".carroyage_intersects_split_poly_id AS (
		SELECT b.id_car "ID_CAR", a.geom
		FROM "F1_DEN_Densite_Logements_IN_OUT".carroyage_intersects_split_poly a
		LEFT JOIN public."_CarroyageMicro_PV_2154" b
		ON ST_Intersects(ST_PointOnSurface(a.geom),b.geom) --AND ST_Area(ST_Intersection(a.geom,b.geom)) > 1
	);
	DROP INDEX IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".carroyage_intersects_split_poly_id_geom_idx;
	CREATE INDEX carroyage_intersects_split_poly_id_geom_idx ON "F1_DEN_Densite_Logements_IN_OUT".carroyage_intersects_split_poly_id USING GIST (geom);

-- 4 min 47 secs.
-- Pour finir on ne garde que les carreaux qui intersectent les territoires
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".carroyage_final;
CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT".carroyage_final AS (
	WITH main_territoire AS (
		SELECT *
		FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154"
		WHERE rank = 1
	)
	SELECT car."ID_CAR", row_number() OVER () as new_id_car, car.geom
	FROM "F1_DEN_Densite_Logements_IN_OUT".carroyage_intersects_split_poly_id car
	LEFT JOIN main_territoire
	ON ST_Intersects(ST_PointOnSurface(car.geom), main_territoire.geom)
	WHERE main_territoire.id_geom IS NOT NULL
);
DROP INDEX IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".carroyage_final_geom_idx;
CREATE INDEX carroyage_final_geom_idx ON "F1_DEN_Densite_Logements_IN_OUT".carroyage_final USING GIST (geom);*/


-- On crée une nouvelle colonne d'ID avec le rownum et la position du carreau par rapport à l'enveloppe urbaine
/*ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT".carroyage_final
DROP COLUMN IF EXISTS location;
ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT".carroyage_final
ADD COLUMN location varchar;
SET location = (
	CASE
	WHEN ST_Intersects(Poi)
)*/
 -- On génère un id (mais pas une clé primaire) pour chaque géométries de carreau
ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT".carroyage_final DROP COLUMN IF EXISTS "new_id_car";
ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT".carroyage_final ADD COLUMN "new_id_car" serial ;


ALTER TABLE public."enveloppebourg2018" DROP COLUMN IF EXISTS "new_id";
ALTER TABLE public."enveloppebourg2018" ADD COLUMN "new_id" serial ;



-- Formatage de la table de carreaux
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".carroyage_final_format;
CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT".carroyage_final_format AS (
	SELECT carr.new_id_car, terr.id_geom id_geom, ST_Area(carr.geom) "Count_ENTITIES_ref", ST_Union(carr.geom) geom
	FROM "F1_DEN_Densite_Logements_IN_OUT".carroyage_final AS carr
	LEFT JOIN public."TerritoryTable_PV_BDTopo_2020.08_full_2154" AS terr
	ON ST_Intersects(terr.geom, ST_PointOnSurface(carr.geom))
	WHERE terr.rank = 3
	GROUP BY carr.new_id_car, terr.id_geom, carr.geom
);
DROP INDEX IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".carroyage_final_format_geom_idx;
CREATE INDEX carroyage_final_format_geom_idx ON "F1_DEN_Densite_Logements_IN_OUT"."carroyage_final_format" USING GIST (geom);



--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
--/--/--/--/-- CHIFFRES CLES REFERENCE --/--/--/--/--
--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--

-- Couche pour MBTile
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_reference;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_reference AS (
		SELECT carr.new_id_car, carr.id_geom, Count(logt.*) "Count_ENTITIES", carr."Count_ENTITIES_ref", carr.geom
		FROM "F1_DEN_Densite_Logements_IN_OUT".carroyage_final_format AS carr
		LEFT JOIN "F1_DEN_Densite_Logements_IN_OUT"."01_logt_reference" AS logt
		ON ST_Intersects(carr.geom, logt.geom)
		WHERE logt.idlocal IS NOT NULL
		GROUP BY carr.new_id_car, carr.id_geom, carr."Count_ENTITIES_ref", carr.geom
	);
	DROP INDEX IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_reference_geom_idx;
	CREATE INDEX _dataviz_carreaux_reference_geom_idx ON "F1_DEN_Densite_Logements_IN_OUT"."_dataviz_carreaux_reference" USING GIST (geom);

	-- On ajoute la colonne de moyenne _avg
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_reference
	DROP COLUMN IF EXISTS "Count_ENTITIES_avg";
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_reference
	ADD COLUMN "Count_ENTITIES_avg" float;
	UPDATE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_reference
	SET "Count_ENTITIES_avg" = ROUND((CAST("Count_ENTITIES" as float)/(ST_Area(geom)/10000))::numeric, 1);

	-- On ajoute la colonne pour la classe pour la dataviz
	-- À cette étape il faut s'arrêter et aller regarder la valeur maximale de densité dans le carroyage (dans celui d'actualisation comme celui de référence). On utilise cette valeur maximale pour la borne max, toutes les autres bornes ont été fixées arbitrairement et validées par Nancy : on n'y touche plus peu importe le territoire.
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_reference
	DROP COLUMN IF EXISTS "densite_cl";
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_reference
	ADD COLUMN "densite_cl" varchar;
	UPDATE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_reference
	SET "densite_cl" = (
		CASE
		WHEN  "Count_ENTITIES_avg" >= 1 AND "Count_ENTITIES_avg" <= 2 THEN '[1 - 2]'
		WHEN  "Count_ENTITIES_avg" > 2 AND "Count_ENTITIES_avg" <= 6 THEN ']2 - 6]'
		WHEN  "Count_ENTITIES_avg" > 6 AND "Count_ENTITIES_avg" <= 12 THEN ']6 - 12]'
		WHEN  "Count_ENTITIES_avg" > 12 AND "Count_ENTITIES_avg" <= 21 THEN ']12 - 21]'
		WHEN  "Count_ENTITIES_avg" > 21 AND "Count_ENTITIES_avg" <= 31 THEN ']21 - 31]'
		WHEN  "Count_ENTITIES_avg" > 31 AND "Count_ENTITIES_avg" <= 47 THEN ']31 - 47]'
		WHEN  "Count_ENTITIES_avg" > 47 AND "Count_ENTITIES_avg" <= 86 THEN ']47 - 86]'
		WHEN  "Count_ENTITIES_avg" > 86 AND "Count_ENTITIES_avg" <= 248 THEN ']86 - 247]'
		ELSE '999'
		END
	);

-- Chiffres clés IN
	-- On stocke tous les logements à l'intérieur de l'enveloppe urbaine à l'échelle du territoire
	-- À remplacer : la colonne d'id de l'enveloppe urbaine
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference_part01;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference_part01 AS (
		SELECT logt.*
		FROM "F1_DEN_Densite_Logements_IN_OUT"."01_logt_reference" logt
		LEFT JOIN public."enveloppebourg2018" env
		ON ST_Intersects(logt.geom, env.geom)
		WHERE env.id IS NOT NULL
	);

	-- On stocke tous les carreaux à l'intérieur de l'enveloppe urbaine à l'échelle du territoire
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference_part02;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference_part02 AS (
		WITH carr AS ( -- les carreaux à l'intérieur de l'enveloppe urbaine ...
			SELECT carr.id_car, carr.geom
			FROM "F1_DEN_Densite_Logements_IN_OUT".carroyage_final carr
			LEFT JOIN public."enveloppebourg2018" env
			ON ST_Intersects(ST_PointOnSurface(carr.geom), env.geom)
			WHERE env.id IS NOT NULL
		) 
		-- ... et qui intersectent un logement
		SELECT carr.*
		FROM carr
		LEFT JOIN "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference_part01 logt
		ON ST_Intersects(logt.geom, carr.geom)
		WHERE logt.idlocal IS NOT NULL
		GROUP BY carr.id_car, carr.geom
	);

	-- On groupe le nombre de logements et de carreaux à l'intérieur ('IN') de l'enveloppe urbaine (les deux tables précédentes) par territoire (11 min 35 secs)
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference_part1;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference_part1 AS (
		SELECT a.id_geom, a."Location", a."Count_ENTITIES", b."Count_ENTITIES_ref"
		FROM (
			SELECT terr.id_geom, 'IN'::varchar "Location", Count(logt.*) AS "Count_ENTITIES"
			FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154" terr
			LEFT JOIN "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference_part01 logt
			ON ST_Intersects(logt.geom, terr.geom)
			WHERE terr.id_geom IS NOT NULL
			GROUP BY terr.id_geom
		) a
		LEFT JOIN (
			SELECT terr.id_geom, SUM(ST_Area(carr.geom))/10000 "Count_ENTITIES_ref"
			FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154" terr
			LEFT JOIN "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference_part02 carr
			ON ST_Intersects(ST_PointOnSurface(carr.geom), terr.geom)
			GROUP BY terr.id_geom
		) b
		ON a.id_geom = b.id_geom
	);

-- Chiffres clés Total, OUT, et aggrégation.
	--Requête pour totaux par territoire (38 min 43 secs)
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference_part2;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference_part2 AS (
		WITH temp_carr_intersects_logt AS (
			SELECT carr.*
			FROM "F1_DEN_Densite_Logements_IN_OUT".carroyage_final carr
			LEFT JOIN "F1_DEN_Densite_Logements_IN_OUT"."01_logt_reference" logt
			ON ST_Intersects(logt.geom, carr.geom)
			WHERE logt.idlocal IS NOT NULL
			GROUP BY carr.new_id_car, carr.geom 
		)
		SELECT a.id_geom, a."Count_ENTITIES", b."Count_ENTITIES_ref"
		FROM (
			SELECT terr.id_geom, Count(logt.geom) "Count_ENTITIES"
			FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154" terr
			LEFT JOIN "F1_DEN_Densite_Logements_IN_OUT"."01_logt_reference" logt
			ON ST_Intersects(logt.geom, terr.geom)
			WHERE terr.id_geom IS NOT NULL
			GROUP BY terr.id_geom
		) a
		LEFT JOIN (
			SELECT terr.id_geom, SUM(ST_Area(carr.geom))/10000 "Count_ENTITIES_ref"
			FROM temp_carr_intersects_logt carr
			LEFT JOIN public."TerritoryTable_PV_BDTopo_2020.08_full_2154" terr
			ON ST_Intersects(ST_PointOnSurface(carr.geom), terr.geom)
			WHERE terr.id IS NOT NULL
			GROUP BY terr.id_geom
		) b
		ON a.id_geom = b.id_geom
	);



	-- Aggégation et calcul du 'OUT' (351 msec)
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference AS (
		SELECT a.id_geom, a."Location", a."Count_ENTITIES", a."Count_ENTITIES_ref"
		FROM "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference_part1 a
		UNION ALL (
			SELECT b.id_geom, 'OUT'::varchar "Location", (b."Count_ENTITIES"-c."Count_ENTITIES") "Count_ENTITIES", (b."Count_ENTITIES_ref"-c."Count_ENTITIES_ref") "Count_ENTITIES_ref"
			FROM "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference_part2 b
			LEFT JOIN "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference_part1 c
			ON b.id_geom = c.id_geom
		)
		ORDER BY id_geom, "Location"
	);

	-- On ajoute la colonne de moyenne _avg
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference
	DROP COLUMN IF EXISTS "Count_ENTITIES_avg";
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference 
	ADD COLUMN "Count_ENTITIES_avg" float;
	UPDATE "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference 
	SET "Count_ENTITIES_avg" = CAST("Count_ENTITIES" as float)/"Count_ENTITIES_ref";
	SELECT * FROM "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference;
/*
-- Table de chiffres clés
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference;
CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference AS (
	SELECT terr.id_geom, SUM(carr."Count_ENTITIES") "Count_ENTITIES", SUM(ST_Area(carr.geom))/10000 "Count_ENTITIES_ref"
	FROM "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_reference AS carr
	LEFT JOIN public."TerritoryTable_PV_BDTopo_2020.08_full_2154" AS terr
	ON ST_Intersects(ST_PointOnSurface(carr.geom), terr.geom)
	WHERE terr.id IS NOT NULL
	GROUP BY terr.id_geom
);

-- On ajoute la colonne de moyenne _avg
ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference
DROP COLUMN IF EXISTS "Count_ENTITIES_avg";
ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference
ADD COLUMN "Count_ENTITIES_avg" float;
UPDATE "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference
SET "Count_ENTITIES_avg" = CAST("Count_ENTITIES" as float)/"Count_ENTITIES_ref";
SELECT * FROM "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_reference;*/




--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
--/--/--/--/-- CHIFFRES CLES ACTUALISATION --/--/--/-
--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--

-- Couche pour MBTile
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_actualisation;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_actualisation AS (
		SELECT carr.new_id_car, carr.id_geom, Count(logt.*) "Count_ENTITIES", carr."Count_ENTITIES_ref", carr.geom
		FROM "F1_DEN_Densite_Logements_IN_OUT".carroyage_final_format AS carr
		LEFT JOIN "F1_DEN_Densite_Logements_IN_OUT"."02_logt_actualisation" AS logt
		ON ST_Intersects(carr.geom, logt.geom)
		WHERE logt.idlocal IS NOT NULL
		GROUP BY carr.new_id_car, carr.id_geom, carr."Count_ENTITIES_ref", carr.geom
	);
	DROP INDEX IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_actualisation_geom_idx;
	CREATE INDEX _dataviz_carreaux_actualisation_geom_idx ON "F1_DEN_Densite_Logements_IN_OUT"."_dataviz_carreaux_actualisation" USING GIST (geom);

	-- On ajoute la colonne de moyenne _avg
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_actualisation
	DROP COLUMN IF EXISTS "Count_ENTITIES_avg";
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_actualisation
	ADD COLUMN "Count_ENTITIES_avg" float;
	UPDATE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_actualisation
	SET "Count_ENTITIES_avg" = ROUND((CAST("Count_ENTITIES" as float)/(ST_Area(geom)/10000))::numeric, 1);

	-- On ajoute la colonne pour la classe pour la dataviz
	-- À cette étape il faut s'arrêter et aller regarder la valeur maximale de densité dans le carroyage (dans celui d'actualisation comme celui de référence). On utilise cette valeur maximale pour la borne max, toutes les autres bornes ont été fixées arbitrairement et validées par Nancy : on n'y touche plus peu importe le territoire.
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_actualisation
	DROP COLUMN IF EXISTS "densite_cl";
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_actualisation
	ADD COLUMN "densite_cl" varchar;
	UPDATE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_actualisation
	SET "densite_cl" = (
		CASE
		WHEN  "Count_ENTITIES_avg" >= 1 AND "Count_ENTITIES_avg" <= 2 THEN '[1 - 2]'
		WHEN  "Count_ENTITIES_avg" > 2 AND "Count_ENTITIES_avg" <= 6 THEN ']2 - 6]'
		WHEN  "Count_ENTITIES_avg" > 6 AND "Count_ENTITIES_avg" <= 12 THEN ']6 - 12]'
		WHEN  "Count_ENTITIES_avg" > 12 AND "Count_ENTITIES_avg" <= 21 THEN ']12 - 21]'
		WHEN  "Count_ENTITIES_avg" > 21 AND "Count_ENTITIES_avg" <= 31 THEN ']21 - 31]'
		WHEN  "Count_ENTITIES_avg" > 31 AND "Count_ENTITIES_avg" <= 47 THEN ']31 - 47]'
		WHEN  "Count_ENTITIES_avg" > 47 AND "Count_ENTITIES_avg" <= 86 THEN ']47 - 86]'
		WHEN  "Count_ENTITIES_avg" > 86 AND "Count_ENTITIES_avg" <= 247 THEN ']86 - 248]'
		ELSE '999'
		END
	);

-- Chiffres clés IN
	-- On stocke tous les logements à l'intérieur de l'enveloppe urbaine à l'échelle du territoire
	-- À remplacer : la colonne d'id de l'enveloppe urbaine
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_actualisation_part01;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_actualisation_part01 AS (
		SELECT logt.*
		FROM "F1_DEN_Densite_Logements_IN_OUT"."02_logt_actualisation" logt
		LEFT JOIN public."enveloppebourg2018" env
		ON ST_Intersects(logt.geom, env.geom)
		WHERE env.new_id IS NOT NULL
	);

	-- On stocke tous les carreaux à l'intérieur de l'enveloppe urbaine à l'échelle du territoire
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_actualisation_part02;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_actualisation_part02 AS (
		WITH carr AS ( -- les carreaux à l'intérieur de l'enveloppe urbaine ...
			SELECT carr.new_id_car, carr.geom
			FROM "F1_DEN_Densite_Logements_IN_OUT".carroyage_final carr
			LEFT JOIN public."enveloppebourg2018" env
			ON ST_Intersects(ST_PointOnSurface(carr.geom), env.geom)
			WHERE env.new_id IS NOT NULL
		) 
		-- ... et qui intersectent un logement
		SELECT carr.*
		FROM carr
		LEFT JOIN "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_actualisation_part01 logt
		ON ST_Intersects(logt.geom, carr.geom)
		WHERE logt.idlocal IS NOT NULL
		GROUP BY carr.new_id_car, carr.geom
	);

	-- On groupe le nombre de logements et de carreaux à l'intérieur ('IN') de l'enveloppe urbaine (les deux tables précédentes) par territoire (11 min 35 secs)
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_actualisation_part1;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_actualisation_part1 AS (
		SELECT a.id_geom, a."Location", a."Count_ENTITIES", b."Count_ENTITIES_ref"
		FROM (
			SELECT terr.id_geom, 'IN'::varchar "Location", Count(logt.*) AS "Count_ENTITIES"
			FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154" terr
			LEFT JOIN "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_actualisation_part01 logt
			ON ST_Intersects(logt.geom, terr.geom)
			WHERE terr.id_geom IS NOT NULL
			GROUP BY terr.id_geom
		) a
		LEFT JOIN (
			SELECT terr.id_geom, SUM(ST_Area(carr.geom))/10000 "Count_ENTITIES_ref"
			FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154" terr
			LEFT JOIN "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_actualisation_part02 carr
			ON ST_Intersects(ST_PointOnSurface(carr.geom), terr.geom)
			GROUP BY terr.id_geom
		) b
		ON a.id_geom = b.id_geom
	);

-- Chiffres clés Total, OUT, et aggrégation.
	--Requête pour totaux par territoire (38 min 43 secs)
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_actualisation_part2;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_actualisation_part2 AS (
		WITH temp_carr_intersects_logt AS (
			SELECT carr.*
			FROM "F1_DEN_Densite_Logements_IN_OUT".carroyage_final carr
			LEFT JOIN "F1_DEN_Densite_Logements_IN_OUT"."02_logt_actualisation" logt
			ON ST_Intersects(logt.geom, carr.geom)
			WHERE logt.idlocal IS NOT NULL
			GROUP BY carr.new_id_car, carr.geom
		)
		SELECT a.id_geom, a."Count_ENTITIES", b."Count_ENTITIES_ref"
		FROM (
			SELECT terr.id_geom, Count(logt.geom) "Count_ENTITIES"
			FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154" terr
			LEFT JOIN "F1_DEN_Densite_Logements_IN_OUT"."02_logt_actualisation" logt
			ON ST_Intersects(logt.geom, terr.geom)
			WHERE terr.id_geom IS NOT NULL
			GROUP BY terr.id_geom
		) a
		LEFT JOIN (
			SELECT terr.id_geom, SUM(ST_Area(carr.geom))/10000 "Count_ENTITIES_ref"
			FROM temp_carr_intersects_logt carr
			LEFT JOIN public."TerritoryTable_PV_BDTopo_2020.08_full_2154" terr
			ON ST_Intersects(ST_PointOnSurface(carr.geom), terr.geom)
			WHERE terr.id IS NOT NULL
			GROUP BY terr.id_geom
		) b
		ON a.id_geom = b.id_geom
	);


	-- Aggégation et calcul du 'OUT' (351 msec)
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_actualisation;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_actualisation AS (
		SELECT a.id_geom, a."Location", a."Count_ENTITIES", a."Count_ENTITIES_ref"
		FROM "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_actualisation_part1 a
		UNION ALL (
			SELECT b.id_geom, 'OUT'::varchar "Location", (b."Count_ENTITIES"-c."Count_ENTITIES") "Count_ENTITIES", (b."Count_ENTITIES_ref"-c."Count_ENTITIES_ref") "Count_ENTITIES_ref"
			FROM "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_actualisation_part2 b
			LEFT JOIN "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_actualisation_part1 c
			ON b.id_geom = c.id_geom
		)
		ORDER BY id_geom, "Location"
	);

	-- On ajoute la colonne de moyenne _avg
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_actualisation
	DROP COLUMN IF EXISTS "Count_ENTITIES_avg";
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_actualisation 
	ADD COLUMN "Count_ENTITIES_avg" float;
	UPDATE "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_actualisation
	SET "Count_ENTITIES_avg" = CAST("Count_ENTITIES" as float)/"Count_ENTITIES_ref";
	SELECT * FROM "F1_DEN_Densite_Logements_IN_OUT".chiffres_cles_actualisation;




--/--/--/--/--/--/--/--/--/--/--/--/--/--/
--/--/--/--/-- CALCUL ÉVOLUTION --/--/--/-
--/--/--/--/--/--/--/--/--/--/--/--/--/--/

-- Couche pour geojson
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_evolution;
CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_evolution AS (
	SELECT carr.new_id_car, carr.id_geom, Count(logt.*) "Count_ENTITIES", ST_Union(carr.geom) AS geom
	FROM "F1_DEN_Densite_Logements_IN_OUT".carroyage_final_format AS carr
	LEFT JOIN "F1_DEN_Densite_Logements_IN_OUT"."03_logt_evolution" AS logt
	ON ST_Intersects(logt.geom, carr.geom)
	WHERE logt.idlocal IS NOT NULL
	GROUP BY new_id_car, id_geom
);


-- Ajout du nombe de logement de l'année de référence
ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_evolution DROP COLUMN IF EXISTS "Count_ENTITIES_ref";
ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_evolution ADD COLUMN "Count_ENTITIES_ref" numeric;
UPDATE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_evolution carr
SET "Count_ENTITIES_ref" = COALESCE(ref."Count_ENTITIES",0)
	FROM "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_reference AS ref
	WHERE carr.new_id_car = ref.new_id_car;
-- Il y a des valeurs nulles
UPDATE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_evolution AS carr
SET "Count_ENTITIES_ref" = (
	CASE
	WHEN "Count_ENTITIES_ref" IS NULL THEN 0
	ELSE "Count_ENTITIES_ref"
	END
);

-- Ajout du nombe de logement de l'année d'actualisation (normalement pas de valeurs à zéro ici)
ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_evolution DROP COLUMN IF EXISTS "Count_ENTITIES_actu";
ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_evolution ADD COLUMN "Count_ENTITIES_actu" numeric;
UPDATE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_evolution AS carr
SET "Count_ENTITIES_actu" = COALESCE(actu."Count_ENTITIES",0)
	FROM "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_actualisation AS actu
	WHERE carr.new_id_car = actu.new_id_car;


select * from "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_evolution order by "Count_ENTITIES" desc;



-- On ajoute la colonne pour la classe pour la dataviz
-- À cette étape il faut s'arrêter et aller regarder la valeur maximale (la requete ci-dessus affiche la table pour ce faire)
-- de densité dans le carroyage (dans celui d'actualisation comme celui de référence). On utilise cette valeur maximale pour la borne max, toutes les autres bornes ont été fixées arbitrairement et validées par Nancy : on n'y touche plus peu importe le territoire.
ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_evolution
DROP COLUMN IF EXISTS "densite_cl";
ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_evolution
ADD COLUMN "densite_cl" varchar;
UPDATE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_evolution
SET "densite_cl" = (
	CASE
	WHEN  "Count_ENTITIES" >= 1 AND "Count_ENTITIES" <= 2 THEN '[1 - 2]'
	WHEN  "Count_ENTITIES" > 2 AND "Count_ENTITIES" <= 10 THEN ']2 - 10]'
	WHEN  "Count_ENTITIES" > 10 AND "Count_ENTITIES" <= 16 THEN ']10 - 16]'
	WHEN  "Count_ENTITIES" > 16 AND "Count_ENTITIES" <= 25 THEN ']16 - 25]'
	
	--WHEN  "Count_ENTITIES" > 30 AND "Count_ENTITIES" <= 50 THEN ']30 - 50]'
	-- Pour PSB on n'a pas besoin de la dernière classe à + de 50, mais il faut pas l'oublier si on a un autre territoire
    --WHEN  "Count_ENTITIES" > 50 AND "Count_ENTITIES" <= 47 THEN ']50 - 79]'
	ELSE '999'
	END
);



--/--/--/--/--/--/--/--/--/--/--/--/--/--/
--/--/--/--/-- DENSITE ZONES AU --/--/--/-
--/--/--/--/--/--/--/--/--/--/--/--/--/--/

-- la table zonesau est dans le schema public

-- special SUPVitré : ils voulaient uniquement les Zones AU à vocation d'habitat. Ca a donné lieu à des échanges et pas mal de travail manuel afin de remplir le champ "vocation"
-- créés avec le script caracterisation_ZAU_PLU
drop table if exists public."PV_ZAU_20220204_spe_DEN";
Create table public."PV_ZAU_20220204_spe_DEN" as(
    Select * from public."PV_ZAU_20220204"
    where vocation='habitat'
)


--TO DO !! 
ALTER TABLE public."PV_ZAU_20220204_spe_DEN" DROP COLUMN IF EXISTS ID;
ALTER TABLE public."PV_ZAU_20220204_spe_DEN" ADD COLUMN ID SERIAL; --PRIMARY KEY;

-- Compte des logements de référence
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"._temp_densite_zonesau;
CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT"._temp_densite_zonesau AS (
	SELECT zau.id, zau.libelle, zau.typezone, ST_Area(zau.geom) area_zau, COALESCE(Count(ref.*), 0) "Count_ref", zau.geom --, zau.destdomi
	FROM public."PV_ZAU_20220204_spe_DEN" AS zau
	LEFT JOIN "F1_DEN_Densite_Logements_IN_OUT"."01_logt_reference" AS ref
	ON ST_Intersects(zau.geom, ref.geom)
	GROUP BY zau.id, zau.libelle, zau.typezone, zau.geom  --, zau.destdomi
);
DROP INDEX IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"._temp_densite_zonesau_geom_idx;
CREATE INDEX _temp_densite_zonesau_geom_idx ON "F1_DEN_Densite_Logements_IN_OUT"."_temp_densite_zonesau" USING GIST (geom);


-- Compte des logements à l'actualisation
DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"._dataviz_densite_zonesau;
CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_densite_zonesau AS (
	SELECT zau.id, zau.libelle, zau.typezone, ST_Area(zau.geom) AS area_zau,  zau."Count_ref", COALESCE(Count(actu.*), 0) "Count_actu", zau.geom --, zau.destdomi
	FROM "F1_DEN_Densite_Logements_IN_OUT"._temp_densite_zonesau AS zau
	LEFT JOIN "F1_DEN_Densite_Logements_IN_OUT"."02_logt_actualisation" AS actu
	ON ST_Intersects(zau.geom, actu.geom)
	GROUP BY zau.id, zau.libelle, zau.typezone, zau."Count_ref", zau.geom --, zau.destdomi
);


-- On ajoute la colonne de densité pour chacune des années
	-- réfrérence
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_densite_zonesau DROP COLUMN IF EXISTS "densite_ref";
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_densite_zonesau ADD COLUMN "densite_ref" float;
	UPDATE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_densite_zonesau
	SET "densite_ref" = ROUND((CAST("Count_ref" as float)/(CAST(area_zau as float)/10000))::numeric, 1);

	-- actualisation
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_densite_zonesau DROP COLUMN IF EXISTS "densite_actu";
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_densite_zonesau ADD COLUMN "densite_actu" float;
	UPDATE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_densite_zonesau
	SET "densite_actu" = ROUND((CAST("Count_actu" as float)/(CAST(area_zau as float)/10000))::numeric, 1);




--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/-
--/--/--/--/-- POUR EXPORTS CARREAUX EPCI --/--/--/-
--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/-

-- Création de tables de carroyage avec un label EPCI pour séparer les couches et créer des MBTiles
	-- Densité de référence
/*	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_reference_EPCI;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_reference_EPCI AS (
		SELECT carr.*, terr.label typo
		FROM "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_reference AS carr
		LEFT JOIN public."TerritoryTable_PV_BDTopo_2020.08_full_2154" AS terr
		ON ST_Intersects(terr.geom, ST_PointOnSurface(carr.geom))
		WHERE terr.rank = 2
	);

	-- Densité d'actualisation
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_actualisation_EPCI;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_actualisation_EPCI AS (
		SELECT carr.*, terr.label typo
		FROM "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_actualisation AS carr
		LEFT JOIN public."TerritoryTable_PV_BDTopo_2020.08_full_2154" AS terr
		ON ST_Intersects(terr.geom, ST_PointOnSurface(carr.geom))
		WHERE terr.rank = 2
	);

	-- Evolution
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_evolution_EPCI;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_evolution_EPCI AS (
		SELECT carr.*, terr.label typo
		FROM "F1_DEN_Densite_Logements_IN_OUT"._dataviz_carreaux_evolution AS carr
		LEFT JOIN public."TerritoryTable_PV_BDTopo_2020.08_full_2154" AS terr
		ON ST_Intersects(terr.geom, ST_PointOnSurface(carr.geom))
		WHERE terr.rank = 2
	);

	-- Zones AU
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"._dataviz_densite_zonesau_EPCI;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT"._dataviz_densite_zonesau_EPCI AS (
		SELECT zau.*, terr.label typo
		FROM "F1_DEN_Densite_Logements_IN_OUT"._dataviz_densite_zonesau AS zau
		LEFT JOIN public."TerritoryTable_PV_BDTopo_2020.08_full_2154" AS terr
		ON ST_Intersects(terr.geom, ST_PointOnSurface(zau.geom))
		WHERE terr.rank = 2
	);
*/

--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/-
--/--/--/--/-- RECOMMENCE CARROYAGE --/--/--/-
--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/-

-- On recommmence le carroyage pour finalement n'afficher que des carreaux entier.
-- Les chiffres clés sont basés sur le carroyage, mais on fait le choix de ne pas les changer. Ils restent les mêmes c'est à dire qu'on continue de compter les surfaces de référence des carreau avec ST_Area (et non en partant du principe qu'un carreau = 1ha comme avant)
-- J'utilise la table _CarroyageMicro_PV_EPSG2154 qui est dans le public

-- Couche actualisation

	-- Couche pour MBTile
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_actualisation;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_actualisation AS (
		SELECT carr.id_car, Count(logt.*) "Count_ENTITIES", ST_Area(carr.geom) "Count_ENTITIES_ref", carr.geom
		FROM public."_CarroyageMicro_PV_EPSG2154" AS carr
		LEFT JOIN "F1_DEN_Densite_Logements_IN_OUT"."02_logt_actualisation" AS logt
		ON ST_Intersects(carr.geom, logt.geom)
		WHERE logt.idlocal IS NOT NULL
		GROUP BY carr.id_car, carr.geom
	);
	DROP INDEX IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_actualisation_geom_idx;
	CREATE INDEX _new_dataviz_carreaux_actualisation_geom_idx ON "F1_DEN_Densite_Logements_IN_OUT"."_new_dataviz_carreaux_actualisation" USING GIST (geom);

	-- On ajoute la colonne de moyenne _avg
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_actualisation
	DROP COLUMN IF EXISTS "Count_ENTITIES_avg";
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_actualisation
	ADD COLUMN "Count_ENTITIES_avg" float;
	UPDATE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_actualisation
	SET "Count_ENTITIES_avg" = ROUND((CAST("Count_ENTITIES" as float)/(ST_Area(geom)/10000))::numeric, 1);

	-- On ajoute la colonne pour la classe pour la dataviz

	-- ! -- ! -- ! -- ! -- ! -- ! -- ! --
-- Il faut s'arrêter à cette étape là, et regarder la valeur max de la couche _dataviz_carreaux_reference pour mettre à jour la borne max à l'étape suivante (']86 - 160]'). Et pareil pour toutes les autres bornes ensuite. Les deux bornes max de '_dataviz_carreaux_reference' et '_dataviz_carreaux_actualisation' doivent être les mêmes (parce que dans la dataviz on n'a prévu de renseigner qu'un seul ensemble de bornes)
-- ! -- ! -- ! -- ! -- ! -- ! -- ! --


	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_actualisation
	DROP COLUMN IF EXISTS "densite_cl";
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_actualisation
	ADD COLUMN "densite_cl" varchar;
	UPDATE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_actualisation
	SET "densite_cl" = (
		CASE
		WHEN  "Count_ENTITIES_avg" >= 1 AND "Count_ENTITIES_avg" <= 2 THEN '[1 - 2]'
		WHEN  "Count_ENTITIES_avg" > 2 AND "Count_ENTITIES_avg" <= 6 THEN ']2 - 6]'
		WHEN  "Count_ENTITIES_avg" > 6 AND "Count_ENTITIES_avg" <= 12 THEN ']6 - 12]'
		WHEN  "Count_ENTITIES_avg" > 12 AND "Count_ENTITIES_avg" <= 21 THEN ']12 - 21]'
		WHEN  "Count_ENTITIES_avg" > 21 AND "Count_ENTITIES_avg" <= 31 THEN ']21 - 31]'
		WHEN  "Count_ENTITIES_avg" > 31 AND "Count_ENTITIES_avg" <= 47 THEN ']31 - 47]'
		WHEN  "Count_ENTITIES_avg" > 47 AND "Count_ENTITIES_avg" <= 86 THEN ']47 - 86]'
		WHEN  "Count_ENTITIES_avg" > 86 AND "Count_ENTITIES_avg" <= 248 THEN ']86 - 247]'
		ELSE '999'
		END
	);

-- Couche référence

	-- Couche pour MBTile
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_reference;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_reference AS (
		SELECT carr.id_car, Count(logt.*) "Count_ENTITIES", ST_Area(carr.geom) "Count_ENTITIES_ref", carr.geom
		FROM public."_CarroyageMicro_PV_EPSG2154" AS carr
		LEFT JOIN "F1_DEN_Densite_Logements_IN_OUT"."01_logt_reference" AS logt
		ON ST_Intersects(carr.geom, logt.geom)
		WHERE logt.idlocal IS NOT NULL
		GROUP BY carr.id_car, carr.geom
	);
	DROP INDEX IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_reference_geom_idx;
	CREATE INDEX _new_dataviz_carreaux_reference_geom_idx ON "F1_DEN_Densite_Logements_IN_OUT"."_new_dataviz_carreaux_reference" USING GIST (geom);

	-- On ajoute la colonne de moyenne _avg
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_reference
	DROP COLUMN IF EXISTS "Count_ENTITIES_avg";
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_reference
	ADD COLUMN "Count_ENTITIES_avg" float;
	UPDATE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_reference
	SET "Count_ENTITIES_avg" = ROUND((CAST("Count_ENTITIES" as float)/(ST_Area(geom)/10000))::numeric, 1);

	-- On ajoute la colonne pour la classe pour la dataviz

	-- ! -- ! -- ! -- ! -- ! -- ! -- ! --
-- Il faut s'arrêter à cette étape là, et regarder la valeur max de la couche _dataviz_carreaux_reference pour mettre à jour la borne max à l'étape suivante (']86 - 160]'). Et pareil pour toutes les autres bornes ensuite. Les deux bornes max de '_dataviz_carreaux_reference' et '_dataviz_carreaux_actualisation' doivent être les mêmes (parce que dans la dataviz on n'a prévu de renseigner qu'un seul ensemble de bornes)
-- ! -- ! -- ! -- ! -- ! -- ! -- ! --


	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_reference
	DROP COLUMN IF EXISTS "densite_cl";
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_reference
	ADD COLUMN "densite_cl" varchar;
	UPDATE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_reference
	SET "densite_cl" = (
		CASE
		WHEN  "Count_ENTITIES_avg" >= 1 AND "Count_ENTITIES_avg" <= 2 THEN '[1 - 2]'
		WHEN  "Count_ENTITIES_avg" > 2 AND "Count_ENTITIES_avg" <= 6 THEN ']2 - 6]'
		WHEN  "Count_ENTITIES_avg" > 6 AND "Count_ENTITIES_avg" <= 12 THEN ']6 - 12]'
		WHEN  "Count_ENTITIES_avg" > 12 AND "Count_ENTITIES_avg" <= 21 THEN ']12 - 21]'
		WHEN  "Count_ENTITIES_avg" > 21 AND "Count_ENTITIES_avg" <= 31 THEN ']21 - 31]'
		WHEN  "Count_ENTITIES_avg" > 31 AND "Count_ENTITIES_avg" <= 47 THEN ']31 - 47]'
		WHEN  "Count_ENTITIES_avg" > 47 AND "Count_ENTITIES_avg" <= 86 THEN ']47 - 86]'
		WHEN  "Count_ENTITIES_avg" > 86 AND "Count_ENTITIES_avg" <= 248 THEN ']86 - 247]'
		ELSE '999'
		END
	);


-- Couche d'évolution
	-- Couche pour geojson
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_evolution;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_evolution AS (
		SELECT carr.id_car, Count(logt.*) "Count_ENTI", carr.geom
		FROM public."_CarroyageMicro_PV_EPSG2154" AS carr
		LEFT JOIN "F1_DEN_Densite_Logements_IN_OUT"."03_logt_evolution" AS logt
		ON ST_Intersects(logt.geom, carr.geom)
		WHERE logt.idlocal IS NOT NULL
		GROUP BY id_car, carr.geom
	);

	-- Ajout du nombe de logement de l'année de référence
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_evolution DROP COLUMN IF EXISTS "Count_EN_1";
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_evolution ADD COLUMN "Count_EN_1" numeric;
	UPDATE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_evolution AS carr
	SET "Count_EN_1" = COALESCE(ref."Count_ENTITIES",0)
		FROM "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_reference AS ref
		WHERE carr.id_car = ref.id_car;
	-- Il y a des valeurs nulles
	UPDATE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_evolution AS carr
	SET "Count_EN_1" = (
		CASE
		WHEN "Count_EN_1" IS NULL THEN 0
		ELSE "Count_EN_1"
		END
	);

	-- Ajout du nombe de logement de l'année d'actualisation (normalement pas de valeurs à zéro ici)
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_evolution DROP COLUMN IF EXISTS "Count_EN_2";
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_evolution ADD COLUMN "Count_EN_2" numeric;
	UPDATE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_evolution carr
	SET "Count_EN_2" = COALESCE(actu."Count_ENTITIES",0)
		FROM "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_actualisation actu
		WHERE carr.id_car = actu.id_car;


	-- On ajoute la colonne pour la classe pour la dataviz
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_evolution
	DROP COLUMN IF EXISTS "densite_cl";
	ALTER TABLE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_evolution
	ADD COLUMN "densite_cl" varchar;
	UPDATE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_evolution
	SET "densite_cl" = (
	CASE
	WHEN  "Count_ENTI" >= 1 AND "Count_ENTI" <= 2 THEN '[1 - 2]'
	WHEN  "Count_ENTI" > 2 AND "Count_ENTI" <= 10 THEN ']2 - 10]'
	WHEN  "Count_ENTI" > 10 AND "Count_ENTI" <= 16 THEN ']10 - 16]'
	WHEN  "Count_ENTI" > 16 AND "Count_ENTI" <= 25 THEN ']16 - 25]'
	
	
	--WHEN  "Count_ENTI" > 27 AND "Count_ENTI" <= 50 THEN ']27 - 50]'
	-- Pour PSB on n'a pas besoin de la dernière classe à + de 50, mais il faut pas l'oublier si on a un autre territoire
    --WHEN  "Count_ENTI" > 50 AND "Count_ENTI" <= 79 THEN ']50 - 79]'
	ELSE '999'
	END
	);



-- ! Chiffres clés pour carte thématique/choroplèthe
-- 37min48
drop index if exists "F1_DEN_Densite_Logements_IN_OUT"."02_logt_actualisation_idx" ;
create index "02_logt_actualisation_idx" on "F1_DEN_Densite_Logements_IN_OUT"."02_logt_actualisation" using gist(geom);

drop table if exists "F1_DEN_Densite_Logements_IN_OUT"."den_log_actualisation_choroplethe" ;
create table "F1_DEN_Densite_Logements_IN_OUT"."den_log_actualisation_choroplethe" as (
with 
zau0 as (
select tt.id_geom, st_transform(zau.geom,2154) geom from public."TerritoryTable_PV_BDTopo_2020.08_full_2154" tt 
left join public."PV_ZAU_20220204_spe_DEN" zau
on st_intersects(tt.geom,zau.geom)
),
zau as (
select id_geom, st_area(st_union(geom))/10000 zau_area_ha, st_union(geom) geom  from zau0
group by id_geom
),
t0 as (
select   zau.geom , zau.id_geom,  coalesce(count(st_intersects(t1.geom, zau.geom)), 0) nb_log_zau, zau_area_ha,   zau_area_ha*10000 zau_area
from zau 
left join "F1_DEN_Densite_Logements_IN_OUT"."02_logt_actualisation" t1
on st_intersects(zau.geom, t1.geom)
group by id_geom, zau.geom, zau_area_ha
) 
select  id_geom, nb_log_zau, zau_area_ha, nullif(coalesce(nb_log_zau / nullif(zau_area_ha,0), 0),0) dens_log  from t0
)



create table "F1_DEN_Densite_Logements".zau_test as (
select row_number() OVER () AS tid,id_geom, st_union(st_intersection(tt.geom,au.geom)) geom
from public."TerritoryTable_PV_BDTopo_2020.08_full_2154" tt 
left join public.PV_ZAU_20220204_spe_DEN_pv_022021 au 
on st_intersects(tt.geom,au.geom)
--where tt.geom is not null
group by id_geom
)



--count(st_intersects(st_centroid(t3.geom),t2.geom)) nb_carr ,

-- Pour les EPCI
-- ! Attention, ici on est obligés d'utiliser le centroide des carreaux pour associer le carreau à un EPCI.
-- L'idéal ce serait de l'associer si : le carreau intersecte l'ecpi ET contient un logement dans l'epci, mais ça voudrait dire qu'un carreau peut apparaitre dans les deux EPCI à la fois
-- Et surout avec cette méthode on perd tous les carreaux entiers dont le centroïde n'intersecte pas le territoire
-- Ça veut dire qu'il manque des carreaux dans les dataviz aux EPCI

/*	-- Densité de référence
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_reference_EPCI;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_reference_EPCI AS (
		SELECT carr.*, terr.label typo
		FROM "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_reference carr
		LEFT JOIN public."TerritoryTable_PV_BDTopo_2020.08_full_2154" AS terr
		ON ST_Intersects(terr.geom, ST_Centroid(carr.geom))
		WHERE terr.rank = 2
	);

	-- Densité d'actualisation
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_actualisation_EPCI;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_actualisation_EPCI AS (
		SELECT carr.*, terr.label typo
		FROM "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_actualisation carr
		LEFT JOIN public."TerritoryTable_PV_BDTopo_2020.08_full_2154" AS terr
		ON ST_Intersects(terr.geom, ST_Centroid(carr.geom))
		WHERE terr.rank = 2
	);

	-- Evolution
	DROP TABLE IF EXISTS "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_evolution_EPCI;
	CREATE TABLE "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_evolution_EPCI AS (
		SELECT carr.*, terr.label typo
		FROM "F1_DEN_Densite_Logements_IN_OUT"._new_dataviz_carreaux_evolution carr
		LEFT JOIN public."TerritoryTable_PV_BDTopo_2020.08_full_2154" AS terr
		ON ST_Intersects(terr.geom, ST_Centroid(carr.geom))
		WHERE terr.rank = 2
	);
*/
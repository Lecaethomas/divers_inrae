-- L'indicateur s'appelait "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP" mais probablement qu'on en aura besoin 


DROP INDEX IF EXISTS "F1_REN_DensiteBatie".Carroyage_CAP_2154_clip_terr_geom_idx;
CREATE INDEX Carroyage_CAP_2154_clip_terr_geom_idx ON "F1_REN_DensiteBatie"."Carroyage_CAP_2154_clip_terr" USING GIST (geom);
-- Index table bati 2018
DROP INDEX IF EXISTS "F1_REN_DensiteBatie".batiments_pci_122018_cap_clean_noduplicates_idx;
CREATE INDEX batiments_pci_122018_cap_clean_noduplicates_idx ON "F1_REN_DensiteBatie"."batiments_pci_122018_cap_clean" USING GIST (geom);
-- Index table bati 2019
DROP INDEX IF EXISTS "F1_REN_DensiteBatie".batiments_pci_01012019_cap_clean_geom_idx;
CREATE INDEX batiments_pci_01012019_cap_clean_geom_idx ON "F1_REN_DensiteBatie"."batiments_pci_01012019_cap_clean" USING GIST (geom);
-- Index table bati 2020
DROP INDEX IF EXISTS "F1_REN_DensiteBatie".batiments_pci_01012020_cap_clean_geom_idx;
CREATE INDEX batiments_pci_01012020_cap_clean_geom_idx ON "F1_REN_DensiteBatie"."batiments_pci_01012020_cap_clean" USING GIST (geom);

-- Index table bati #2021
DROP INDEX IF EXISTS "F1_REN_DensiteBatie".cap_batiments_merged_clean_202102_idx;
CREATE INDEX cap_batiments_merged_clean_202102_idx ON "F1_REN_DensiteBatie".cap_batiments_merged_clean_202102 USING GIST (geom);

--- Chasse aux duplicats #2021
	DROP TABLE IF EXISTS "F1_REN_DensiteBatie".cap_batiments_merged_clean_202102_noduplicates;
	CREATE TABLE "F1_REN_DensiteBatie".cap_batiments_merged_clean_202102_noduplicates AS (
		WITH unique_geoms (id, geom) AS (
			SELECT row_number() OVER (PARTITION BY geom) as id, geom 
			FROM "F1_REN_DensiteBatie".cap_batiments_merged_clean_202102
		)
		SELECT id, geom 
		FROM unique_geoms 
		WHERE id=1
	);
	DROP INDEX IF EXISTS "F1_REN_DensiteBatie".cap_batiments_merged_clean_202102_noduplicates_geom_idx;
	CREATE INDEX cap_batiments_merged_clean_202102_noduplicates_geom_idx on "F1_REN_DensiteBatie"."cap_batiments_merged_clean_202102_noduplicates" USING GIST (geom);


--- Chasse aux duplicats 2020
	DROP TABLE IF EXISTS "F1_REN_DensiteBatie".batiments_pci_01012020_cap_clean_noduplicates;
	CREATE TABLE "F1_REN_DensiteBatie".batiments_pci_01012020_cap_clean_noduplicates AS (
		WITH unique_geoms (id, geom) AS (
			SELECT row_number() OVER (PARTITION BY geom) as id, geom 
			FROM "F1_REN_DensiteBatie".batiments_pci_01012020_cap_clean
		)
		SELECT id, geom 
		FROM unique_geoms 
		WHERE id=1
	);
	DROP INDEX IF EXISTS "F1_REN_DensiteBatie".batiments_pci_01012020_cap_clean_noduplicates_geom_idx;
	CREATE INDEX batiments_pci_01012020_cap_clean_noduplicates_geom_idx ON "F1_REN_DensiteBatie"."batiments_pci_01012020_cap_clean_noduplicates" USING GIST (geom);

--- Chasse aux duplicats 2019
	DROP TABLE IF EXISTS "F1_REN_DensiteBatie".batiments_pci_01012019_cap_clean_noduplicates;
	CREATE TABLE "F1_REN_DensiteBatie".batiments_pci_01012019_cap_clean_noduplicates AS (
		WITH unique_geoms (id, geom) AS (
			SELECT row_number() OVER (PARTITION BY geom) as id, geom
			FROM "F1_REN_DensiteBatie".batiments_pci_01012019_cap_clean
		)
		SELECT id, geom 
		FROM unique_geoms 
		WHERE id=1
	);
	DROP INDEX IF EXISTS "F1_REN_DensiteBatie".batiments_pci_01012020_cap_clean_noduplicates_geom_idx;
	CREATE INDEX batiments_pci_01012019_cap_clean_noduplicates_geom_idx ON "F1_REN_DensiteBatie"."batiments_pci_01012019_cap_clean_noduplicates" USING GIST (geom);

--- Chasse aux duplicats 2018
	DROP TABLE IF EXISTS "F1_REN_DensiteBatie"."batiments_pci_122018_cap_clean_no_duplicates";
	CREATE TABLE "F1_REN_DensiteBatie"."batiments_pci_122018_cap_clean_no_duplicates" AS (
		WITH unique_geoms (id, geom) AS (
			SELECT row_number() OVER (PARTITION BY geom) as id, geom
			FROM "F1_REN_DensiteBatie"."batiments_pci_122018_cap_clean"
		)
		SELECT id, geom 
		FROM unique_geoms 
		WHERE id=1
	);
	DROP INDEX IF EXISTS "F1_REN_DensiteBatie".batiments_pci_122018_cap_clean_no_duplicates_geom_idx;
	CREATE INDEX batiments_pci_122018_cap_clean_no_duplicates_geom_idx ON "F1_REN_DensiteBatie"."batiments_pci_122018_cap_clean_no_duplicates" USING GIST (geom);


	ALTER TABLE "F1_REN_DensiteBatie"."batiments_pci_01012019_cap_clean_noduplicates" DROP COLUMN IF EXISTS id;
	ALTER TABLE "F1_REN_DensiteBatie"."batiments_pci_01012019_cap_clean_noduplicates" ADD COLUMN id SERIAL PRIMARY KEY;
	ALTER TABLE "F1_REN_DensiteBatie"."batiments_pci_122018_cap_clean_no_duplicates" DROP COLUMN IF EXISTS id;
	ALTER TABLE "F1_REN_DensiteBatie"."batiments_pci_122018_cap_clean_no_duplicates" ADD COLUMN id SERIAL PRIMARY KEY;
	ALTER TABLE "F1_REN_DensiteBatie"."batiments_pci_01012020_cap_clean_noduplicates" DROP COLUMN IF EXISTS id;
	ALTER TABLE "F1_REN_DensiteBatie"."batiments_pci_01012020_cap_clean_noduplicates" ADD COLUMN id SERIAL PRIMARY KEY;
	ALTER TABLE "F1_REN_DensiteBatie"."cap_batiments_merged_clean_202102_noduplicates" DROP COLUMN IF EXISTS id;
	ALTER TABLE "F1_REN_DensiteBatie"."cap_batiments_merged_clean_202102_noduplicates" ADD COLUMN id SERIAL PRIMARY KEY;
		--Creation extension

		--#2021
--2min46
	DROP TABLE IF EXISTS "F1_REN_DensiteBatie"."creations_extensions_2021";
	CREATE TABLE "F1_REN_DensiteBatie"."creations_extensions_2021" AS (
		WITH t1 AS (
			SELECT a.id, 'creation'::varchar typo, a.geom geom 
			FROM "F1_REN_DensiteBatie"."cap_batiments_merged_clean_202102_noduplicates" a
			LEFT JOIN "F1_REN_DensiteBatie"."batiments_pci_01012020_cap_clean_noduplicates" b
			ON ST_Intersects(a.geom,b.geom) AND ST_Area(ST_Intersection(a.geom,b.geom)) > ST_Area(a.geom)*0.05 --Si l'intersection n'existe pas, postgis renvoie une GEOMETRYCOLLECTION EMPTY qui donne zéro au ST_Area(), donc ça passe
			WHERE b.id IS NULL
		)
		SELECT a.id, 'extension'::varchar typo, a.geom geom
		FROM "F1_REN_DensiteBatie"."cap_batiments_merged_clean_202102_noduplicates" a
		LEFT JOIN "F1_REN_DensiteBatie"."batiments_pci_01012020_cap_clean_noduplicates" b
		-- À 95% de surface déjà existante au millésime n-1 on ne considère pas le bâtiment comme une nouvelle construction, mais comme une simple extension (ça change rien dans l'indicateur au final)
		ON ST_Intersects(a.geom,b.geom) AND ST_Area(ST_Intersection(a.geom,b.geom)) > ST_Area(a.geom)*0.95
		WHERE b.id IS NULL 
		AND a.id NOT IN (SELECT id FROM t1)
		UNION ALL
		SELECT * FROM t1
	);
	DROP INDEX IF EXISTS "F1_REN_DensiteBatie".creations_extensions_2021_geom_idx;
	CREATE INDEX creations_extensions_2021_geom_idx ON "F1_REN_DensiteBatie"."creations_extensions_2021" USING GIST (geom);
		
		--2020
--2min46
	DROP TABLE IF EXISTS "F1_REN_DensiteBatie"."creations_extensions_2020";
	CREATE TABLE "F1_REN_DensiteBatie"."creations_extensions_2020" AS (
		WITH t1 AS (
			SELECT a.id, 'creation'::varchar typo, a.geom geom 
			FROM "F1_REN_DensiteBatie"."batiments_pci_01012020_cap_clean_noduplicates" a
			LEFT JOIN "F1_REN_DensiteBatie"."batiments_pci_01012019_cap_clean_noduplicates" b
			ON ST_Intersects(a.geom,b.geom) AND ST_Area(ST_Intersection(a.geom,b.geom)) > ST_Area(a.geom)*0.05 --Si l'intersection n'existe pas, postgis renvoie une GEOMETRYCOLLECTION EMPTY qui donne zéro au ST_Area(), donc ça passe
			WHERE b.id IS NULL
		)
		SELECT a.id, 'extension'::varchar typo, a.geom geom
		FROM "F1_REN_DensiteBatie"."batiments_pci_01012020_cap_clean_noduplicates" a
		LEFT JOIN "F1_REN_DensiteBatie"."batiments_pci_01012019_cap_clean_noduplicates" b
		-- À 95% de surface déjà existante au millésime n-1 on ne considère pas le bâtiment comme une nouvelle construction, mais comme une simple extension (ça change rien dans l'indicateur au final)
		ON ST_Intersects(a.geom,b.geom) AND ST_Area(ST_Intersection(a.geom,b.geom)) > ST_Area(a.geom)*0.95
		WHERE b.id IS NULL 
		AND a.id NOT IN (SELECT id FROM t1)
		UNION ALL
		SELECT * FROM t1
	);
	DROP INDEX IF EXISTS "F1_REN_DensiteBatie".creations_extensions_2020_geom_idx;
	CREATE INDEX creations_extensions_2020_geom_idx ON "F1_REN_DensiteBatie"."creations_extensions_2020" USING GIST (geom);

		--2019
		
		DROP TABLE IF EXISTS "F1_REN_DensiteBatie"."creations_extensions_2019";
	CREATE TABLE "F1_REN_DensiteBatie"."creations_extensions_2019" AS (
		WITH t1 AS (
			SELECT a.id, 'creation'::varchar typo, a.geom geom 
			FROM "F1_REN_DensiteBatie"."batiments_pci_01012019_cap_clean_noduplicates" a
			LEFT JOIN "F1_REN_DensiteBatie"."batiments_pci_122018_cap_clean_no_duplicates" b
			ON ST_Intersects(a.geom,b.geom) AND ST_Area(ST_Intersection(a.geom,b.geom)) > ST_Area(a.geom)*0.05 --Si l'intersection n'existe pas, postgis renvoie une GEOMETRYCOLLECTION EMPTY qui donne zéro au ST_Area(), donc ça passe
			WHERE b.id IS NULL
		)
		SELECT a.id, 'extension'::varchar typo, a.geom geom
		FROM "F1_REN_DensiteBatie"."batiments_pci_01012019_cap_clean_noduplicates" a
		LEFT JOIN "F1_REN_DensiteBatie"."batiments_pci_122018_cap_clean_no_duplicates" b
		-- À 95% de surface déjà existante au millésime n-1 on ne considère pas le bâtiment comme une nouvelle construction, mais comme une simple extension (ça change rien dans l'indicateur au final)
		ON ST_Intersects(a.geom,b.geom) AND ST_Area(ST_Intersection(a.geom,b.geom)) > ST_Area(a.geom)*0.95
		WHERE b.id IS NULL 
		AND a.id NOT IN (SELECT id FROM t1)
		UNION ALL
		SELECT * FROM t1
	);
	DROP INDEX IF EXISTS "F1_REN_DensiteBatie".creations_extensions_2019_geom_idx;
	CREATE INDEX creations_extensions_2019_geom_idx ON "F1_REN_DensiteBatie"."creations_extensions_2019" USING GIST (geom);



					-----------------------
					---- FAUX BATIMENTS ---
					-----------------------
--1.148sec	
-- On crée la fausse couche en ajoutant ces nouveaux bâtiments à la table du millésime précédent 

					--2019 

	DROP TABLE IF EXISTS "F1_REN_DensiteBatie"."faux_batiments_2019";
	CREATE TABLE "F1_REN_DensiteBatie"."faux_batiments_2019" AS (
		SELECT id, geom
		FROM "F1_REN_DensiteBatie"."creations_extensions_2019"
		UNION ALL
		SELECT id, geom
		FROM "F1_REN_DensiteBatie"."batiments_pci_122018_cap_clean_no_duplicates"
	);
	DROP INDEX IF EXISTS "F1_REN_DensiteBatie".faux_batiments_2019_geom_idx;
	CREATE INDEX faux_batiments_2019_geom_idx ON "F1_REN_DensiteBatie"."faux_batiments_2019" USING GIST (geom);

					--2020
					
	DROP TABLE IF EXISTS "F1_REN_DensiteBatie"."faux_batiments_2020";
	CREATE TABLE "F1_REN_DensiteBatie"."faux_batiments_2020" AS (
		SELECT id, geom
		FROM "F1_REN_DensiteBatie"."creations_extensions_2020"
		UNION ALL
		SELECT id, geom
		FROM "F1_REN_DensiteBatie"."faux_batiments_2019"
	);
	DROP INDEX IF EXISTS "F1_REN_DensiteBatie".faux_batiments_2020_geom_idx;
	CREATE INDEX faux_batiments_2020_geom_idx ON "F1_REN_DensiteBatie"."faux_batiments_2020" USING GIST (geom);

					--2021
					
	DROP TABLE IF EXISTS "F1_REN_DensiteBatie"."faux_batiments_2021";
	CREATE TABLE "F1_REN_DensiteBatie"."faux_batiments_2021" AS (
		SELECT id, geom
		FROM "F1_REN_DensiteBatie"."creations_extensions_2021"
		UNION ALL
		SELECT id, geom
		FROM "F1_REN_DensiteBatie"."faux_batiments_2020"
	);
	DROP INDEX IF EXISTS "F1_REN_DensiteBatie".faux_batiments_2021_geom_idx;
	CREATE INDEX faux_batiments_2021_geom_idx ON "F1_REN_DensiteBatie"."faux_batiments_2021" USING GIST (geom);
				

	





					--couche de densite carroyée

					--couche de densite 2021
	
	DROP TABLE IF EXISTS "F1_REN_DensiteBatie".carreaux_densite_2021;
	CREATE TABLE "F1_REN_DensiteBatie".carreaux_densite_2021 AS (
		SELECT a.id_car, b."Count_ENTITIES", a.geom
		FROM "F1_REN_DensiteBatie"."Carroyage_CAP_2154_clip_terr" a
		FULL JOIN (
			SELECT c.id_car, Count(bati.geom) "Count_ENTITIES", c.geom
			FROM "F1_REN_DensiteBatie"."Carroyage_CAP_2154_clip_terr" c,
				"F1_REN_DensiteBatie"."faux_batiments_2021" bati
			WHERE ST_Intersects(ST_Centroid(bati.geom),c.geom)
			GROUP BY c.id_car, c.geom
		) b
		ON a.id_car = b.id_car
	);
	DROP INDEX IF EXISTS "F1_REN_DensiteBatie".carreaux_densite_2021_geom_idx;
	CREATE INDEX carreaux_densite_2021_geom_idx ON "F1_REN_DensiteBatie".carreaux_densite_2021 USING GIST (geom);



					--couche de densite 2020
	
	DROP TABLE IF EXISTS "F1_REN_DensiteBatie".carreaux_densite_2020;
	CREATE TABLE "F1_REN_DensiteBatie".carreaux_densite_2020 AS (
		SELECT a.id_car, b."Count_ENTITIES", a.geom
		FROM "F1_REN_DensiteBatie"."Carroyage_CAP_2154_clip_terr" a
		FULL JOIN (
			SELECT c.id_car, Count(bati.geom) "Count_ENTITIES", c.geom
			FROM "F1_REN_DensiteBatie"."Carroyage_CAP_2154_clip_terr" c,
				"F1_REN_DensiteBatie"."faux_batiments_2020" bati
			WHERE ST_Intersects(ST_Centroid(bati.geom),c.geom)
			GROUP BY c.id_car, c.geom
		) b
		ON a.id_car = b.id_car
	);
	DROP INDEX IF EXISTS "F1_REN_DensiteBatie".carreaux_densite_2020_geom_idx;
	CREATE INDEX carreaux_densite_2020_geom_idx ON "F1_REN_DensiteBatie".carreaux_densite_2020 USING GIST (geom);


							--couche de densite 2019
	
	DROP TABLE IF EXISTS "F1_REN_DensiteBatie".carreaux_densite_2019;
	CREATE TABLE "F1_REN_DensiteBatie".carreaux_densite_2019 AS (
		SELECT a.id_car, b."Count_ENTITIES", a.geom
		FROM "F1_REN_DensiteBatie"."Carroyage_CAP_2154_clip_terr" a
		FULL JOIN (
			SELECT c.id_car, Count(bati.geom) "Count_ENTITIES", c.geom
			FROM "F1_REN_DensiteBatie"."Carroyage_CAP_2154_clip_terr" c,
				"F1_REN_DensiteBatie"."faux_batiments_2019" bati
			WHERE ST_Intersects(ST_Centroid(bati.geom),c.geom)
			GROUP BY c.id_car, c.geom
		) b
		ON a.id_car = b.id_car
	);
	DROP INDEX IF EXISTS "F1_REN_DensiteBatie".carreaux_densite_2019_geom_idx;
	CREATE INDEX carreaux_densite_2019_geom_idx ON "F1_REN_DensiteBatie".carreaux_densite_2019 USING GIST (geom);

SELECT count(*) FROM "F1_REN_DensiteBatie".carreaux_densite_2019
		--couche de densite 2018
	
	DROP TABLE IF EXISTS "F1_REN_DensiteBatie".carreaux_densite_2018;
	CREATE TABLE "F1_REN_DensiteBatie".carreaux_densite_2018 AS (
		SELECT a.id_car, b."Count_ENTITIES", a.geom
		FROM "F1_REN_DensiteBatie"."Carroyage_CAP_2154_clip_terr" a
		FULL JOIN (
			SELECT c.id_car, Count(bati.geom) "Count_ENTITIES", c.geom
			FROM "F1_REN_DensiteBatie"."Carroyage_CAP_2154_clip_terr" c,
				"F1_REN_DensiteBatie"."batiments_pci_122018_cap_clean_no_duplicates" bati
			WHERE ST_Intersects(ST_Centroid(bati.geom),c.geom)
			GROUP BY c.id_car, c.geom
		) b
		ON a.id_car = b.id_car
	);
	DROP INDEX IF EXISTS "F1_REN_DensiteBatie".carreaux_densite_2018_geom_idx;
	CREATE INDEX carreaux_densite_2018_geom_idx ON "F1_REN_DensiteBatie".carreaux_densite_2018 USING GIST (geom);


--/--/--/--/--/--/--/--/--/--/--/--/
--/--/--/--/-- EXPORT --/--/--/--/--
--/--/--/--/--/--/--/--/--/--/--/--/


-- Création de la couche d'évolution (3 secs 723 msec)
	-- Jointure des deux résultats précédents
	DROP TABLE IF EXISTS "F1_REN_DensiteBatie".carreaux_evolution_2018_2021;
	CREATE TABLE "F1_REN_DensiteBatie".carreaux_evolution_2018_2021 AS (
		SELECT c.id_car, den_18."Count_ENTITIES" den_18, den_19."Count_ENTITIES" den_19, den_20."Count_ENTITIES" den_20, den_21."Count_ENTITIES" den_21,c.geom geom
		FROM "F1_REN_DensiteBatie"."Carroyage_CAP_2154_clip_terr" c
		JOIN "F1_REN_DensiteBatie".carreaux_densite_2018 den_18 ON c.id_car = den_18.id_car
		JOIN "F1_REN_DensiteBatie".carreaux_densite_2019 den_19 ON c.id_car = den_19.id_car
		JOIN "F1_REN_DensiteBatie".carreaux_densite_2020 den_20 ON c.id_car = den_20.id_car
		JOIN "F1_REN_DensiteBatie".carreaux_densite_2021 den_21 ON c.id_car = den_21.id_car
	);
	-- Ajout de la colonne d'évolution
	ALTER TABLE "F1_REN_DensiteBatie".carreaux_evolution_2018_2021 DROP COLUMN IF EXISTS evolution;
	ALTER TABLE "F1_REN_DensiteBatie".carreaux_evolution_2018_2021 ADD COLUMN evolution int;
	UPDATE "F1_REN_DensiteBatie".carreaux_evolution_2018_2021 SET evolution = COALESCE(den_21,0)-COALESCE(den_18,0);
	-- Suppression des évolultions nulles
	DELETE FROM "F1_REN_DensiteBatie".carreaux_evolution_2018_2021 WHERE evolution = 0;

---- Evolution format dataviz: 
	-- Pour sortir l'évolution format dataviz:
	DROP TABLE IF EXISTS "F1_REN_DensiteBatie".evolution_2018_2021;
	CREATE TABLE "F1_REN_DensiteBatie".evolution_2018_2021 AS (
		SELECT a.den_18, a.den_21, a.evolution, (
			CASE
			WHEN  a.evolution >= 1 AND a.evolution <= 2 THEN '[1-2]'
			WHEN  a.evolution > 2 AND a.evolution <= 3 THEN ']2-3]'
			WHEN  a.evolution > 3 AND a.evolution <= 5 THEN ']3-5]'
			WHEN  a.evolution > 5 AND a.evolution <= 9 THEN ']5-9]'
			WHEN  a.evolution > 9 AND a.evolution <= 16 THEN ']9-16]'
			ELSE '999'
			END
		) cat,
		b.geom
		FROM "F1_REN_DensiteBatie"."carreaux_evolution_2018_2021" a
		LEFT JOIN "F1_REN_DensiteBatie"."Carroyage_CAP_2154_clip_terr" b
		ON a.id_car = b.id_car
		WHERE evolution > 0
	);

--//////----//////
-- Le csv pour les carreaux de densite:
--////////////////
--// STOP --/
-- ouvrir la couche de carreaux densité pour vérifier la fourchette max (attention elle peut diminuer)

-- 2021

DROP TABLE IF EXISTS "F1_REN_DensiteBatie"."spe_F1_REN_EnvUrbaine_DensiteBatie_carroyage_2021";
CREATE TABLE "F1_REN_DensiteBatie"."spe_F1_REN_EnvUrbaine_DensiteBatie_carroyage_2021" AS (
	SELECT id_car "ID_CAR", (
		CASE
		WHEN "Count_ENTITIES" >= 1 AND "Count_ENTITIES" <= 2 THEN '1 - 2'
		WHEN "Count_ENTITIES" > 2 AND "Count_ENTITIES" <= 6 THEN '2 - 6'
		WHEN "Count_ENTITIES" > 6 AND "Count_ENTITIES" <= 12 THEN '6 - 12'
		WHEN "Count_ENTITIES" > 12 AND "Count_ENTITIES" <= 21 THEN '12 - 21'
		WHEN "Count_ENTITIES" > 21 AND "Count_ENTITIES" <= 31 THEN '21 - 31'
		WHEN "Count_ENTITIES" > 31 AND "Count_ENTITIES" <= 47 THEN '31 - 47'
		WHEN "Count_ENTITIES" > 47 AND "Count_ENTITIES" <= 82 THEN '47 - 82'
		ELSE '999'
		END
	) typo
	FROM "F1_REN_DensiteBatie".carreaux_densite_2021
	WHERE "Count_ENTITIES" > 0
);

-- 2020
DROP TABLE IF EXISTS "F1_REN_DensiteBatie"."spe_F1_REN_EnvUrbaine_DensiteBatie_carroyage_2020";
CREATE TABLE "F1_REN_DensiteBatie"."spe_F1_REN_EnvUrbaine_DensiteBatie_carroyage_2020" AS (
	SELECT id_car "ID_CAR", (
		CASE
		WHEN "Count_ENTITIES" >= 1 AND "Count_ENTITIES" <= 2 THEN '1 - 2'
		WHEN "Count_ENTITIES" > 2 AND "Count_ENTITIES" <= 6 THEN '2 - 6'
		WHEN "Count_ENTITIES" > 6 AND "Count_ENTITIES" <= 12 THEN '6 - 12'
		WHEN "Count_ENTITIES" > 12 AND "Count_ENTITIES" <= 21 THEN '12 - 21'
		WHEN "Count_ENTITIES" > 21 AND "Count_ENTITIES" <= 31 THEN '21 - 31'
		WHEN "Count_ENTITIES" > 31 AND "Count_ENTITIES" <= 47 THEN '31 - 47'
		WHEN "Count_ENTITIES" > 47 AND "Count_ENTITIES" <= 82 THEN '47 - 82'
		ELSE '999'
		END
	) typo
	FROM "F1_REN_DensiteBatie".carreaux_densite_2020
	WHERE "Count_ENTITIES" > 0
);
-- On a besoin de créer une table de densité carroyée sans les carreaux qui n'ont pas de valeur
--2021


DROP TABLE IF EXISTS "F1_REN_DensiteBatie".carreaux_faussedensite_2021_nonull;
CREATE TABLE "F1_REN_DensiteBatie".carreaux_faussedensite_2021_nonull AS (
	SELECT *
	FROM "F1_REN_DensiteBatie"."carreaux_densite_2021" 
	WHERE "Count_ENTITIES" > 0
);
DROP INDEX IF EXISTS "F1_REN_DensiteBatie".carreaux_faussedensite_2021_nonull_geom_idx;
CREATE INDEX carreaux_faussedensite_2021_nonull_geom_idx ON "F1_REN_DensiteBatie".carreaux_faussedensite_2021_nonull USING GIST (geom);

--2020

DROP TABLE IF EXISTS "F1_REN_DensiteBatie".carreaux_faussedensite_2020_nonull;
CREATE TABLE "F1_REN_DensiteBatie".carreaux_faussedensite_2020_nonull AS (
	SELECT *
	FROM "F1_REN_DensiteBatie"."carreaux_densite_2020" 
	WHERE "Count_ENTITIES" > 0
);
DROP INDEX IF EXISTS "F1_REN_DensiteBatie".carreaux_faussedensite_2020_nonull_geom_idx;
CREATE INDEX carreaux_faussedensite_2020_nonull_geom_idx ON "F1_REN_DensiteBatie".carreaux_faussedensite_2020_nonull USING GIST (geom);

--2019

DROP TABLE IF EXISTS "F1_REN_DensiteBatie".carreaux_faussedensite_2019_nonull;
CREATE TABLE "F1_REN_DensiteBatie".carreaux_faussedensite_2019_nonull AS (
	SELECT *
	FROM "F1_REN_DensiteBatie"."carreaux_densite_2019" 
	WHERE "Count_ENTITIES" > 0
);
DROP INDEX IF EXISTS "F1_REN_DensiteBatie".carreaux_faussedensite_2019_nonull_geom_idx;
CREATE INDEX carreaux_faussedensite_2019_nonull_geom_idx ON "F1_REN_DensiteBatie".carreaux_faussedensite_2019_nonull USING GIST (geom);

--2018

DROP TABLE IF EXISTS "F1_REN_DensiteBatie".carreaux_faussedensite_2018_nonull;
CREATE TABLE "F1_REN_DensiteBatie".carreaux_faussedensite_2018_nonull AS (
	SELECT *
	FROM "F1_REN_DensiteBatie"."carreaux_densite_2018" 
	WHERE "Count_ENTITIES" > 0
);
DROP INDEX IF EXISTS "F1_REN_DensiteBatie".carreaux_faussedensite_2018_nonull_geom_idx;
CREATE INDEX carreaux_faussedensite_2018_nonull_geom_idx ON "F1_REN_DensiteBatie".carreaux_faussedensite_2018_nonull USING GIST (geom);
				----------//////////----------
				-----   CHIFFRES-CLES  -------
				---------///////////----------

-- Chiffres clés IN
	-- On stocke tous les bâtis à l'intérieur de l'enveloppe urbaine à l'échelle du territoire
	DROP TABLE IF EXISTS "F1_REN_DensiteBatie".chiffres_cles_part01;
	CREATE TABLE "F1_REN_DensiteBatie".chiffres_cles_part01 AS (
		SELECT bati.*
		FROM "F1_REN_DensiteBatie"."faux_batiments_2021" bati
		LEFT JOIN public."Cap_Atlantique_EnvUrbaine_PourCalculs_2018" env
		ON ST_Intersects(ST_Centroid(bati.geom), env.geom)
		WHERE env.id IS NOT NULL
	);
	DROP INDEX IF EXISTS "F1_REN_DensiteBatie".chiffres_cles_part01_geom_idx;
	CREATE INDEX chiffres_cles_part01_geom_idx ON "F1_REN_DensiteBatie".chiffres_cles_part01 USING GIST (geom);

	-- On stocke tous les carreaux à l'intérieur de l'enveloppe urbaine à l'échelle du territoire
	DROP TABLE IF EXISTS "F1_REN_DensiteBatie".chiffres_cles_part02;
	CREATE TABLE "F1_REN_DensiteBatie".chiffres_cles_part02 AS (
		SELECT carr.*
		FROM "F1_REN_DensiteBatie".carreaux_faussedensite_2021_nonull carr
		LEFT JOIN public."Cap_Atlantique_EnvUrbaine_PourCalculs_2018" env
		ON ST_Intersects(carr.geom, env.geom) AND ST_Area(ST_Intersection(carr.geom, env.geom))>ST_Area(carr.geom)*0.5
		WHERE env.id IS NOT NULL
	);
	DROP INDEX IF EXISTS "F1_REN_DensiteBatie".chiffres_cles_part02_geom_idx;
	CREATE INDEX chiffres_cles_part02_geom_idx ON "F1_REN_DensiteBatie".chiffres_cles_part02 USING GIST (geom);
	

	-- On groupe le nombre de bâtis et de carreaux à l'intérieur ('IN') de l'enveloppe urbaine (les deux tables précédentes) par territoire (11 min 35 secs)

	DROP TABLE IF EXISTS "F1_REN_DensiteBatie".chiffres_cles_part1;
	CREATE TABLE "F1_REN_DensiteBatie".chiffres_cles_part1 AS (
		SELECT a.id_geom, a."Location", a."Count_ENTITIES", b."Count_ENTITIES_ref"
		FROM (
			SELECT terr.id_geom, 'IN'::varchar "Location", Count(bati.*) AS "Count_ENTITIES"
			FROM public."territory_table_CAP20" terr
			LEFT JOIN "F1_REN_DensiteBatie".chiffres_cles_part01 bati
			ON ST_Intersects(ST_Centroid(bati.geom), terr.geom)
			WHERE terr.id_geom IS NOT NULL
			GROUP BY terr.id_geom
		) a
		LEFT JOIN (
			SELECT terr.id_geom, Count(carr.geom) "Count_ENTITIES_ref"
			FROM public."territory_table_CAP20" terr
			LEFT JOIN "F1_REN_DensiteBatie".chiffres_cles_part02 carr
			ON ST_Intersects(carr.geom, terr.geom) AND ST_Area(ST_Intersection(carr.geom, terr.geom))>ST_Area(carr.geom)*0.5
			GROUP BY terr.id_geom
		) b
		ON a.id_geom = b.id_geom
	);
	
-- Chiffres clés Total, OUT, et aggrégation.
	--Requête pour totaux par territoire (38 min 43 secs)
	DROP TABLE IF EXISTS "F1_REN_DensiteBatie".chiffres_cles_part2;
	CREATE TABLE "F1_REN_DensiteBatie".chiffres_cles_part2 AS (
		SELECT a.id_geom, a."Count_ENTITIES", b."Count_ENTITIES_ref"
		FROM (
			SELECT terr.id_geom, Count(bati.geom) "Count_ENTITIES"
			FROM public."territory_table_CAP20" terr
			LEFT JOIN "F1_REN_DensiteBatie".faux_batiments_2021 bati
			ON ST_Intersects(ST_Centroid(bati.geom), terr.geom)
			WHERE terr.id_geom IS NOT NULL
			GROUP BY terr.id_geom
		) a
		LEFT JOIN (
			SELECT terr.id_geom, Count(carr.geom) "Count_ENTITIES_ref"
			FROM "F1_REN_DensiteBatie".carreaux_faussedensite_2021_nonull carr
			LEFT JOIN public."territory_table_CAP20" terr
			ON ST_Intersects(carr.geom, terr.geom) AND ST_Area(ST_Intersection(carr.geom, terr.geom))>ST_Area(carr.geom)*0.5
			WHERE terr.id IS NOT NULL
			GROUP BY terr.id_geom
		) b
		ON a.id_geom = b.id_geom
	);
	
	DROP TABLE IF EXISTS "F1_REN_DensiteBatie".chiffres_cles;
	CREATE TABLE "F1_REN_DensiteBatie".chiffres_cles AS (
		SELECT a.id_geom, a."Location", a."Count_ENTITIES", a."Count_ENTITIES_ref"
		FROM "F1_REN_DensiteBatie".chiffres_cles_part1 a
		UNION ALL (
			SELECT b.id_geom, 'OUT'::varchar "Location", (b."Count_ENTITIES"-c."Count_ENTITIES") "Count_ENTITIES", (b."Count_ENTITIES_ref"-c."Count_ENTITIES_ref") "Count_ENTITIES_ref"
			FROM "F1_REN_DensiteBatie".chiffres_cles_part2 b
			LEFT JOIN "F1_REN_DensiteBatie".chiffres_cles_part1 c
			ON b.id_geom = c.id_geom
		)
		ORDER BY id_geom, "Location"
	);

	-- On ajoute la colonne de moyenne _avg
	ALTER TABLE "F1_REN_DensiteBatie".chiffres_cles
	DROP COLUMN IF EXISTS "Count_ENTITIES_avg";
	ALTER TABLE "F1_REN_DensiteBatie".chiffres_cles 
	ADD COLUMN "Count_ENTITIES_avg" float;
	UPDATE "F1_REN_DensiteBatie".chiffres_cles 
	SET "Count_ENTITIES_avg" = CAST("Count_ENTITIES" as float)/"Count_ENTITIES_ref";
	SELECT * FROM "F1_REN_DensiteBatie".chiffres_cles;
	
DROP TABLE IF EXISTS "F1_REN_DensiteBatie".chiffres_cles_part01;
DROP TABLE IF EXISTS "F1_REN_DensiteBatie".chiffres_cles_part02;
DROP TABLE IF EXISTS "F1_REN_DensiteBatie".chiffres_cles_part1;
DROP TABLE IF EXISTS "F1_REN_DensiteBatie".chiffres_cles_part2;

				
				-----   Calcul surfaces baties  -------

select id_geom, sum(st_area((st_intersection(tt.geom, fb.geom)))) surf_bat_21, st_area(tt.geom) surf_ter 
	from "F1_REN_DensiteBatie".faux_batiments_2021 fb 
		left join public."territory_table_CAP20" tt
		on st_intersects(fb.geom,tt.geom)
	where tt.id_geom = '44006'
	group by id_geom, tt.geom;
	
select id_geom, sum(st_area((st_intersection(tt.geom, fb.geom)))) surf_bat_20, st_area(tt.geom) surf_ter 
	from "F1_REN_DensiteBatie".faux_batiments_2020 fb 
		left join public."territory_table_CAP20" tt
		on st_intersects(fb.geom,tt.geom)
	where tt.id_geom = '44006'
	group by id_geom, tt.geom
				
	
	SELECT count(c.geom)
			FROM "F1_REN_DensiteBatie"."Carroyage_CAP_2154_clip_terr" c left join
				"F1_REN_DensiteBatie"."faux_batiments_2020" bati
				on ST_Intersects(ST_Centroid(bati.geom),c.geom)
			WHERE ST_Intersects(ST_Centroid(bati.geom),c.geom)
			--GROUP BY c.id_car, c.geom




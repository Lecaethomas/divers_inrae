-- Variables à remplacer:

-- Le nom du schema 												spe_F1_REN_EnvUrbaine_DensiteBatie_CAP
-- La table de bâti 2019											batiments_pci_01012019_cap_clean
-- La table de bâti 2018											BatiPCI_0201_clean
-- La table de carroyage découpé sur les limites du territoire 		Carroyage_Intersects_Territoire


-- Pour la production de CAP, j'utilise Postgres, avec différents schémas:
	-- Un pour les données "globales":			production_cap_t1_global
	-- Un pour les données de l'indicateur:		spe_F1_REN_EnvUrbaine_DensiteBatie_CAP

-- La colonne de géométrie s'appelle toujours 'geom'


-- /!\ IMPORTANT /!\
-- Pour les indicateurs à base de données carroyées il y a une étape de traiements manuels avant (j'avais fais un truc sur PostGIS mais c'était super lent autant faire ça une fois à la main dans QGis)
-- Le but c'est de ne garder que la partie des carreaux qui intersecte le territoire, faute de quoi, au moment de ne garder que les carreaux qui intersectent au moins à 50% une commune (ou dont le centroïde intersecte la commune, vaut peut-être mieux ça d'ailleurs), on risquerait de "perdre" des carreaux (aux limites extérieures du territoire)
	-- Dissoudre la table territoire pour avoir un seul polygone
	-- Découper le carroyage selon les limites du terrtoire, on nomme la table "Carroyage_Intersects_Territoire"

-- On a quand même besoin de la table de carroyage complet à la fin, pour sortir la couche d'évolution selon la géométrie du carroyage complet. Sans ça on sort des carreaux d'évolution découpés en bordure de territoire (c'est pas obligatoire, mais c'est plus propre).


--/--/--/--/--/--/--/--/--/--/--/--/--/-
--/--/--/--/-- PRODUCTION --/--/--/--/--
--/--/--/--/--/--/--/--/--/--/--/--/--/-


-- Index table carroyage
DROP INDEX IF EXISTS production_cap_t1_global.Carroyage_Intersects_Territoire_geom_idx;
CREATE INDEX Carroyage_Intersects_Territoire_geom_idx ON production_cap_t1_global."Carroyage_Intersects_Territoire" USING GIST (geom);
-- Index table bati 2018
DROP INDEX IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".BatiPCI_0201_clean_geom_idx;
CREATE INDEX BatiPCI_0201_clean_geom_idx ON "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."BatiPCI_0201_clean" USING GIST (geom);
-- Index table bati 2019
DROP INDEX IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".batiments_pci_01012019_cap_clean_geom_idx;
CREATE INDEX batiments_pci_01012019_cap_clean_geom_idx ON "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."batiments_pci_01012019_cap_clean" USING GIST (geom);

-- /!\ IMPORTANT /!\ 
-- /!\ IMPORTANT /!\ 
-- /!\ IMPORTANT /!\ 
-- Pour l'initialisation on a utilisé le cadastre, donnée source ici: D:\_CLIENT\CAP\DATA_SCoT_CAP_Atlantique\_RAW\_OCS\ETALAB_02.02.18\CAP\BatiPCI_0201.shp (104448 entités)
-- Mais la couche utilisée pour les calculs c'est "BatiPCI_0201_clean.shp". (103111 entités)
-- En effet, il y avait 1337 doublons sur la commune de Camoël
-- Dans le millésime pour actualisation, il y a encore des doublons dans la donnée brute (mais plus que 6)
-- Un bon moyen pour supprimer les géométries dupliquées c'est de passer dans PostGIS (parce que dans QGis on est pas rendus): https://gis.stackexchange.com/questions/124583/delete-duplicate-geometry-in-postgis-tables

	DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".batiments_pci_01012019_cap_clean_noduplicates;
	CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".batiments_pci_01012019_cap_clean_noduplicates AS (
		WITH unique_geoms (id, geom) AS (
			SELECT row_number() OVER (PARTITION BY geom) as id, geom 
			FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".batiments_pci_01012019_cap_clean
		)
		SELECT id, geom 
		FROM unique_geoms 
		WHERE id=1
	);
	DROP INDEX IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".batiments_pci_01012019_cap_clean_noduplicates_geom_idx;
	CREATE INDEX batiments_pci_01012019_cap_clean_noduplicates_geom_idx ON "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."batiments_pci_01012019_cap_clean_noduplicates" USING GIST (geom);

/*-- Éventuellement, ne conserver que les bâtiments qui font plus de 20m² (mais là pour CAP on le fait pas)
	-- Pour 2018
	DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."BatiPCI_0201_clean_sup20";
	CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."BatiPCI_0201_clean_sup20" AS (
		SELECT *
		FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."BatiPCI_0201_clean"
		WHERE ST_Area(geom) > 20
	);
	DROP INDEX IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".BatiPCI_0201_clean_sup20_geom_idx;
	CREATE INDEX BatiPCI_0201_clean_sup20_geom_idx ON "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."BatiPCI_0201_clean_sup20" USING GIST (geom);

	-- Pour 2019
	DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."batiments_pci_01012019_cap_clean_noduplicates_dur_sup20";
	CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."batiments_pci_01012019_cap_clean_noduplicates_dur_sup20" AS (
		SELECT *
		FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."batiments_pci_01012019_cap_clean_noduplicates_dur"
		WHERE ST_Area(geom) > 20
	);
	DROP INDEX IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".batiments_pci_01012019_cap_clean_noduplicates_dur_geom_idx;
	CREATE INDEX batiments_pci_01012019_cap_clean_noduplicates_dur_sup20_geom_idx ON "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."batiments_pci_01012019_cap_clean_noduplicates_dur_sup20" USING GIST (geom);
*/


-- Comme pour les logements, on ne veut pas compter les évolutions négatives, ni celles liées à des mouvements dans les limites de bâtiments. On ne veut pas non plus passer en surface (parce que ça met trop en valeur les zones d'activité). Et on est moyen chauds sur l'idée de passer à un vrai indicateur de densité bâtie à partir de la BD Topo = (Bati*Hauteur)/Surface.
-- Donc chaque année on repère les évolutions, on les ajoute à la table de l'année précédente et on recalcule la nouvelle densité sur cette base (oui c'est n'importe quoi mais c'est comme ça)


-- Créer la fausse couche de bâtiments pour 2019

	-- On commence par récupérer tous les bâtiments de 2019 qui n'étaient pas là en 2018 (5 min 5 secs avec index, sans doute plusieurs heures sans)
	-- Dans le doute on supprime et re-crée les colonnes 'id' des deux tables de bâtiments parce que sinon ça peut faire des bêtises sans qu'on s'en rende compte (j'ai eu le problème)
	ALTER TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."batiments_pci_01012019_cap_clean_noduplicates" DROP COLUMN IF EXISTS id;
	ALTER TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."batiments_pci_01012019_cap_clean_noduplicates" ADD COLUMN id SERIAL PRIMARY KEY;
	ALTER TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."BatiPCI_0201_clean" DROP COLUMN IF EXISTS id;
	ALTER TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."BatiPCI_0201_clean" ADD COLUMN id SERIAL PRIMARY KEY;

	DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."creations_extensions";
	CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."creations_extensions" AS (
		WITH t1 AS (
			SELECT a.id, 'creation'::varchar typo, a.geom geom 
			FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."batiments_pci_01012019_cap_clean_noduplicates" a
			LEFT JOIN "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."BatiPCI_0201_clean" b
			ON ST_Intersects(a.geom,b.geom) AND ST_Area(ST_Intersection(a.geom,b.geom)) > ST_Area(a.geom)*0.05 --Si l'intersection n'existe pas, postgis renvoie une GEOMETRYCOLLECTION EMPTY qui donne zéro au ST_Area(), donc ça passe
			WHERE b.id IS NULL
		)
		SELECT a.id, 'extension'::varchar typo, a.geom geom
		FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."batiments_pci_01012019_cap_clean_noduplicates" a
		LEFT JOIN "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."BatiPCI_0201_clean" b
		-- À 95% de surface déjà existante au millésime n-1 on ne considère pas le bâtiment comme une nouvelle construction, mais comme une simple extension (ça change rien dans l'indicateur au final)
		ON ST_Intersects(a.geom,b.geom) AND ST_Area(ST_Intersection(a.geom,b.geom)) > ST_Area(a.geom)*0.95
		WHERE b.id IS NULL 
		AND a.id NOT IN (SELECT id FROM t1)
		UNION ALL
		SELECT * FROM t1
	);
	DROP INDEX IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".creations_extensions_geom_idx;
	CREATE INDEX creations_extensions_geom_idx ON "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."creations_extensions" USING GIST (geom);


	-- On crée la fausse couche en ajoutant ces nouveaux bâtiments à la table du millésime précédent (5 secs 39 msec.
	DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."faux_batiments_2019";
	CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."faux_batiments_2019" AS (
		SELECT id, geom
		FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."creations_extensions"
		UNION ALL
		SELECT id, geom
		FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."BatiPCI_0201_clean"
	);
	DROP INDEX IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".faux_batiments_2019_geom_idx;
	CREATE INDEX faux_batiments_2019_geom_idx ON "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."faux_batiments_2019" USING GIST (geom);


-- Création couche densité (26 secs 665 msec)
	--Pour 2018
	DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_densite_2018;
	CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_densite_2018 AS (
		SELECT a.id_car, b."Count_ENTITIES", a.geom
		FROM production_cap_t1_global."Carroyage_Intersects_Territoire" a
		FULL JOIN (
			SELECT c.id_car, Count(bati.geom) "Count_ENTITIES", c.geom
			FROM production_cap_t1_global."Carroyage_Intersects_Territoire" c,
				"spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."BatiPCI_0201_clean" bati
			WHERE ST_Intersects(ST_Centroid(bati.geom),c.geom)
			GROUP BY c.id_car, c.geom
		) b
		ON a.id_car = b.id_car
	);
	DROP INDEX IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_densite_2018_geom_idx;
	CREATE INDEX carreaux_densite_2018_geom_idx ON "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_densite_2018 USING GIST (geom);

	-- Pour 2019
	DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_densite_2019;
	CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_densite_2019 AS (
		SELECT a.id_car, b."Count_ENTITIES", a.geom
		FROM production_cap_t1_global."Carroyage_Intersects_Territoire" a
		FULL JOIN (
			SELECT c.id_car, Count(bati.geom) "Count_ENTITIES", c.geom
			FROM production_cap_t1_global."Carroyage_Intersects_Territoire" c,
				"spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."faux_batiments_2019" bati
			WHERE ST_Intersects(ST_Centroid(bati.geom),c.geom)
			GROUP BY c.id_car, c.geom
		) b
		ON a.id_car = b.id_car
	);
	DROP INDEX IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_densite_2019_geom_idx;
	CREATE INDEX carreaux_densite_2019_geom_idx ON "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_densite_2019 USING GIST (geom);




--/--/--/--/--/--/--/--/--/--/--/--/
--/--/--/--/-- EXPORT --/--/--/--/--
--/--/--/--/--/--/--/--/--/--/--/--/


-- Création de la couche d'évolution (3 secs 723 msec)
	-- Jointure des deux résultats précédents
	DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_evolution_2018_2019;
	CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_evolution_2018_2019 AS (
		SELECT c.id_car, den_18."Count_ENTITIES" den_18, den_19."Count_ENTITIES" den_19, c.geom geom
		FROM production_cap_t1_global."Carroyage_Intersects_Territoire" c
		JOIN "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_densite_2018 den_18 ON c.id_car = den_18.id_car
		JOIN "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_densite_2019 den_19 ON c.id_car = den_19.id_car
	);
	-- Ajout de la colonne d'évolution
	ALTER TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_evolution_2018_2019 DROP COLUMN IF EXISTS evolution;
	ALTER TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_evolution_2018_2019 ADD COLUMN evolution int;
	UPDATE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_evolution_2018_2019 SET evolution = COALESCE(den_19,0)-COALESCE(den_18,0);
	-- Suppression des évolultions nulles
	DELETE FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_evolution_2018_2019 WHERE evolution = 0;

	-- Pour sortir l'évolution format dataviz:
	DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".evolution;
	CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".evolution AS (
		SELECT a.den_18, a.den_19, a.evolution, (
			CASE
			WHEN  a.evolution >= 1 AND a.evolution <= 2 THEN '[1-2]'
			WHEN  a.evolution > 2 AND a.evolution <= 3 THEN ']2-3]'
			WHEN  a.evolution > 3 AND a.evolution <= 5 THEN ']3-5]'
			WHEN  a.evolution > 5 AND a.evolution <= 9 THEN ']5-9]'
			WHEN  a.evolution > 9 AND a.evolution <= 13 THEN ']9-13]'
			ELSE '999'
			END
		) cat,
		b.geom
		FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."carreaux_evolution_2018_2019" a
		LEFT JOIN production_cap_t1_global."_CarroyageMicro_CAP_EPSG2154" b
		ON a.id_car = b.id_car
		WHERE evolution > 0
	);

-- Si on veut le .csv qui sert pour faire la jointure avec le MBTile de carroyage
DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."spe_F1_REN_EnvUrbaine_DensiteBatie_carroyage";
CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."spe_F1_REN_EnvUrbaine_DensiteBatie_carroyage" AS (
	SELECT id_car "ID_CAR", (
		CASE
		WHEN "Count_ENTITIES" >= 1 AND "Count_ENTITIES" <= 2 THEN '1 - 2'
		WHEN "Count_ENTITIES" > 2 AND "Count_ENTITIES" <= 6 THEN '2 - 6'
		WHEN "Count_ENTITIES" > 6 AND "Count_ENTITIES" <= 12 THEN '6 - 12'
		WHEN "Count_ENTITIES" > 12 AND "Count_ENTITIES" <= 21 THEN '12 - 21'
		WHEN "Count_ENTITIES" > 21 AND "Count_ENTITIES" <= 31 THEN '21 - 31'
		WHEN "Count_ENTITIES" > 31 AND "Count_ENTITIES" <= 47 THEN '31 - 47'
		WHEN "Count_ENTITIES" > 47 AND "Count_ENTITIES" <= 86 THEN '47 - 86'
		ELSE '999'
		END
	) typo
	FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_densite_2019
	WHERE "Count_ENTITIES" > 0
);

--/--/--/--/--/--/--/--/--/--/--/--/--/--/-
--/--/--/--/-- CHIFFRES CLES --/--/--/--/--
--/--/--/--/--/--/--/--/--/--/--/--/--/--/-


-- On a besoin de créer une table de densité carroyée sans les carreaux avec une valeur nulle
DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_faussedensite_2019_nonull;
CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_faussedensite_2019_nonull AS (
	SELECT *
	FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."carreaux_densite_2019" 
	WHERE "Count_ENTITIES" > 0
);
DROP INDEX IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_faussedensite_2019_nonull_geom_idx;
CREATE INDEX carreaux_faussedensite_2019_nonull_geom_idx ON "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_faussedensite_2019_nonull USING GIST (geom);

	/*-- Pour la livraison on donne au territoire la version des carreaux non-découpés selon les limites des territoire
	-- Pour ça on prend les infos attributaires de la couche carreaux_faussedensite_2019_nonull avec la géométrie du _CarroyageMicro_CAP_EPSG2154 grace à une jointure du l'id_car
	DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_faussedensite_2019_nonull_exportlivraison;
	CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_faussedensite_2019_nonull_exportlivraison AS (
		SELECT a.id_car "ID_CAR", a."Count_ENTITIES" "NbrBat", b.geom
		FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_faussedensite_2019_nonull a
		LEFT JOIN production_cap_t1_global."_CarroyageMicro_CAP_EPSG2154" b
		ON a.id_car = b.id_car
	);*/

-- On a besoin de créer une table de densité carroyée sans les carreaux qui n'ont pas de valeur
DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_densite_2018_nonull;
CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_densite_2018_nonull AS (
	SELECT *
	FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."carreaux_densite_2018" 
	WHERE "Count_ENTITIES" > 0
);
DROP INDEX IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_densite_2018_nonull_geom_idx;
CREATE INDEX carreaux_densite_2018_nonull_geom_idx ON "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_densite_2018_nonull USING GIST (geom);

-- Table temporaire pour stocker les carreaux à plus de 50% dans les enveloppes urbaines
/*DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".test_temp;
CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".test_temp AS (
	SELECT carr.*
	FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_faussedensite_2019_nonull carr
	LEFT JOIN test_majic_cap."Cap_Atlantique_EnvUrbaine_PourCalculs_2018" env
	ON ST_Intersects(carr.geom, env.geom) AND ST_Area(ST_Intersection(carr.geom, env.geom))>ST_Area(carr.geom)*0.5
	WHERE env.id IS NOT NULL
);
DROP INDEX IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".test_temp_geom_idx;
CREATE INDEX test_temp_geom_idx ON "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".test_temp USING GIST (geom);

-- Chiffres clés IN
DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".test;
CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".test AS (
	SELECT terr.id_geom, 'IN' "Location", Count(carr.geom) Count_ENTITIES_ref
	FROM test_majic_cap."territory_table_CAP_2020" terr
	LEFT JOIN "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".test_temp carr
	ON ST_Intersects(carr.geom, terr.geom) AND ST_Area(ST_Intersection(carr.geom, terr.geom))>ST_Area(carr.geom)*0.5
	WHERE carr.id_car IS NOT NULL
	GROUP BY terr.id_geom
);			

--Requête pour totaux par territoire
DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".test_total;
CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".test_total AS (
	SELECT terr.id_geom, Count(carr.geom) Count_ENTITIES_ref
	FROM test_majic_cap."territory_table_CAP_2020" terr
	LEFT JOIN "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_faussedensite_2019_nonull carr
	ON ST_Intersects(carr.geom, terr.geom) AND ST_Area(ST_Intersection(carr.geom, terr.geom))>ST_Area(carr.geom)*0.5
	WHERE carr.id_car IS NOT NULL
	GROUP BY terr.id_geom
);
*/

-- Ça marche pas
-- ON ANNULE TOUT
-- C'est comme ça qu'il faut faire:
-- Explication: pour le bâti, contrairement à la densité, on ne prend pas la somme des sommes de bâtiments par carreaux à l'intérieur de l'enveloppe divisée par la somme du nombre de carreaux à l'intérieur de l'enveloppe. Mais la somme des bâtiments à l'intérieur de l'enveloppe divisée par la somme du nombre de carreaux à l'intérieur de l'enveloppe. (C'est clair ?)

-- Chiffres clés IN
	-- On stocke tous les bâtis à l'intérieur de l'enveloppe urbaine à l'échelle du territoire
	DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part01;
	CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part01 AS (
		SELECT bati.*
		FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."faux_batiments_2019" bati
		LEFT JOIN production_cap_t1_global."Cap_Atlantique_EnvUrbaine_PourCalculs_2018" env
		ON ST_Intersects(ST_Centroid(bati.geom), env.geom)
		WHERE env.id IS NOT NULL
	);
	DROP INDEX IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part01_geom_idx;
	CREATE INDEX chiffres_cles_part01_geom_idx ON "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part01 USING GIST (geom);

	-- On stocke tous les carreaux à l'intérieur de l'enveloppe urbaine à l'échelle du territoire
	DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part02;
	CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part02 AS (
		SELECT carr.*
		FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_faussedensite_2019_nonull carr
		LEFT JOIN production_cap_t1_global."Cap_Atlantique_EnvUrbaine_PourCalculs_2018" env
		ON ST_Intersects(carr.geom, env.geom) AND ST_Area(ST_Intersection(carr.geom, env.geom))>ST_Area(carr.geom)*0.5
		WHERE env.id IS NOT NULL
	);
	DROP INDEX IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part02_geom_idx;
	CREATE INDEX chiffres_cles_part02_geom_idx ON "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part02 USING GIST (geom);

	-- On groupe le nombre de bâtis et de carreaux à l'intérieur ('IN') de l'enveloppe urbaine (les deux tables précédentes) par territoire (11 min 35 secs)
	DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part1;
	CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part1 AS (
		SELECT a.id_geom, a."Location", a."Count_ENTITIES", b."Count_ENTITIES_ref"
		FROM (
			SELECT terr.id_geom, 'IN'::varchar "Location", Count(bati.*) AS "Count_ENTITIES"
			FROM production_cap_t1_global."territory_table_CAP_2020" terr
			LEFT JOIN "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part01 bati
			ON ST_Intersects(ST_Centroid(bati.geom), terr.geom)
			WHERE terr.id_geom IS NOT NULL
			GROUP BY terr.id_geom
		) a
		LEFT JOIN (
			SELECT terr.id_geom, Count(carr.geom) "Count_ENTITIES_ref"
			FROM production_cap_t1_global."territory_table_CAP_2020" terr
			LEFT JOIN "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part02 carr
			ON ST_Intersects(carr.geom, terr.geom) AND ST_Area(ST_Intersection(carr.geom, terr.geom))>ST_Area(carr.geom)*0.5
			GROUP BY terr.id_geom
		) b
		ON a.id_geom = b.id_geom
	);

-- Chiffres clés Total, OUT, et aggrégation.
	--Requête pour totaux par territoire (38 min 43 secs)
	DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part2;
	CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part2 AS (
		SELECT a.id_geom, a."Count_ENTITIES", b."Count_ENTITIES_ref"
		FROM (
			SELECT terr.id_geom, Count(bati.geom) "Count_ENTITIES"
			FROM production_cap_t1_global."territory_table_CAP_2020" terr
			LEFT JOIN "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".faux_batiments_2019 bati
			ON ST_Intersects(ST_Centroid(bati.geom), terr.geom)
			WHERE terr.id_geom IS NOT NULL
			GROUP BY terr.id_geom
		) a
		LEFT JOIN (
			SELECT terr.id_geom, Count(carr.geom) "Count_ENTITIES_ref"
			FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_faussedensite_2019_nonull carr
			LEFT JOIN production_cap_t1_global."territory_table_CAP_2020" terr
			ON ST_Intersects(carr.geom, terr.geom) AND ST_Area(ST_Intersection(carr.geom, terr.geom))>ST_Area(carr.geom)*0.5
			WHERE terr.id IS NOT NULL
			GROUP BY terr.id_geom
		) b
		ON a.id_geom = b.id_geom
	);


	-- Aggégation et calcul du 'OUT' (351 msec)
	DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles;
	CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles AS (
		SELECT a.id_geom, a."Location", a."Count_ENTITIES", a."Count_ENTITIES_ref"
		FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part1 a
		UNION ALL (
			SELECT b.id_geom, 'OUT'::varchar "Location", (b."Count_ENTITIES"-c."Count_ENTITIES") "Count_ENTITIES", (b."Count_ENTITIES_ref"-c."Count_ENTITIES_ref") "Count_ENTITIES_ref"
			FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part2 b
			LEFT JOIN "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part1 c
			ON b.id_geom = c.id_geom
		)
		ORDER BY id_geom, "Location"
	);

	-- On ajoute la colonne de moyenne _avg
	ALTER TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles
	DROP COLUMN IF EXISTS "Count_ENTITIES_avg";
	ALTER TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles 
	ADD COLUMN "Count_ENTITIES_avg" float;
	UPDATE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles 
	SET "Count_ENTITIES_avg" = CAST("Count_ENTITIES" as float)/"Count_ENTITIES_ref";
	SELECT * FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles;

-- On a plus besoin des tables temporaires
--DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part01;
--DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part02;
--DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part1;
--DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part2;








--/--/--/--/--/--/--/--/--/--/--/--/--/--/---/--/--/--/--/--/--/--/--/--/--/
--/--/--/--/--/--/--/--/--/--/--/--/--/--/---/--/--/--/--/--/--/--/--/--/--/
--/--/--/--/-- CHIFFRES CLES: VARIANTE AVEC CARREAUX DÉCOUPÉS --/--/--/--/--
--/--/--/--/--/--/--/--/--/--/--/--/--/--/---/--/--/--/--/--/--/--/--/--/--/
--/--/--/--/--/--/--/--/--/--/--/--/--/--/---/--/--/--/--/--/--/--/--/--/--/

-- L'idée c'est de ne plus compter les carreaux IN/OUT selon le critère de 50% par rapport à l'enveloppe urbaine, mais de plutôt découper les carreaux selon les limites de l'enveloppe urbaine, et de compter chaque partie de son côté.
-- À priori il suffit de remplacer <Count(carr.geom)> par <ST_Area(carr.geom)/10000> (pas tout à fait en fait)


-- Chiffres clés IN
	-- On stocke tous les bâtis à l'intérieur de l'enveloppe urbaine à l'échelle du territoire
	DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_test_part01;
	CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_test_part01 AS (
		SELECT bati.*
		FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."BatiPCI_0201_clean" bati
		LEFT JOIN production_cap_t1_global."Cap_Atlantique_EnvUrbaine_PourCalculs_2018" env
		ON ST_Intersects(ST_Centroid(bati.geom), env.geom)
		WHERE env.id IS NOT NULL
	);
	DROP INDEX IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_test_part01_geom_idx;
	CREATE INDEX chiffres_cles_test_part01_geom_idx ON "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_test_part01 USING GIST (geom);

	-- On stocke tous les carreaux à l'intérieur de l'enveloppe urbaine à l'échelle du territoire
	DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_test_part02;
	CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_test_part02 AS (
		SELECT carr.id_car, ST_Intersection(carr.geom,env.geom) geom
		FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_densite_2018_nonull carr
		LEFT JOIN production_cap_t1_global."Cap_Atlantique_EnvUrbaine_PourCalculs_2018" env
		ON ST_Intersects(carr.geom, env.geom) --AND ST_Area(ST_Intersection(carr.geom, env.geom))>ST_Area(carr.geom)*0.5
		WHERE env.id IS NOT NULL
	);
	DROP INDEX IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_test_part02_geom_idx;
	CREATE INDEX chiffres_cles_test_part02_geom_idx ON "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_test_part02 USING GIST (geom);

	-- On groupe le nombre de bâtis et de carreaux à l'intérieur ('IN') de l'enveloppe urbaine (les deux tables précédentes) par territoire (11 min 35 secs)
	DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_test_part1;
	CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_test_part1 AS (
		SELECT a.id_geom, a."Location", a."Count_ENTITIES", b."Count_ENTITIES_ref"
		FROM (
			SELECT terr.id_geom, 'IN'::varchar "Location", Count(bati.*) AS "Count_ENTITIES"
			FROM production_cap_t1_global."territory_table_CAP_2020" terr
			LEFT JOIN "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_test_part01 bati
			ON ST_Intersects(ST_Centroid(bati.geom), terr.geom)
			WHERE terr.id_geom IS NOT NULL
			GROUP BY terr.id_geom
		) a
		LEFT JOIN (
			SELECT terr.id_geom, SUM(ST_Area(carr.geom))/10000 "Count_ENTITIES_ref"
			FROM production_cap_t1_global."territory_table_CAP_2020" terr
			LEFT JOIN "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_test_part02 carr
			ON ST_Intersects(carr.geom, terr.geom) --AND ST_Area(ST_Intersection(carr.geom, terr.geom))>ST_Area(carr.geom)*0.5
			GROUP BY terr.id_geom
		) b
		ON a.id_geom = b.id_geom
	);

-- Chiffres clés Total, OUT, et aggrégation.
	--Requête pour totaux par territoire (38 min 43 secs)
	DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_test_part2;
	CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_test_part2 AS (
		SELECT a.id_geom, a."Count_ENTITIES", b."Count_ENTITIES_ref"
		FROM (
			SELECT terr.id_geom, Count(bati.geom) "Count_ENTITIES"
			FROM production_cap_t1_global."territory_table_CAP_2020" terr
			LEFT JOIN "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."BatiPCI_0201_clean" bati
			ON ST_Intersects(ST_Centroid(bati.geom), terr.geom)
			WHERE terr.id_geom IS NOT NULL
			GROUP BY terr.id_geom
		) a
		LEFT JOIN (
			SELECT terr.id_geom, SUM(ST_Area(ST_Intersection(carr.geom,terr.geom)))/10000 "Count_ENTITIES_ref"
			FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_densite_2018_nonull carr
			LEFT JOIN production_cap_t1_global."territory_table_CAP_2020" terr
			ON ST_Intersects(carr.geom, terr.geom) --AND ST_Area(ST_Intersection(carr.geom, terr.geom))>ST_Area(carr.geom)*0.5
			WHERE terr.id IS NOT NULL
			GROUP BY terr.id_geom
		) b
		ON a.id_geom = b.id_geom
	);


	-- Aggégation et calcul du 'OUT' (351 msec)
	DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_test_cles;
	CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_test_cles AS (
		SELECT a.id_geom, a."Location", a."Count_ENTITIES", a."Count_ENTITIES_ref"
		FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_test_part1 a
		UNION ALL (
			SELECT b.id_geom, 'OUT'::varchar "Location", (b."Count_ENTITIES"-c."Count_ENTITIES") "Count_ENTITIES", (b."Count_ENTITIES_ref"-c."Count_ENTITIES_ref") "Count_ENTITIES_ref"
			FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_test_part2 b
			LEFT JOIN "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_test_part1 c
			ON b.id_geom = c.id_geom
		)
		ORDER BY id_geom, "Location"
	);

	-- On ajoute la colonne de moyenne _avg
	ALTER TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_test_cles
	DROP COLUMN IF EXISTS "Count_ENTITIES_avg";
	ALTER TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_test_cles 
	ADD COLUMN "Count_ENTITIES_avg" float;
	UPDATE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_test_cles 
	SET "Count_ENTITIES_avg" = CAST("Count_ENTITIES" as float)/"Count_ENTITIES_ref";
	SELECT * FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_test_cles;

-- On a plus besoin des tables temporaires
--DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_test_part01;
--DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part02;
--DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_part1;
--DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".chiffres_cles_test_part2;






























-- Test avec la surface au lieu du compte de bâti:

/*
DROP INDEX IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".Carroyage_evolution_2018_2019_idx_geom;
CREATE INDEX Carroyage_evolution_2018_2019_idx_geom ON "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."Carroyage_evolution_2018_2019_extract" USING GIST (geom);

ALTER TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."Carroyage_evolution_2018_2019_extract" DROP COLUMN IF EXISTS _18_surf_entities;
ALTER TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."Carroyage_evolution_2018_2019_extract" ADD COLUMN _18_surf_entities int;
UPDATE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."Carroyage_evolution_2018_2019_extract" SET _18_surf_entities = ST_Area(ST_Intersection(c.geom,b.geom))
	FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."Carroyage_evolution_2018_2019_extract" c,
	"spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."BatiPCI_0201_clean" b
	WHERE ST_Intersects(c.geom,b.geom);



-- Pour créer les surfaces: 
DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_densite_surf_2018;
CREATE TABLE "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP".carreaux_densite_surf_2018 AS (
	SELECT c.id_car, SUM(ST_Area(ST_Intersection(c.geom,bati.geom))) "Surf_ENTITIES", c.geom
	FROM "spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."Carroyage_evolution_2018_2019_extract" c,
		"spe_F1_REN_EnvUrbaine_DensiteBatie_CAP"."BatiPCI_0201_clean" bati
	WHERE ST_Intersects(bati.geom,c.geom)
	GROUP BY c.id_car, c.geom
);




-- Requête pour les chiffres clés:
DROP TABLE IF EXISTS test_majic_cap_extract.spe_F1_REN_EnvUrbaine_DensiteBatie_CAP;
CREATE TABLE test_majic_cap_extract.spe_F1_REN_EnvUrbaine_DensiteBatie_CAP AS (
	SELECT terr.id_geom, "IN" Location, Count(bat.geom) Count_ENTITIES, Count(carr.geom) Count_ENTITIES_ref
	FROM 	spe_F1_REN_EnvUrbaine_DensiteBatie_CAP.batiments_pci_01012019_cap bat, 
			test_majic_cap."territory_table_CAP_2020" terr, 
			spe_F1_REN_EnvUrbaine_DensiteBatie_CAP.clip_carreau carr,
			test_majic_cap."Cap_Atlantique_EnvUrbaine_PourCalculs_2018" env
	WHERE ST_Intersects(carr.geom, terr.geom)
	AND ST_Area(ST_Intersection(carr.geom,env.geom)) > ST_Area(carr.geom)*0.5
	AND ST_Intersects(bat.geom, terr.geom)
	AND ST_Area(ST_Intersection(bat.geom,env.geom)) > ST_Area(carr.geom)*0.5

	GROUP BY b.id_car, b.geom
);
*/

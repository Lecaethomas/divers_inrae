-- Variables à remplacer: 

-- Le nom de la base			CAP_maj_2022
-- Le nom du schema 			F1_REN_EnvUrbaine_Logements
-- La table de locaux			fftp_2020_pb0010_local
-- La table de parcelles		"fftp_2018_pnb10_parcelle"--pas utilisé
-- La table de carroyage 		PSB_car_100m_2154_2020 -- pas utilisé
-- La territory table		    territory_table_CAP20
-- l'enveloppe urbaine          "Cap_Atlantique_EnvUrbaine_PourCalculs_2018"
-- ZONES AU                     "cap_PLUs_zaus_202201"

-- Les années, avec le millésime 2016: 
	-- la densité de référence est calculée sur la base de tous les logements construits le 31 décembre 2015	
	-- on étudie l'évolution entre le 1er janvier 2016 et 31 décembre 2017
	-- on affiche à titre d'information les locaux construits à partir du 1er janvier 2018: ce sont des données encore incomplètes qui seront mises à jour au prochain millésime

--//// !! WARNING !! --/////
--Script utilisé pour la prod de fougère qui n'a jamais pu nous fournir le millésime 2019, on a donc du travailler avec le 2020 et simuler un 2019 
--donc les logement d'évolution et simple affichage sont construits grace à des fourchettes de jannath


--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/
--/--/--/--/-- PREPARATION LOGEMENTS --/--/--/--/--
--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/

-- On met de côté les logements WHERE jannath < 2016, ce sont les logements de référence
-- On ajoute leur position par rapport à l'enveloppe urbaine
-- On élimine les logements sans géométries 
-- 5 secs 767 msec.
DROP TABLE IF EXISTS "F1_REN_EnvUrbaine_Logements"."logt_reference";
CREATE TABLE "F1_REN_EnvUrbaine_Logements"."logt_reference" AS (
	WITH logt_IN_OUT AS (
		SELECT loc.idlocal, loc.geom, env.id env_id
		FROM public.fftp_2020_pb0010_local loc
		LEFT JOIN public."Cap_Atlantique_EnvUrbaine_PourCalculs_2018" env
		ON ST_Intersects(env.geom, loc.geom)
		WHERE jannath < 2016 AND dteloc IN ('1','2')
	)
	SELECT logt.idlocal, logt.geom, 'IN'::varchar "Location"
	FROM logt_IN_OUT logt
	WHERE logt.env_id IS NOT NULL AND logt.geom IS NOT NULL
	UNION ALL
	SELECT logt.idlocal, logt.geom, 'OUT'::varchar "Location"
	FROM logt_IN_OUT logt
	WHERE logt.env_id IS NULL AND logt.geom IS NOT NULL
);

	-- Ajout du label EPCI pour séparer la couche pour les MBTiles 58 secs 872 msec.
	DROP TABLE IF EXISTS "F1_REN_EnvUrbaine_Logements"."_dataviz_logt_reference";
	CREATE TABLE "F1_REN_EnvUrbaine_Logements"."_dataviz_logt_reference" AS (
		SELECT logt.*, terr.label
		FROM "F1_REN_EnvUrbaine_Logements"."logt_reference" logt
		LEFT JOIN public."territory_table_CAP20" terr
		ON ST_Intersects(terr.geom, logt.geom)
		WHERE terr.rank = '2'
	);

-- On met de côté les logements WHERE jannath < 2017, ce sont les logements à date d'actualisation  4 secs 74 msec.
DROP TABLE IF EXISTS "F1_REN_EnvUrbaine_Logements"."_dataviz_logt_actualisation";
CREATE TABLE "F1_REN_EnvUrbaine_Logements"."_dataviz_logt_actualisation" AS (
	WITH logt_IN_OUT AS (
		SELECT loc.idlocal, loc.geom, env.id env_id
		FROM public.fftp_2020_pb0010_local loc
		LEFT JOIN public."Cap_Atlantique_EnvUrbaine_PourCalculs_2018" env
		ON ST_Intersects(env.geom, loc.geom)
		WHERE jannath < 2019 AND dteloc IN ('1','2')
	)
	SELECT logt.idlocal, logt.geom, 'IN'::varchar "Location"
	FROM logt_IN_OUT logt
	WHERE logt.env_id IS NOT NULL AND logt.geom IS NOT NULL
	UNION ALL
	SELECT logt.idlocal, logt.geom, 'OUT'::varchar "Location"
	FROM logt_IN_OUT logt
	WHERE logt.env_id IS NULL AND logt.geom IS NOT NULL
);

-- On met de côté les logements WHERE jannath = 2016, ce sont les logements nouvellement produits 543 msec.
DROP TABLE IF EXISTS "F1_REN_EnvUrbaine_Logements"."_dataviz_logt_evolution";
CREATE TABLE "F1_REN_EnvUrbaine_Logements"."_dataviz_logt_evolution" AS (
	WITH logt_IN_OUT AS (
		SELECT loc.idlocal, loc.geom, env.id env_id
		FROM public.fftp_2020_pb0010_local loc
		LEFT JOIN public."Cap_Atlantique_EnvUrbaine_PourCalculs_2018" env
		ON ST_Intersects(env.geom, loc.geom)
		WHERE (jannath >= 2016 and jannath < 2019) AND dteloc IN ('1','2')
	)
	SELECT logt.idlocal, logt.geom, 'IN'::varchar "Location"
	FROM logt_IN_OUT logt
	WHERE logt.env_id IS NOT NULL AND logt.geom IS NOT NULL
	UNION ALL
	SELECT logt.idlocal, logt.geom, 'OUT'::varchar "Location"
	FROM logt_IN_OUT logt
	WHERE logt.env_id IS NULL AND logt.geom IS NOT NULL
);

-- On met de côté les logements WHERE jannath > 2016 pour simple affichage  470 msec.
DROP TABLE IF EXISTS "F1_REN_EnvUrbaine_Logements"."_dataviz_logt_simple_affichage";
CREATE TABLE "F1_REN_EnvUrbaine_Logements"."_dataviz_logt_simple_affichage" AS (
	WITH logt_IN_OUT AS (
		SELECT loc.idlocal, loc.geom, env.id env_id
		FROM public.fftp_2020_pb0010_local loc
		LEFT JOIN public."Cap_Atlantique_EnvUrbaine_PourCalculs_2018" env
		ON ST_Intersects(env.geom, loc.geom)
		WHERE (jannath > 2018 and jannath < 2020) AND dteloc IN ('1','2')
	)
	SELECT logt.idlocal, logt.geom, 'IN'::varchar "Location"
	FROM logt_IN_OUT logt
	WHERE logt.env_id IS NOT NULL AND logt.geom IS NOT NULL
	UNION ALL
	SELECT logt.idlocal, logt.geom, 'OUT'::varchar "Location"
	FROM logt_IN_OUT logt
	WHERE logt.env_id IS NULL AND logt.geom IS NOT NULL
);



--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
--/--/--/--/-- CHIFFRES CLES REFERENCE --/--/--/--/--
--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--

-- Pour pas se planter dans les calculs de chiffres clés IN/OUT, le plus simple est de créer une 1ère table avec uniquement les logements IN par territoire. Puis y ajouter le nombre total de logements par territoire. Et enfin obtenir le nombre de logements OUT par soustraction des deux colonnes précédentes. (Au début j'étais parti sur qq chose genre "SELECT * WHERE ST_Intersects("Cap_Atlantique_EnvUrbaine_PourCalculs_2018") + SELECT * WHERE NOT ST_Intersects("Cap_Atlantique_EnvUrbaine_PourCalculs_2018")", mais selon les géométries, les cas particuliers, les points en dehors du territoire, y'a un risque de se planter. Là ça tient la route partout.

-- Tous les logements IN l'enveloppe urbaine, groupés par territoire (1 min 47 secs)
DROP TABLE IF EXISTS "F1_REN_EnvUrbaine_Logements".chiffres_cles_reference_step1;
CREATE TABLE "F1_REN_EnvUrbaine_Logements".chiffres_cles_reference_step1 AS (
	SELECT terr.id_geom, 'IN'::varchar "Location", Count(logt.*) AS "Count_ENTITIES"
	FROM public."territory_table_CAP20" terr
	LEFT JOIN ( -- Sous requête de tous les logements IN l'enveloppe urbaine
		SELECT logt.*
		FROM "F1_REN_EnvUrbaine_Logements"."_dataviz_logt_reference" logt
		LEFT JOIN public."Cap_Atlantique_EnvUrbaine_PourCalculs_2018" env
		ON ST_Intersects(logt.geom, env.geom)
		WHERE env.id IS NOT NULL
	) logt
	ON ST_Intersects(logt.geom, terr.geom)
	WHERE terr.id_geom IS NOT NULL
	GROUP BY terr.id_geom
);

-- Aggégation et calcul du 'OUT' (1 min 56 secs)
DROP TABLE IF EXISTS "F1_REN_EnvUrbaine_Logements".chiffres_cles_reference;
CREATE TABLE "F1_REN_EnvUrbaine_Logements".chiffres_cles_reference AS (
	SELECT a.id_geom, a."Location", a."Count_ENTITIES"
	FROM "F1_REN_EnvUrbaine_Logements".chiffres_cles_reference_step1 a -- Les logements IN
	UNION ALL ( -- Les logements OUT
		SELECT b.id_geom, 'OUT'::varchar "Location", (b."Count_ENTITIES"-c."Count_ENTITIES") "Count_ENTITIES"
		FROM ( -- Sous requête de tous les logements par territoire
			SELECT terr.id_geom, Count(logt.geom) "Count_ENTITIES"
			FROM public."territory_table_CAP20" terr
			LEFT JOIN "F1_REN_EnvUrbaine_Logements"."_dataviz_logt_reference" logt
			ON ST_Intersects(logt.geom, terr.geom)
			WHERE terr.id_geom IS NOT NULL
			GROUP BY terr.id_geom
		) b
		LEFT JOIN "F1_REN_EnvUrbaine_Logements".chiffres_cles_reference_step1 c
		ON b.id_geom = c.id_geom
	)
	ORDER BY id_geom, "Location"
);



--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
--/--/--/--/-- CHIFFRES CLES ACTUALISATION --/--/--/-
--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--

-- Tous les logements IN l'enveloppe urbaine, groupés par territoire (1 min 47 secs)
DROP TABLE IF EXISTS "F1_REN_EnvUrbaine_Logements".chiffres_cles_actualisation_step1;
CREATE TABLE "F1_REN_EnvUrbaine_Logements".chiffres_cles_actualisation_step1 AS (
	SELECT terr.id_geom, 'IN'::varchar "Location", Count(logt.*) AS "Count_ENTITIES"
	FROM public."territory_table_CAP20" terr
	LEFT JOIN ( -- Sous requête de tous les logements IN l'enveloppe urbaine
		SELECT logt.*
		FROM "F1_REN_EnvUrbaine_Logements"."_dataviz_logt_actualisation" logt
		LEFT JOIN public."Cap_Atlantique_EnvUrbaine_PourCalculs_2018" env
		ON ST_Intersects(logt.geom, env.geom)
		WHERE env.id IS NOT NULL
	) logt
	ON ST_Intersects(logt.geom, terr.geom)
	WHERE terr.id_geom IS NOT NULL
	GROUP BY terr.id_geom
);

-- Aggégation et calcul du 'OUT' (1 min 56 secs)
DROP TABLE IF EXISTS "F1_REN_EnvUrbaine_Logements".chiffres_cles_actualisation;
CREATE TABLE "F1_REN_EnvUrbaine_Logements".chiffres_cles_actualisation AS (
	SELECT a.id_geom, a."Location", a."Count_ENTITIES"
	FROM "F1_REN_EnvUrbaine_Logements".chiffres_cles_actualisation_step1 a -- Les logements IN
	UNION ALL ( -- Les logements OUT
		SELECT b.id_geom, 'OUT'::varchar "Location", (b."Count_ENTITIES"-c."Count_ENTITIES") "Count_ENTITIES"
		FROM ( -- Sous requête de tous les logements par territoire
			SELECT terr.id_geom, Count(logt.geom) "Count_ENTITIES"
			FROM public."territory_table_CAP20" terr
			LEFT JOIN "F1_REN_EnvUrbaine_Logements"."_dataviz_logt_actualisation" logt
			ON ST_Intersects(logt.geom, terr.geom)
			WHERE terr.id_geom IS NOT NULL
			GROUP BY terr.id_geom
		) b
		LEFT JOIN "F1_REN_EnvUrbaine_Logements".chiffres_cles_actualisation_step1 c
		ON b.id_geom = c.id_geom
	)
	ORDER BY id_geom, "Location"
);



--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
--/--/--/--/-- NB LOGEMENTS ZONES AU --/--/--/-
--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--

-- la table zonesau est dans le schema public
ALTER TABLE public."cap_PLUs_zaus_202201" DROP COLUMN IF EXISTS ttid;
ALTER TABLE public."cap_PLUs_zaus_202201" ADD COLUMN ttid SERIAL ;

-- Compte des logements de référence
DROP TABLE IF EXISTS "F1_REN_EnvUrbaine_Logements"._temp_logt_zonesau;
CREATE TABLE "F1_REN_EnvUrbaine_Logements"._temp_logt_zonesau AS (
	SELECT zau.ttid, zau.libelle, zau.typezone, zau.destdomi, COALESCE(Count(ref.*), 0) "Count_ref", zau.geom 
	FROM public."cap_PLUs_zaus_202201" zau
	LEFT JOIN "F1_REN_EnvUrbaine_Logements"."_dataviz_logt_reference" ref
	ON ST_Intersects(zau.geom, ref.geom)
	GROUP BY zau.ttid, zau.libelle, zau.typezone, zau.destdomi, zau.geom
);
DROP INDEX IF EXISTS "F1_REN_EnvUrbaine_Logements"._temp_logt_zonesau_geom_idx;
CREATE INDEX _temp_logt_zonesau_geom_idx ON "F1_REN_EnvUrbaine_Logements"."_temp_logt_zonesau" USING GIST (geom);


-- Compte des logements à l'actualisation
DROP TABLE IF EXISTS "F1_REN_EnvUrbaine_Logements"._dataviz_logt_zonesau;
CREATE TABLE "F1_REN_EnvUrbaine_Logements"._dataviz_logt_zonesau AS (
	SELECT zau.ttid, zau.libelle, zau.typezone, zau.destdomi, zau."Count_ref", COALESCE(Count(actu.*), 0) "Count_actu", zau.geom 
	FROM "F1_REN_EnvUrbaine_Logements"._temp_logt_zonesau zau
	LEFT JOIN "F1_REN_EnvUrbaine_Logements"."_dataviz_logt_actualisation" actu
	ON ST_Intersects(zau.geom, actu.geom)
	GROUP BY zau.ttid, zau.libelle, zau.typezone, zau.destdomi, zau."Count_ref", zau.geom
);


--/--/--/--/--/--/--/--/--/--/--/--/--/--/-
--/--/--/--/-- POUR EXPORTS EPCI --/--/--/-
--/--/--/--/--/--/--/--/--/--/--/--/--/--/-

-- Zones AU 
DROP TABLE IF EXISTS "F1_REN_EnvUrbaine_Logements"._dataviz_densite_zonesau_EPCI;
CREATE TABLE "F1_REN_EnvUrbaine_Logements"._dataviz_densite_zonesau_EPCI AS (
	SELECT zau.*, terr.label typo
	FROM "F1_REN_EnvUrbaine_Logements"._dataviz_logt_zonesau zau
	LEFT JOIN public."territory_table_CAP20" terr
	ON ST_Intersects(terr.geom, ST_PointOnSurface(zau.geom))
	WHERE terr.rank = '2'
);

-- Logements simple affichage
DROP TABLE IF EXISTS "F1_REN_EnvUrbaine_Logements"._dataviz_logt_simple_affichage_epci;
CREATE TABLE "F1_REN_EnvUrbaine_Logements"._dataviz_logt_simple_affichage_epci AS (
	SELECT logt.*, terr.label typo
	FROM "F1_REN_EnvUrbaine_Logements"._dataviz_logt_simple_affichage logt
	LEFT JOIN public."territory_table_CAP20" terr
	ON ST_Intersects(terr.geom, logt.geom)
	WHERE terr.rank = '2'
);

-- Logements evolution
DROP TABLE IF EXISTS "F1_REN_EnvUrbaine_Logements"._dataviz_logt_evolution_epci;
CREATE TABLE "F1_REN_EnvUrbaine_Logements"._dataviz_logt_evolution_epci AS (
	SELECT logt.*, terr.label typo
	FROM "F1_REN_EnvUrbaine_Logements"._dataviz_logt_evolution logt
	LEFT JOIN public."territory_table_CAP20" terr
	ON ST_Intersects(terr.geom, logt.geom)
	WHERE terr.rank = '2'
);
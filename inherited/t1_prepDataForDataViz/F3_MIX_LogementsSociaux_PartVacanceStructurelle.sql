-- author : SIL

-- Attention, cet indicateur a besoin de l'information de vacances, qui n'est pas présente dans les RPLS détaillés en accès libre (colonne CodeModeOccupation). À partir de 2019, le site du SDES propose le téléchargement de données à la commune qui indiquent la vacance (https://www.statistiques.developpement-durable.gouv.fr/le-parc-locatif-social-au-1er-janvier-2019-0: "Données nationales : Régions, Départements, EPCI et communes - RPLS au 1er janvier 2019 (xls, 22.64 Mo) ")
-- Pour les années précédentes on peut trouver de l'info sur la vacance ici: http://www.bretagne.developpement-durable.gouv.fr/historique-des-principaux-indicateurs-rpls-en-a870.html

-- L'initialisation de l'indicateur avait été faite avec les données détaillées au logements, on ne peut pas réutiliser ce qui avait été fait mais on garde quand même les résultats déjà existants.
-- Je sais pas trop pourquoi mais visiblement il y a quelques différences dans les chiffres, par exemple là je vois qu'en 2019 le fichier global donne 3822 logements sociaux pour l'EPCI de Fougères, alors qu'avec le RPLS au logement j'en ai trouvé 3818.
-- Mais bon je me rend compte qu'il y a aussi des différences dans les deux indicateurs déjà initialisés sur TEREvAL (EPCI Fougères): 
--																	2013	2014	2015	2016
-- Évolution du nombre de logements sociaux loués ou vacants		3856	3740	3754	3754
-- Évolution du nombre de logements sociaux							3862	3748	3754	3754

-- Le jeu de données 2019 semble être en géométrie 2018, mais je ne retrouve pas toutes les communes. Par exemple: la commune de Val-Couesnon (35004) a été créée en 2019. On ne la retrouve pas, mais on ne retrouve que 2 des 4 communes qui ont fusionné pour former Val-Couesnon: Antrain et La Fontenelle, mais Tremblay et Saint-Ouen-la-Rouërie ne sont pas dans la liste alors qu'elles contiennent bien des logements sociaux. Pour autant j'ai l'impression que les totaux de ces communes sont quand même comptés dans la commmune d'Antrain, car le fichier RPLS national 2019 donne 122 logements pour Antrain, + 1 pour La Fontenelle, ce qui donne bien le total à 123 logements que l'on avait trouvé pour la commune nouvelle Val-Couesnon avec le RPLS détaillé.
-- Le jeu de donnée de la DREAL bretagne est déjà en géométrie 2019

-- On passe les jeux de données en csv et cogugaisonne le fichier 2019

-- Avant de commencer je met à jour la version de dataviz sinon y'en a pour 3 plombes avec le vieux modèle qui fait galérer à calculer les pourcentages en dur dans la table

--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/-
--/--/-- rpls_2013_a_2018_-_principaux_indicateurs_par_dep_commune_et_epci_.csv --/--/--
--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/-

DROP TABLE IF EXISTS "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2013_2018;
CREATE TABLE "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2013_2018 AS (
	SELECT rpls."Code zonage" insee, rpls."RPLS année N" as year, REPLACE(REPLACE(REPLACE(rpls."Proposé à la location et occupé",'/','0'),' ',''),'NR','0')::numeric "Logements sociaux loués", REPLACE(REPLACE(REPLACE(rpls."Nb de logts vacants de plus de 3 mois",'/','0'),' ',''),'NR','0')::numeric "Vacance structurelle (>3 mois)", REPLACE(REPLACE(REPLACE(rpls."Nb total logt vacants",'/','0'),' ',''),'NR','0')::numeric-REPLACE(REPLACE(REPLACE(rpls."Nb de logts vacants de plus de 3 mois",'/','0'),' ',''),'NR','0')::numeric "Vacance non structurelle", rpls."Occupé avec ou sans contrepartie financière"::numeric + rpls."Pris en charge par une association"::numeric + rpls."Vide"::numeric "Autres" 
	FROM "F3_MIX_LogementsSociaux_PartVacanceStructurelle"."rpls_2013_a_2018_-_principaux_indicateurs_par_dep_commune_et_ep" rpls 
	LEFT JOIN public."TerritoryTable_PF_2019" terr 
	ON rpls."Code zonage"::text = terr.id_geom
	WHERE terr.id_geom IS NOT NULL
	ORDER BY year
);

-- Ajout du total
ALTER TABLE "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2013_2018
DROP COLUMN IF EXISTS total;
ALTER TABLE "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2013_2018 
ADD COLUMN total float;
UPDATE "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2013_2018 
SET total = "Logements sociaux loués" + "Vacance structurelle (>3 mois)" + "Vacance non structurelle" + "Autres";
SELECT * FROM "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2013_2018;



-- Et ensuite il faut aggréger manuellement les résultats aux EPCI et au Territoire. Le plus simple est de refaire une jointure attributaire avec la table territoire: 

DROP TABLE IF EXISTS "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2013_2018_epci;
CREATE TABLE "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2013_2018_epci AS (
	SELECT a.*, b."TYPE_EPCI"
	FROM "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2013_2018 a
	LEFT JOIN ( -- SQ parce qu'il y a des "doublons" dans la table
		SELECT "INSEE_COM2", "TYPE_EPCI"
		FROM public."FOUGERES_Communes_EPCI_ante2019"
		GROUP BY "INSEE_COM2", "TYPE_EPCI"
	) b
	ON a.insee = b."INSEE_COM2"::text
	ORDER BY year
);

-- Et rajouter les valeurs avec les bons codes en faisant du Group by:
	-- Pour le SCoT
	INSERT INTO "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2013_2018_epci
	SELECT '248' insee, year, SUM("Logements sociaux loués") "Logements sociaux loués", SUM("Vacance structurelle (>3 mois)") "Vacance structurelle (>3 mois)", SUM("Vacance non structurelle") "Vacance non structurelle", SUM("Autres") "Autres", SUM(total) total
	FROM "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2013_2018_epci
	GROUP BY year
	ORDER BY year;

	-- Pour l'EPCI n°200070688
	INSERT INTO "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2013_2018_epci
	SELECT '200070688' insee, year, SUM("Logements sociaux loués") "Logements sociaux loués", SUM("Vacance structurelle (>3 mois)") "Vacance structurelle (>3 mois)", SUM("Vacance non structurelle") "Vacance non structurelle", SUM("Autres") "Autres", SUM(total) total
	FROM "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2013_2018_epci
	WHERE "TYPE_EPCI" LIKE 'CC Couesnon Marches de Bretagne'
	GROUP BY year
	ORDER BY year;

	-- Pour l'autre EPCI
	INSERT INTO "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2013_2018_epci
	SELECT '200072452' insee, year, SUM("Logements sociaux loués") "Logements sociaux loués", SUM("Vacance structurelle (>3 mois)") "Vacance structurelle (>3 mois)", SUM("Vacance non structurelle") "Vacance non structurelle", SUM("Autres") "Autres", SUM(total) total
	FROM "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2013_2018_epci
	WHERE "TYPE_EPCI" LIKE 'CA Fougères Agglomération'
	GROUP BY year
	ORDER BY year;

ALTER TABLE "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2013_2018_epci
DROP COLUMN IF EXISTS "TYPE_EPCI";
SELECT * FROM "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2013_2018_epci;


-- Finalement je décide de ne pas garder les résultats qui existaient déjà (pour les années 2013 à 2016), parce que je sais pas pourquoi on avait pas les mêmes chiffres que dans l'évolution du nombre de logements sociaux total, alors que là je retrouve bien les mêmes valeurs.


--/--/--/--/--/--/--/--/--/--/--/--/--/--
--/--/-- resultats-rpls-2019.csv --/--/--
--/--/--/--/--/--/--/--/--/--/--/--/--/--

-- Je prépare la data pour la cogugaisonner (supprimer les colonnes inutiles, supprimer tous les espaces pour que les nombres soient pas considérés comme du texte)
-- Convertir la sortie en UTF-8
-- On utilise ça pour la suite 'D:\_CLIENT\PF\_TRAVAIL\F3_MIX_LogementsSociaux_PartVacanceStructurelle\travail\02_output_cogugaison\resultats-rpls-2019'

-- STOP
-- En fait j'ai pas le nombre de logements vacants > 3 mois ici, j'ai le pourcentage uniquement. Mais je vois que je peux retrouver mes chiffres.
-- Par contre je peux pas cogugaisonner des pourcentages. Donc je vais recalculer mes colonnes dans l'Excel et je recogugaisonnerai tout ça après




DROP TABLE IF EXISTS "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2019;
CREATE TABLE "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2019 AS (
	SELECT rpls."Commune" insee, '2019' as year, rpls."loués"::numeric "Logements sociaux loués", rpls."vacant.plus.de.3.mois"::numeric "Vacance structurelle (>3 mois)", rpls."vacant.moins.de.3.mois"::numeric "Vacance non structurelle", rpls."vides"::numeric + rpls."pris.en.charge.par.une.association"::numeric + rpls."occupés.avec.ou.sans.contrepartie.financière"::numeric "Autres" 
	FROM "F3_MIX_LogementsSociaux_PartVacanceStructurelle"."resultats-rpls-2019" rpls
	LEFT JOIN public."TerritoryTable_PF_2019" terr 
	ON rpls."Commune"::text = terr.id_geom
	WHERE terr.id_geom IS NOT NULL
	ORDER BY year
);
SELECT * FROM "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2019;

-- Ajout du total
ALTER TABLE "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2019
DROP COLUMN IF EXISTS total;
ALTER TABLE "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2019 
ADD COLUMN total float;
UPDATE "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2019 
SET total = "Logements sociaux loués" + "Vacance structurelle (>3 mois)" + "Vacance non structurelle" + "Autres";
SELECT * FROM "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2019;


-- Et ensuite il faut aggréger manuellement les résultats aux EPCI et au Territoire. Le plus simple est de refaire une jointure attributaire avec la table territoire: 
DROP TABLE IF EXISTS "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2019_epci;
CREATE TABLE "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2019_epci AS (
	SELECT a.*, b."TYPE_EPCI"
	FROM "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2019 a
	LEFT JOIN ( -- SQ parce qu'il y a des "doublons" dans la table
		SELECT "INSEE_COM2", "TYPE_EPCI"
		FROM public."FOUGERES_Communes_EPCI_ante2019"
		GROUP BY "INSEE_COM2", "TYPE_EPCI"
	) b
	ON a.insee = b."INSEE_COM2"::text
	ORDER BY year
);

-- Et rajouter les valeurs avec les bons codes en faisant du Group by:
	-- Pour le SCoT
	INSERT INTO "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2019_epci
	SELECT '248' insee, year, SUM("Logements sociaux loués") "Logements sociaux loués", SUM("Vacance structurelle (>3 mois)") "Vacance structurelle (>3 mois)", SUM("Vacance non structurelle") "Vacance non structurelle", SUM("Autres") "Autres", SUM(total) total
	FROM "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2019_epci
	GROUP BY year
	ORDER BY year;

	-- Pour l'EPCI n°200070688
	INSERT INTO "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2019_epci
	SELECT '200070688' insee, year, SUM("Logements sociaux loués") "Logements sociaux loués", SUM("Vacance structurelle (>3 mois)") "Vacance structurelle (>3 mois)", SUM("Vacance non structurelle") "Vacance non structurelle", SUM("Autres") "Autres", SUM(total) total
	FROM "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2019_epci
	WHERE "TYPE_EPCI" LIKE 'CC Couesnon Marches de Bretagne'
	GROUP BY year
	ORDER BY year;

	-- Pour l'autre EPCI
	INSERT INTO "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2019_epci
	SELECT '200072452' insee, year, SUM("Logements sociaux loués") "Logements sociaux loués", SUM("Vacance structurelle (>3 mois)") "Vacance structurelle (>3 mois)", SUM("Vacance non structurelle") "Vacance non structurelle", SUM("Autres") "Autres", SUM(total) total
	FROM "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2019_epci
	WHERE "TYPE_EPCI" LIKE 'CA Fougères Agglomération'
	GROUP BY year
	ORDER BY year;

ALTER TABLE "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2019_epci
DROP COLUMN IF EXISTS "TYPE_EPCI";
SELECT * FROM "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2019_epci;


--/--/--/--/--/--/--/--/--/--/--/--/--/--
--/--/-- resultats-rpls-2020.csv --/--/--
--/--/--/--/--/--/--/--/--/--/--/--/--/--
DROP TABLE IF EXISTS "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2021;
CREATE TABLE "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2021 AS (
	SELECT rpls."Commune" insee, '2021' as year, REPLACE(rpls."loués", 'NA'::varchar, '0'::varchar)::numeric "Logements sociaux loués", REPLACE(rpls."vacant.plus.de.3.mois"::varchar, 'NA'::varchar, '0'::varchar)::numeric "Vacance structurelle (>3 mois)", REPLACE(rpls."vacant.moins.de.3.mois"::varchar, 'NA'::varchar, '0'::varchar)::numeric "Vacance non structurelle", REPLACE(rpls."vides"::varchar, 'NA'::varchar, '0'::varchar)::numeric + REPLACE(rpls."pris.en.charge.par.une.association"::varchar, 'NA'::varchar, '0'::varchar)::numeric + REPLACE(rpls."occupé.s.avec.ou.sans.contrepartie.financière"::varchar, 'NA'::varchar, '0'::varchar)::numeric "Autres" 
	FROM "F3_MIX_LogementsSociaux_PartVacanceStructurelle"."resultats-rpls-2021" rpls
	LEFT JOIN public."TerritoryTable_PF_2019" terr 
	ON rpls."Commune"::text = terr.id_geom
	WHERE terr.id_geom IS NOT NULL
	ORDER BY year
);
SELECT * FROM "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2021;

-- Ajout du total
ALTER TABLE "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2021
DROP COLUMN IF EXISTS total;
ALTER TABLE "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2021 
ADD COLUMN total float;
UPDATE "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2021
SET total = "Logements sociaux loués" + "Vacance structurelle (>3 mois)" + "Vacance non structurelle" + "Autres";
SELECT * FROM "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2021;


--- AGGREGATION aux echelles suppérieures
DROP TABLE IF EXISTS "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2021_final;
CREATE TABLE "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2021_final AS (
WITH t1 AS (
SELECT tt.id_geom insee,  tt.geom , '2021'::text as year,"Logements sociaux loués","Vacance structurelle (>3 mois)","Vacance non structurelle","Autres",total  FROM "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2021 cc
right JOIN public."TerritoryTable_PF_2019" tt
ON tt.id_geom = cc.insee 
WHERE tt.RANK = 1

),
	rank2 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."TerritoryTable_PF_2019"
			WHERE rank = 2
			GROUP BY id_geom
	),
	t2 as (
		select rank2.id_geom as insee,t1.year,sum("Logements sociaux loués") as "Logements sociaux loués",sum("Vacance structurelle (>3 mois)") as "Vacance structurelle (>3 mois)",sum("Vacance non structurelle") "Vacance non structurelle",sum("Autres") as "Autres",sum("total") as "total",
		rank2.geom
		from rank2
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank2.geom)
		GROUP BY rank2.id_geom, t1."year", rank2.geom
	),
		rank3 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."TerritoryTable_PF_2019"
			WHERE rank = 3
			GROUP BY id_geom
	),
	t3 as (
		select rank3.id_geom as insee,t1.year,sum("Logements sociaux loués") as "Logements sociaux loués",sum("Vacance structurelle (>3 mois)") as "Vacance structurelle (>3 mois)",sum("Vacance non structurelle") "Vacance non structurelle",sum("Autres") as "Autres",sum("total") as "total",
		rank3.geom
		from rank3
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank3.geom)
		GROUP BY rank3.id_geom, t1."year", rank3.geom
	)
	SELECT t1.insee,"year","Logements sociaux loués","Vacance structurelle (>3 mois)", "Vacance non structurelle", "Autres",total 
	FROM t1 --where year is not null
	UNION
	SELECT insee, "year","Logements sociaux loués","Vacance structurelle (>3 mois)", "Vacance non structurelle", "Autres",total  
	FROM t2 --where year is not null
	UNION 
	SELECT insee, "year","Logements sociaux loués","Vacance structurelle (>3 mois)", "Vacance non structurelle", "Autres",total  
	FROM t3-- where year is not null
	--UNION 
	--SELECT * FROM t4 where year is not null
	ORDER BY insee, "year"
	);

--//--//--//--//--//--//
-- Union des résultats sur plusieurs millésimes
--//--//--//--//--//--//

DROP TABLE IF EXISTS "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_total_2013_2021;
CREATE TABLE "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_total_2013_2021 AS (
	SELECT insee::text, year::text, COALESCE("Logements sociaux loués",0)::int "Logements sociaux loués", COALESCE("Vacance structurelle (>3 mois)",0)::int "Vacance structurelle (>3 mois)", COALESCE("Vacance non structurelle",0)::int "Vacance non structurelle", COALESCE("Autres",0)::NUMERIC "Autres", COALESCE(total,0)::INT total
	FROM "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2013_2020
	UNION ALL
	SELECT insee::text, year::text, COALESCE("Logements sociaux loués",0)::int "Logements sociaux loués", COALESCE("Vacance structurelle (>3 mois)",0)::int "Vacance structurelle (>3 mois)", COALESCE("Vacance non structurelle",0)::int "Vacance non structurelle", COALESCE("Autres",0)::NUMERIC "Autres", COALESCE(total,0)::INT total
	FROM "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_2021_final
	ORDER BY insee, year
);
SELECT * FROM "F3_MIX_LogementsSociaux_PartVacanceStructurelle".chiffres_cles_total_2013_2021
WHERE YEAR ='2021' AND length("insee")=5;

SELECT *  FROM public."TerritoryTable_PF_2019" tt
WHERE RANK = '1'




-- Résultat final: je comprend pas trop pourquoi j'ai des une 20aine de logements en "trop" au SCoT en 2018 & 2019
-- public


--!-- Valeurs a fixer par remplacement --!--
-- le nom du schema:		public

----------
-- 2010 --
----------

-- Importer la table dans le schema
DROP TABLE IF EXISTS "F3_HAB_Logements_Commences".sitadel_commences_2010;
CREATE TABLE "F3_HAB_Logements_Commences".sitadel_commences_2010 
("données" varchar,
 "nom_commune" varchar,
 "Nombre.de.logements.commencés.individuels.purs" real,
 "Nombre.de.logements.commencés.individuels.groupés" real,
 "Nombre.de.logements.commencés.collectifs" real,
 "Nombre.de.logements.commencés.en.résidence" real,
 "Total.nombre.de.logements" real);
 
COPY "F3_HAB_Logements_Commences".sitadel_commences_2010 
FROM 'C:\_Default_Run_Environment_Test\4_Results_Step_n2_DATA_COGugaison_2020\SitadelCommences\LOT_2021\dr-lgt-03_74035426700229_2010_2009.csv' 
DELIMITER ',' CSV HEADER ENCODING 'ISO885915';

-- On rajoute une colonne 'year'
ALTER TABLE "F3_HAB_Logements_Commences".sitadel_commences_2010 DROP COLUMN IF EXISTS year;
ALTER TABLE "F3_HAB_Logements_Commences".sitadel_commences_2010 ADD COLUMN year real;
UPDATE "F3_HAB_Logements_Commences".sitadel_commences_2010 SET year = 2010;

----------
-- 2011 --
----------

-- Importer la table dans le schema
DROP TABLE IF EXISTS "F3_HAB_Logements_Commences".sitadel_commences_2011;
CREATE TABLE "F3_HAB_Logements_Commences".sitadel_commences_2011 
("données" varchar,
 "nom_commune" varchar,
 "Nombre.de.logements.commencés.individuels.purs" real,
 "Nombre.de.logements.commencés.individuels.groupés" real,
 "Nombre.de.logements.commencés.collectifs" real,
 "Nombre.de.logements.commencés.en.résidence" real,
 "Total.nombre.de.logements" real);
 
COPY "F3_HAB_Logements_Commences".sitadel_commences_2011 
FROM 'C:\_Default_Run_Environment_Test\4_Results_Step_n2_DATA_COGugaison_2020\SitadelCommences\LOT_2021\dr-lgt-03_74035213445886_2011_2010.csv' 
DELIMITER ',' CSV HEADER ENCODING 'ISO885915';

-- On rajoute une colonne 'year'
ALTER TABLE "F3_HAB_Logements_Commences".sitadel_commences_2011 DROP COLUMN IF EXISTS year;
ALTER TABLE "F3_HAB_Logements_Commences".sitadel_commences_2011 ADD COLUMN year real;
UPDATE "F3_HAB_Logements_Commences".sitadel_commences_2011 SET year = 2011;



----------
-- 2010 --
----------

-- Importer la table dans le schema
DROP TABLE IF EXISTS "F3_HAB_Logements_Commences".sitadel_commences_2012;
CREATE TABLE "F3_HAB_Logements_Commences".sitadel_commences_2012 
("données" varchar,
 "nom_commune" varchar,
 "Nombre.de.logements.commencés.individuels.purs" real,
 "Nombre.de.logements.commencés.individuels.groupés" real,
 "Nombre.de.logements.commencés.collectifs" real,
 "Nombre.de.logements.commencés.en.résidence" real,
 "Total.nombre.de.logements" real);
 
COPY "F3_HAB_Logements_Commences".sitadel_commences_2012 
FROM 'C:\_Default_Run_Environment_Test\4_Results_Step_n2_DATA_COGugaison_2020\SitadelCommences\LOT_2021\dr-lgt-03_74034924686839_2012_2011.csv' 
DELIMITER ',' CSV HEADER ENCODING 'ISO885915';

-- On rajoute une colonne 'year'
ALTER TABLE "F3_HAB_Logements_Commences".sitadel_commences_2012 DROP COLUMN IF EXISTS year;
ALTER TABLE "F3_HAB_Logements_Commences".sitadel_commences_2012 ADD COLUMN year real;
UPDATE "F3_HAB_Logements_Commences".sitadel_commences_2012 SET year = 2012;


----------
-- 2011 --
----------

-- Importer la table dans le schema
DROP TABLE IF EXISTS "F3_HAB_Logements_Commences".sitadel_commences_2013;
CREATE TABLE "F3_HAB_Logements_Commences".sitadel_commences_2013 
("données" varchar,
 "nom_commune" varchar,
 "Nombre.de.logements.commencés.individuels.purs" real,
 "Nombre.de.logements.commencés.individuels.groupés" real,
 "Nombre.de.logements.commencés.collectifs" real,
 "Nombre.de.logements.commencés.en.résidence" real,
 "Total.nombre.de.logements" real);
 
COPY "F3_HAB_Logements_Commences".sitadel_commences_2013 
FROM 'C:\_Default_Run_Environment_Test\4_Results_Step_n2_DATA_COGugaison_2020\SitadelCommences\LOT_2021\dr-lgt-03_74034617831530_2013_2012.csv' 
DELIMITER ',' CSV HEADER ENCODING 'ISO885915';

-- On rajoute une colonne 'year'
ALTER TABLE "F3_HAB_Logements_Commences".sitadel_commences_2013 DROP COLUMN IF EXISTS year;
ALTER TABLE "F3_HAB_Logements_Commences".sitadel_commences_2013 ADD COLUMN year real;
UPDATE "F3_HAB_Logements_Commences".sitadel_commences_2013 SET year = 2013;



----------
-- 2012 --
----------

-- Importer la table dans le schema
DROP TABLE IF EXISTS "F3_HAB_Logements_Commences".sitadel_commences_2014;
CREATE TABLE "F3_HAB_Logements_Commences".sitadel_commences_2014 
("données" varchar,
 "nom_commune" varchar,
 "Nombre.de.logements.commencés.individuels.purs" real,
 "Nombre.de.logements.commencés.individuels.groupés" real,
 "Nombre.de.logements.commencés.collectifs" real,
 "Nombre.de.logements.commencés.en.résidence" real,
 "Total.nombre.de.logements" real);
 
COPY "F3_HAB_Logements_Commences".sitadel_commences_2014 
FROM 'C:\_Default_Run_Environment_Test\4_Results_Step_n2_DATA_COGugaison_2020\SitadelCommences\LOT_2021\dr-lgt-03_74033860911397_2014_2013.csv' 
DELIMITER ',' CSV HEADER ENCODING 'ISO885915';

-- On rajoute une colonne 'year'
ALTER TABLE "F3_HAB_Logements_Commences".sitadel_commences_2014 DROP COLUMN IF EXISTS year;
ALTER TABLE "F3_HAB_Logements_Commences".sitadel_commences_2014 ADD COLUMN year real;
UPDATE "F3_HAB_Logements_Commences".sitadel_commences_2014 SET year = 2014;



----------
-- 2013 --
----------

-- Importer la table dans le schema
DROP TABLE IF EXISTS "F3_HAB_Logements_Commences".sitadel_commences_2015;
CREATE TABLE "F3_HAB_Logements_Commences".sitadel_commences_2015 
("données" varchar,
 "nom_commune" varchar,
 "Nombre.de.logements.commencés.individuels.purs" real,
 "Nombre.de.logements.commencés.individuels.groupés" real,
 "Nombre.de.logements.commencés.collectifs" real,
 "Nombre.de.logements.commencés.en.résidence" real,
 "Total.nombre.de.logements" real);
 
COPY "F3_HAB_Logements_Commences".sitadel_commences_2015 
FROM 'C:\_Default_Run_Environment_Test\4_Results_Step_n2_DATA_COGugaison_2020\SitadelCommences\LOT_2021\dr-lgt-03_74032562821494_2015_2014.csv' 
DELIMITER ',' CSV HEADER ENCODING 'ISO885915';

-- On rajoute une colonne 'year'
ALTER TABLE "F3_HAB_Logements_Commences".sitadel_commences_2015 DROP COLUMN IF EXISTS year;
ALTER TABLE "F3_HAB_Logements_Commences".sitadel_commences_2015 ADD COLUMN year real;
UPDATE "F3_HAB_Logements_Commences".sitadel_commences_2015 SET year = 2015;



----------
-- 2016 --
----------

-- Importer la table dans le schema
DROP TABLE IF EXISTS "F3_HAB_Logements_Commences".sitadel_commences_2016;
CREATE TABLE "F3_HAB_Logements_Commences".sitadel_commences_2016 
("données" varchar,
 "nom_commune" varchar,
 "Nombre.de.logements.commencés.individuels.purs" real,
 "Nombre.de.logements.commencés.individuels.groupés" real,
 "Nombre.de.logements.commencés.collectifs" real,
 "Nombre.de.logements.commencés.en.résidence" real,
 "Total.nombre.de.logements" real);
 
COPY "F3_HAB_Logements_Commences".sitadel_commences_2016 
FROM 'C:\_Default_Run_Environment_Test\4_Results_Step_n2_DATA_COGugaison_2020\SitadelCommences\LOT_2021\dr-lgt-03_74032929581454_2016_2015.csv' 
DELIMITER ',' CSV HEADER ENCODING 'ISO885915';

-- On rajoute une colonne 'year'
ALTER TABLE "F3_HAB_Logements_Commences".sitadel_commences_2016 DROP COLUMN IF EXISTS year;
ALTER TABLE "F3_HAB_Logements_Commences".sitadel_commences_2016 ADD COLUMN year real;
UPDATE "F3_HAB_Logements_Commences".sitadel_commences_2016 SET year = 2016;



----------
-- 2017 --
----------

-- Importer la table dans le schema
DROP TABLE IF EXISTS "F3_HAB_Logements_Commences".sitadel_commences_2017;
CREATE TABLE "F3_HAB_Logements_Commences".sitadel_commences_2017 
("données" varchar,
 "nom_commune" varchar,
 "Nombre.de.logements.commencés.individuels.purs" real,
 "Nombre.de.logements.commencés.individuels.groupés" real,
 "Nombre.de.logements.commencés.collectifs" real,
 "Nombre.de.logements.commencés.en.résidence" real,
 "Total.nombre.de.logements" real);
 
COPY "F3_HAB_Logements_Commences".sitadel_commences_2017 
FROM 'C:\_Default_Run_Environment_Test\4_Results_Step_n2_DATA_COGugaison_2020\SitadelCommences\LOT_2021\dr-lgt-03_74030511555573_2017_2016.csv' 
DELIMITER ',' CSV HEADER ENCODING 'ISO885915';

-- On rajoute une colonne 'year'
ALTER TABLE "F3_HAB_Logements_Commences".sitadel_commences_2017 DROP COLUMN IF EXISTS year;
ALTER TABLE "F3_HAB_Logements_Commences".sitadel_commences_2017 ADD COLUMN year real;
UPDATE "F3_HAB_Logements_Commences".sitadel_commences_2017 SET year = 2017;



-- ----------
-- -- 2017 --
-- ----------

-- -- Importer la table dans le schema
-- DROP TABLE IF EXISTS "F3_HAB_Logements_Commences".sitadel_commences_2017;
-- CREATE TABLE "F3_HAB_Logements_Commences".sitadel_commences_2017 
-- ("données" varchar,
--  "nom_commune" varchar,
--  "Nombre.de.logements.commencés.individuels.purs" real,
--  "Nombre.de.logements.commencés.individuels.groupés" real,
--  "Nombre.de.logements.commencés.collectifs" real,
--  "Nombre.de.logements.commencés.en.résidence" real,
--  "Total.nombre.de.logements" real);
 
-- COPY "F3_HAB_Logements_Commences".sitadel_commences_2017 
-- FROM 'C:\_Default_Run_Environment_Test\4_Results_Step_n2_DATA_COGugaison_2020\SitadelCommences\LOT_2021\dr-lgt-03_74035426700229_2017_2016.csv' 
-- DELIMITER ',' CSV HEADER ENCODING 'ISO885915';

-- -- On rajoute une colonne 'year'
-- ALTER TABLE "F3_HAB_Logements_Commences".sitadel_commences_2017 DROP COLUMN IF EXISTS year;
-- ALTER TABLE "F3_HAB_Logements_Commences".sitadel_commences_2017 ADD COLUMN year real;
-- UPDATE "F3_HAB_Logements_Commences".sitadel_commences_2017 SET year = 2017;


----------
-- 2018 --
----------

-- Importer la table dans le schema
DROP TABLE IF EXISTS "F3_HAB_Logements_Commences".sitadel_commences_2018;
CREATE TABLE "F3_HAB_Logements_Commences".sitadel_commences_2018 
("données" varchar,
 "nom_commune" varchar,
 "Nombre.de.logements.commencés.individuels.purs" real,
 "Nombre.de.logements.commencés.individuels.groupés" real,
 "Nombre.de.logements.commencés.collectifs" real,
 "Nombre.de.logements.commencés.en.résidence" real,
 "Total.nombre.de.logements" real);
 
COPY "F3_HAB_Logements_Commences".sitadel_commences_2018 
FROM 'C:\_Default_Run_Environment_Test\4_Results_Step_n2_DATA_COGugaison_2020\SitadelCommences\LOT_2021\dr-lgt-03_74030291905777_2018_2017.csv' 
DELIMITER ',' CSV HEADER ENCODING 'ISO885915';

-- On rajoute une colonne 'year'
ALTER TABLE "F3_HAB_Logements_Commences".sitadel_commences_2018 DROP COLUMN IF EXISTS year;
ALTER TABLE "F3_HAB_Logements_Commences".sitadel_commences_2018 ADD COLUMN year real;
UPDATE "F3_HAB_Logements_Commences".sitadel_commences_2018 SET year = 2018;


----------
-- 2019 --
----------

-- Importer la table dans le schema
DROP TABLE IF EXISTS "F3_HAB_Logements_Commences".sitadel_commences_2019;
CREATE TABLE "F3_HAB_Logements_Commences".sitadel_commences_2019 
("données" varchar,
 "nom_commune" varchar,
 "Nombre.de.logements.commencés.individuels.purs" real,
 "Nombre.de.logements.commencés.individuels.groupés" real,
 "Nombre.de.logements.commencés.collectifs" real,
 "Nombre.de.logements.commencés.en.résidence" real,
 "Total.nombre.de.logements" real);
 
COPY "F3_HAB_Logements_Commences".sitadel_commences_2019 
FROM 'C:\_Default_Run_Environment_Test\4_Results_Step_n2_DATA_COGugaison_2020\SitadelCommences\LOT_2021\dr-lgt-03_74029718443089_2019_2018.csv' 
DELIMITER ',' CSV HEADER ENCODING 'ISO885915';

-- On rajoute une colonne 'year'
ALTER TABLE "F3_HAB_Logements_Commences".sitadel_commences_2019 DROP COLUMN IF EXISTS year;
ALTER TABLE "F3_HAB_Logements_Commences".sitadel_commences_2019 ADD COLUMN year real;
UPDATE "F3_HAB_Logements_Commences".sitadel_commences_2019 SET year = 2019;



-----------
-- UNION --
-----------

DROP TABLE IF EXISTS "F3_HAB_Logements_Commences".sitadel_commences_2010_2019;
CREATE TABLE "F3_HAB_Logements_Commences".sitadel_commences_2010_2019 AS (
	SELECT * FROM "F3_HAB_Logements_Commences".sitadel_commences_2010
	UNION ALL
	SELECT * FROM "F3_HAB_Logements_Commences".sitadel_commences_2011
	UNION ALL
	SELECT * FROM "F3_HAB_Logements_Commences".sitadel_commences_2012
	UNION ALL
	SELECT * FROM "F3_HAB_Logements_Commences".sitadel_commences_2013
	UNION ALL
	SELECT * FROM "F3_HAB_Logements_Commences".sitadel_commences_2014
	UNION ALL
	SELECT * FROM "F3_HAB_Logements_Commences".sitadel_commences_2015
	UNION ALL
	SELECT * FROM "F3_HAB_Logements_Commences".sitadel_commences_2016
	UNION ALL
	SELECT * FROM "F3_HAB_Logements_Commences".sitadel_commences_2017
	UNION ALL
	SELECT * FROM "F3_HAB_Logements_Commences".sitadel_commences_2018
	UNION ALL
	SELECT * FROM "F3_HAB_Logements_Commences".sitadel_commences_2019
	-- UNION ALL
	-- SELECT * FROM "F3_HAB_Logements_Commences".sitadel_commences_2018
	-- ORDER BY "données", "year"
);
SELECT * FROM "F3_HAB_Logements_Commences".sitadel_commences_2010_2019 LIMIT 100;



------------
-- CALCUL --
------------

DROP TABLE IF EXISTS "F3_HAB_Logements_Commences"."F3_HAB_LogementsCommences_LOT2021";
CREATE TABLE "F3_HAB_Logements_Commences"."F3_HAB_LogementsCommences_LOT2021" AS (
	-- Données à la commune
	WITH t1 AS ( 
		SELECT Table1.id_geom AS insee, Table0.year,
		Sum(COALESCE(Table0."Nombre.de.logements.commencés.individuels.purs"::real,0)) AS "Nombre d'individuels purs",
		Sum(COALESCE(Table0."Nombre.de.logements.commencés.individuels.groupés"::real,0)) AS "Nombre d'individuels groupés",
		Sum(COALESCE(Table0."Nombre.de.logements.commencés.collectifs"::real,0)) AS "Nombre de collectifs",
		Sum(COALESCE(Table0."Nombre.de.logements.commencés.en.résidence"::real,0)) AS "Nombre de résidences",
		Sum(COALESCE(Table0."Total.nombre.de.logements"::real,0)) AS "total",
		Table1.geom
		-- Jointure des données INSEE france entière sur la territory table
		FROM ( -- Données territoire
			SELECT label AS ColMaj, label, id_geom, geom
			FROM public."TerritoryTable_PF_2019" 
			GROUP BY ColMaj, label, id_geom, geom
		) AS Table1
		-- Données INSEE
		LEFT JOIN ( 
			SELECT "données" AS ColMaj,* FROM (
				SELECT * FROM "F3_HAB_Logements_Commences"."sitadel_commences_2010_2019"
				--WHERE ("données" LIKE '%35%')
			) z
		) AS Table0 
		ON Table0.ColMaj LIKE Table1.id_geom
		WHERE Table1.id_geom IS NOT NULL
		GROUP BY Table1.id_geom, Table0."year", Table1.geom
		ORDER BY Table0."year"
	),
	-- Géométries niveau 2 de la table territoire
	rank2 AS (
		SELECT id_geom, ST_Union(geom) geom
		FROM public."TerritoryTable_PF_2019"
		WHERE rank = 2
		GROUP BY id_geom
	),
	-- Données aux polarités
	t2 AS ( 
		SELECT rank2.id_geom insee, t1."year",
		Sum(COALESCE(t1."Nombre d'individuels purs"::real,0)) AS "Nombre d'individuels purs",
		Sum(COALESCE(t1."Nombre d'individuels groupés"::real,0)) AS "Nombre d'individuels groupés",
		Sum(COALESCE(t1."Nombre de collectifs"::real,0)) AS "Nombre de collectifs",
		Sum(COALESCE(t1."Nombre de résidences"::real,0)) AS "Nombre de résidences",
		Sum(COALESCE(t1."total"::real,0)) AS "total",
		rank2.geom geom
		FROM rank2
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank2.geom)
		GROUP BY rank2.id_geom, t1."year", rank2.geom
	),
	-- Géométries niveau 3 de la table territoire
	rank3 AS (
		SELECT id_geom, ST_Union(geom) geom
		FROM public."TerritoryTable_PF_2019"
		WHERE rank = 3
		GROUP BY id_geom
	),
	-- Données à l'EPCI
	t3 AS ( 
		SELECT rank3.id_geom insee, t1."year",
		Sum(COALESCE(t1."Nombre d'individuels purs"::real,0)) AS "Nombre d'individuels purs",
		Sum(COALESCE(t1."Nombre d'individuels groupés"::real,0)) AS "Nombre d'individuels groupés",
		Sum(COALESCE(t1."Nombre de collectifs"::real,0)) AS "Nombre de collectifs",
		Sum(COALESCE(t1."Nombre de résidences"::real,0)) AS "Nombre de résidences",
		Sum(COALESCE(t1."total"::real,0)) AS "total",
		rank3.geom geom
		FROM rank3
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank3.geom)
		
		GROUP BY rank3.id_geom, t1."year", rank3.geom
	 )--,
	-- -- Géométries niveau 4 de la table territoire
	-- rank4 AS (
	-- 	SELECT id_geom, ST_Union(geom) geom
	-- 	FROM public."TerritoryTable_PF_2019"
	-- 	WHERE rank = 4
	-- 	GROUP BY id_geom
	-- ),
	-- -- Données au territoire (bon il suffirait de faire un SUM de tout dans l'absolu)
	-- t4 AS (
	-- 	SELECT rank4.id_geom insee, t1."year",
	-- 	Sum(COALESCE(t1."Nombre d'individuels purs"::real,0)) AS "Nombre d'individuels purs",
	-- 	Sum(COALESCE(t1."Nombre d'individuels groupés"::real,0)) AS "Nombre d'individuels groupés",
	-- 	Sum(COALESCE(t1."Nombre de collectifs"::real,0)) AS "Nombre de collectifs",
	-- 	Sum(COALESCE(t1."Nombre de résidences"::real,0)) AS "Nombre de résidences",
	-- 	Sum(COALESCE(t1."total"::real,0)) AS "total",
	-- 	rank4.geom geom
	-- 	FROM t1, rank4
	-- 	WHERE t1.insee IN (
	-- 		SELECT terr1.id_geom
	-- 		FROM public."TerritoryTable_PF_2019" terr1, rank4
	-- 		WHERE ST_Intersects(ST_PointOnSurface(terr1.geom),rank4.geom)
	-- 			AND terr1.rank = 1
	-- 	)
	-- 	GROUP BY rank4.id_geom, t1."year", rank4.geom
	-- )
	SELECT insee::varchar, "year"::varchar , "Nombre d'individuels purs"::integer,"Nombre d'individuels groupés"::integer,"Nombre de collectifs"::integer,"Nombre de résidences"::integer,"total"::integer FROM t1
	where "year" is not null and year < 2019
	UNION
	SELECT insee::varchar, "year"::varchar , "Nombre d'individuels purs"::integer,"Nombre d'individuels groupés"::integer,"Nombre de collectifs"::integer,"Nombre de résidences"::integer,"total"::integer FROM t2
	where "year" is not null and year < 2019
	UNION 
	SELECT insee::varchar, "year"::varchar , "Nombre d'individuels purs"::integer,"Nombre d'individuels groupés"::integer,"Nombre de collectifs"::integer,"Nombre de résidences"::integer,"total"::integer FROM t3
	where "year" is not null and year < 2019
	-- UNION 
	-- SELECT * FROM t4
	ORDER BY insee, "year"
); 
SELECT * FROM "F3_HAB_Logements_Commences"."F3_HAB_LogementsCommences_LOT2021"

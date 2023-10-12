-- F3_HAB_LogementsAutorises


--!-- Valeurs a fixer par remplacement --!--
-- le nom du schema:		F3_HAB_LogementsAutorises
-- le nom de la table 		bpe18_ensemble


----------
-- 2010 --
----------

-- Importer la table dans le schema
DROP TABLE IF EXISTS "F3_HAB_LogementsAutorises".sitadel_autorises_2010;
CREATE TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2010 
("données" varchar,
 "nom_commune" varchar,
 "Nombre.de.logements.autorisés.individuels.purs" real,
 "Nombre.de.logements.autorisés.individuels.groupés" real,
 "Nombre.de.logements.autorisés.collectifs" real,
 "Nombre.de.logements.autorisés.en.résidence" real,
 "Total.nombre.de.logements" real);
 
COPY "F3_HAB_LogementsAutorises".sitadel_autorises_2010 
FROM 'D:\_Default_Run_Environment_Test\4_Results_Step_n2_DATA_COGugaison_2019\SitadelAutorises\LogementsSitadel_Autorises_DateReelle_2010_2009.csv' 
DELIMITER ',' CSV HEADER ENCODING 'ISO885915';

-- On rajoute une colonne 'year'
ALTER TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2010 DROP COLUMN IF EXISTS year;
ALTER TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2010 ADD COLUMN year real;
UPDATE "F3_HAB_LogementsAutorises".sitadel_autorises_2010 SET year = 2010;


----------
-- 2011 --
----------

-- Importer la table dans le schema
DROP TABLE IF EXISTS "F3_HAB_LogementsAutorises".sitadel_autorises_2011;
CREATE TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2011 
("données" varchar,
 "nom_commune" varchar,
 "Nombre.de.logements.autorisés.individuels.purs" real,
 "Nombre.de.logements.autorisés.individuels.groupés" real,
 "Nombre.de.logements.autorisés.collectifs" real,
 "Nombre.de.logements.autorisés.en.résidence" real,
 "Total.nombre.de.logements" real);
 
COPY "F3_HAB_LogementsAutorises".sitadel_autorises_2011 
FROM 'D:\_Default_Run_Environment_Test\4_Results_Step_n2_DATA_COGugaison_2019\SitadelAutorises\LogementsSitadel_Autorises_DateReelle_2011_2010.csv' 
DELIMITER ',' CSV HEADER ENCODING 'ISO885915';

-- On rajoute une colonne 'year'
ALTER TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2011 DROP COLUMN IF EXISTS year;
ALTER TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2011 ADD COLUMN year real;
UPDATE "F3_HAB_LogementsAutorises".sitadel_autorises_2011 SET year = 2011;



----------
-- 2012 --
----------

-- Importer la table dans le schema
DROP TABLE IF EXISTS "F3_HAB_LogementsAutorises".sitadel_autorises_2012;
CREATE TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2012 
("données" varchar,
 "nom_commune" varchar,
 "Nombre.de.logements.autorisés.individuels.purs" real,
 "Nombre.de.logements.autorisés.individuels.groupés" real,
 "Nombre.de.logements.autorisés.collectifs" real,
 "Nombre.de.logements.autorisés.en.résidence" real,
 "Total.nombre.de.logements" real);
 
COPY "F3_HAB_LogementsAutorises".sitadel_autorises_2012 
FROM 'D:\_Default_Run_Environment_Test\4_Results_Step_n2_DATA_COGugaison_2019\SitadelAutorises\LogementsSitadel_Autorises_DateReelle_2012_2011.csv' 
DELIMITER ',' CSV HEADER ENCODING 'ISO885915';

-- On rajoute une colonne 'year'
ALTER TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2012 DROP COLUMN IF EXISTS year;
ALTER TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2012 ADD COLUMN year real;
UPDATE "F3_HAB_LogementsAutorises".sitadel_autorises_2012 SET year = 2012;



----------
-- 2013 --
----------

-- Importer la table dans le schema
DROP TABLE IF EXISTS "F3_HAB_LogementsAutorises".sitadel_autorises_2013;
CREATE TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2013 
("données" varchar,
 "nom_commune" varchar,
 "Nombre.de.logements.autorisés.individuels.purs" real,
 "Nombre.de.logements.autorisés.individuels.groupés" real,
 "Nombre.de.logements.autorisés.collectifs" real,
 "Nombre.de.logements.autorisés.en.résidence" real,
 "Total.nombre.de.logements" real);
 
COPY "F3_HAB_LogementsAutorises".sitadel_autorises_2013 
FROM 'D:\_Default_Run_Environment_Test\4_Results_Step_n2_DATA_COGugaison_2019\SitadelAutorises\LogementsSitadel_Autorises_DateReelle_2013_2012.csv' 
DELIMITER ',' CSV HEADER ENCODING 'ISO885915';

-- On rajoute une colonne 'year'
ALTER TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2013 DROP COLUMN IF EXISTS year;
ALTER TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2013 ADD COLUMN year real;
UPDATE "F3_HAB_LogementsAutorises".sitadel_autorises_2013 SET year = 2013;



----------
-- 2014 --
----------

-- Importer la table dans le schema
DROP TABLE IF EXISTS "F3_HAB_LogementsAutorises".sitadel_autorises_2014;
CREATE TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2014 
("données" varchar,
 "nom_commune" varchar,
 "Nombre.de.logements.autorisés.individuels.purs" real,
 "Nombre.de.logements.autorisés.individuels.groupés" real,
 "Nombre.de.logements.autorisés.collectifs" real,
 "Nombre.de.logements.autorisés.en.résidence" real,
 "Total.nombre.de.logements" real);
 
COPY "F3_HAB_LogementsAutorises".sitadel_autorises_2014 
FROM 'D:\_Default_Run_Environment_Test\4_Results_Step_n2_DATA_COGugaison_2019\SitadelAutorises\LogementsSitadel_Autorises_DateReelle_2014_2013.csv' 
DELIMITER ',' CSV HEADER ENCODING 'ISO885915';

-- On rajoute une colonne 'year'
ALTER TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2014 DROP COLUMN IF EXISTS year;
ALTER TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2014 ADD COLUMN year real;
UPDATE "F3_HAB_LogementsAutorises".sitadel_autorises_2014 SET year = 2014;



----------
-- 2015 --
----------

-- Importer la table dans le schema
DROP TABLE IF EXISTS "F3_HAB_LogementsAutorises".sitadel_autorises_2015;
CREATE TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2015 
("données" varchar,
 "nom_commune" varchar,
 "Nombre.de.logements.autorisés.individuels.purs" real,
 "Nombre.de.logements.autorisés.individuels.groupés" real,
 "Nombre.de.logements.autorisés.collectifs" real,
 "Nombre.de.logements.autorisés.en.résidence" real,
 "Total.nombre.de.logements" real);
 
COPY "F3_HAB_LogementsAutorises".sitadel_autorises_2015 
FROM 'D:\_Default_Run_Environment_Test\4_Results_Step_n2_DATA_COGugaison_2019\SitadelAutorises\LogementsSitadel_Autorises_DateReelle_2015_2014.csv' 
DELIMITER ',' CSV HEADER ENCODING 'ISO885915';

-- On rajoute une colonne 'year'
ALTER TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2015 DROP COLUMN IF EXISTS year;
ALTER TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2015 ADD COLUMN year real;
UPDATE "F3_HAB_LogementsAutorises".sitadel_autorises_2015 SET year = 2015;



----------
-- 2016 --
----------

-- Importer la table dans le schema
DROP TABLE IF EXISTS "F3_HAB_LogementsAutorises".sitadel_autorises_2016;
CREATE TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2016 
("données" varchar,
 "nom_commune" varchar,
 "Nombre.de.logements.autorisés.individuels.purs" real,
 "Nombre.de.logements.autorisés.individuels.groupés" real,
 "Nombre.de.logements.autorisés.collectifs" real,
 "Nombre.de.logements.autorisés.en.résidence" real,
 "Total.nombre.de.logements" real);
 
COPY "F3_HAB_LogementsAutorises".sitadel_autorises_2016 
FROM 'D:\_Default_Run_Environment_Test\4_Results_Step_n2_DATA_COGugaison_2019\SitadelAutorises\LogementsSitadel_Autorises_DateReelle_2016_2015.csv' 
DELIMITER ',' CSV HEADER ENCODING 'ISO885915';

-- On rajoute une colonne 'year'
ALTER TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2016 DROP COLUMN IF EXISTS year;
ALTER TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2016 ADD COLUMN year real;
UPDATE "F3_HAB_LogementsAutorises".sitadel_autorises_2016 SET year = 2016;


----------
-- 2017 --
----------

-- Importer la table dans le schema
DROP TABLE IF EXISTS "F3_HAB_LogementsAutorises".sitadel_autorises_2017;
CREATE TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2017 
("données" varchar,
 "nom_commune" varchar,
 "Nombre.de.logements.autorisés.individuels.purs" real,
 "Nombre.de.logements.autorisés.individuels.groupés" real,
 "Nombre.de.logements.autorisés.collectifs" real,
 "Nombre.de.logements.autorisés.en.résidence" real,
 "Total.nombre.de.logements" real);
 
COPY "F3_HAB_LogementsAutorises".sitadel_autorises_2017 
FROM 'D:\_Default_Run_Environment_Test\4_Results_Step_n2_DATA_COGugaison_2019\SitadelAutorises\LogementsSitadel_Autorises_DateReelle_2017_2016.csv' 
DELIMITER ',' CSV HEADER ENCODING 'ISO885915';

-- On rajoute une colonne 'year'
ALTER TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2017 DROP COLUMN IF EXISTS year;
ALTER TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2017 ADD COLUMN year real;
UPDATE "F3_HAB_LogementsAutorises".sitadel_autorises_2017 SET year = 2017;


----------
-- 2018 --
----------

-- Importer la table dans le schema
DROP TABLE IF EXISTS "F3_HAB_LogementsAutorises".sitadel_autorises_2018;
CREATE TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2018 
("données" varchar,
 "nom_commune" varchar,
 "Nombre.de.logements.autorisés.individuels.purs" real,
 "Nombre.de.logements.autorisés.individuels.groupés" real,
 "Nombre.de.logements.autorisés.collectifs" real,
 "Nombre.de.logements.autorisés.en.résidence" real,
 "Total.nombre.de.logements" real);
 
COPY "F3_HAB_LogementsAutorises".sitadel_autorises_2018 
FROM 'D:\_Default_Run_Environment_Test\4_Results_Step_n2_DATA_COGugaison_2019\SitadelAutorises\LogementsSitadel_Autorises_DateReelle_2018_2017.csv' 
DELIMITER ',' CSV HEADER ENCODING 'ISO885915';

-- On rajoute une colonne 'year'
ALTER TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2018 DROP COLUMN IF EXISTS year;
ALTER TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2018 ADD COLUMN year real;
UPDATE "F3_HAB_LogementsAutorises".sitadel_autorises_2018 SET year = 2018;


----------
-- 2019 --
----------

-- Importer la table dans le schema
DROP TABLE IF EXISTS "F3_HAB_LogementsAutorises".sitadel_autorises_2019;
CREATE TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2019 
("données" varchar,
 "nom_commune" varchar,
 "Nombre.de.logements.autorisés.individuels.purs" real,
 "Nombre.de.logements.autorisés.individuels.groupés" real,
 "Nombre.de.logements.autorisés.collectifs" real,
 "Nombre.de.logements.autorisés.en.résidence" real,
 "Total.nombre.de.logements" real);
 
COPY "F3_HAB_LogementsAutorises".sitadel_autorises_2019 
FROM 'D:\_Default_Run_Environment_Test\4_Results_Step_n2_DATA_COGugaison_2019\SitadelAutorises\LogementsSitadel_Autorises_DateReelle_2019_2018.csv' 
DELIMITER ',' CSV HEADER ENCODING 'ISO885915';

-- On rajoute une colonne 'year'
ALTER TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2019 DROP COLUMN IF EXISTS year;
ALTER TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2019 ADD COLUMN year real;
UPDATE "F3_HAB_LogementsAutorises".sitadel_autorises_2019 SET year = 2019;


-----------
-- UNION --
-----------

DROP TABLE IF EXISTS "F3_HAB_LogementsAutorises".sitadel_autorises_2010_2019;
CREATE TABLE "F3_HAB_LogementsAutorises".sitadel_autorises_2010_2019 AS (
	SELECT * FROM "F3_HAB_LogementsAutorises".sitadel_autorises_2010
	UNION ALL
	SELECT * FROM "F3_HAB_LogementsAutorises".sitadel_autorises_2011
	UNION ALL
	SELECT * FROM "F3_HAB_LogementsAutorises".sitadel_autorises_2012
	UNION ALL
	SELECT * FROM "F3_HAB_LogementsAutorises".sitadel_autorises_2013
	UNION ALL
	SELECT * FROM "F3_HAB_LogementsAutorises".sitadel_autorises_2014
	UNION ALL
	SELECT * FROM "F3_HAB_LogementsAutorises".sitadel_autorises_2015
	UNION ALL
	SELECT * FROM "F3_HAB_LogementsAutorises".sitadel_autorises_2016
	UNION ALL
	SELECT * FROM "F3_HAB_LogementsAutorises".sitadel_autorises_2017
	UNION ALL
	SELECT * FROM "F3_HAB_LogementsAutorises".sitadel_autorises_2018
	UNION ALL
	SELECT * FROM "F3_HAB_LogementsAutorises".sitadel_autorises_2019
	ORDER BY "données", "year"
);
SELECT * FROM "F3_HAB_LogementsAutorises".sitadel_autorises_2011_2020 LIMIT 100;



------------
-- CALCUL --
------------

DROP TABLE IF EXISTS "F3_HAB_LogementsAutorises"."F3_HAB_LogementsAutorises_LOT2020";
CREATE TABLE "F3_HAB_LogementsAutorises"."F3_HAB_LogementsAutorises_LOT2020" AS (
	-- Données à la commune
	WITH t1 AS ( 
		SELECT x.id_geom AS insee, x."year",
		Sum(COALESCE("Nombre d'individuels purs"::real,0)) AS "Nombre d'individuels purs",
		Sum(COALESCE("Nombre d'individuels groupés"::real,0)) AS "Nombre d'individuels groupés",
		Sum(COALESCE("Nombre de collectifs"::real,0)) AS "Nombre de collectifs",
		Sum(COALESCE("Nombre de résidences"::real,0)) AS "Nombre de résidences",
		Sum(COALESCE("total"::real,0)) AS "total",
		x.geom geom
		FROM (
			SELECT Table0.*,Table1.label,Table1.id_geom,
			"Nombre.de.logements.autorisés.individuels.purs" AS "Nombre d'individuels purs",
			"Nombre.de.logements.autorisés.individuels.groupés" AS "Nombre d'individuels groupés",
			"Nombre.de.logements.autorisés.collectifs" AS "Nombre de collectifs",
			"Nombre.de.logements.autorisés.en.résidence" AS "Nombre de résidences",
			"Total.nombre.de.logements" AS "total",
			geom
			FROM (
				SELECT label AS ColMaj,label,id_geom,geom
				FROM "TerritoryTable_PF_2019" 
				GROUP BY ColMaj,label,id_geom,geom
				) AS Table1
			LEFT JOIN (
				SELECT "données" AS ColMaj,*
				FROM "F3_HAB_LogementsAutorises"."sitadel_autorises_2011_2020"
				) AS Table0 ON Table0.ColMaj LIKE Table1.id_geom
			WHERE Table1.label IS NOT NULL
		) x
		WHERE x."year" is not NULL 
		GROUP BY x.label,x.id_geom,x."year",x.geom
		ORDER BY x."year"
	),
	-- Géométries niveau 2 de la table territoire
	rank2 AS (
		SELECT id_geom, ST_Union(geom) geom
		FROM "TerritoryTable_PF_2019"
		WHERE rank = '2'
		GROUP BY id_geom
	),
	-- Données à l'EPCI
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
		FROM "TerritoryTable_PF_2019"
		WHERE rank = '3'
		GROUP BY id_geom
	),
	-- Données au territoire (bon il suffirait de faire un SUM de tout dans l'absolu)
	t3 AS (
		SELECT rank3.id_geom insee, t1."year",
		Sum(COALESCE(t1."Nombre d'individuels purs"::real,0)) AS "Nombre d'individuels purs",
		Sum(COALESCE(t1."Nombre d'individuels groupés"::real,0)) AS "Nombre d'individuels groupés",
		Sum(COALESCE(t1."Nombre de collectifs"::real,0)) AS "Nombre de collectifs",
		Sum(COALESCE(t1."Nombre de résidences"::real,0)) AS "Nombre de résidences",
		Sum(COALESCE(t1."total"::real,0)) AS "total",
		rank3.geom geom
		FROM t1, rank3
		WHERE t1.insee IN (
			SELECT terr1.id_geom
			FROM "TerritoryTable_PF_2019" terr1, rank3
			WHERE ST_Intersects(ST_PointOnSurface(terr1.geom),rank3.geom)
				AND terr1.rank = '1'
		)
		GROUP BY rank3.id_geom, t1."year", rank3.geom
	)
	SELECT insee::varchar, "year"::varchar , "Nombre d'individuels purs"::integer,"Nombre d'individuels groupés"::integer,"Nombre de collectifs"::integer,"Nombre de résidences"::integer,"total"::integer  FROM t1
	where year < 2020
	UNION
	SELECT insee::varchar, "year"::varchar , "Nombre d'individuels purs"::integer,"Nombre d'individuels groupés"::integer,"Nombre de collectifs"::integer,"Nombre de résidences"::integer,"total"::integer  FROM t2
	where year < 2020
	UNION 
	SELECT insee::varchar, "year"::varchar , "Nombre d'individuels purs"::integer,"Nombre d'individuels groupés"::integer,"Nombre de collectifs"::integer,"Nombre de résidences"::integer,"total"::integer  FROM t3
	where year < 2020
	ORDER BY insee, "year"
); 

SELECT * FROM "F3_HAB_LogementsAutorises"."F3_HAB_LogementsAutorises_LOT2020";
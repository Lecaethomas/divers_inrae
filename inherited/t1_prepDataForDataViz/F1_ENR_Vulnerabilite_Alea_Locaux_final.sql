
/* Pr�paration logements */

-- locaux de r�f�rence "jannath < 2010" avec un type local in ('1','2') 

DROP TABLE IF EXISTS "F1_ENR_Vulnerabilite_Alea_Locaux"."dataviz_local_reference";
CREATE TABLE "F1_ENR_Vulnerabilite_Alea_Locaux"."dataviz_local_reference" AS (
	SELECT *
	FROM "ff_2018_PST".fftp_2018_pb0010_local
	WHERE jannath < 2010 AND dteloc IN ('1','2')
);
-- index
CREATE INDEX dataviz_local_reference_geom_idx
  ON  "F1_ENR_Vulnerabilite_Alea_Locaux"."dataviz_local_reference"
  USING GIST (geomloc);
--locaux WHERE jannath < 2017, ce sont les locaux � date d'actualisation.

DROP TABLE IF EXISTS "F1_ENR_Vulnerabilite_Alea_Locaux"."dataviz_local_actualisation";
CREATE TABLE "F1_ENR_Vulnerabilite_Alea_Locaux"."dataviz_local_actualisation" AS (
	SELECT *
	FROM "ff_2018_PST".fftp_2018_pb0010_local
	WHERE jannath < 2017 AND dteloc IN ('1','2')
);
--index 
CREATE INDEX dataviz_local_actualisation_geom_idx
  ON  "F1_ENR_Vulnerabilite_Alea_Locaux"."dataviz_local_actualisation"
USING GIST (geomloc);

-- locaux WHERE jannath = 2010, ce sont les logements nouvellement produits.

DROP TABLE IF EXISTS "F1_ENR_Vulnerabilite_Alea_Locaux"."dataviz_local_evolution";
CREATE TABLE "F1_ENR_Vulnerabilite_Alea_Locaux"."dataviz_local_evolution" AS (
	SELECT *
	FROM "ff_2018_PST".fftp_2018_pb0010_local
	WHERE jannath = 2010 AND dteloc IN ('1','2')
);
--index 
CREATE INDEX dataviz_local_evolution_geom_idx
  ON  "F1_ENR_Vulnerabilite_Alea_Locaux"."dataviz_local_evolution"
USING GIST (geomloc);

-- locaux WHERE jannath > 2016 pour simple affichage
DROP TABLE IF EXISTS "F1_ENR_Vulnerabilite_Alea_Locaux"."dataviz_local_simple_affichage";
CREATE TABLE "F1_ENR_Vulnerabilite_Alea_Locaux"."dataviz_local_simple_affichage" AS (
	SELECT *
	FROM "ff_2018_PST".fftp_2018_pb0010_local
	WHERE jannath > 2016 AND dteloc IN ('1','2')
);

/*Chiffres cl�s locaux */

/* 
 *  Pour ne pas se planter dans les calculs de chiffres cl�s IN/OUT, le plus simple est de cr�er une 1�re table
 *  avec uniquement les logements IN par territoire. Puis y ajouter le nombre total de logements par territoire.
 *  Et enfin obtenir le nombre de logements OUT par soustraction des deux colonnes pr�c�dentes. 
 * (Au d�but j'�tais parti sur qq chose genre
 *  "SELECT * WHERE ST_Intersects(env_urbaine) + SELECT * WHERE NOT ST_Intersects(env_urbaine)", 
 * mais selon les g�om�tries, les cas particuliers, les points en dehors du territoire, y'a un risque de se planter. 
 * L� �a tient la route partout.
*/

DROP TABLE IF EXISTS "F1_ENR_Vulnerabilite_Alea_Locaux".chiffres_cles_reference;

CREATE TABLE "F1_ENR_Vulnerabilite_Alea_Locaux".chiffres_cles_reference AS (
	-- Nombre total de locaux par commune. Les communes sans locaux n'apparaitront pas dans la table finale
	WITH total_by_com AS ( 
		SELECT t.id_geom as id_geom, Count(loc.geomloc) "Count_ENTITIES"
		FROM "F1_ENR_Vulnerabilite_Alea_Locaux"."dataviz_local_reference" loc, public."TerritoryTable_PST_2019_maj_2020" t
		WHERE ST_Intersects(loc.geomloc,t.geom)
		GROUP BY t.id_geom
	),
	-- Nombre de locaux dans la centralit� par commune
	total_by_com_in_zone AS (
		select t.id_geom as id_geom,zona.nivalea as nivalea, count(loc.geomloc) "Count_ENTITIES",'IN'::text "Location" from 
		"F1_ENR_Vulnerabilite_Alea_Locaux"."zone_alea_pprn_s_PST_decoupee" zona  ,
		"F1_ENR_Vulnerabilite_Alea_Locaux".dataviz_local_reference loc,
		"public"."TerritoryTable_PST_2019_maj_2020" t
		where ST_intersects(loc.geomloc,t.geom) and st_intersects(loc.geomloc,zona.geom)
		group by t.id_geom, zona.nivalea ,"Location" 
	),
	-- Nombre de locaux hors centralit�s par commune
	total_by_com_out_zone AS (
		SELECT total_by_com.id_geom as id_geom, total_by_com_in_zone.nivalea , SUM(total_by_com."Count_ENTITIES" - total_by_com_in_zone."Count_ENTITIES") "Count_ENTITIES", 'OUT'::text "Location"
		FROM total_by_com, total_by_com_in_zone
		WHERE total_by_com.id_geom = total_by_com_in_zone.id_geom
		GROUP BY total_by_com.id_geom, total_by_com_in_zone."nivalea", "Location"
		UNION 
		-- �a c'est pour g�rer les communes qui auraient des locaux, mais aucun dans le p�rim�tre de centralit�
		-- Attention � cette �tape, si la commune est multi-partie on aura sans doute un probl�me
		SELECT total_by_com.id_geom as id_geom, total_by_com_in_zone."nivalea", total_by_com."Count_ENTITIES" "Count_ENTITIES", 'OUT'::text "Location"
		FROM total_by_com, total_by_com_in_zone
		WHERE total_by_com.id_geom NOT IN (SELECT id_geom FROM total_by_com_in_zone)
		GROUP BY total_by_com.id_geom, total_by_com_in_zone."nivalea", total_by_com."Count_ENTITIES", "Location"
	)
	-- Union par commune du nombre de locaux dans/hors la centralit�
	SELECT id_geom::text, "nivalea"::text, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_in_zone
	UNION
	SELECT id_geom::text, "nivalea"::text, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_out_zone
	ORDER BY id_geom, "Location"
);

-- verif
-- SELECT * FROM "F1_ENR_Vulnerabilite_Alea_Locaux".chiffres_cles_reference;

/*Chiffres cl�s actualisation */
DROP TABLE IF EXISTS "F1_ENR_Vulnerabilite_Alea_Locaux".chiffres_cles_actualisation;

CREATE TABLE "F1_ENR_Vulnerabilite_Alea_Locaux".chiffres_cles_actualisation AS (
	-- Nombre total de locaux par commune. Les communes sans locaux n'apparaitront pas dans la table finale
	WITH total_by_com AS ( 
		SELECT t.id_geom id_geom, Count(loc.geomloc) "Count_ENTITIES"
		FROM "F1_ENR_Vulnerabilite_Alea_Locaux"."dataviz_local_actualisation" loc, public."TerritoryTable_PST_2019_maj_2020" t
		WHERE ST_Intersects(loc.geomloc,t.geom)
		GROUP BY id_geom
	),
	-- Nombre de locaux dans la centralit� par commune
	total_by_com_in_zone AS (
		select t.id_geom  id_geom,zona.nivalea as nivalea, count(loc.geomloc) "Count_ENTITIES",'IN'::text "Location" from 
		"F1_ENR_Vulnerabilite_Alea_Locaux"."zone_alea_pprn_s_PST_decoupee" zona  ,
		"F1_ENR_Vulnerabilite_Alea_Locaux".dataviz_local_actualisation loc,
		"public"."TerritoryTable_PST_2019_maj_2020" t
		where ST_intersects(loc.geomloc,t.geom) and st_intersects(loc.geomloc,zona.geom)
		group by t.id_geom, zona.nivalea ,"Location" 
	),
	-- Nombre de locaux hors centralit�s par commune
	total_by_com_out_zone AS (
		SELECT total_by_com.id_geom id_geom, total_by_com_in_zone.nivalea , SUM(total_by_com."Count_ENTITIES" - total_by_com_in_zone."Count_ENTITIES") "Count_ENTITIES", 'OUT'::text "Location"
		FROM total_by_com, total_by_com_in_zone
		WHERE total_by_com.id_geom = total_by_com_in_zone.id_geom
		GROUP BY total_by_com.id_geom, total_by_com_in_zone."nivalea", "Location"
		UNION 
		-- �a c'est pour g�rer les communes qui auraient des locaux, mais aucun dans le p�rim�tre de centralit�
		-- Attention � cette �tape, si la commune est multi-partie on aura sans doute un probl�me
		SELECT total_by_com.id_geom id_geom, total_by_com_in_zone."nivalea", total_by_com."Count_ENTITIES" "Count_ENTITIES", 'OUT'::text "Location"
		FROM total_by_com, total_by_com_in_zone
		WHERE total_by_com.id_geom NOT IN (SELECT id_geom FROM total_by_com_in_zone)
		GROUP BY total_by_com.id_geom, total_by_com_in_zone."nivalea", total_by_com."Count_ENTITIES", "Location"
	)
	
	-- Union par commune du nombre de locaux dans/hors la centralit�
	SELECT id_geom::text, "nivalea"::text, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_in_zone
	UNION
	SELECT id_geom::text, "nivalea"::text, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_out_zone
	ORDER BY id_geom, "Location"
);

select * from "F1_ENR_Vulnerabilite_Alea_Locaux".chiffres_cles_actualisation




select 'F',count(*) from "F1_ENR_Vulnerabilite_Alea_Locaux".dataviz_local_reference dlr 
, public."TerritoryTable_PST_2019_maj_2020" ttpm, "F1_ENR_Vulnerabilite_Alea_Locaux"."zone_alea_pprn_s_PST_decoupee" zapspd 
where st_intersects(dlr.geomloc,ttpm.geom) 
and st_intersects(dlr.geomloc,zapspd.geom) and zapspd.nivalea  like 'F' and ttpm.id_geom like '200066819'
union
select 'M',count(*) from "F1_ENR_Vulnerabilite_Alea_Locaux".dataviz_local_reference dlr 
, public."TerritoryTable_PST_2019_maj_2020" ttpm, "F1_ENR_Vulnerabilite_Alea_Locaux"."zone_alea_pprn_s_PST_decoupee" zapspd 
where st_intersects(dlr.geomloc,ttpm.geom) 
and st_intersects(dlr.geomloc,zapspd.geom) and zapspd.nivalea  like 'M' and ttpm.id_geom like '200066819'
UNION
select 'Fai',count(*) from "F1_ENR_Vulnerabilite_Alea_Locaux".dataviz_local_reference dlr 
, public."TerritoryTable_PST_2019_maj_2020" ttpm, "F1_ENR_Vulnerabilite_Alea_Locaux"."zone_alea_pprn_s_PST_decoupee" zapspd 
where st_intersects(dlr.geomloc,ttpm.geom) 
and st_intersects(dlr.geomloc,zapspd.geom) and zapspd.nivalea  like 'Fai' and ttpm.id_geom like '200066819'


select * from "F1_ENR_Vulnerabilite_Alea_Locaux".chiffres_cles_reference ccr where id_geom like '200066819'


select count(*) from "F1_ENR_Vulnerabilite_Alea_Locaux".dataviz_local_reference dlr , public."TerritoryTable_PST_2019_maj_2020" ttpm ,
"F1_ENR_Vulnerabilite_Alea_Locaux"."zone_alea_pprn_s_PST_decoupee" zapspd 
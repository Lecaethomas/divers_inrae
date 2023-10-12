-- Script de production de l'indicateur "Surfaces consommées à partir des unités foncières dans/hors les enveloppes urbaines" 
-- j'ai récupéré la base dans un txt dans le dossier de travail de Simon puis j'ai fait en sorte de récupérer des réultats cohérents.
-- schema :: 				- spe_F1_REN_EnvUrbaine_Surface
-- parcelles :: 			- ff2020.fftp_2020_pnb10_parcelle
-- 
-- Summary : on utilise les parcelles des ffonciers -- il y avait un pb avec les requêtes initiales, qui avaient été développées avec les ff 2017
-- ils comprenaient une variable qui n'éxistait plus ensuite "typprop" et si j'ai bien compris la doc, elle a été remplacée par "catpro2" -- 
-- On extrait les parcelles selon qu'elles intersectent un bati du pci vecteur. 
-- J'ai un doute à partir des unités foncières pures , rien ne décrivait comment on arrivait à cette couche ni ce qui la différenciait
-- Ensuite on calcule les surface In/Out pour les chiffres clés 


--- ### Création des unités foncières avec somme des nlocmaison etc. pour classification ###

DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_Surface".unites_foncieres;

CREATE TABLE "spe_F1_REN_EnvUrbaine_Surface".unites_foncieres AS (
	WITH temp2 AS (
SELECT
	*,
	ST_ClusterDBSCAN(a.geompar,
	0.8,
	1) OVER(PARTITION BY idprocpte) AS clst2
FROM
	ff2020.fftp_2020_pnb10_parcelle a
	--WHERE a.nlocal > 0
	)
SELECT
	(ST_Dump(ST_Union(temp2.geompar))).geom geom,
	temp2.catpro2,
	SUM(temp2.nloccom) nloccom,
	SUM(temp2.nlocappt) nlocappt,
	SUM(temp2.nlocmaison) nlocmaison,
	SUM(temp2.nloclog) nloclog
FROM
	temp2
GROUP BY
	temp2.idprocpte,
	temp2.clst2,
	temp2.catpro2
);

UPDATE
	"spe_F1_REN_EnvUrbaine_Surface".unites_foncieres
SET
	geom = ST_MakeValid(geom)
WHERE
	ST_Isvalid(geom) = FALSE
	AND geom IS NOT NULL;


DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_Surface".unites_foncieres_pures;
CREATE TABLE "spe_F1_REN_EnvUrbaine_Surface".unites_foncieres_pures AS (
SELECT
	*
FROM
	"spe_F1_REN_EnvUrbaine_Surface".unites_foncieres
);
DROP INDEX IF EXISTS unites_foncieres_pures_idx;

CREATE INDEX unites_foncieres_pures_idx ON
"spe_F1_REN_EnvUrbaine_Surface".unites_foncieres_pures
	USING gist(geom);
---### Ajout d'une colonne bati boolean pour savoir si la parcelle est construite selon le cadastre du 02 01 ###

ALTER TABLE "spe_F1_REN_EnvUrbaine_Surface".unites_foncieres_pures DROP COLUMN IF EXISTS bati;

ALTER TABLE "spe_F1_REN_EnvUrbaine_Surface".unites_foncieres_pures ADD COLUMN bati int;

UPDATE
	"spe_F1_REN_EnvUrbaine_Surface".unites_foncieres_pures
SET
	bati = 1
FROM
	"F1_REN_DensiteBatie"."cap_batiments_merged_clean_202102_noduplicates" b
WHERE
	--b.geom && unites_foncieres_pures.geom
	 ST_Intersects(unites_foncieres_pures.geom,b.geom)
	AND ST_Area(ST_Intersection(unites_foncieres_pures.geom,
	b.geom)) > 1;


---### Creation du champ typologie ###
ALTER TABLE "spe_F1_REN_EnvUrbaine_Surface".unites_foncieres_pures DROP COLUMN IF EXISTS typologie;

ALTER TABLE "spe_F1_REN_EnvUrbaine_Surface".unites_foncieres_pures ADD COLUMN typologie varchar;

UPDATE
	"spe_F1_REN_EnvUrbaine_Surface".unites_foncieres_pures
SET
	typologie = 
	CASE
		WHEN "nloccom">0
		AND "nloclog" = 0 THEN 0 -- commerce pur
		WHEN "nlocappt">0
		AND "nlocmaison" = 0
		AND "nloccom" = 0 THEN 1 --appartement pur
		WHEN "nloccom" = 0
		AND "nloclog">0
		AND "nlocappt">0
		AND "nlocmaison">0 THEN 2 -- logement pur
		WHEN "nlocmaison">0
		AND "nlocappt" = 0
		AND "nloccom" = 0 THEN 3 --maison pur
		WHEN "nloccom">0
		AND "nloclog">0 THEN 4 --mixte (logement + commerces)
		ELSE 6
	END;
	

-- la surface consommée correspond à la surface des unités foncières dont la typologie est différentes de 0 et 6 et qui intersectent un batiment
	
	--//--//--//--//--//--//--//--//--//--//--//--//
	--//--//--//--// CHIFFRES-CLES--//--//--//--//
	--//--//--//--//--//--//--//--//--//--//--//--//
	
DROP TABLE IF EXISTS "spe_F1_REN_EnvUrbaine_Surface".chiffres_cles ;
CREATE TABLE "spe_F1_REN_EnvUrbaine_Surface".chiffres_cles AS (
WITH env AS (
SELECT
	ROW_NUMBER () OVER (
	ORDER BY id_geom) gid ,
	tt.id_geom ,
	st_union(st_intersection(env.geom,
	tt.geom)) geom
FROM
	public."territory_table_CAP20" tt
LEFT JOIN public."Cap_Atlantique_EnvUrbaine_PourCalculs_2018" env 
ON
	st_intersects(env.geom,
	tt.geom)
	--WHERE tt.id_geom = '44049'
GROUP BY
	id_geom
),
uf AS (
SELECT
	ROW_NUMBER () OVER (
	) gid,
	tt.id_geom ,
	typologie,
	--st_union(st_buffer(st_makevalid(uf_p.geom), 0)) geom
	st_union(st_intersection( st_buffer(st_makevalid(uf_p.geom), 0),
	tt.geom)) geom
	
FROM
	public."territory_table_CAP20" tt
LEFT JOIN 
"spe_F1_REN_EnvUrbaine_Surface"."unites_foncieres_pures_OLD" uf_p
ON
	st_intersects( uf_p.geom,tt.geom)
WHERE
	uf_p.typologie NOT in ('0', '6') AND bati ='1'
	AND  tt.id_geom = '44049'--AND tt.RANK='1' --AND  tt.id_geom = '44049' --bati = '1' AND  --AND tt.id_geom ='44049' --AND (nloclog > '0' or nloccom > '0'or nlocappt > '0' or nlocmaison > '0') --
GROUP BY
	--id_geom,
	typologie
), 
"in" AS (
SELECT
	--uf.id_geom::TEXT ,
	typologie::TEXT ,
	st_area(st_intersection(st_union(uf.geom),
	st_union(env.geom)))::REAL "Surf_ENTITIES",
	'IN'::TEXT AS "Location"
FROM
	uf
LEFT JOIN env
ON
	st_intersects(env.geom,
	uf.geom)
	GROUP BY  typologie   --uf.id_geom,
),
"out" AS (
SELECT
	--uf.id_geom::TEXT ,
	typologie::TEXT ,
	st_area(st_difference(st_makevalid(st_buffer(st_makevalid(st_union(uf.geom)),0)) , st_union(env.geom)))::integer "Surf_ENTITIES" ,
	'OUT'::TEXT AS "Location"
FROM
	uf
LEFT JOIN env  
ON
	ST_Intersects(uf.geom,
	env.geom)
	
GROUP BY
	--uf.id_geom,
	
	typologie--,
	
)

SELECT
	"out".*--, st_area("out".geom) "surf_ENTITIES"
FROM
	"out"
--WHERE
	--id_geom IS NOT NULL
UNION
SELECT
	"in".*--, st_area("in".geom) "surf_ENTITIES"
FROM
	"in"
--WHERE
	--id_geom IS NOT NULL
ORDER BY
	--id_geom,
	"Location" 
);


--//--//--//--//--//--//--//--//--//--//
--//--//  Unites foncieres pour la viz
--//--//--//--//--//--//--//--//--//--//

DROP TABLE IF EXISTS dataviz_unites_foncieres_pures;
CREATE TABLE dataviz_unites_foncieres_pures AS (
SELECT uf.* FROM "spe_F1_REN_EnvUrbaine_Surface"."unites_foncieres_pures" uf  , 
public."territory_table_CAP20" tt 
WHERE st_intersects(tt.geom, uf.geom) AND uf.typologie NOT in ('0', '6') AND bati ='1'
)

SELECT sum("Surf_ENTITIES") FROM "spe_F1_REN_EnvUrbaine_Surface".chiffres_cles cc 
WHERE cc."Location" ='IN'
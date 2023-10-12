--On a une couche de parc d'activites qui n'a pas changé depuis l'initialisation, par contre le territoire nous envoie une liste màj de parcs qui ont été requalifés
-- j'ai donc crees deux champs booleen, l'un pour la requalification, l'autre pour la representation (car deux parcs ('communal non-transferes') ne doivent pas être représentés)
-- La liste des Parcs fournie par le client donnait aussi une catégorisation par niveau d'avancement 
-->j'ai donc du mettre à jour manuellement la donnée pour l'info de qualification, s'il faut les représenter ou non et enfin la catégorisation.

DROP TABLE IF EXISTS  "spe_F4_EQU_ProjetsRequalificationParcsActivite".parcs_requalifies_2021;
CREATE TABLE "spe_F4_EQU_ProjetsRequalificationParcsActivite".parcs_requalifies_2021 as(
SELECT * FROM "spe_F4_EQU_ProjetsRequalificationParcsActivite".parcs_activites
WHERE "requalif_21" = true and  "rprstation_21" = TRUE
);

DROP TABLE IF EXISTS  "spe_F4_EQU_ProjetsRequalificationParcsActivite".parcs_non_requalifies_2021;
CREATE TABLE "spe_F4_EQU_ProjetsRequalificationParcsActivite".parcs_non_requalifies_2021 as(
SELECT * FROM "spe_F4_EQU_ProjetsRequalificationParcsActivite".parcs_activites
WHERE "requalif_21" = false and  "rprstation_21" = TRUE
);


DROP TABLE IF EXISTS  "spe_F4_EQU_ProjetsRequalificationParcsActivite".dataviz_parcs_2021;
CREATE TABLE "spe_F4_EQU_ProjetsRequalificationParcsActivite".dataviz_parcs_2021 as(
WITH t1 AS (
SELECT 
CASE WHEN requalif_21 IS TRUE THEN '1'
ELSE '0'
END requalif , statut , nom_parc , coll_nom ,
geom, detail_21, round((st_area(geom)/10000)::numeric,2) st_area
FROM "spe_F4_EQU_ProjetsRequalificationParcsActivite".parcs_activites
WHERE "rprstation_21" = TRUE
)
SELECT geom, st_area, statut , nom_parc , coll_nom , 
	CASE 
		WHEN requalif = '1' AND detail_21 = 'requalifie' THEN '1'
	 	WHEN requalif = '1' AND detail_21 = 'en cours' THEN '2'
	 	WHEN requalif = '1' AND detail_21 = 'en preparation' THEN '3'
	 	WHEN requalif = '0'  THEN '0'
	 	END requalif
	 	FROM t1
)



DROP TABLE IF EXISTS  "spe_F4_EQU_ProjetsRequalificationParcsActivite".chiffres_cles;
CREATE TABLE "spe_F4_EQU_ProjetsRequalificationParcsActivite".chiffres_cles AS (
SELECT tt.id_geom, count(pa.*) "Count_ENTITIES"
FROM "spe_F4_EQU_ProjetsRequalificationParcsActivite".parcs_activites pa
LEFT JOIN public."territory_table_CAP20" tt
ON st_intersects(st_centroid(pa.geom), tt.geom)
WHERE "requalif_21" = true and  "rprstation_21" = TRUE
GROUP BY id_geom--, pa.nom_parc  
);
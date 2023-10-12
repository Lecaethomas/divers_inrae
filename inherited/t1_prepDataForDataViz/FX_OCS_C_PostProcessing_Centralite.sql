-- Post-processing de centralite
-- author : SAH
-- date : 20220426
-- applied on : CAP 2022 , PSB 2022



--Pour l'étape suivante ("delta") on besoin des valeurs brutes de nombres de "choses" dans les carreaux; or pour PSB, j'ai pas pu remettre la main dessus
-- je dois donc les recalculer

WITH car_log as(
SELECT t1.geom, densitelog::int "Ra_DeLog", id_car 
FROM "FX_OCS_C_CentraliteDetermination_integration"."carroyage_DensiteLogements_parcelles2015_100mV2" t1
LEFT JOIN public."PSB_car_100m_2154_2020" t2
ON st_contains(t2.geom, st_centroid(t1.geom))
),
car_bat AS(
SELECT car_log.id_car, count(st_centroid(bat.geom)) "Ra_DeBat" FROM car_log
LEFT JOIN "FX_OCS_C_CentraliteDetermination_integration".bd_topo_bati_2016 bat 
ON st_intersects(bat.geom, car_log.geom)
GROUP BY car_log.id_car),
car_log AS(
SELECT car_log.id_car, count((com.geom)) "ComLoc" FROM car_log
LEFT JOIN "FX_OCS_C_CentraliteDetermination_integration".geo_sirene_22 com
ON st_intersects(com.geom, car_log.geom)
GROUP BY  car_log.id_car),

SELECT * FROM "FX_OCS_C_CentraliteDetermination_integration".geo_sirene_22 com
LEFT JOIN "FX_OCS_C_CentraliteDetermination_integration"."NOMENCLATURE" n
ON com.code_equ= n."TYPE"::varchar 
WHERE n."TYPE" IS NOT null









--  comparaison des valeurs de centralité
-- DELTA V
DROP TABLE IF EXISTS "FX_OCS_C_CentraliteDetermination_integration".delta_valeurs_centralite_2018_2022;
CREATE TABLE "FX_OCS_C_CentraliteDetermination_integration".delta_valeurs_centralite_2018_2022 as
SELECT  c."id_car",  
COALESCE(v18."Ra_DeBat",0) Ra_DeBat_deb,   COALESCE(v22."Ra_DeBat",0) Ra_DeBat_fin,       (COALESCE(v22."Ra_DeBat",0) - COALESCE(v18."Ra_DeBat",0) ) Ra_DeBat_delta,
COALESCE(v18."Ra_DeLog",0) Ra_DeLog_deb,  COALESCE(v22."Ra_DeLog",0) Ra_DeLog_fin,        (COALESCE(v22."Ra_DeLog",0) - COALESCE(v18."Ra_DeLog",0) ) Ra_DeLog_delta,
COALESCE(v18."Ra_ComLoc",0) Ra_ComLoc_deb,   COALESCE(v22."Ra_ComLoc",0) Ra_ComLoc_fin,   (COALESCE(v22."Ra_ComLoc",0) - COALESCE(v18."Ra_ComLoc",0) ) Ra_ComLoc_delta,
COALESCE(v18."Ra_IntCol",0) Ra_IntCol_deb, COALESCE(v22."Ra_IntCol",0) Ra_IntCol_fin,     (COALESCE(v22."Ra_IntCol",0) - COALESCE(v18."Ra_IntCol",0) ) Ra_IntCol_delta,
COALESCE(v18."Ra_EspSoc",0) Ra_EspSoc_deb, COALESCE(v22."Ra_EspSoc",0) Ra_EspSoc_fin,     (COALESCE(v22."Ra_EspSoc",0) - COALESCE(v18."Ra_EspSoc",0) ) Ra_EspSoc_delta,
COALESCE(v18."Ra_AcMai",0) Ra_AcMai_deb,  COALESCE(v22."Ra_AcMai",0) Ra_AcMai_fin,        (COALESCE(v22."Ra_AcMai",0) - COALESCE(v18."Ra_AcMai",0) ) Ra_AcMai_delta,
COALESCE(v18."Ra_AcEco",0) Ra_AcEco_deb,  COALESCE(v22."Ra_AcEco",0) Ra_AcEco_fin,        (COALESCE(v22."Ra_AcEco",0) - COALESCE(v18."Ra_AcEco",0) ) Ra_AcEco_delta,
COALESCE(v18."Ra_AcLie",0) Ra_AcLie_deb, COALESCE(v22."Ra_AcLie",0) Ra_AcLie_fin,         (COALESCE(v22."Ra_AcLie",0) - COALESCE(v18."Ra_AcLie",0) ) Ra_AcLie_delta,
COALESCE(v18."NoteMoyDes",0) NoteMoyDes_deb, COALESCE(v22."NoteMoyDes",0) NoteMoyDes_fin, (COALESCE(v22."NoteMoyDes",0) - COALESCE(v18."NoteMoyDes",0) ) NoteMoyDes_delta,
 v18."Niv_Centra"  as Niv_Centra_deb,  v22."Niv_Centra" as Niv_Centra_fin, (v22."Niv_Centra" -v18."Niv_Centra") as Niv_Centra_delta,
 c.geom
FROM public."PSB_car_100m_2154_2020" c 
LEFT JOIN "FX_OCS_C_CentraliteDetermination_integration".valeurs_centralites_2022 v22
ON v22."ID_CAR" = c."id_car"
LEFT JOIN "FX_OCS_C_CentraliteDetermination_integration".valeurs_centralites_2018 v18
ON v18."ID_CAR"::varchar = c."id_car"


---------------------------------------------------------------------
---------------------------------------------------------------------
-------- POSTTRAITEMENT (A APPLIQUER QUE POUR LES ACTUALISATIONS) ---
---------------------------------------------------------------------
---------------------------------------------------------------------



-- CALCULATE CENTRALITE_2022 NEIGHBOURS INSIDE CENTRALITE_2018 PERIMETER
DROP TABLE IF EXISTS "FX_OCS_C_CentraliteDetermination_integration".t1_neighbours_in_t0;
CREATE TABLE "FX_OCS_C_CentraliteDetermination_integration".t1_neighbours_in_t0 AS 
WITH t0 AS (
	SELECT c18."ID_CAR" , c18.geom FROM "FX_OCS_C_CentraliteDetermination_integration".valeurs_centralites_2018 c18
	JOIN 
	"FX_OCS_C_CentraliteDetermination_integration".perimetres_2018 p0
	ON st_intersects(st_centroid(c18.geom),p0.geom)
),
t1 AS (
	SELECT c22.* FROM "FX_OCS_C_CentraliteDetermination_integration".valeurs_centralites_2022 c22
	JOIN 
	"FX_OCS_C_CentraliteDetermination_integration".perimetres_2022 p0
	ON st_intersects(st_centroid(c22.geom),p0.geom)
),
n8 AS (
	SELECT t1."ID_CAR", count(*) AS neighbours FROM t1 
 	LEFT JOIN t0
	ON st_touches(t0.geom,t1.geom)
GROUP BY t1."ID_CAR"
)
SELECT  *  FROM n8;

--  INDENTIFICATION :
-- Tous les carreaux du T1 qui ne sont pas dans le T0 et qui ont évolué que sur les descripteurs de densité de logements et/ou bâtie 





---[V2] ====> NEIGHBOURS FILTERING
DROP TABLE IF EXISTS "FX_OCS_C_CentraliteDetermination_integration".neighbours_filtering_res;
CREATE TABLE "FX_OCS_C_CentraliteDetermination_integration".neighbours_filtering_res AS 
SELECT delta.*, n8.neighbours FROM
"FX_OCS_C_CentraliteDetermination_integration".valeurs_centralites_2022 c22
LEFT JOIN 
"FX_OCS_C_CentraliteDetermination_integration".perimetres_2018 p0
ON 
ST_intersects(st_centroid(c22.geom),p0.geom)
LEFT JOIN
"FX_OCS_C_CentraliteDetermination_integration".perimetres_2022 p1
ON
ST_intersects(st_centroid(c22.geom),p1.geom)
JOIN
"FX_OCS_C_CentraliteDetermination_integration".delta_valeurs_centralite_2018_2022 delta
ON
delta.id_car LIKE c22."ID_CAR"
LEFT JOIN 
"FX_OCS_C_CentraliteDetermination_integration".t1_neighbours_in_t0 AS n8 
ON n8."ID_CAR" LIKE c22."ID_CAR"
WHERE c22."Niv_Centra" >=2 AND p0.id IS null and p1.id is not NULL  AND n8.neighbours <8
AND (delta.ra_debat_delta <> 0 OR delta.ra_delog_delta <> 0)
AND delta.ra_comloc_delta =0 AND delta.ra_intcol_delta = 0
AND delta.ra_espsoc_delta =0 AND delta.ra_acmai_delta = 0
AND delta.ra_aceco_delta =0 AND delta.ra_aclie_delta  = 0



-- PROCESS PERIMETER :
-- Suppression de tous les carreaux qui ont des évolutions que sur les descripteurs de logements/densité batie (LOT1) 
-- et les carreaux qui devait être orphelins si on considérait pas les carreaux du (LOT1)
DROP TABLE IF EXISTS "FX_OCS_C_CentraliteDetermination_integration".perimetres_2022_postprocessing;
CREATE TABLE "FX_OCS_C_CentraliteDetermination_integration".perimetres_2022_postprocessing AS
WITH more_than_one_filtred_centra AS (
	SELECT (ST_DUMP(st_union(st_buffer(c22.geom,0.1)))).geom , 
	round(st_area((ST_DUMP(st_union(st_buffer(c22.geom,0.1)))).geom) / 10000) AS "count" FROM 
"FX_OCS_C_CentraliteDetermination_integration".valeurs_centralites_2022 c22
JOIN 
"FX_OCS_C_CentraliteDetermination_integration".perimetres_2022 p1
ON st_intersects(st_centroid(c22.geom),p1.geom)
LEFT JOIN 
"FX_OCS_C_CentraliteDetermination_integration".neighbours_filtering_res n
ON n.id_car LIKE c22."ID_CAR"
WHERE n.id_car IS NULL  
)
SELECT ROW_NUMBER() OVER() AS fid,* FROM more_than_one_filtred_centra WHERE "count" > 1
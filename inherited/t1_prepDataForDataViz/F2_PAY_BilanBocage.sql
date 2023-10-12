create index idx_bocage_t0_old_and_new on bocage_t0_old_and_new using gist(geom)
--Ici on calcule le nombre de m�tres lin�aires de haie par carreau

drop table if exists "F2_ENV4_SuiviPlantationHaies".carroyage_haies_total;
create table "F2_ENV4_SuiviPlantationHaies".carroyage_haies_total as(
SELECT carr.geom, carr."ID_CAR",
			COALESCE(SUM(ST_Length(ST_Intersection(carr.geom,haie.geom))),0)::int AS len_haies
		FROM public."_CarroyageMicro_PV_EPSG2154" AS carr left join
			 "F2_ENV4_SuiviPlantationHaies"."bocage_t0_old_and_new" AS haie
			 on st_intersects(carr.geom, haie.geom)
			 --where ST_Intersects(carr.geom,haie.geom)
		GROUP BY carr."ID_CAR", carr.geom
	);

	------------------------------------------
	
--Ici l'on cherche � calculer le nombre de m�tre lin�aires (d�j� pr�sents dans les carreaux) rapport�s au nombre total de carreaux (null et non-null)
--ceci en vue d'obtenir une donn�e permettant de savoir le nombre de m�tre lin�aires moyens par �chelles admin..
drop table if exists "F2_ENV4_SuiviPlantationHaies".ml_ha_moy_ccles_geom;
create table "F2_ENV4_SuiviPlantationHaies".ml_ha_moy_ccles_geom as (
-- avec t1 on calcule le nombre de m�tres lin�aires aux diff�rentes �chelles territoriales
--en sommant la longueur d�j� pr�sente dans les carreaux, d�s lors qu'ils intersectent les contours administratifs
with t1 as(
select ttpbf.id_geom , sum(carr.len_haies) as sum_
from "F2_ENV4_SuiviPlantationHaies".carroyage_haies_total carr 
left join public."TerritoryTable_PV_BDTopo_2020.08_full_2154" ttpbf 
on st_intersects( ttpbf.geom,st_centroid(carr.geom))
--where ttpbf.id_geom not in ('35170','35347','35260','35192')
group by ttpbf.id_geom
order by ttpbf.id_geom
),
--Avec t2 on calcule le nombre de carreaux pr�sents dans chacun des d�coupage en utilisant la m�me technique d'intersection (st_pointonsurface). 
t2 as(
select ttpbf.id_geom,ttpbf.geom, count(distinct(carr.geom)) as count_
from "F2_ENV4_SuiviPlantationHaies".carroyage_haies_total carr 
left join public."TerritoryTable_PV_BDTopo_2020.08_full_2154" ttpbf 
on st_intersects(ttpbf.geom, st_centroid(carr.geom))
---where ttpbf.id_geom not in ('35170','35347','35260','35192')
group by ttpbf.id_geom,ttpbf.geom
order by ttpbf.id_geom
)
-- Enfin on calcule le rapport entre la somme des longueurs et le nombre de carreaux calcul�s par contours administratif,
-- en joignant t1 et T2 on obtient ainsi un ml/ha/�ch_admin
select t2.id_geom, t1.sum_ / t2.count_ as Count_ENTITIES
from t1 left join t2 on t1.id_geom=t2.id_geom
);


----------------------------------------------
-- Ici on cr�e un champs contenant les classes qui seront utilis�es par la datavisualisation

alter table "F2_ENV4_SuiviPlantationHaies".carroyage_haies_total drop column if exists "length_class";
alter table "F2_ENV4_SuiviPlantationHaies".carroyage_haies_total ADD COLUMN "length_class" varchar;

UPDATE "F2_ENV4_SuiviPlantationHaies".carroyage_haies_total
SET "length_class" = (
		CASE
		WHEN  "len_haies" >= 1 AND "len_haies" <= 49 THEN '[1 -49]'
		WHEN  "len_haies" > 50 AND "len_haies" <= 99 THEN ']50 - 99]'
		WHEN  "len_haies" > 100 AND "len_haies" <= 149 THEN ']100 - 149]'
		WHEN  "len_haies" > 150 THEN ']150 - 705]'
		
		ELSE '99999'
		END
	);
DELETE FROM carroyage_haies_total
WHERE "length_class"='99999';


-----------------------------------------------------
--    REPRISE DATAVIZ --> Methode de Salah utilisée pour FORO
-----------------------------------------------------
 

-- on Refait le t0
drop table if exists t0_haies_pv_clean;
create table t0_haies_pv_clean as(
select id, geom, an_implant from haies_2014 h2 
union
select id, geom, an_implant from haies_2015 h3 
union
select id, geom, an_implant from haies_2020 h4 
)
--creation d'une couche de carreau definie par l'intersection avec les haies



drop index if exists t0_haies_pv_clean_idx;
create index on "F2_PAY_Bocage_Global".t0_haies_pv_clean using gist(geom)

-- temps de calcul : 51 secondes
DROP TABLE IF EXISTS "F2_PAY_Bocage_Global".densite_bocagere_carreaux;
CREATE TABLE "F2_PAY_Bocage_Global".densite_bocagere_carreaux AS (
	SELECT  grid.geom geom, sum(st_length(st_intersection(h.geom,grid.geom))/(st_area(grid.geom)/10000)) AS dens_boca_brute ,grid."ID_CAR" AS id  FROM public."_CarroyageMicro_PV_EPSG2154" grid 
	JOIN 
	"F2_PAY_Bocage_Global".t0_haies_pv_clean h 
	ON ST_intersects(grid.geom,h.geom)
	GROUP BY "ID_CAR", grid.geom
);




-- Classification de la densite par carreau

ALTER TABLE  densite_bocagere_carreaux DROP COLUMN IF EXISTS db_cl;
ALTER TABLE densite_bocagere_carreaux ADD COLUMN db_cl varchar(30);
UPDATE densite_bocagere_carreaux  SET db_cl = CASE 
WHEN  "dens_boca_brute" >0 and  "dens_boca_brute" <=50 THEN ']0 - 50]'
WHEN  "dens_boca_brute" >50 and  "dens_boca_brute" <=100 THEN ']50 - 100]'
WHEN  "dens_boca_brute" >100 and  "dens_boca_brute" <=150 THEN ']100 - 150]'
WHEN  "dens_boca_brute" >=150 and  "dens_boca_brute" <706 THEN ']150 - 706]'
ELSE
NULL
END;-- END CLASSIFICATION



 --- CCLES 

 DROP TABLE IF EXISTS "F2_PAY_Bocage_Global".densite_bocagere_ccles;
CREATE TABLE "F2_PAY_Bocage_Global".densite_bocagere_ccles AS (
	SELECT t.id_geom,t.rank, sum(st_length(st_intersection(h.geom,t.geom))/(st_area(t.geom)/10000)) AS dens_boca_brute, sum(st_length(st_intersection(h.geom,t.geom))) AS hedge_length_m, st_area(t.geom)/10000 AS territory_area_ha FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154" t 
	INNER JOIN 
	"F2_PAY_Bocage_Global".t0_haies_pv_clean h
	ON ST_intersects(t.geom,h.geom)
	GROUP BY t.id_geom,t.RANK,t.geom
);



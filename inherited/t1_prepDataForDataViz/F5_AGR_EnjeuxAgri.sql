-- Author : THL
-- date : 26-07-2021
-- Description : Scrit de calcul des chiffres clés à partir du carroyage sortant du script SYNTHESEAgricole.py (pyqgis)

drop index if exists "F5_AGR_PressionsEspacesAgricoles"."Carroyage_ENJEUX_AGRICOLES_idx";
create index "Carroyage_ENJEUX_AGRICOLES_idx" on "F5_AGR_PressionsEspacesAgricoles"."Carroyage_ENJEUX_AGRICOLES" using gist(geom);
-- 10m50s

drop table if exists "F5_AGR_PressionsEspacesAgricoles"."chiffres_cles2020";
create table "F5_AGR_PressionsEspacesAgricoles"."chiffres_cles2020" as( 
with t0 as (
select t1.id_geom, count(*) niv_0
from "F5_AGR_PressionsEspacesAgricoles"."Carroyage_ENJEUX_AGRICOLES" t1
left join public."TerritoryTable_PV_BDTopo_2020.08_full_2154" t2
on st_intersects(st_pointonsurface(t1.geom), t2.geom)
where t1."Niv_Enjeu" = '0' and t1.id_geom is not null
group by t1.id_geom
),
t1 as (
select t1.id_geom, count(*) niv_1
from "F5_AGR_PressionsEspacesAgricoles"."Carroyage_ENJEUX_AGRICOLES" t1
left join public."TerritoryTable_PV_BDTopo_2020.08_full_2154" t2
on st_intersects(st_pointonsurface(t1.geom), t2.geom)
where t1."Niv_Enjeu" = '1' and t1.id_geom is not null
group by t1.id_geom
),
t2 as (
select t1.id_geom, count(*) niv_2
from "F5_AGR_PressionsEspacesAgricoles"."Carroyage_ENJEUX_AGRICOLES" t1
left join public."TerritoryTable_PV_BDTopo_2020.08_full_2154" t2
on st_intersects(st_pointonsurface(t1.geom), t2.geom)
where t1."Niv_Enjeu" = '2' and t1.id_geom is not null
group by t1.id_geom
),
t3 as (
select t1.id_geom, count(*) niv_3
from "F5_AGR_PressionsEspacesAgricoles"."Carroyage_ENJEUX_AGRICOLES" t1
left join public."TerritoryTable_PV_BDTopo_2020.08_full_2154" t2
on st_intersects(st_pointonsurface(t1.geom), t2.geom)
where t1."Niv_Enjeu" = '3' and t1.id_geom is not null
group by t1.id_geom
),
t4 as (
select t1.id_geom, count(*) niv_4
from "F5_AGR_PressionsEspacesAgricoles"."Carroyage_ENJEUX_AGRICOLES" t1
left join public."TerritoryTable_PV_BDTopo_2020.08_full_2154" t2
on st_intersects(st_pointonsurface(t1.geom), t2.geom)
where t1."Niv_Enjeu" = '4' and t1.id_geom is not null
group by t1.id_geom
),
t_final as (
select t1.id_geom,niv_0 "Niv_0",niv_1 "Niv_1",niv_2 "Niv_2",niv_3 "Niv_3", niv_4 "Niv_4" from t0
left join t1 on t0.id_geom = t1.id_geom 
left join t2 on t0.id_geom = t2.id_geom 
left join t3 on t0.id_geom = t3.id_geom 
left join t4 on t0.id_geom = t4.id_geom 
)
select id_geom,"Niv_0","Niv_1","Niv_2", "Niv_3", "Niv_4", coalesce("Niv_0", 0)+coalesce("Niv_1", 0)+coalesce("Niv_2", 0)+ coalesce("Niv_3", 0)+ coalesce("Niv_4", 0) "Total" 
from t_final
)


-- Author : THL
-- Date : 23/08/2021
-- Adpatation de F1_OCS_ConsommationEspaceReelleActivite.sql pour matcher les besoins de PF


drop table if exists "F1_OCS_ConsommationEspaceReelleActivite".composition_PA_Type_Zone_Plu;
create table "F1_OCS_ConsommationEspaceReelleActivite".composition_PA_Type_Zone_Plu as (

with tPLU as( 
select t2.id,t2.geom ,"TYPEZONE", sum(st_area(st_intersection(t1.geom, t2.geom))) surfzone , st_area(t2.geom) surf_pa
from public."DOCURBA_SCoTPF_GPU_20210818" t1
right join public."union_zones_activites_pf" t2 on st_intersects(t1.geom,t2.geom)
group by t2.id ,"TYPEZONE" 
order by t2.id	
),
tAUc as (
select t1.id, round(coalesce(t1.surfzone/t1.surf_pa *100,0)::numeric, 2) "AUc", surfzone "surfzAUc", surf_pa "surfpaAUc" from tPLU t1
where t1."TYPEZONE" ='AUc'
),
tU as (
select id,  round(coalesce(t1.surfzone/t1.surf_pa *100,0)::numeric, 2) "U" , surfzone "surfzU", surf_pa "surfpaU"  from tPLU t1
--left join public."DOCURBA_SCoTPF_GPU_20210818" t2 on st_intersects(t1.geom,t2.geom) 
where t1."TYPEZONE" ='U'
) ,
tNh as (
select id,  round(coalesce(t1.surfzone/t1.surf_pa *100,0)::numeric, 2) "Nh" , surfzone "surfzNh", surf_pa "surfpaNh"  from tPLU t1
--eft join public."DOCURBA_SCoTPF_GPU_20210818" t2 on st_intersects(t1.geom,t2.geom) 
where t1."TYPEZONE" ='Nh'
) ,
tAUs as (
select id,  round(coalesce(t1.surfzone/t1.surf_pa *100,0)::numeric, 2) "AUs", surfzone "surfzAUs", surf_pa "surfpaAUs"  from tPLU t1
--left join public."DOCURBA_SCoTPF_GPU_20210818" t2 on st_intersects(t1.geom,t2.geom) 
where t1."TYPEZONE" ='AUs'
) ,
tN as (
select id,  round(coalesce(t1.surfzone/t1.surf_pa *100,0)::numeric, 2) "N" , surfzone "surfzN", surf_pa "surfpaN"  from tPLU t1
--left join public."DOCURBA_SCoTPF_GPU_20210818" t2 on st_intersects(t1.geom,t2.geom) 
where t1."TYPEZONE" ='N'
) ,
tA as (
select id,  round(coalesce(t1.surfzone/t1.surf_pa *100,0)::numeric, 2)  "A" , surfzone "surfzA", surf_pa "surfpaA"  from tPLU t1
--left join public."DOCURBA_SCoTPF_GPU_20210818" t2 on st_intersects(t1.geom,t2.geom) 
where t1."TYPEZONE" ='A'
) 
select tPLU.id,tPLU.geom,  round(coalesce("AUc",0),2)"AUc",sum(coalesce("surfzAUc",0)) "surfzAUc",
 round(coalesce("U",0),2)"U",sum(coalesce("surfzU",0)) "surfzU",
round(coalesce("Nh",0),2)"Nh",sum(coalesce("surfzNh",0)) "surfzNh",
round(coalesce("AUs",0),2)"AUs",sum(coalesce("surfzAUs",0)) "surfzAUs",
 round(coalesce("N",0),2)"N",sum(coalesce("surfzN",0)) "surfzN",
round(coalesce("A",0),2) "A",sum(coalesce("surfzA",0)) "surfzA",
 round(coalesce("AUc",0)+ coalesce("U",0) + coalesce("Nh",0) + coalesce("AUs",0) + coalesce("N",0) + coalesce("A",0)) total,  sum(coalesce("surfpaA",0))  surfpa
from tPLU
left join tAUc on tAUc.id= tPLU.id
left join tU on tU.id= tPLU.id
left join tNh on tNh.id= tPLU.id
left join tAUs on tAUs.id= tPLU.id
left join tN on tN.id= tPLU.id
left join tA on tA.id= tPLU.id
group by tPLU.id,tPLU.geom, "AUc", "U","Nh", "AUs", "N","A" 
)


select distinct(t."TYPEZONE") from public."DOCURBA_SCoTPF_GPU_20210818" t, "F1_OCS_ConsommationEspaceReelleActivite"."Couesnon_ZA_072021" t1 where st_intersects (t.geom,t1.geom)

drop table if exists "F1_OCS_ConsommationEspaceReelleActivite"."F1_OCS_ConsommationEspaceReelleActivite";
create table "F1_OCS_ConsommationEspaceReelleActivite"."F1_OCS_ConsommationEspaceReelleActivite" as (

with t0 as (
select id_geom, "label", rank, sum(st_area(st_intersection(t1.geom, t2.geom))) surf_pa_id_geom, st_union(st_intersection(t1.geom,t2.geom)) geom 
from public."TerritoryTable_PF_2019" t1 
left join public.union_zones_activites_pf t2 on st_intersects(t1.geom, t2.geom)
where st_intersects(t1.geom, t2.geom)
group by id_geom, "label",rank
)--,
--t2 as (
select tpa.id_geom, st_union(st_intersection(t2.geom,t1.geom)) geom ,"TYPEZONE", sum(st_area(st_intersection(t1.geom, t2.geom))) surfzone , tpa.surf_pa_id_geom
from public."DOCURBA_SCoTPF_GPU_20210818" t1
left join public.union_zones_activites_pf as t2 
on st_intersects(t1.geom,t2.geom)
right join t0 as tpa 
on st_intersects(t2.geom, tpa.geom)
group by "TYPEZONE" ,   tpa.id_geom, tpa.surf_pa_id_geom
)
select id_geom, "TYPEZONE",st_collectionextract(st_union(geom), 3)::geometry, sum(surfzone)surfzone, sum(surf_pa_id_geom)surf_pa_id_geom, avg((surfzone/surf_pa_id_geom) *100) avge
from t2
group by id_geom, "TYPEZONE" 
)


select distinct("TYPEZONE") from  public."DOCURBA_SCoTPF_GPU_20210818" t1
right join public.union_zones_activites_pf as t2 on st_intersects(t1.geom,t2.geom)

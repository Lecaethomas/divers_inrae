-- Avant d'envoyer la table de correspondance au client on a voulu "pré-caractériser" les vocations en préremplissant les champs selon le contenu du libelong

drop table if exists "table_correspondance_DU_SUPV_202202";
create table "table_correspondance_DU_SUPV_202202" as (
with t1 as (
select pgs.geom,case when insee is null then substring("Nomfic",0,6) else insee end insee ,"Libelle","Libelong","Typezone","Nomfic","Urlfic","Idurba","Datvalid","LIB_ATTR1","LIB_VAL1",destdomi,datappro
from "PLUs_GPU_SUPV_20220204_v2" pgs 
order by insee desc),

t2 as (
select distinct on ("Typezone", "Libelle", "Libelong", insee)"Typezone", "Libelle", "Libelong", insee, tt.label, datappro ,"Datvalid" from t1
left join public."TerritoryTable_PV_BDTopo_2020.08_full_2154" tt
on t1.insee = tt.id_geom
order by insee),

t3 as (
select "label",insee,"Datvalid",datappro, "Typezone","Libelle","Libelong", 
case when substring("Typezone",0,3) ilike '%AU%' then 'oui' else 'non' end "Zone_AU"
from t2
where label is not null),

t4 as(
select "label",insee,"Datvalid",datappro, "Typezone","Libelle","Libelong","Zone_AU",
--case when "Libelong" ilike '%economique%' then 'économique' when "Libelong" ilike '%habitat%' then 'habitat' end vocation_deduite
case 
when ("Libelong" ilike '%economique%' 
or "Libelong" ilike '%économique%') and "Zone_AU" = 'oui' then 'économique' 
when "Libelong" ilike '%habitat%' and "Zone_AU" = 'oui' then 'habitat'  end temp_voc
from t3)

select case when temp_voc is null
	and "Zone_AU" = 'oui' 
	then 'à remplir' else temp_voc end vocation, 
	"Zone_AU","label",insee,"Datvalid",datappro,"Typezone","Libelle","Libelong"

from t4
order by insee, vocation
)


drop table if exists "PV_ZAU_20220204";
create table "PV_ZAU_20220204" as(

with t1 as (
select ttid,geom,tid,"Libelle","Libelong","Typezone","Nomfic","Urlfic","Idurba","Datvalid",gid,id,"LIB_ATTR1","LIB_VAL1",destdomi,insee as inseee,datappro,"DL_GPU**da","INSEE_1",layer,"path", 
case 
when insee is null then substring("Nomfic",0,6) 
--when insee is null and "INSEE_1" is null then substring("Idurba",0,6)  
else insee end insee
from "PLUs_GPU_SUPV_20220204_v2" pgsv 
order by insee
),
t2 as (
select t1.geom, t2.vocation, t2."Zone_AU",t2."label",t1.insee,t1."Datvalid",t1.datappro,t1."Typezone",t1."Libelle",t1."Libelong" from t1 left join 
"table_correspondance_DU_SUPV_20220204_SUPV_Final" t2 on t1.insee=t2.insee::varchar and lower(t1."Typezone") = lower(t2."Typezone") and lower(t1."Libelle") = lower(t2."Libelle")
)
select * from t2
where "Libelle" ilike '%au%'-- and insee = '35194'
order by  insee
);





drop table if exists "PLUs_GPU_SUPV_20220204_v2_OLD";
create table "PLUs_GPU_SUPV_20220204_v2_OLD" as (
select * from "PLUs_GPU_SUPV_20220204_v2"
)

select * from "PLUs_GPU_SUPV_20220204_v2"
where "insee"  = '35260' and "Libelle" ilike '%au%'
--substring("Nomfic",0,5)


select * from "table_correspondance_DU_SUPV_20220204_SUPV_Final"

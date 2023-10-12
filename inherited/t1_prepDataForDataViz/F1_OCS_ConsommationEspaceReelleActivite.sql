-- Author: THL
-- Date : 30/02/2021

-- Purpose: En utilisant les parcs d'activités du territoire, la tache urbaine produite uniquement à l'aide des entités se trouvant à l'intérieur des zonages d'activité,
-- ainsi que la ttable on cherche à extraire l'emprise de la TU dans chacun des parcs, dans un premier temps sous l'angle des types de parcs d'activité,
-- ensuite selon leur classification au PLU (ZUA ou ZAU 1 et 2)

-- Input: zonages de Parcs d'Activités, TU spécifique pour cet indicateur (voir confluence), territory table 

-- UPDATE 30/07/2021 :: le cient souhaite avoir au clic un jauge de remplissage (rapport surface TU/Surf PA)
-- + le client souhaite avoir une catégorisation prenant en variable primaire le type de Parc d'Activité puis le type de zone plu


------------------------------------------------------

-- Avant de calculer les chiffres clés je "façonne" les zones d'activités ( pour qu'elles contiennent un id_geom et les differents zonages des DU)
drop table if exists public.pf_zactivites_2021;
create table public.pf_zactivites_2021 as(
select nom_pa, interet , geom from "F1_OCS_ConsommationEspaceReelleActivite"."Couesnon_ZA_072021"
union all
select nom_za nom_pa, interet, geom from "F1_OCS_ConsommationEspaceReelleActivite"."Fagglo_ZA_082021"
)





drop table if exists "F1_OCS_ConsommationEspaceReelleActivite".pv_zactivites_2021_speConso;
create table "F1_OCS_ConsommationEspaceReelleActivite".pv_zactivites_2021_speConso as (
select za.nom_pa,za.type_pa ,tt.id_geom,du."Libelle" , du."Typezone"::text zonage_plu , st_makevalid(st_union(st_collectionextract( st_intersection(za.geom,ST_Force2D(du.geom)),3))) geom 
from "F1_OCS_ConsommationEspaceReelleActivite".pv_zactivites_2021 za
left join  public."DOCURBA_SCoTPV_GPU_20220204" du 
on st_intersects(za.geom, du.geom)
left join public."TerritoryTable_PV_BDTopo_2020.08_full_2154" tt 
on st_intersects(za.geom, tt.geom)
group by za.nom_pa, za.type_pa,id_geom,  du."Typezone", du."Libelle"
);

DROP INDEX IF EXISTS "pv_zactivites_2021_speconso_idx";
CREATE INDEX "pv_zactivites_2022_speconso_idx" ON "F1_OCS_ConsommationEspaceReelleActivite"."pv_zactivites_2021_speconso" USING gist(geom);
-- On a besoin d'aggréger les type de zones de PLU 
select distinct(zonage_plu) from "F1_OCS_ConsommationEspaceReelleActivite".pv_zactivites_2021_speConso;


ALTER TABLE "F1_OCS_ConsommationEspaceReelleActivite"."pv_zactivites_2021_speconso" 
ALTER COLUMN zonage_plu TYPE VARCHAR(10);

update "F1_OCS_ConsommationEspaceReelleActivite"."pv_zactivites_2021_speconso" 
set zonage_plu =
case 
when zonage_plu = 'AUs' then '2AUA' 
when zonage_plu = 'AUc'  then '1AUA' 
when zonage_plu = 'Nh' then 'N' 
when zonage_plu = 'Ah' then 'A' 
WHEN "Libelle" = 'UA' THEN 'UA'
else zonage_plu
end ;

DROP INDEX IF EXISTS "pv_zactivites_2021_speconso_idx";
CREATE INDEX "pv_zactivites_2021_speconso_idx" ON "F1_OCS_ConsommationEspaceReelleActivite"."pv_zactivites_2021_speconso" USING gist(geom);



--------------------
-- Chiffres-clés --
-- 5 min
--------------------



drop table if exists "F1_OCS_ConsommationEspaceReelleActivite"."F1_OCS_ConsommationEspaceReelleActivite";
create table "F1_OCS_ConsommationEspaceReelleActivite"."F1_OCS_ConsommationEspaceReelleActivite" as(
with rank1 as(
select temps.id_geom,  sum(coalesce(st_area(temps.geom))) surf, temps.zonage_plu , temps.type_pa--
	from ( 
	select  pa.type_pa,pa.id_geom,(st_dump(st_collectionextract(st_intersection(st_makevalid(st_buffer(pa.geom,0.01)),st_makevalid(st_buffer(tu.geom,0.01))),3))).geom::geometry(Polygon,2154) geom, pa.zonage_plu
		from "F1_OCS_ConsommationEspaceReelleActivite"."tacheUrbaine_speConso" tu 
		left join "F1_OCS_ConsommationEspaceReelleActivite"."pv_zactivites_2021_speconso" pa 
		on st_intersects( st_makevalid(st_buffer(tu.geom,0.01)) , st_makevalid(st_buffer(pa.geom,0.01)) ) 
		) temps 
		group by id_geom, type_pa, zonage_plu
		)
select id_geom, round(surf) surf,zonage_plu , type_pa from rank1 
order by id_geom, zonage_plu, type_pa
);--end CREATE



SELECT * FROM "F1_OCS_ConsommationEspaceReelleActivite"."F1_OCS_ConsommationEspaceReelleActivite";
----------------------------------------
-- Zones d'activités pour la dataviz --
-- taux de remplissage des parcs d'activité
-- 4 min 50
----------------------------------------

drop table if exists "F1_OCS_ConsommationEspaceReelleActivite"."F1_OCS_ConsommationEspaceReelleActivite_ZAE";
create table "F1_OCS_ConsommationEspaceReelleActivite"."F1_OCS_ConsommationEspaceReelleActivite_ZAE" as (
select row_number() OVER () AS id,za.nom_pa,za.id_geom, za.zonage_plu , za.type_pa,st_union(za.geom), coalesce(sum(st_area(st_intersection(st_makevalid(st_buffer(tu.geom,0.01)),st_makevalid(st_buffer(za.geom,0.01))))),0) surf_tu, coalesce(sum(st_area(za.geom)),0) surf_pa 
from "F1_OCS_ConsommationEspaceReelleActivite"."pv_zactivites_2021_speconso"za
left join "F1_OCS_ConsommationEspaceReelleActivite"."tacheUrbaine_speConso" tu
on st_intersects(st_makevalid(st_buffer(za.geom,0.01)), st_makevalid(st_buffer(tu.geom,0.01)))
where length(za.id_geom)=5
group by za.nom_pa, za.id_geom , za.zonage_plu , za.type_pa )


select *  from public.pf_zactivites_2021_speconso za

select sum(surf) from "F1_OCS_ConsommationEspaceReelleActivite"."F1_OCS_ConsommationEspaceReelleActivite"
where id_geom='248'

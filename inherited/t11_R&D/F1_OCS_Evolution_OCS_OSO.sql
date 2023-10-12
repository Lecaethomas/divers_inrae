--un script pour extraire des chiffres clés d'occupation du sol à partir de de l'OSO du CNES


-- on extrait les couches pour le territoire
	drop table if exists OSO_vitre_2018;
	create table OSO_vitre_2018 as (
	select st_intersection(st_makevalid(t1.geom), ttpbf.geom) geom, classe from "departement_35 - 2018" t1, public."TerritoryTable_PV_BDTopo_2020.08_full_2154" ttpbf where ttpbf.id_geom ='35360' and st_intersects(t1.geom,ttpbf.geom)
	);
	
	
	drop table if exists OSO_vitre_2019;
	create table OSO_vitre_2019 as (
	select st_intersection(st_makevalid(t1.geom), ttpbf.geom) geom, classe from "departement_35 - 2019" t1, public."TerritoryTable_PV_BDTopo_2020.08_full_2154" ttpbf where ttpbf.id_geom ='35360' and st_intersects(t1.geom,ttpbf.geom)
	)

--CClés de l'occupation du sol 2018 pour SUPVitre
drop index if exists  "departement_35_2018_idx";
create index "departement_35_2018_idx" on "departement_35 - 2018" using gist(geom);

drop table if exists "CompositionOCS_carto_2018";
create table "CompositionOCS_carto_2018" as(
select id_geom , classe id_ocs,  sum(st_area(st_intersection(d.geom,ttpbf.geom))) / 10000 "Area_ENTITIES" from "oso_vitre_2018" d, public."TerritoryTable_PV_BDTopo_2020.08_full_2154" ttpbf 
where st_intersects(d.geom,ttpbf.geom) and ttpbf.rank='4'
group by classe, id_geom --, surf
)

select * from "departement_35 - 2018" where classe=1

--CClés de l'occupation du sol 2019 pour SUPVitre
drop index if exists  "OSO_vitre_2019_idx";
create index "OSO_vitre_2019_idx" on "oso_vitre_2019" using gist(geom);

drop table if exists "CompositionOCS_carto_2019";
create table "CompositionOCS_carto_2019" as(
with t1 as (
select * from public."TerritoryTable_PV_BDTopo_2020.08_full_2154" ttpbf where rank='4'
)
select ttpbf.id_geom , classe id_ocs,  sum(st_area(st_intersection(d.geom,ttpbf.geom))) / 10000 "Area_ENTITIES" from "oso_vitre_2019" d, public."TerritoryTable_PV_BDTopo_2020.08_full_2154" ttpbf, t1 --where st_intersects(d.geom,ttpbf.geom)
where st_intersects(d.geom,t1.geom) --and ttpbf.rank='4'
group by classe, ttpbf.id_geom --, surf
);
select * from "CompositionOCS_carto_2019"


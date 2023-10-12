


   			-- compute ccles for differents scales and grouping by year of planting 
drop table if exists "F2_PAY_Bocage_Global"."F2_PAY_SuiviPlantationHaiesCcles";
create table "F2_PAY_Bocage_Global"."F2_PAY_SuiviPlantationHaiesCcles" as(
SELECT terr.id_geom, haie.an_implant ,
			COALESCE(SUM(ST_Length(ST_Intersection(terr.geom,haie.geom))),0)::int AS len_haies
		FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154" AS terr 
		left join "F2_PAY_Bocage_Global".t0_haies_pv_clean haie 
			 on st_intersects(terr.geom,haie.geom)
			 where ST_Intersects(terr.geom,haie.geom) 
			 and haie.an_implant is not null and haie.an_implant not in('9999', '-1','0','1')
			 and haie.an_implant >= '2000'
		GROUP BY terr.id_geom,haie.an_implant--, haie.geom 
	);

-- compute ccles for differents scales WITHOUT grouping by year of planting 
drop table if exists "F2_PAY_Bocage_Global"."F2_PAY_TotalHaiesCcles_intermediaire";
create table "F2_PAY_Bocage_Global"."F2_PAY_TotalHaiesCcles_intermediaire"as(
SELECT terr.id_geom ,
			COALESCE(SUM(ST_Length(ST_Intersection(terr.geom,haie.geom))),0)::int AS len_haies
		FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154" AS terr,
			 "F2_PAY_Bocage_Global".t0_haies_pv_clean  AS haie
			 where ST_Intersects(terr.geom,haie.geom) 
		GROUP BY terr.id_geom, haie.geom
	);

alter table "F2_PAY_Bocage_Global"."F2_PAY_TotalHaiesCcles_intermediaire" add column year int;
update "F2_PAY_Bocage_Global"."F2_PAY_TotalHaiesCcles_intermediaire" set year = 2020;


drop table if exists "F2_PAY_TotalHaiesCcles";
create table "F2_PAY_TotalHaiesCcles" as(
select a.id_geom insee, year ,round(st_area(b.geom)) as surf ,total , total/round(st_perimeter(b.geom)) "Nombre de chefs d'exploitations ou d'entrepreneurs agricoles"
from "ccles_haies_admin_total" a
left join public."TerritoryTable_PV_BDTopo_2020.08_full_2154" b
on a.id_geom=b.id_geom
where length(a.year::text)=4 and cast(a.year as int) >2000 and cast(a.year as int)< 2021
);
select * from "F2_PAY_TotalHaiesCcles";



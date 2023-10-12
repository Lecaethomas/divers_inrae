/** filtrage des données aux territoires d'études */

drop table if exists "F1_OCS_ConsommationEspaceReelleHabitat"."artificialisationCEREMA_PF_2019";
create table "F1_OCS_ConsommationEspaceReelleHabitat"."artificialisationCEREMA_PF_2019" as (
SELECT com.id_geom,art.geom, epci20, art09hab10, art10hab11, art11hab12, art12hab13,
art13hab14, art14hab15,art15hab16,art16hab17,art17hab18,art18hab19,arthab0919
FROM  "F1_OCS_ConsommationEspaceReelleHabitat"."artificialisationCEREMA_2019"  art, 
public."TerritoryTable_PF_2019" com
WHERE com.rank ='1' and art.idcom = com.id_geom
);



/** agrégation */

-- niv 1 : commune
drop table if exists "F1_OCS_ConsommationEspaceReelleHabitat"."F1_OCS_ConsommationEspaceReelleHabitat";
create table "F1_OCS_ConsommationEspaceReelleHabitat"."F1_OCS_ConsommationEspaceReelleHabitat" as(
with tab as (
	select id_geom as insee,epci20,round((st_area(geom)/10000)::numeric,2) as surf_com,(art09hab10 ) / 10000 as artif_ha ,'2010' as year from "F1_OCS_ConsommationEspaceReelleHabitat"."artificialisationCEREMA_PF_2019" ac 
	union
	select id_geom as insee,epci20,round((st_area(geom)/10000)::numeric,2) as surf_com,(art09hab10+art10hab11 ) / 10000 as artif_ha ,'2011' as year from "F1_OCS_ConsommationEspaceReelleHabitat"."artificialisationCEREMA_PF_2019" ac 
	union
	select id_geom as insee,epci20,round((st_area(geom)/10000)::numeric,2) as surf_com,(art09hab10+art10hab11+art11hab12 ) / 10000 as artif_ha ,'2012' as year from "F1_OCS_ConsommationEspaceReelleHabitat"."artificialisationCEREMA_PF_2019" ac 
	union
	select id_geom as insee,epci20,round((st_area(geom)/10000)::numeric,2) as surf_com,(art09hab10+art10hab11+art11hab12+art12hab13 ) / 10000 as artif_ha ,'2013' as year from "F1_OCS_ConsommationEspaceReelleHabitat"."artificialisationCEREMA_PF_2019" ac 
	union
	select id_geom as insee,epci20,round((st_area(geom)/10000)::numeric,2) as surf_com,(art09hab10+art10hab11+art11hab12+art12hab13+art13hab14 ) / 10000 as artif_ha ,'2014' as year from "F1_OCS_ConsommationEspaceReelleHabitat"."artificialisationCEREMA_PF_2019" ac 
	union
	select id_geom as insee,epci20,round((st_area(geom)/10000)::numeric,2) as surf_com,(art09hab10+art10hab11+art11hab12+art12hab13+art13hab14+art14hab15 ) / 10000 as artif_ha ,'2015' as year from "F1_OCS_ConsommationEspaceReelleHabitat"."artificialisationCEREMA_PF_2019" ac 
	union
	select id_geom as insee,epci20,round((st_area(geom)/10000)::numeric,2) as surf_com,(art09hab10+art10hab11+art11hab12+art12hab13+art13hab14+art14hab15+art15hab16 ) / 10000 as artif_ha ,'2016' as year from "F1_OCS_ConsommationEspaceReelleHabitat"."artificialisationCEREMA_PF_2019" ac 
	union
	select id_geom as insee,epci20,round((st_area(geom)/10000)::numeric,2) as surf_com,(art09hab10+art10hab11+art11hab12+art12hab13+art13hab14+art14hab15+art15hab16+art16hab17 ) / 10000 as artif_ha ,'2017' as year from "F1_OCS_ConsommationEspaceReelleHabitat"."artificialisationCEREMA_PF_2019" ac 
	union
	select id_geom as insee,epci20,round((st_area(geom)/10000)::numeric,2) as surf_com,(art09hab10+art10hab11+art11hab12+art12hab13+art13hab14+art14hab15+art15hab16+art16hab17+art17hab18 ) / 10000 as artif_ha ,'2018' as year 
	from "F1_OCS_ConsommationEspaceReelleHabitat"."artificialisationCEREMA_PF_2019" ac 
	union
	select id_geom as insee,epci20,round((st_area(geom)/10000)::numeric,2) as surf_com,(art09hab10+art10hab11+art11hab12+art12hab13+art13hab14+art14hab15+art15hab16+art16hab17+art17hab18+art18hab19 ) / 10000 as artif_ha ,'2019' as year 
	from "F1_OCS_ConsommationEspaceReelleHabitat"."artificialisationCEREMA_PF_2019" ac 
),
t1 as (
	select insee,surf_com, artif_ha,year,com.geom
	from tab 
	left join 
	public."TerritoryTable_PF_2019" com
	on tab.insee = com.id_geom 
	
)
,rank2 as (
	SELECT id_geom, ST_Union(geom) geom
	FROM public."TerritoryTable_PF_2019"
	WHERE rank = '2'
	GROUP BY id_geom
),
-- niv 2 : Polarités
t2 as (
		select rank2.id_geom as insee,t1.year,sum(artif_ha) as artif_ha,
		round((st_area(rank2.geom )/10000)::numeric,2) as surf_com
		from rank2
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank2.geom)
		GROUP BY rank2.id_geom, t1."year", rank2.geom
),
-- Géométries niveau 3 de la table territoire
rank3 as (
	SELECT id_geom, ST_Union(geom) geom
	FROM public."TerritoryTable_PF_2019"
	WHERE rank = '3'
	GROUP BY id_geom
),
-- Données à l'EPCI
t3 as (
	select rank3.id_geom as insee,t1.year,sum(artif_ha) as artif_ha,
	round((st_area(rank3.geom )/10000)::numeric,2) as surf_com
	from rank3
	LEFT JOIN t1
	ON ST_Intersects(ST_PointOnSurface(t1.geom),rank3.geom)
	GROUP BY rank3.id_geom, t1."year", rank3.geom
),
-- Géométries niveau 4 de la table territoire
rank4 as (
	SELECT id_geom, ST_Union(geom) geom
	FROM public."TerritoryTable_PF_2019"
	WHERE rank = '4'
	GROUP BY id_geom
),
t4 as (
		select rank4.id_geom as insee,t1.year,sum(artif_ha) as artif_ha,
	round((st_area(rank4.geom )/10000)::numeric,2) as surf_com
		from t1,rank4
		WHERE t1.insee IN (
				SELECT terr1.id_geom
				FROM public."TerritoryTable_PF_2019" terr1, rank4
				WHERE ST_Intersects(ST_PointOnSurface(terr1.geom),rank4.geom)
					AND terr1.rank = '1'
		)
		GROUP BY rank4.id_geom, t1."year", rank4.geom
)

SELECT insee,year,artif_ha "Surface totale de l'habitat en Hectare",surf_com, artif_ha total FROM t1 where year is not null
UNION
SELECT insee,year,artif_ha "Surface totale de l'habitat en Hectare",surf_com, artif_ha total FROM t2 where year is not null
UNION 
SELECT insee,year,artif_ha "Surface totale de l'habitat en Hectare",surf_com, artif_ha total FROM t3 where year is not null
UNION 
SELECT insee,year,artif_ha "Surface totale de l'habitat en Hectare",surf_com, artif_ha total FROM t4 where year is not null
ORDER BY insee, "year" 
)




drop table if exists "F1_MOB"."parts_modales_ccles";
create table "F1_MOB"."parts_modales_ccles" as (
	with t1 as (
		select Table1.id_geom as insee, Table0.year,sum("PasTransport") as "PasTransport", sum("MarchePied") as "MarchePied",sum("DeuxRoues") as "DeuxRoues",sum("Voiture") as "Voiture",sum("TC") as "TC",sum("Total") as "Total",
		Table1.geom
		from ( select label as ColMaj,label,id_geom,geom from "public"."TerritoryTable_PST_2020_2154" ) as Table1
		left join (
			select "CODGEO"::text, year,"NOM_COM" ,"PasTransport" ,"MarchePied"  ,"DeuxRoues" ,"Voiture","TC","Total"  from "F1_MOB"."Parts_Modales_PST_GEO_2019"  where substring("CODGEO"::text,1,2) like '31'
		) as Table0
		on Table0."CODGEO" = Table1.id_geom
		where Table1.id_geom is not null and year is not null 
		group by Table1.id_geom,Table0.year,Table1.geom
		order by Table1.id_geom,Table0.year
		),

	rank2 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."TerritoryTable_PST_2020_2154"
			WHERE rank = 2
			GROUP BY id_geom
	),
	t2 as (
		select rank2.id_geom as insee,t1.year,sum("PasTransport") as "PasTransport", sum("MarchePied") as "MarchePied",sum("DeuxRoues") as "DeuxRoues",sum("Voiture") as "Voiture",sum("TC") as "TC",sum("Total") as "Total",
		rank2.geom
		from rank2
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank2.geom)
		GROUP BY rank2.id_geom, t1."year", rank2.geom
	),
	
	rank3 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."TerritoryTable_PST_2020_2154"
			WHERE rank = 3
			GROUP BY id_geom
	),
	t3 as (
		select rank3.id_geom as insee,t1.year,sum("PasTransport") as "PasTransport", sum("MarchePied") as "MarchePied",sum("DeuxRoues") as "DeuxRoues",sum("Voiture") as "Voiture",sum("TC") as "TC",sum("Total") as "Total",
		rank3.geom
		from rank3
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank3.geom)
		GROUP BY rank3.id_geom, t1."year", rank3.geom
	)--,
--	rank4 as (
--		SELECT id_geom, ST_Union(geom) geom
--			FROM public."TerritoryTable_PST_2020_2154"
--			WHERE rank = 4
--			GROUP BY id_geom
--	)--,
--	t4 as (
--		select rank4.id_geom as insee,t1.year,sum("PasTransport") as "PasTransport", sum("MarchePied") as "MarchePied",sum("DeuxRoues") as "DeuxRoues",sum("Voiture") as "Voiture",sum("TC") as "TC",sum("Total") as "Total",
--		rank4.geom
--		from t1,rank4
--		WHERE t1.insee IN (
--				SELECT terr1.id_geom
--				FROM public."TerritoryTable_PST_2020_2154" terr1, rank4
--				WHERE ST_Intersects(ST_PointOnSurface(terr1.geom),rank4.geom)
--					AND terr1.rank = 1
--		)
--		GROUP BY rank4.id_geom, t1."year", rank4.geom
--	)
	SELECT "insee","year","PasTransport","MarchePied","DeuxRoues", "Voiture","TC" FROM t1 where year is not null
	UNION
	SELECT "insee","year","PasTransport","MarchePied","DeuxRoues", "Voiture","TC" FROM t2 where year is not null
	UNION 
	SELECT "insee","year","PasTransport","MarchePied","DeuxRoues", "Voiture","TC" FROM t3 where year is not null
	--UNION 
	--SELECT * FROM t4 where year is not null
	ORDER BY insee, "year"
);
--alter table "F1_MOB"."parts_modales_ccles" drop column geom
select * from "F1_MOB"."parts_modales_ccles";
select count(distinct insee) from "F1_MOB"."parts_modales_ccles" 

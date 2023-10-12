drop table if exists "F1_POP2_TailleMenages".taille_menages;
create table "F1_POP2_TailleMenages".taille_menages as (
	with t1 as (
		select Table1.id_geom as insee, Table0.year,sum(nb_men) as nb_men, sum(pers_men) as pers_men,
		Table1.geom
		from ( select label as ColMaj,label,id_geom,geom from "pv_initialisation"."public"."TerritoryTable_PV_BDTopo_2020.08_full_2154" ) as Table1
		left join (
			select insee,year,nom_commune ,nb_men ,pers_men ,nb_pers_menages  from public.taille_menages_full  where substring(insee,1,2) like '35'
		) as Table0
		on Table0.insee = Table1.id_geom
		where Table1.id_geom is not null and year is not null 
		group by Table1.id_geom,Table0.year,Table1.geom
		order by Table1.id_geom,Table0.year
		),
	rank2 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154"
			WHERE rank = 2
			GROUP BY id_geom
	),
	t2 as (
		select rank2.id_geom as insee,t1.year,sum(nb_men) as nb_men,sum(pers_men) as pers_men,
		rank2.geom
		from rank2
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank2.geom)
		GROUP BY rank2.id_geom, t1."year", rank2.geom
	),
	rank3 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154"
			WHERE rank = 3
			GROUP BY id_geom
	),
	t3 as (
		select rank3.id_geom as insee,t1.year,sum(nb_men) as nb_men,sum(pers_men) as pers_men,
		rank3.geom
		from rank3
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank3.geom)
		GROUP BY rank3.id_geom, t1."year", rank3.geom
	),
	rank4 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154"
			WHERE rank = 4
			GROUP BY id_geom
	),
	t4 as (
		select rank4.id_geom as insee,t1.year,sum(nb_men) as nb_men,sum(pers_men) as pers_men,
		rank4.geom
		from t1,rank4
		WHERE t1.insee IN (
				SELECT terr1.id_geom
				FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154" terr1, rank4
				WHERE ST_Intersects(ST_PointOnSurface(terr1.geom),rank4.geom)
					AND terr1.rank = 1
		)
		GROUP BY rank4.id_geom, t1."year", rank4.geom
	)
	SELECT * FROM t1 where year is not null
	UNION
	SELECT * FROM t2 where year is not null
	UNION 
	SELECT * FROM t3 where year is not null
	UNION 
	SELECT * FROM t4 where year is not null
	ORDER BY insee, "year"
);

ALTER TABLE "F1_POP2_TailleMenages".taille_menages DROP IF EXISTS nb_pers_men,

ADD COLUMN nb_pers_men decimal;

--Select * from "F1_POP2_TailleMenages".taille_menages ,
UPDATE "F1_POP2_TailleMenages".taille_menages  SET nb_pers_men = pers_men/nb_men;
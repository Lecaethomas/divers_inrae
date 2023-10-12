-- nécessite l'existence des sorties de F4_EMP_EvolEmploi plus précisement la table
-- emploi_act_2011_2017

drop table if exists "public".activite_chomage_1564;
create table "public".activite_chomage_1564 as (
	
	-- Niv 1 : Commune
	with t1 as (
	select Table1.id_geom as insee, Table0.year,sum(pxx_pop1564) as pxx_pop1564,sum(pxx_act1564) as pxx_act1564,sum(pxx_chom1564) as pxx_chom1564,
	sum(pxx_actocc1564) as pxx_actocc1564,sum(pxx_inact1564) as pxx_inact1564,Table1.geom
	from ( select label as ColMaj,label,id_geom,geom from public."TerritoryTable_PV_BDTopo_2020" ) as Table1
	left join (
		select insee,year,nom_commune ,pxx_pop1564 ,pxx_act1564 ,pxx_chom1564 ,pxx_actocc1564 ,pxx_inact1564 from public.emploi_act_2011_2017 ea where substring(insee,1,2) like '35'
	) as Table0
	on Table0.insee = Table1.id_geom
	where Table1.id_geom is not null and year is not null 
	group by Table1.id_geom,Table0.year,Table1.geom
	order by Table1.id_geom,Table0.year
	),
	-- Géométries niveau 2 de la table territoire
	rank2 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."TerritoryTable_PV_BDTopo_2020"
			WHERE rank = 2
			GROUP BY id_geom
	),
	-- Niv 2 : Polarités
	t2 as (
		select rank2.id_geom as insee,t1.year,sum(pxx_pop1564) as pxx_pop1564,sum(pxx_act1564) as pxx_act1564,sum(pxx_chom1564) as pxx_chom1564,
		sum(pxx_actocc1564) as pxx_actocc1564,sum(pxx_inact1564) as pxx_inact1564,rank2.geom
		from rank2
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank2.geom)
		GROUP BY rank2.id_geom, t1."year", rank2.geom
	),
	-- Géométries niveau 3 de la table territoire
	rank3 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."TerritoryTable_PV_BDTopo_2020"
			WHERE rank = 3
			GROUP BY id_geom
	),
	-- Données à l'EPCI
	t3 as (
		select rank3.id_geom as insee,t1.year,sum(pxx_pop1564) as pxx_pop1564,sum(pxx_act1564) as pxx_act1564,sum(pxx_chom1564) as pxx_chom1564,
		sum(pxx_actocc1564) as pxx_actocc1564,sum(pxx_inact1564) as pxx_inact1564, rank3.geom
		from rank3
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank3.geom)
		GROUP BY rank3.id_geom, t1."year", rank3.geom
	),
	-- Géométries niveau 4 de la table territoire
	rank4 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."TerritoryTable_PV_BDTopo_2020"
			WHERE rank = 4
			GROUP BY id_geom
	),
	t4 as (
		select rank4.id_geom as insee,t1.year,sum(pxx_pop1564) as pxx_pop1564,sum(pxx_act1564) as pxx_act1564,sum(pxx_chom1564) as pxx_chom1564,
		sum(pxx_actocc1564) as pxx_actocc1564,sum(pxx_inact1564) as pxx_inact1564,rank4.geom
		from t1,rank4
		WHERE t1.insee IN (
				SELECT terr1.id_geom
				FROM public."TerritoryTable_PV_BDTopo_2020" terr1, rank4
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
)
SELECT "Code insee de la commune principale"::varchar cod_geo , "Logements créés":: int nb_log_crees, "year"::varchar FROM "F3_HAB_Logements_Autorises_local".extraction_pc_20220114_final epf 
UNION all
SELECT "Code insee de la commune principale"::varchar cod_geo , "Logements créés":: int nb_log_crees, "year"::varchar FROM "F3_HAB_Logements_Autorises_local"."extractions_PC_20220214_pour2017" epp 

-- le plus simple c'est de grouper les tables dans excel (PV nous les fournit par ECPI) puis les rentrer dans postgres et intégrer utiliser le script suivant 
-- (la première cte fait l'union avec la derniere donnée reçue qui permettait de compléter 2018 avec les PC déposés fin 2017 et validés en 2018)


--Concatenation des différents fichiers de permis de construire
drop  table if exists "F3_HAB_Logements_Autorises_local"."F3_HAB_Logements_Autorises_local" ;
create table "F3_HAB_Logements_Autorises_local"."F3_HAB_Logements_Autorises_local"  as (
	with t2 as (
	SELECT "Code insee de la commune principale"::varchar cod_geo , "Logements créés":: int nb_log_crees, "year"::varchar FROM "F3_HAB_Logements_Autorises_local".extraction_pc_20220114_final epf 
	UNION all
	SELECT "Code insee de la commune principale"::varchar cod_geo , "Logements créés":: int nb_log_crees, "year"::varchar FROM "F3_HAB_Logements_Autorises_local"."extractions_PC_20220214_pour2017" epp 
	),

	-- ! aggrégation aux échelles supérieures

	table1 as (
		select label, cod_geo insee,  "year" , sum(nb_log_crees)nb_log_crees, geom from t2  left join public."TerritoryTable_PV_BDTopo_2020.08_full_2154" tt on t2.cod_geo = tt.id_geom
		where tt.rank = 1
		group by label, cod_geo, geom, "year"
	),
	rank2 as (
	SELECT label, id_geom, ST_Union(geom) geom
		FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154" 
		WHERE rank = 2
		GROUP BY id_geom, label
	),
	table2 as (
	select rank2.label, rank2.id_geom as insee, table1."year", sum(nb_log_crees) as nb_log_crees , rank2.geom
	from rank2
	LEFT JOIN table1
	ON ST_Intersects(ST_PointOnSurface(table1.geom),rank2.geom)
	GROUP BY rank2.id_geom, table1."year", rank2.geom,rank2.label
	),
		rank3 as (
	SELECT label, id_geom, ST_Union(geom) geom
		FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154" 
		WHERE rank = 3
		GROUP BY id_geom, label
	),
	table3 as (
	select rank3.label, rank3.id_geom as insee, table1."year", sum(nb_log_crees) as nb_log_crees , rank3.geom
	from rank3
	LEFT JOIN table1
	ON ST_Intersects(ST_PointOnSurface(table1.geom),rank3.geom)
	GROUP BY rank3.id_geom, table1."year", rank3.geom,rank3.label
	),
			rank4 as (
	SELECT label, id_geom, ST_Union(geom) geom
		FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154" 
		WHERE rank = 4
		GROUP BY id_geom, label
	),
	table4 as (
	select rank4.label, rank4.id_geom as insee, table1."year", sum(nb_log_crees) as nb_log_crees , rank4.geom
	from rank4
	LEFT JOIN table1
	ON ST_Intersects(ST_PointOnSurface(table1.geom),rank4.geom)
	GROUP BY rank4.id_geom, table1."year", rank4.geom,rank4.label
	),
	table5 AS (
	select  insee::text, "year", nb_log_crees nb_log_aut from table1
	union
	select  insee::text, "year", nb_log_crees nb_log_aut from table2
	union
	select  insee::text, "year", nb_log_crees nb_log_aut from table3
	union
	select  insee::text, "year", nb_log_crees nb_log_aut from table4)
	SELECT * FROM table5 
	WHERE YEAR <> '2021'
	ORDER BY insee, year
);

select  insee, "year", nb_log_aut  from "F3_HAB_Logements_Autorises_local"."F3_HAB_Logements_Autorises_local"
order by insee, year;

--///--///--///--///--///--///--///--///--///--///--///
-- Association autorisation de PC / Parcelles
--//Essayer avec la table des parcelles de 2018?
--///--///--///--///--///--///--///--///--///--///--///
-- Regarder où se trouvent celles que l'on ne localise pas (fusion de commune)
-- On ne connaît pas le millésime de référence cadastrale? quel millésime de cadastre


with t2 as (
select translate(left("Parcelle", strpos("Parcelle", ',')-1), ' ', '') parcelles, "Code insee de la commune principale" insee
from "F3_HAB_Logements_Autorises_local"."RAF_export_lgmntsAutorises_full"
),
p as (
select p.geom, concat(p.section, p.numero) id_parcelle , commune
from "F3_HAB_Logements_Autorises_local"."parcelles_PV_etalab_11_2020" p 
)--,
--t3 as(
select p.geom, parcelles from t2 
left join  p
on t2.parcelles = id_parcelle 
and t2.insee :: varchar =p."commune"
where geom is not null
order by id_parcelle
--)

select count(*) from t3
where geom is not null;

--Reponse au besoin initial : connaître le nombre de logements autorisés dans le territoires
drop table if exists "F3_HAB_Logements_Autorises_local"."F3_HAB_Logements_Autorises_local";
create table "F3_HAB_Logements_Autorises_local"."F3_HAB_Logements_Autorises_local" as (
with t1 as (
select "Code insee de la commune principale" insee , sum("Logements créés") nb_log , "year" 
from "F3_HAB_Logements_Autorises_local"."extraction_pc_20220114_final"
group by "Code insee de la commune principale", "year"
order by "year", "Code insee de la commune principale" ),
a2 as (
	select  tt.id_geom insee,year, t1.nb_log,  tt.geom
		from t1 left join public."TerritoryTable_PV_BDTopo_2020.08_full_2154" tt
		on tt.id_geom = t1.insee::varchar),
rank2 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154"
			WHERE rank = 2
			GROUP BY id_geom
	),
	t2 as (
		select rank2.id_geom as insee,a2.year,sum(nb_log) as nb_log,
		rank2.geom
		from rank2
		LEFT JOIN a2
		ON ST_Intersects(ST_PointOnSurface(a2.geom),rank2.geom)
		GROUP BY rank2.id_geom,a2."year", rank2.geom
	),
	rank3 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154"
			WHERE rank = 3
			GROUP BY id_geom
	),
	t3 as (
		select rank3.id_geom as insee,a2.year,sum(nb_log) as nb_log,
		rank3.geom
		from rank3
		LEFT JOIN a2
		ON ST_Intersects(ST_PointOnSurface(a2.geom),rank3.geom)
		GROUP BY rank3.id_geom, a2."year", rank3.geom
	),
	rank4 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154"
			WHERE rank = 4
			GROUP BY id_geom
	),
	t4 as (
		select rank4.id_geom as insee,a2.year,sum(nb_log) as nb_log,
		rank4.geom
		from a2,rank4
		WHERE a2.insee IN (
				SELECT terr1.id_geom
				FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154" terr1, rank4
				WHERE ST_Intersects(ST_PointOnSurface(terr1.geom),rank4.geom)
					AND terr1.rank = 1
		)
		GROUP BY rank4.id_geom, a2."year", rank4.geom
	)
	SELECT insee, "year", nb_log nb_log_aut FROM a2 where year is not null and year < '2021'
	UNION
	SELECT insee, "year", nb_log nb_log_aut FROM t2 where year is not null and year < '2021'
	UNION 
	SELECT insee,"year",nb_log nb_log_aut FROM t3 where year is not null and year < '2021'
	UNION 
	SELECT insee,"year",nb_log nb_log_aut FROM t4 where year is not null and year < '2021'
	ORDER BY insee, "year"
);




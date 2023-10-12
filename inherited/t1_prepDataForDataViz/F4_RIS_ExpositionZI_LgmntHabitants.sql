-- Input : 
-- nom du schema													- F4_RIS_ExpositionZI_LgmntHabitants
-- la couche de locaux la plus acutalisée ::  						- fftp_2020_pb0010_local
-- la couche d'isochrones piétons 5, 10 , 15 autour des TAD :: 		- CAP_ZI_LOGEMENTS_V4_2019
-- la couche de population des communes :: 							- "INSEE_population_tot_2018_geo_2021"

-- date : 20220223
-- Summary:
-- Le principe de la requête (désolé pour les CTE mais je suis en galère d'espace disque donc je préfère cette solution) 
-- c'est de compter les logements (ff) dans les différents isochrones (iso) qu'on aura dissolu (groupe by id_geom) après avoir appliqué un buffer de +50m (raison inconnue mais la méthodo d'origine fait ça)  
-- !! et seulement à l'échelle des communes !! sinon ça prend trop de temps. Donc ensuite il faut aggrèger aux échelles sup. (on passe de 4h de calcul à 1m)

-- 1m7min 


--- !!! ATTENTION !!!
-- On a besoin de conserver l'id unique des points et celui hérité par les isochrones pour la dataviz. En effet il est possible de cliquer sur le point pour afficher uniquement les isochrones correpsondants à un arrêt
-- pour ça il faut une correspondance entre l'id de larret et celui (commun) aux trois isochrones correspondants
--- !!! ATTENTION - bis !!! 
-- pour un bel affichage on utilise l'outil qgis ordoner la couche avec l'expression toint("time") et decoche l'option par ordre croissant 
-- (comme ça on a les isochrone dans l'ordre 5, 10 , 15)


-- on a besoin de créer une table "population" à part et pas dans la requête globale suivante car il n'y a pas forcément d'isochrones dans toutes les communes, 
-- donc pendant l'aggrégation/somme on ne récupère pa tous les habitants

-- //-- //-- //-- //-- //-- //-- //-- //-- //-- //-- //-- //-- //
-- //-- //-- //-- //-- // 2017-- //-- //-- //-- //-- //-- //-- //
-- //-- //-- //-- //-- //-- //-- //-- //-- //-- //-- //-- //-- //

-- aggregation de la pop 2017 aux différentes échelles 

drop table if exists "F4_RIS_ExpositionZI_LgmntHabitants".pop_cap_2017;
create table "F4_RIS_ExpositionZI_LgmntHabitants".pop_cap_2017 as (
with t1 as(
		
			select tt.id_geom insee, tt.geom, pop.total_pop_17::int  
			from public."territory_table_CAP20" tt
			left join "F4_RIS_ExpositionZI_LgmntHabitants"."INSEE_population_tot_2017_geo_2020" pop
			on tt.id_geom::varchar  = pop."CODGEO"::varchar
			where tt.rank = '1'
			
		),
rank2 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."territory_table_CAP20"
			WHERE rank = 2
			GROUP BY id_geom
	),
	t2 as (
		select rank2.id_geom as insee, sum(total_pop_17)::int as poptot, rank2.geom
		from rank2
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank2.geom)
		GROUP BY rank2.id_geom,  rank2.geom
	),
	rank3 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."territory_table_CAP20"
			WHERE rank = 3
			GROUP BY id_geom
	),
	t3 as (
		select rank3.id_geom as insee, sum(total_pop_17)::int as poptot, 
		rank3.geom
		from rank3
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank3.geom)
		GROUP BY rank3.id_geom, rank3.geom
	),
	rank4 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."territory_table_CAP20"
			WHERE rank = 4
			GROUP BY id_geom
	),
	t4 as (
		select rank4.id_geom as insee, sum(total_pop_17)::int as poptot,
		rank4.geom
		from t1,rank4
		WHERE t1.insee IN (
				SELECT terr1.id_geom
				FROM public."territory_table_CAP20" terr1, rank4
				WHERE ST_Intersects(ST_PointOnSurface(terr1.geom),rank4.geom)
					AND terr1.rank = 1
		)
		GROUP BY rank4.id_geom, rank4.geom
	)
	--final as (
	SELECT t1.insee id_geom,  total_pop_17::int as poptot  FROM t1 --where year is not null
	UNION
	SELECT t2.insee id_geom ,  t2.poptot  FROM t2 --where year is not null
	UNION 
	SELECT t3.insee id_geom,  t3.poptot  FROM t3 --where year is not null
	UNION 
	SELECT t4.insee id_geom, t4.poptot  FROM t4 --where year is not null
	ORDER BY id_geom--, "year"
);


DROP TABLE IF EXISTS "F4_RIS_ExpositionZI_LgmntHabitants".dataviz_logements_2017 ;
CREATE TABLE "F4_RIS_ExpositionZI_LgmntHabitants".dataviz_logements_2017 AS (
select  ff.geom , ff.idpk
	from "F1_DEN_Densite_Logements_IN_OUT".fftp_2020_pb0010_local ff
		left join public."territory_table_CAP20" tt
		on st_intersects(tt.geom, ff.geom)
	where tt.rank = '3' AND ff.dteloc IN ('1','2') AND jannath < '2017'
);


-- Calcul des logements compris dans les isochrones & communes 
-- et jointure avec la table de pop

drop table if exists "F4_RIS_ExpositionZI_LgmntHabitants"."chiffres_cles_intermediaire_2017";
create table "F4_RIS_ExpositionZI_LgmntHabitants"."chiffres_cles_intermediaire_2017" as (
with ff as(
select tt.id_geom, ff.*  
	from "F4_RIS_ExpositionZI_LgmntHabitants".dataviz_logements_2017 ff
		left join public."territory_table_CAP20" tt
		on st_intersects(tt.geom, ff.geom)
	where tt.rank = '1' --AND ff.dteloc IN ('1','2') AND jannath < '2019'
	--where  tt.id_geom in ('56030', '56058', '44125')
),
iso as (
select  row_number() OVER () AS id, tt.id_geom , iso."TYPE_ALEA"::varchar, st_union(st_intersection(tt.geom, st_makevalid(st_buffer(iso.geom,0)))) geom 
	from "F4_RIS_ExpositionZI_LgmntHabitants"."cap_zonages_inondations_2019" iso
		left join public."territory_table_CAP20" tt
		on st_intersects(tt.geom,iso.geom)
	where tt.rank = '1'
	--where  tt.id_geom in ('56030', '56058', '44125')
	group by iso."TYPE_ALEA", tt.id_geom
),
log_in as (
select iso."TYPE_ALEA"::varchar, count(st_intersects(ff.geom, iso.geom)) nblog, 'IN'::varchar  pos , ff.id_geom id_geom
	from iso 
		left join ff 
		on st_intersects(ff.geom, iso.geom)
	group by iso."TYPE_ALEA", ff.id_geom
	),
log_out as(
SELECT 
  logt.id_geom id_geom, count(logt.idpk) nblog, 'OUT'::varchar  pos, CAST(NULL AS varchar) "TYPE_ALEA"
FROM 
  ff as logt
LEFT JOIN
  iso ON
  ST_Intersects(logt.geom,iso.geom)
WHERE iso.id IS null
group by logt.id_geom
),
t1 as(
		with t1_1 as (
			select id_geom insee,nblog::int nb_log ,pos,"TYPE_ALEA"::varchar from log_out
			union
			select id_geom insee,nblog::int nb_log,pos,"TYPE_ALEA"::varchar from log_in)
		
			select t1_1.*, tt.geom  from t1_1 
			left join public."territory_table_CAP20" tt
			on tt.id_geom = t1_1.insee
		),
rank2 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."territory_table_CAP20"
			WHERE rank = 2
			GROUP BY id_geom
	),
	t2 as (
		select rank2.id_geom as insee,sum(nb_log)::int  as nb_log, pos , CAST("TYPE_ALEA"as varchar),
		rank2.geom
		from rank2
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank2.geom)
		GROUP BY rank2.id_geom,  rank2.geom,pos,"TYPE_ALEA"
	),
	rank3 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."territory_table_CAP20"
			WHERE rank = 3
			GROUP BY id_geom
	),
	t3 as (
		select rank3.id_geom as insee,sum(nb_log)::int  as nb_log, pos,CAST("TYPE_ALEA"as varchar),
		rank3.geom
		from rank3
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank3.geom)
		GROUP BY rank3.id_geom, rank3.geom,pos,"TYPE_ALEA"
	),
	rank4 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."territory_table_CAP20"
			WHERE rank = 4
			GROUP BY id_geom
	),
	t4 as (
		select rank4.id_geom as insee,sum(nb_log)::int  as nb_log  , pos,CAST("TYPE_ALEA"as varchar),
		rank4.geom
		from t1,rank4
		WHERE t1.insee IN (
				SELECT terr1.id_geom
				FROM public."territory_table_CAP20" terr1, rank4
				WHERE ST_Intersects(ST_PointOnSurface(terr1.geom),rank4.geom)
					AND terr1.rank = 1
		)
		GROUP BY rank4.id_geom, rank4.geom,pos,"TYPE_ALEA"
	),
	final as (
	SELECT t1.insee , t1.nb_log ,  t1.pos,  CAST("TYPE_ALEA"as varchar) FROM t1 --where year is not null
	UNION
	SELECT t2.insee , t2.nb_log ,  t2.pos,  CAST("TYPE_ALEA"as varchar) FROM t2 --where year is not null
	UNION 
	SELECT t3.insee , t3.nb_log ,  t3.pos,  CAST("TYPE_ALEA"as varchar) FROM t3 --where year is not null
	UNION 
	SELECT t4.insee , t4.nb_log ,  t4.pos,  CAST("TYPE_ALEA"as varchar) FROM t4 --where year is not null
	ORDER BY insee--, "year"
	)
	select final.insee , nb_log::int , poptot::int  , pos , CAST("TYPE_ALEA"as varchar) from final
		left join "F4_RIS_ExpositionZI_LgmntHabitants".pop_cap_2017 pop
			on pop.insee = final.insee
);

-- La structure de la table utilisée en dataviz nécessite que l'on ajoute une étape supplémentaire (et ça évite que l'on ralonge la liste des CTE)
-- Ici on calcule le nombre total de logements par territoire (les logements dans les isochrones (ceux déjà stockés dans 15min) + les logements hors isochrone (OUT))
-- ça permet d'éviter de recalculer l'intersection
-- Ensuite on calcule les ratios et renomme les champs

drop table if exists "F4_RIS_ExpositionZI_LgmntHabitants".chiffres_cles_2017 ; 
create table "F4_RIS_ExpositionZI_LgmntHabitants".chiffres_cles_2017 as (
with ratio as (
	with out as(
		select insee,  sum(nb_log)  nb_log from "F4_RIS_ExpositionZI_LgmntHabitants".chiffres_cles_intermediaire_2017 
		where pos = 'OUT'group by insee
),
	min15 as(
		select insee,  sum(nb_log) nb_log from "F4_RIS_ExpositionZI_LgmntHabitants".chiffres_cles_intermediaire_2017 
		where "TYPE_ALEA" = 'MOYEN CC - Xynthia + 60cm' OR "TYPE_ALEA" = 'EXTREME'  group by insee
)
select out.insee, out.nb_log + min15.nb_log as tot_log --, cc.poptot ,  cc.pos , cc."time" 
	from "out"
		left join min15 
		on out.insee = min15.insee
)
select cc.insee as id_geom, cc.nb_log as "Count_ENTITIES", poptot ,  pos "Location" , COALESCE("TYPE_ALEA", 'TotGeo') nivalea , 
	ratio.tot_log::numeric / poptot::numeric as "ratioLocPop",  
	ratio.tot_log::numeric / poptot::numeric * nb_log as "EquivPop"
from "F4_RIS_ExpositionZI_LgmntHabitants".chiffres_cles_intermediaire_2017 cc 
	left join ratio
		on ratio.insee = cc.insee
		
	ORDER BY cc.insee, "TYPE_ALEA"
	
);


-- //-- //-- //-- //-- //-- //-- //-- //-- //-- //-- //-- //-- //
-- //-- //-- //-- //-- // 2018-- //-- //-- //-- //-- //-- //-- //
-- //-- //-- //-- //-- //-- //-- //-- //-- //-- //-- //-- //-- //

-- aggregation de la pop 2018 aux différentes échelles 
drop table if exists "F4_RIS_ExpositionZI_LgmntHabitants".pop_cap_2018;
create table "F4_RIS_ExpositionZI_LgmntHabitants".pop_cap_2018 as (
with t1 as(
		
			select tt.id_geom insee, tt.geom, pop.total_pop_18::int  
			from public."territory_table_CAP20" tt
			left join "F4_RIS_ExpositionZI_LgmntHabitants"."INSEE_population_tot_2018_geo_2021" pop
			on tt.id_geom::varchar  = pop."CODGEO"::varchar
			where tt.rank = '1'
			
		),
rank2 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."territory_table_CAP20"
			WHERE rank = 2
			GROUP BY id_geom
	),
	t2 as (
		select rank2.id_geom as insee, sum(total_pop_18)::int as poptot, rank2.geom
		from rank2
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank2.geom)
		GROUP BY rank2.id_geom,  rank2.geom
	),
	rank3 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."territory_table_CAP20"
			WHERE rank = 3
			GROUP BY id_geom
	),
	t3 as (
		select rank3.id_geom as insee, sum(total_pop_18)::int as poptot, 
		rank3.geom
		from rank3
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank3.geom)
		GROUP BY rank3.id_geom, rank3.geom
	),
	rank4 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."territory_table_CAP20"
			WHERE rank = 4
			GROUP BY id_geom
	),
	t4 as (
		select rank4.id_geom as insee, sum(total_pop_18)::int as poptot,
		rank4.geom
		from t1,rank4
		WHERE t1.insee IN (
				SELECT terr1.id_geom
				FROM public."territory_table_CAP20" terr1, rank4
				WHERE ST_Intersects(ST_PointOnSurface(terr1.geom),rank4.geom)
					AND terr1.rank = 1
		)
		GROUP BY rank4.id_geom, rank4.geom
	)
	--final as (
	SELECT t1.insee id_geom,  total_pop_18::int as poptot  FROM t1 --where year is not null
	UNION
	SELECT t2.insee id_geom ,  t2.poptot  FROM t2 --where year is not null
	UNION 
	SELECT t3.insee id_geom,  t3.poptot  FROM t3 --where year is not null
	UNION 
	SELECT t4.insee id_geom, t4.poptot  FROM t4 --where year is not null
	ORDER BY id_geom--, "year"
);




--//--//--//--//
--//--// Table des locaux pour la viz
--//--//--//--//

DROP TABLE IF EXISTS "F4_RIS_ExpositionZI_LgmntHabitants".dataviz_logements_2018 ;
CREATE TABLE "F4_RIS_ExpositionZI_LgmntHabitants".dataviz_logements_2018 AS (
select  ff.geom , idpk
	from "F1_DEN_Densite_Logements_IN_OUT".fftp_2020_pb0010_local ff
		left join public."territory_table_CAP20" tt
		on st_intersects(tt.geom, ff.geom)
	where tt.rank = '3' AND ff.dteloc IN ('1','2') AND jannath < '2019'
);


select  count(ff.geom)-- , idpk
	from "F1_DEN_Densite_Logements_IN_OUT".fftp_2020_pb0010_local ff
		left join public."territory_table_CAP20" tt
		on st_intersects(tt.geom, ff.geom)
	where tt.rank = '1' AND ff.dteloc IN ('1','2') AND jannath < '2019'

-- Calcul des logements compris dans les isochrones & communes 
-- et jointure avec la table de pop

drop table if exists "F4_RIS_ExpositionZI_LgmntHabitants"."chiffres_cles_intermediaire_2018";
create table "F4_RIS_ExpositionZI_LgmntHabitants"."chiffres_cles_intermediaire_2018" as (
with ff as(
select tt.id_geom, ff.*  
	from "F4_RIS_ExpositionZI_LgmntHabitants".dataviz_logements_2018 ff
		left join public."territory_table_CAP20" tt
		on st_intersects(tt.geom, ff.geom)
	where tt.rank = '1' --AND ff.dteloc IN ('1','2') AND jannath < '2019'
	--where  tt.id_geom in ('56030', '56058', '44125')
),
iso as (
select  row_number() OVER () AS id, tt.id_geom , iso."TYPE_ALEA"::varchar, st_union(st_intersection(tt.geom, st_makevalid(st_buffer(iso.geom,0)))) geom 
	from "F4_RIS_ExpositionZI_LgmntHabitants"."cap_zonages_inondations_2019" iso
		left join public."territory_table_CAP20" tt
		on st_intersects(tt.geom,iso.geom)
	where tt.rank = '1'
	--where  tt.id_geom in ('56030', '56058', '44125')
	group by iso."TYPE_ALEA", tt.id_geom
),
log_in as (
select iso."TYPE_ALEA"::varchar, count(st_intersects(ff.geom, iso.geom)) nblog, 'IN'::varchar  pos , ff.id_geom id_geom
	from iso 
		left join ff 
		on st_intersects(ff.geom, iso.geom)
	group by iso."TYPE_ALEA", ff.id_geom
	),
log_out as(
SELECT 
  logt.id_geom id_geom, count(logt.idpk) nblog, 'OUT'::varchar  pos, CAST(NULL AS varchar) "TYPE_ALEA"
FROM 
  ff as logt
LEFT JOIN
  iso ON
  ST_Intersects(logt.geom,iso.geom)
WHERE iso.id IS null
group by logt.id_geom
),
t1 as(
		with t1_1 as (
			select id_geom insee,nblog::int nb_log ,pos,"TYPE_ALEA"::varchar from log_out
			union
			select id_geom insee,nblog::int nb_log,pos,"TYPE_ALEA"::varchar from log_in)
		
			select t1_1.*, tt.geom  from t1_1 
			left join public."territory_table_CAP20" tt
			on tt.id_geom = t1_1.insee
		),
rank2 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."territory_table_CAP20"
			WHERE rank = 2
			GROUP BY id_geom
	),
	t2 as (
		select rank2.id_geom as insee,sum(nb_log)::int  as nb_log, pos , CAST("TYPE_ALEA"as varchar),
		rank2.geom
		from rank2
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank2.geom)
		GROUP BY rank2.id_geom,  rank2.geom,pos,"TYPE_ALEA"
	),
	rank3 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."territory_table_CAP20"
			WHERE rank = 3
			GROUP BY id_geom
	),
	t3 as (
		select rank3.id_geom as insee,sum(nb_log)::int  as nb_log, pos,CAST("TYPE_ALEA"as varchar),
		rank3.geom
		from rank3
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank3.geom)
		GROUP BY rank3.id_geom, rank3.geom,pos,"TYPE_ALEA"
	),
	rank4 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."territory_table_CAP20"
			WHERE rank = 4
			GROUP BY id_geom
	),
	t4 as (
		select rank4.id_geom as insee,sum(nb_log)::int  as nb_log  , pos,CAST("TYPE_ALEA"as varchar),
		rank4.geom
		from t1,rank4
		WHERE t1.insee IN (
				SELECT terr1.id_geom
				FROM public."territory_table_CAP20" terr1, rank4
				WHERE ST_Intersects(ST_PointOnSurface(terr1.geom),rank4.geom)
					AND terr1.rank = 1
		)
		GROUP BY rank4.id_geom, rank4.geom,pos,"TYPE_ALEA"
	),
	final as (
	SELECT t1.insee , t1.nb_log ,  t1.pos,  CAST("TYPE_ALEA"as varchar) FROM t1 --where year is not null
	UNION
	SELECT t2.insee , t2.nb_log ,  t2.pos,  CAST("TYPE_ALEA"as varchar) FROM t2 --where year is not null
	UNION 
	SELECT t3.insee , t3.nb_log ,  t3.pos,  CAST("TYPE_ALEA"as varchar) FROM t3 --where year is not null
	UNION 
	SELECT t4.insee , t4.nb_log ,  t4.pos,  CAST("TYPE_ALEA"as varchar) FROM t4 --where year is not null
	ORDER BY insee--, "year"
	)
	select final.insee , nb_log::int , poptot::int  , pos , CAST("TYPE_ALEA"as varchar) from final
		left join "F4_RIS_ExpositionZI_LgmntHabitants".pop_cap_2018 pop
			on pop.insee = final.insee
);

SELECT * FROM "F4_RIS_ExpositionZI_LgmntHabitants".chiffres_cles_intermediaire_2017
ORDER BY insee;

SELECT * FROM "F4_RIS_ExpositionZI_LgmntHabitants".chiffres_cles_intermediaire_2018
ORDER BY insee

-- La structure de la table utilisée en dataviz nécessite que l'on ajoute une étape supplémentaire (et ça évite que l'on ralonge la liste des CTE)
-- Ici on calcule le nombre total de logements par territoire (les logements dans les isochrones (ceux déjà stockés dans 15min) + les logements hors isochrone (OUT))
-- ça permet d'éviter de recalculer l'intersection
-- Ensuite on calcule les ratios et renomme les champs

drop table if exists "F4_RIS_ExpositionZI_LgmntHabitants".chiffres_cles_2018 ; 
create table "F4_RIS_ExpositionZI_LgmntHabitants".chiffres_cles_2018 as (
with ratio as (
	with out as(
		select insee,  sum(nb_log)  nb_log from "F4_RIS_ExpositionZI_LgmntHabitants".chiffres_cles_intermediaire_2018 
		where pos = 'OUT'group by insee
),
	min15 as(
		select insee,  sum(nb_log) nb_log from "F4_RIS_ExpositionZI_LgmntHabitants".chiffres_cles_intermediaire_2018 
		where "TYPE_ALEA" = 'MOYEN CC - Xynthia + 60cm' OR "TYPE_ALEA" = 'EXTREME'  group by insee
)
select out.insee, out.nb_log + min15.nb_log as tot_log --, cc.poptot ,  cc.pos , cc."time" 
	from "out"
		left join min15 
		on out.insee = min15.insee
)
select cc.insee as id_geom, cc.nb_log as "Count_ENTITIES", poptot ,  pos "Location" , COALESCE("TYPE_ALEA", 'TotGeo') nivalea , 
	ratio.tot_log::numeric / poptot::numeric as "ratioLocPop",  
	ratio.tot_log::numeric / poptot::numeric * nb_log as "EquivPop"
from "F4_RIS_ExpositionZI_LgmntHabitants".chiffres_cles_intermediaire_2018 cc 
	left join ratio
		on ratio.insee = cc.insee
	ORDER BY cc.insee, "TYPE_ALEA"
	 
);



DROP TABLE IF EXISTS "F4_RIS_ExpositionZI_LgmntHabitants".chiffres_cles_pop_final_2018; 
CREATE TABLE "F4_RIS_ExpositionZI_LgmntHabitants".chiffres_cles_pop_final_2018 AS (
SELECT id_geom, nivalea, "Location", CASE WHEN "Location"= 'OUT' THEN poptot ELSE "EquivPop"::int  END "Count_ENTITIES" 
FROM "F4_RIS_ExpositionZI_LgmntHabitants".chiffres_cles_2018
WHERE id_geom IS NOT NULL );

DROP TABLE IF EXISTS "F4_RIS_ExpositionZI_LgmntHabitants".chiffres_cles_pop_final_2017; 
CREATE TABLE "F4_RIS_ExpositionZI_LgmntHabitants".chiffres_cles_pop_final_2017 AS (
SELECT id_geom, nivalea, "Location", CASE WHEN "Location"= 'OUT' THEN poptot ELSE "EquivPop"::int END "Count_ENTITIES" 
FROM "F4_RIS_ExpositionZI_LgmntHabitants".chiffres_cles_2017
WHERE id_geom IS NOT NULL );


--//--//--//--//
--//--// Table des isochrones pour la viz
--//--//--//--//
DROP TABLE IF EXISTS "F4_RIS_ExpositionZI_LgmntHabitants".dataviz_zonages ;
CREATE TABLE "F4_RIS_ExpositionZI_LgmntHabitants".dataviz_zonages AS (
select   iso.id::int , iso.geom,50 , "TYPE_ALEA"
	from "F4_RIS_ExpositionZI_LgmntHabitants"."cap_zonages_inondations_2019" iso
		,public."territory_table_CAP20" tt
	where tt.rank = '1' AND st_intersects(tt.geom, iso.geom)
	--ORDER BY "TYPE_ALEA" DESC 
)






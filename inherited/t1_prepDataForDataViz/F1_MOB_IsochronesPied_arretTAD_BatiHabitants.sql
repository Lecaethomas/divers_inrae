-- Input : 
-- nom du schema													- F1_MOB_IsochronesPied_arretTAD_BatiHabitants
-- la couche de locaux la plus acutalisée ::  						- fftp_2020_pb0010_local
-- la couche d'isochrones piétons 5, 10 , 15 autour des TAD :: 		- isochrones_5_10_15_pieton_arrets_TAD
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
drop table if exists "F1_MOB_IsochronesPied_arretTAD_BatiHabitants".pop_cap_2018;
create table "F1_MOB_IsochronesPied_arretTAD_BatiHabitants".pop_cap_2018 as (
with t1 as(
		
			select tt.id_geom insee, tt.geom, pop.total_pop_18::int  
			from public."territory_table_CAP20" tt
			left join "F1_MOB_IsochronesPied_arretTAD_BatiHabitants"."INSEE_population_tot_2018_geo_2021" pop
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
	SELECT t1.insee ,  total_pop_18::int as poptot  FROM t1 --where year is not null
	UNION
	SELECT t2.insee ,  t2.poptot  FROM t2 --where year is not null
	UNION 
	SELECT t3.insee ,  t3.poptot  FROM t3 --where year is not null
	UNION 
	SELECT t4.insee , t4.poptot  FROM t4 --where year is not null
	ORDER BY insee--, "year"
);


-- Calcul des logements compris dans les isochrones & communes 
-- et jointure avec la table de pop


drop table if exists "F1_MOB_IsochronesPied_arretTAD_BatiHabitants"."chiffres_cles_intermediaire";
create table "F1_MOB_IsochronesPied_arretTAD_BatiHabitants"."chiffres_cles_intermediaire" as (
with ff as(
select tt.id_geom, ff.*  
	from "F1_DEN_Densite_Logements_IN_OUT".fftp_2020_pb0010_local ff
		left join public."territory_table_CAP20" tt
		on st_intersects(tt.geom, ff.geom)
	where tt.rank = '1' AND ff.dteloc IN ('1','2')
	--where  tt.id_geom in ('56030', '56058', '44125')
),
iso as (
select  row_number() OVER () AS id, tt.id_geom , iso."time"::varchar, st_union(st_intersection(tt.geom, st_buffer(iso.geom,50))) geom 
	from "F1_MOB_IsochronesPied_arretTAD_BatiHabitants"."isochrones_5_10_15_pieton_arrets_TAD" iso
		left join public."territory_table_CAP20" tt
		on st_intersects(tt.geom,iso.geom)
	where tt.rank = '1'
	--where  tt.id_geom in ('56030', '56058', '44125')
	group by iso."time", tt.id_geom
),
log_in as (
select iso."time"::varchar, count(st_intersects(ff.geom, iso.geom)) nblog, 'IN'::varchar  pos , ff.id_geom id_geom
	from iso 
		left join ff 
		on st_intersects(ff.geom, iso.geom)
	group by iso."time", ff.id_geom
	),
log_out as(
SELECT 
  logt.id_geom id_geom, count(logt.idpk) nblog, 'OUT'::varchar  pos, CAST(NULL AS bigint) "time"
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
			select id_geom insee,nblog::int nb_log ,pos,"time"::varchar from log_out
			union
			select id_geom insee,nblog::int nb_log,pos,"time"::varchar from log_in)
		
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
		select rank2.id_geom as insee,sum(nb_log)::int  as nb_log, pos , CAST("time"as bigint),
		rank2.geom
		from rank2
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank2.geom)
		GROUP BY rank2.id_geom,  rank2.geom,pos,"time"
	),
	rank3 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."territory_table_CAP20"
			WHERE rank = 3
			GROUP BY id_geom
	),
	t3 as (
		select rank3.id_geom as insee,sum(nb_log)::int  as nb_log, pos,CAST("time"as bigint),
		rank3.geom
		from rank3
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank3.geom)
		GROUP BY rank3.id_geom, rank3.geom,pos,"time"
	),
	rank4 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."territory_table_CAP20"
			WHERE rank = 4
			GROUP BY id_geom
	),
	t4 as (
		select rank4.id_geom as insee,sum(nb_log)::int  as nb_log  , pos,CAST("time"as bigint),
		rank4.geom
		from t1,rank4
		WHERE t1.insee IN (
				SELECT terr1.id_geom
				FROM public."territory_table_CAP20" terr1, rank4
				WHERE ST_Intersects(ST_PointOnSurface(terr1.geom),rank4.geom)
					AND terr1.rank = 1
		)
		GROUP BY rank4.id_geom, rank4.geom,pos,"time"
	),
	final as (
	SELECT t1.insee , t1.nb_log ,  t1.pos,  CAST("time"as bigint) FROM t1 --where year is not null
	UNION
	SELECT t2.insee , t2.nb_log ,  t2.pos,  CAST("time"as bigint) FROM t2 --where year is not null
	UNION 
	SELECT t3.insee , t3.nb_log ,  t3.pos,  CAST("time"as bigint) FROM t3 --where year is not null
	UNION 
	SELECT t4.insee , t4.nb_log ,  t4.pos,  CAST("time"as bigint) FROM t4 --where year is not null
	ORDER BY insee--, "year"
	)
	select final.insee , nb_log::int , poptot::int  , pos , CAST("time"as bigint) from final
		left join "F1_MOB_IsochronesPied_arretTAD_BatiHabitants".pop_cap_2018 pop
			on pop.insee = final.insee
);

-- La structure de la table utilisée en dataviz nécessite que l'on ajoute une étape supplémentaire (et ça évite que l'on ralonge la liste des CTE)
-- Ici on calcule le nombre total de logements par territoire (les logements dans les isochrones (ceux déjà stockés dans 15min) + les logements hors isochrone (OUT))
-- ça permet d'éviter de recalculer l'intersection
-- Ensuite on calcule les ratios et renomme les champs

drop table if exists "F1_MOB_IsochronesPied_arretTAD_BatiHabitants".chiffres_cles ; 
create table "F1_MOB_IsochronesPied_arretTAD_BatiHabitants".chiffres_cles as (
with ratio as (
	with out as(
		select insee,  sum(nb_log)  nb_log from "F1_MOB_IsochronesPied_arretTAD_BatiHabitants".chiffres_cles_intermediaire 
		where pos = 'OUT'group by insee
),
	min15 as(
		select insee,  sum(nb_log) nb_log from "F1_MOB_IsochronesPied_arretTAD_BatiHabitants".chiffres_cles_intermediaire 
		where time = '15'group by insee
)
select out.insee, out.nb_log + min15.nb_log as tot_log --, cc.poptot ,  cc.pos , cc."time" 
	from "out"
		left join min15 
		on out.insee = min15.insee
)
select cc.insee as id_geom, cc.nb_log as "Count_ENTITIES", poptot ,  pos "Location" , time , 
	ratio.tot_log::numeric / poptot::numeric as "ratioLocPop",  
	ratio.tot_log::numeric / poptot::numeric * nb_log as "EquivPop"
from "F1_MOB_IsochronesPied_arretTAD_BatiHabitants".chiffres_cles_intermediaire cc 
	left join ratio
		on ratio.insee = cc.insee
	ORDER BY cc.insee, time
)


--//--//--//--//
--//--// Table des locaux pour la viz
--//--//--//--//

DROP TABLE IF EXISTS "F1_MOB_IsochronesPied_arretTAD_BatiHabitants".dataviz_logements ;
CREATE TABLE "F1_MOB_IsochronesPied_arretTAD_BatiHabitants".dataviz_logements AS (
select  ff.geom , ff.idlocal, ff.dteloc, ff.dteloctxt
	from "F1_DEN_Densite_Logements_IN_OUT".fftp_2020_pb0010_local ff
		left join public."territory_table_CAP20" tt
		on st_intersects(tt.geom, ff.geom)
	where tt.rank = '1' AND ff.dteloc IN ('1','2') AND jannath < 2019
)
--//--//--//--//
--//--// Table des isochrones pour la viz
--//--//--//--//
DROP TABLE IF EXISTS "F1_MOB_IsochronesPied_arretTAD_BatiHabitants".dataviz_isochrones ;
CREATE TABLE "F1_MOB_IsochronesPied_arretTAD_BatiHabitants".dataviz_isochrones AS (
select   iso.id::int , st_buffer(iso.geom,50) ,  "time"
	from "F1_MOB_IsochronesPied_arretTAD_BatiHabitants"."isochrones_5_10_15_pieton_arrets_TAD" iso
		,public."territory_table_CAP20" tt
		
	where tt.rank = '1' AND st_intersects(tt.geom, iso.geom)
	ORDER BY "time" DESC 
)





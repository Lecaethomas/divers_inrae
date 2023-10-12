-- MANDATORY:
--schéma : 						"F5_ECO_NouveauxCommerces_InOut"
--couche sirene : 				"geo_siret_35" (récup sur opendatasoft avec les statut d'activité des établissements en 'A' )
--territory table : 			public."TerritoryTable_PV_BDTopo_2020.08_full_2154"
--centralité:					public."FX_OCS_CentraliteDetermination_perimetres_centralites"
--sites peripheriques:			public."sites_peripheriques"


-- C'est un indicateur qui permet d'obtenir le nombre de commerces selon la définition donnée par le SUPV dans son DOO (peut différer de ce qui est 
-- donné dans la liste des équipements maison). Les chiffres sont calculés dans les centralités (maison) et les sites périphériques (SUPV)

-- WARNING : partie spé SUPV ci-dessous



--------------------------------------------------------------------------------------------------------------------------------------------------

-- Prétraitement de la table issue d'opendatasoft, on n'a déjà que les établissements actifs.
drop table if exists "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_commerces";
create table "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_commerces" as (
select t1.geom, "activiteprincipaleetablissement",soussectionetablissement, extract(year from t1.datecreationetablissement) "year"
	from "F5_ECO_NouveauxCommerces_InOut"."geo_siret_35" t1 , 
	public."TerritoryTable_PV_BDTopo_2020.08_full_2154" t2
		where t2.rank='4' and st_intersects(t1.geom,t2.geom) and activitePrincipaleEtablissement like '47%' --la catégorie commerces de détail
		or activitePrincipaleEtablissement IN ('10.13B','10.71C', '10.71D')
);

drop index if exists "F5_ECO_Nouveaux_Commerces_commerces_idx" ;
create index "F5_ECO_Nouveaux_Commerces_InOut_commerces_idx" on "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_commerces" using gist(geom);

--Chiffres clés
-----
-- 2018
-- En fait pour l'initialisation on ne produit que 2020 mais je laisse 2018 au cas où .. 

DROP TABLE IF EXISTS "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_chiffres_cles_centralite_2018";
CREATE TABLE "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_chiffres_cles_centralite_2018"AS (
	-- Nombre total de locaux par commune. Les communes sans locaux n'apparaitront pas dans la table finale
	WITH total_by_com AS ( 
		SELECT t.id_geom id_geom,  Count(a.geom) "Count_ENTITIES"
		FROM "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_commerces" a, public."TerritoryTable_PV_BDTopo_2020.08_full_2154" t
		WHERE ST_Intersects(a.geom,t.geom) and a.year < 2019
		GROUP BY id_geom
	),
	-- Nombre de locaux dans la centralité par commune
	total_by_com_in_env AS (
		SELECT t.id_geom id_geom, Count(a.geom) "Count_ENTITIES",'IN' "Location_centra"
		FROM "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_commerces" a, public."TerritoryTable_PV_BDTopo_2020.08_full_2154" t, public."sgevt_centralite_2021" env
		WHERE  ST_Intersects(a.geom,t.geom) and ST_Intersects(a.geom,env.geom) and a.year < 2019
		GROUP BY t.id_geom,  "Location_centra"
	),
	-- Nombre de locaux hors centralités par commune
	total_by_com_out_env AS (
		SELECT total_by_com.id_geom id_geom, COALESCE(SUM(total_by_com."Count_ENTITIES" - total_by_com_in_env."Count_ENTITIES"),0) "Count_ENTITIES", 'OUT' "Location_centra"
		FROM total_by_com 
		LEFT JOIN total_by_com_in_env
		ON total_by_com.id_geom = total_by_com_in_env.id_geom
		--AND total_by_com."Categorie" = total_by_com_in_env."Categorie"
		GROUP BY total_by_com.id_geom,  "Location_centra" 
	)	-- Union par commune du nombre de locaux dans/hors la centralité
	
	SELECT id_geom::text, "Count_ENTITIES"::int,  "Location_centra"::text , 'Commerces' as "Categorie"FROM total_by_com_in_env
	UNION
	SELECT id_geom::text, "Count_ENTITIES"::int,  "Location_centra"::text , 'Commerces' as "Categorie" FROM total_by_com_out_env
);

-----
-- 2020

DROP TABLE IF EXISTS "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_chiffres_cles_centralite_2020";
CREATE TABLE "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_chiffres_cles_centralite_2020"AS (
	-- Nombre total de locaux par commune. Les communes sans locaux n'apparaitront pas dans la table finale
	WITH total_by_com AS ( 
		SELECT t.id_geom id_geom,  Count(st_intersects(a.geom, t.geom)) "Count_ENTITIES"
		FROM "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_commerces" a
		left join public."TerritoryTable_PV_BDTopo_2020.08_full_2154" t
		
		 on ST_Intersects(a.geom,t.geom) WHERE a.year < 2021
		GROUP BY id_geom
	),
	-- Nombre de locaux dans la centralité par commune
	total_by_com_in_env AS (
		SELECT t.id_geom id_geom, Count(a.geom) "Count_ENTITIES",'IN' "Location_centra"
		FROM "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_commerces" a, public."TerritoryTable_PV_BDTopo_2020.08_full_2154" t, public."FX_OCS_CentraliteDetermination_perimetres_centralites" env
		WHERE  ST_Intersects(a.geom,t.geom) and ST_Intersects(a.geom,env.geom) and a.year < 2021
		GROUP BY t.id_geom,  "Location_centra"
	),
	-- Nombre de locaux hors centralités par commune
	total_by_com_out_env AS (
		SELECT total_by_com.id_geom id_geom, COALESCE(SUM(total_by_com."Count_ENTITIES" - total_by_com_in_env."Count_ENTITIES"),0) "Count_ENTITIES", 'OUT' "Location_centra"
		FROM total_by_com 
		LEFT JOIN total_by_com_in_env
		ON total_by_com.id_geom = total_by_com_in_env.id_geom
		--AND total_by_com."Categorie" = total_by_com_in_env."Categorie"
		GROUP BY total_by_com.id_geom,  "Location_centra" 
	)	-- Union par commune du nombre de locaux dans/hors la centralité
	
	SELECT id_geom::text, "Count_ENTITIES"::int,  "Location_centra"::text , 'Commerces' as "Categorie"FROM total_by_com_in_env
	UNION
	SELECT id_geom::text, "Count_ENTITIES"::int,  "Location_centra"::text , 'Commerces' as "Categorie" FROM total_by_com_out_env

);


-----------------
-- Chiffres-clés pour les Sites périphériques (spé SUPV) 
-----------------

-- UPDATE : 2021-08-06 : le territoire souhaite : 
-- les commerces dans les centralités
-- les commerces dans les sites périphériques
--les commerces dans l'enveloppe urbaine
-- les commerces sur le reste du territoire
-- le nombre total de commerces (= l'addition des 4 autres)

-- """ Nous proposons que la qualification de "site périphérique", qui a été délimitée à la main, prévale sur celle de centralité qui a été calculée automatiquement.
-- Nous proposons également que la qualification de "site périphérique"
-- prévale sur celle d'enveloppe urbaine, car elle est plus précise.
-- Idem pour la centralité, qui est une notion plus précise que l'enveloppe urbaine.""" -- cf mail reçu de Fanny le 2021-08-25


-----
-- 2018


DROP TABLE IF EXISTS "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_chiffres_cles_SitesP_2018";
CREATE TABLE "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_chiffres_cles_SitesP_2018"AS (
	-- Nombre total de locaux par commune. Les communes sans locaux n'apparaitront pas dans la table finale
	WITH total_by_com AS ( 
		SELECT t.id_geom id_geom,  Count(a.geom) "Count_ENTITIES"
		FROM "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_commerces" a, public."TerritoryTable_PV_BDTopo_2020.08_full_2154" t
		WHERE ST_Intersects(a.geom,t.geom) and a.year < 2019
		GROUP BY id_geom
	),
	total_by_com_in_sitesperiph AS (
		SELECT t.id_geom id_geom, COALESCE(Count(a.geom),0) "Count_ENTITIES",'IN' "Location_SitePeriph"
		FROM "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_commerces" a, public."TerritoryTable_PV_BDTopo_2020.08_full_2154" t, public."sites_peripheriques" env
		WHERE ST_Intersects(a.geom,t.geom) and ST_Intersects(a.geom,env.geom) and a.year < 2019
		GROUP BY t.id_geom,  "Location_SitePeriph"
	),
	-- Nombre de locaux hors centralités par commune
	total_by_com_out_sitesperiph AS (
		SELECT total_by_com.id_geom id_geom, COALESCE(SUM(total_by_com."Count_ENTITIES" - total_by_com_in_sitesperiph."Count_ENTITIES"),0) "Count_ENTITIES", 'OUT' "Location_SitePeriph"
		FROM total_by_com 
		LEFT JOIN total_by_com_in_sitesperiph
		ON total_by_com.id_geom = total_by_com_in_sitesperiph.id_geom
		--AND total_by_com."Categorie" = total_by_com_in_env."Categorie"
		GROUP BY total_by_com.id_geom,  "Location_SitePeriph" 
	)
	SELECT id_geom::text, coalesce("Count_ENTITIES"::int,0) "Count_ENTITIES_sp",  "Location_SitePeriph"::text FROM total_by_com_out_sitesperiph
	union
	SELECT id_geom::text, coalesce("Count_ENTITIES"::int,0) "Count_ENTITIES_sp",  "Location_SitePeriph"::text FROM total_by_com_in_sitesperiph
);

-----
-- 2020
	
DROP TABLE IF EXISTS "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_chiffres_cles_SitesP_2020";
CREATE TABLE "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_chiffres_cles_SitesP_2020"AS (
	-- Nombre total de locaux par commune. Les communes sans locaux n'apparaitront pas dans la table finale
	WITH total_by_com AS ( 
		SELECT t.id_geom id_geom,  Count(a.geom) "Count_ENTITIES"
		FROM "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_commerces" a, public."TerritoryTable_PV_BDTopo_2020.08_full_2154" t
		WHERE ST_Intersects(a.geom,t.geom) and a.year < 2021
		GROUP BY id_geom
	),
	total_by_com_in_sitesperiph AS (
		SELECT t.id_geom id_geom, COALESCE(Count(a.geom),0) "Count_ENTITIES",'IN' "Location_SitePeriph"
		FROM "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_commerces" a, public."TerritoryTable_PV_BDTopo_2020.08_full_2154" t, public."pv_sites_periph_2020" env
		WHERE ST_Intersects(a.geom,t.geom) and ST_Intersects(a.geom,env.geom) and a.year < 2021
		GROUP BY t.id_geom,  "Location_SitePeriph"
	),
	-- Nombre de locaux hors centralités par commune
	total_by_com_out_sitesperiph AS (
		SELECT total_by_com.id_geom id_geom, COALESCE(SUM(total_by_com."Count_ENTITIES" - total_by_com_in_sitesperiph."Count_ENTITIES"),0) "Count_ENTITIES", 'OUT' "Location_SitePeriph"
		FROM total_by_com 
		LEFT JOIN total_by_com_in_sitesperiph
		ON total_by_com.id_geom = total_by_com_in_sitesperiph.id_geom
		--AND total_by_com."Categorie" = total_by_com_in_env."Categorie"
		GROUP BY total_by_com.id_geom,  "Location_SitePeriph" 
	)
	SELECT id_geom::text, coalesce("Count_ENTITIES"::int,0) "Count_ENTITIES_sp",  "Location_SitePeriph"::text FROM total_by_com_out_sitesperiph
	union
	SELECT id_geom::text, coalesce("Count_ENTITIES"::int,0) "Count_ENTITIES_sp",  "Location_SitePeriph"::text FROM total_by_com_in_sitesperiph)



---------------------------------
	-- Ici on sort les géométries pour la dataviz:
	
drop table if exists "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_commerces_Points2020";
create table "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_commerces_Points2020" as (
with p1 as(
select t1.geom, activitePrincipaleEtablissement,soussectionetablissement, extract(year from t1.datecreationetablissement) "year"
	from "F5_ECO_NouveauxCommerces_InOut"."geo_siret_35" t1 , public."TerritoryTable_PV_BDTopo_2020.08_full_2154" t2
		where t2.rank='4' and st_intersects(t1.geom,t2.geom) and activitePrincipaleEtablissement like '47%' --la catégorie commerces de détail
		or activitePrincipaleEtablissement IN ('10.13B','10.71C', '10.71D') 
)
select p1.geom,p1.activitePrincipaleEtablissement, p2."libelles_40_car" libelle from p1
left join "F5_ECO_NouveauxCommerces_InOut"."nomenclature_NAF_INSEE_FULL" p2
on p1.activitePrincipaleEtablissement = p2."Code"
where year< 2021
);

drop index if exists "F5_ECO_Nouveaux_Commerces_commerces_Points2020_idx" ;
create index "F5_ECO_Nouveaux_Commerces_InOut_commerces_Points2020_idx" on "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_commerces_Points2020" using gist(geom);

select distinct(libelle) from "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut_commerces_Points2020"


-------------------------------------------------------------
-- TABULA RASA On a besoin de coller à la demande ci-dessus
-- input : 
-- public.TerritoryTable_PV_BDTopo_2020.08_full_2154
-- public.enveloppebourg2018 
-- public.sites_peripheriques 
-- geo_siret35

-- difinition de la couche de point pour l'export/dataviz

drop table if exists "F5_ECO_NouveauxCommerces_InOut".commerces_final;
create table "F5_ECO_NouveauxCommerces_InOut".commerces_final as (
select t1.geom, activitePrincipaleEtablissement,soussectionetablissement libelle, extract(year from t1.datecreationetablissement) "year"
	from "F5_ECO_NouveauxCommerces_InOut"."geo_siret_35" t1 
	, public."TerritoryTable_PV_BDTopo_2020.08_full_2154" t2
	--on st_intersects(t1.geom, t2.geom)
		where   (t1.activitePrincipaleEtablissement like '47%' --la catégorie commerces de détail
		or t1.activitePrincipaleEtablissement IN ('10.13B','10.71C', '10.71D'))
		
		and extract(year from t1.datecreationetablissement)<'2021'
		and t2.rank='2'
		and st_intersects(t1.geom, t2.geom)
);


-- difinition de la couhe de zonages (est utilisée pour le calcul du out)
drop table if exists "F5_ECO_NouveauxCommerces_InOut".zonages_com;
create table  "F5_ECO_NouveauxCommerces_InOut".zonages_com as(
with tsp as (
select tt.id_geom,label, st_union(st_intersection(sp.geom,tt.geom)) geom from public.pv_sites_periph_2022 sp
left join public."TerritoryTable_PV_BDTopo_2020.08_full_2154" tt
on st_intersects(tt.geom,sp.geom)
group by tt.id_geom, tt.label
),
centralite as (
select tt.id_geom,tt.label, st_difference(st_union(st_intersection(c.geom,tt.geom))::geometry, st_union(tsp.geom)) geom 
from public."sgevt_centralite_2021" c
left join public."TerritoryTable_PV_BDTopo_2020.08_full_2154" tt
on st_intersects(tt.geom,c.geom), tsp
group by tt.id_geom, tt.label
),
env_urb as (
select tt.id_geom,tt.label, st_difference(st_difference(st_union(st_intersection(env.geom,tt.geom))::geometry, st_union(tsp.geom)), st_union(centralite.geom)) geom 
from public.enveloppebourg2018 env
left join public."TerritoryTable_PV_BDTopo_2020.08_full_2154" tt
on st_intersects(tt.geom,env.geom), tsp , centralite
group by tt.id_geom, tt.label
)
select id_geom, label,'sites_p'::text as "zone", geom from tsp 
union 
select id_geom, label,'centralite'::text "zone", geom from centralite 
union 
select id_geom, label,'env_urb'::text "zone", geom  from env_urb); 

drop index if exists idx_zonages_com;
create index idx_zonages_com on "F5_ECO_NouveauxCommerces_InOut".zonages_com using gist(geom);


-- calcul des cclés, on crée les points à la volée, ainsi que les géométries, je les découpe au fur et à mesure, c'est ça qui prend du temps. 
-- si j'avais un peu de temps je ferais 
--174min 17s
drop table if exists "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut";
create table "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut" as (
with com_idgeom as (
select t1.geom, activitePrincipaleEtablissement,soussectionetablissement, extract(year from t1.datecreationetablissement) "year"
	from "F5_ECO_NouveauxCommerces_InOut".geo_siret_35 t1 
	, public."TerritoryTable_PV_BDTopo_2020.08_full_2154" t2
	--on st_intersects(t1.geom, t2.geom)
		where   (t1.activitePrincipaleEtablissement like '47%' --la catégorie commerces de détail
		or t1.activitePrincipaleEtablissement IN ('10.13B','10.71C', '10.71D'))
		
		and extract(year from t1.datecreationetablissement)<'2021'
		and t2.rank='2'
		and st_intersects(t1.geom, t2.geom)
),
tsp as (
select tt.id_geom,label, st_union(st_intersection(sp.geom,tt.geom)) geom 
from public.pv_sites_periph_2022 sp
left join public."TerritoryTable_PV_BDTopo_2020.08_full_2154" tt
on st_intersects(tt.geom,sp.geom)
group by tt.id_geom, tt.label
--limit 2
),
com_in_sp as(
select tsp.id_geom, tsp.label, count(t00.geom) com_in_sp from 
com_idgeom t00
left join tsp 
on st_intersects(tsp.geom, t00.geom)
group by tsp.id_geom, tsp.label
order by tsp.id_geom
),
centralite as (
select tt.id_geom,tt.label, st_difference(st_union(st_intersection(c.geom,tt.geom))::geometry, st_union(tsp.geom)) geom 
from public."sgevt_centralite_2021" c
left join public."TerritoryTable_PV_BDTopo_2020.08_full_2154" tt
on st_intersects(tt.geom,c.geom), tsp
group by tt.id_geom, tt.label
),
com_in_c as(
select centralite.id_geom, centralite.label, count(t00.geom) com_in_c from 
com_idgeom t00
left join centralite
on st_intersects(centralite.geom, t00.geom)
group by centralite.id_geom, centralite.label
order by centralite.id_geom
),
env_urb as (
select tt.id_geom,tt.label, st_difference(st_difference(st_union(st_intersection(env.geom,tt.geom))::geometry, st_union(tsp.geom)), st_union(centralite.geom)) geom 
from public.enveloppebourg2018 env
left join public."TerritoryTable_PV_BDTopo_2020.08_full_2154" tt
on st_intersects(tt.geom,env.geom), tsp , centralite
group by tt.id_geom, tt.label
),
com_in_env as (
select env.id_geom, env.label, count(t00.geom) com_in_env from 
com_idgeom t00
left join env_urb env
on st_intersects(env.geom, t00.geom)
group by env.id_geom, env.label
order by env.id_geom
), 
allzones as (
select id_geom,st_union(t2.geom) geom from "F5_ECO_NouveauxCommerces_InOut".zonages_com t2
group by id_geom--, zone
),
com_out_table as (
select tt.id_geom, count(t0.geom) com_tot from "F5_ECO_NouveauxCommerces_InOut".geo_siret_35 t0
left join public."TerritoryTable_PV_BDTopo_2020.08_full_2154" tt
on st_intersects(tt.geom,t0.geom)
group by tt.id_geom
)
select tt.id_geom insee, tt.label, coalesce(com_in_sp.com_in_sp, 0) "COUNT_ENTITIES_IN_SITES", coalesce(com_in_c,0) "COUNT_ENTITIES_IN_CENTRA", coalesce(com_in_env,0) "COUNT_ENTITIES_IN_ENV", 
com_tot::numeric - coalesce((coalesce(com_in_sp.com_in_sp, 0) + coalesce(com_in_c,0) + coalesce(com_in_env,0)),0) "OUT"
FROM  public."TerritoryTable_PV_BDTopo_2020.08_full_2154" tt
LEFT  JOIN  com_in_sp 
ON  tt.id_geom = com_in_sp.id_geom
LEFT  JOIN   com_in_c
ON  tt.id_geom = com_in_c.id_geom
LEFT  JOIN  com_in_env
ON  tt.id_geom = com_in_env.id_geom
LEFT  JOIN  com_out_table
on tt.id_geom = com_out_table.id_geom
)


alter table "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut"
add column "TOTAL" NUMERIC;
update "F5_ECO_NouveauxCommerces_InOut"."F5_ECO_NouveauxCommerces_InOut" 
set "TOTAL" = "COUNT_ENTITIES_IN_SITES"+"COUNT_ENTITIES_IN_CENTRA"+"COUNT_ENTITIES_IN_ENV"+"OUT"



select count(*) from "F5_ECO_NouveauxCommerces_InOut".commerces_pour_test




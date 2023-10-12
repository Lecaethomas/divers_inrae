-- Un script pour associer le fichier de RPLS entre eux (après s'être débarassé des NA qui trainent) 
-- Même procédure pour les résidences principale. On réalise ensuite une jointure entre les deux

-- ATTENTION :: les calculs FRANCE ENTIERE ont été réalisés dans la base de PF, schéma "F3_MIX_LogementsSociaux_ResidencesPrinc"



-- Version pour les dataviz non intégrées

select * from "F3_MIX_LogementsSociaux_ResidencesPrinc".rpls_france_entiere order by "CODGEO", year;

drop table if exists "F3_MIX_LogementsSociaux_ResidencesPrinc".rpls_france_entiere;
create table "F3_MIX_LogementsSociaux_ResidencesPrinc".rpls_france_entiere as (

select 
id,"CODGEO":: varchar,nom_commune:: varchar, 
CAST(COALESCE(NULLIF(regexp_replace("Nb_log_parc_loc_bailleurs_soc"::varchar, '[^-0-9.]+', '', 'g'), ''),'0') AS real) "Nb_log_parc_loc_bailleurs_soc",
CAST(COALESCE(NULLIF(regexp_replace("Nb_log_parc_loc_soc"::varchar, '[^-0-9.]+', '', 'g'), ''),'0') AS real)"Nb_log_parc_loc_soc" ,
'2012'::varchar "year" from "F3_MIX_LogementsSociaux_ResidencesPrinc"."RPLS_2012_GEO_2019"

union all

select 
id,"CODGEO":: varchar,nom_commune:: varchar, 
CAST(COALESCE(NULLIF(regexp_replace("Nb_log_parc_loc_bailleurs_soc"::varchar, '[^-0-9.]+', '', 'g'), ''),'0') AS real) "Nb_log_parc_loc_bailleurs_soc",
CAST(COALESCE(NULLIF(regexp_replace("Nb_log_parc_loc_soc"::varchar, '[^-0-9.]+', '', 'g'), ''),'0') AS real)"Nb_log_parc_loc_soc" ,
'2013'::varchar "year"  from "F3_MIX_LogementsSociaux_ResidencesPrinc"."RPLS_2013_GEO_2019"

union all

select id,"CODGEO":: varchar,nom_commune:: varchar, 
CAST(COALESCE(NULLIF(regexp_replace("Nb_log_parc_loc_bailleurs_soc"::varchar, '[^-0-9.]+', '', 'g'), ''),'0') AS real) "Nb_log_parc_loc_bailleurs_soc",
CAST(COALESCE(NULLIF(regexp_replace("Nb_log_parc_loc_soc"::varchar, '[^-0-9.]+', '', 'g'), ''),'0') AS real)"Nb_log_parc_loc_soc" ,
'2014'::varchar "year"  from "F3_MIX_LogementsSociaux_ResidencesPrinc"."RPLS_2014_GEO_2019"

union all

select id,"CODGEO":: varchar,nom_commune:: varchar, 
CAST(COALESCE(NULLIF(regexp_replace("Nb_log_parc_loc_bailleurs_soc"::varchar, '[^-0-9.]+', '', 'g'), ''),'0') AS real) "Nb_log_parc_loc_bailleurs_soc",
CAST(COALESCE(NULLIF(regexp_replace("Nb_log_parc_loc_soc"::varchar, '[^-0-9.]+', '', 'g'), ''),'0') AS real)"Nb_log_parc_loc_soc" ,
'2015'::varchar "year"  from "F3_MIX_LogementsSociaux_ResidencesPrinc"."RPLS_2015_GEO_2019"

union all

select id,"CODGEO":: varchar,nom_commune:: varchar, 
CAST(COALESCE(NULLIF(regexp_replace("Nb_log_parc_loc_bailleurs_soc"::varchar, '[^-0-9.]+', '', 'g'), ''),'0') AS real) "Nb_log_parc_loc_bailleurs_soc",
CAST(COALESCE(NULLIF(regexp_replace("Nb_log_parc_loc_soc"::varchar, '[^-0-9.]+', '', 'g'), ''),'0') AS real)"Nb_log_parc_loc_soc" ,
'2016'::varchar "year"  from "F3_MIX_LogementsSociaux_ResidencesPrinc"."RPLS_2016_GEO_2019"

union all

select id,"CODGEO":: varchar,nom_commune:: varchar, 
CAST(COALESCE(NULLIF(regexp_replace("Nb_log_parc_loc_bailleurs_soc"::varchar, '[^-0-9.]+', '', 'g'), ''),'0') AS real) "Nb_log_parc_loc_bailleurs_soc",
CAST(COALESCE(NULLIF(regexp_replace("Nb_log_parc_loc_soc"::varchar, '[^-0-9.]+', '', 'g'), ''),'0') AS real)"Nb_log_parc_loc_soc" ,
'2017'::varchar "year"  from "F3_MIX_LogementsSociaux_ResidencesPrinc"."RPLS_2017_GEO_2019"

union all

select id,"CODGEO":: varchar,nom_commune:: varchar, 
CAST(COALESCE(NULLIF(regexp_replace("Nb_log_parc_loc_bailleurs_soc"::varchar, '[^-0-9.]+', '', 'g'), ''),'0') AS real) "Nb_log_parc_loc_bailleurs_soc",
CAST(COALESCE(NULLIF(regexp_replace("Nb_log_parc_loc_soc"::varchar, '[^-0-9.]+', '', 'g'), ''),'0') AS real)"Nb_log_parc_loc_soc" ,
'2018'::varchar "year"  from "F3_MIX_LogementsSociaux_ResidencesPrinc"."RPLS_2018_GEO_2019"
);

--
drop table if exists "F3_MIX_LogementsSociaux_ResidencesPrinc"."insee_resPrinc_2012_2018_geom2019";
create table "F3_MIX_LogementsSociaux_ResidencesPrinc"."insee_resPrinc_2012_2018_geom2019" as (
SELECT '2012'::varchar "year", t1.* FROM "F3_MIX_LogementsSociaux_ResidencesPrinc".base_cc_logement_2012_geom2019 t1
UNION ALL 
SELECT '2013'::varchar "year", t2.* FROM "F3_MIX_LogementsSociaux_ResidencesPrinc".base_cc_logement_2013_geom2019 t2
UNION ALL 
SELECT '2014'::varchar "year", t3.* FROM "F3_MIX_LogementsSociaux_ResidencesPrinc".base_cc_logement_2014_geom2019 t3
UNION ALL 
SELECT '2015'::varchar "year", t4.* FROM "F3_MIX_LogementsSociaux_ResidencesPrinc".base_cc_logement_2015_geom2019 t4
UNION ALL 
SELECT '2016'::varchar "year", t5.* FROM "F3_MIX_LogementsSociaux_ResidencesPrinc".base_cc_logement_2016_geom2019 t5
UNION ALL 
SELECT '2017'::varchar "year", t6.* FROM "F3_MIX_LogementsSociaux_ResidencesPrinc".base_cc_logement_2017_geom2019 t6
UNION ALL 
SELECT '2018'::varchar "year", t7.* FROM "F3_MIX_LogementsSociaux_ResidencesPrinc".base_cc_logement_2018_geom2019 t7
ORDER BY insee, "year");
--End create table

-- Table finale : 
DROP TABLE IF EXISTS "F3_MIX_LogementsSociaux_ResidencesPrinc".chiffres_cles;
CREATE TABLE  "F3_MIX_LogementsSociaux_ResidencesPrinc".chiffres_cles AS (
WITH t1a AS (
SELECT insee, res."year", "Nb_log_parc_loc_bailleurs_soc", "Nb_log_parc_loc_soc" ,  "PXX_RP" 
FROM "F3_MIX_LogementsSociaux_ResidencesPrinc"."insee_resPrinc_2012_2018_geom2019" res
LEFT JOIN  "F3_MIX_LogementsSociaux_ResidencesPrinc".rpls_france_entiere rpls
ON res.insee = rpls."CODGEO" AND res."year" =rpls."year" 
),
t1 AS (
SELECT tt.geom, tt."label", t1a.* FROM t1a
LEFT JOIN public."TerritoryTable_PV_BDTopo_2020.08_full_2154" tt
ON tt.id_geom = t1a.insee 
WHERE tt.RANK = '1' AND tt.id_geom IS NOT NULL 
--and res.insee ='35360'
),
-- Géométries niveau 2 de la table territoire
rank2 as (
	SELECT label, id_geom, ST_Union(geom) geom
		FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154" 
		WHERE rank = 2
		GROUP BY id_geom, label
),
-- Niv 2 : Polarités
t2 as (
	select rank2.label, rank2.id_geom as insee , t1."year" ,sum("Nb_log_parc_loc_bailleurs_soc") as "Nb_log_parc_loc_bailleurs_soc", sum("Nb_log_parc_loc_soc" ) as "Nb_log_parc_loc_soc"  , sum("PXX_RP") as "PXX_RP"  , rank2.geom
	from rank2
	LEFT JOIN t1
	ON ST_Intersects(ST_PointOnSurface(t1.geom),rank2.geom)
	GROUP BY rank2.id_geom, t1."year", rank2.geom,rank2.label
),
-- Géométries niveau 3 de la table territoire
rank3 as (
	SELECT label, id_geom, ST_Union(geom) geom
		FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154" 
		WHERE rank = 3
		GROUP BY id_geom, label
),
-- Données à l'EPCI
t3 as (
	select rank3.label, rank3.id_geom as insee , t1."year",  sum("Nb_log_parc_loc_bailleurs_soc") as "Nb_log_parc_loc_bailleurs_soc", sum("Nb_log_parc_loc_soc" ) as "Nb_log_parc_loc_soc"  , sum("PXX_RP") as "PXX_RP" , rank3.geom
	from rank3 
	LEFT JOIN t1
	ON ST_Intersects(ST_PointOnSurface(t1.geom),rank3.geom)
	GROUP BY rank3.id_geom, t1."year", rank3.geom,rank3.label
),
-- Géométries niveau 3 de la table territoire
rank4 as (
	SELECT label, id_geom, ST_Union(geom) geom
		FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154" 
		WHERE rank = 4
		GROUP BY id_geom, label
),
-- Données à l'EPCI
t4 as (
	select rank4.label, rank4.id_geom as insee , t1."year",  sum("Nb_log_parc_loc_bailleurs_soc") as "Nb_log_parc_loc_bailleurs_soc", sum("Nb_log_parc_loc_soc" ) as "Nb_log_parc_loc_soc"  , sum("PXX_RP") as "PXX_RP" , rank4.geom
	from rank4 
	LEFT JOIN t1
	ON ST_Intersects(ST_PointOnSurface(t1.geom),rank4.geom)
	GROUP BY rank4.id_geom, t1."year", rank4.geom,rank4.label
)

select insee,"year",COALESCE("Nb_log_parc_loc_soc",0) "Logements sociaux" , ("PXX_RP" - COALESCE("Nb_log_parc_loc_soc",0)) "Autres résidences principales (hors logements sociaux)" ,  "PXX_RP" total 
FROM t1 where year is not null
UNION
select insee,"year",COALESCE("Nb_log_parc_loc_soc",0) "Logements sociaux" , ("PXX_RP" - COALESCE("Nb_log_parc_loc_soc",0)) "Autres résidences principales (hors logements sociaux)" , "PXX_RP" total 
FROM t2 where year is not null
UNION 
SELECT insee,"year",COALESCE("Nb_log_parc_loc_soc",0) "Logements sociaux" , ("PXX_RP" - COALESCE("Nb_log_parc_loc_soc",0)) "Autres résidences principales (hors logements sociaux)" , "PXX_RP" total 
FROM t3 where year is not null
UNION 
SELECT insee,"year",COALESCE("Nb_log_parc_loc_soc",0) "Logements sociaux" , ("PXX_RP" - COALESCE("Nb_log_parc_loc_soc",0)) "Autres résidences principales (hors logements sociaux)" , "PXX_RP" total 
FROM t4 where year is not null
ORDER BY insee, "year"
)



---//---//---//---//---//---//---//---//---//---//---//
---//---//---//---//---//---//---//---//---//---//---//
-- version pour les dataviz intégrées (màj des données API): 

--Residences principales
drop table if exists "F3_MIX_LogementsSociaux_ResidencesPrinc"."res_princ_france_entiere_TA" ; 
create table "F3_MIX_LogementsSociaux_ResidencesPrinc"."res_princ_france_entiere_TA" as( 

select  t2012.insee "CODGEO",t2012."PXX_RP" "PXX_RP_2012", t2013."PXX_RP" "PXX_RP_2013", t2014."PXX_RP" "PXX_RP_2014" , t2015."PXX_RP" "PXX_RP_2015",t2016."PXX_RP" "PXX_RP_2016", t2017."PXX_RP" "PXX_RP_2017" , t2018."PXX_RP" "PXX_RP_2018" 
	from base_cc_logement_2012_geom2019 t2012 
		left join base_cc_logement_2013_geom2019 t2013 on t2012.insee=t2013.insee
		left join base_cc_logement_2014_geom2019 t2014 on t2012.insee=t2014.insee
		left join base_cc_logement_2015_geom2019 t2015 on t2012.insee=t2015.insee
		left join base_cc_logement_2016_geom2019 t2016 on t2012.insee=t2016.insee
		left join base_cc_logement_2017_geom2019 t2017 on t2012.insee=t2017.insee
		left join base_cc_logement_2018_geom2019 t2018 on t2012.insee=t2018.insee
);--End residence principales france entiere


drop table if exists "F3_MIX_LogementsSociaux_ResidencesPrinc"."rpls_france_entiere_TA";
create table "F3_MIX_LogementsSociaux_ResidencesPrinc"."rpls_france_entiere_TA" as (

select t2012."CODGEO" ,t2012.nom_commune , t2012."Nb_log_parc_loc_soc" nb_log_parc_soc_2012, t2013."Nb_log_parc_loc_soc" nb_log_parc_soc_2013, t2014."Nb_log_parc_loc_soc" nb_log_parc_soc_2014, t2015."Nb_log_parc_loc_soc" nb_log_parc_soc_2015,
t2016."Nb_log_parc_loc_soc" nb_log_parc_soc_2016 , t2017."Nb_log_parc_loc_soc" nb_log_parc_soc_2017 
from "F3_MIX_LogementsSociaux_ResidencesPrinc".rpls_france_entiere t2012 
left join "F3_MIX_LogementsSociaux_ResidencesPrinc".rpls_france_entiere t2013 on t2012."CODGEO" = t2013."CODGEO" 
left join "F3_MIX_LogementsSociaux_ResidencesPrinc".rpls_france_entiere t2014 on t2012."CODGEO" = t2014."CODGEO" 
left join "F3_MIX_LogementsSociaux_ResidencesPrinc".rpls_france_entiere t2015 on t2012."CODGEO" = t2015."CODGEO" 
left join "F3_MIX_LogementsSociaux_ResidencesPrinc".rpls_france_entiere t2016 on t2012."CODGEO" = t2016."CODGEO" 
left join "F3_MIX_LogementsSociaux_ResidencesPrinc".rpls_france_entiere t2017 on t2012."CODGEO" = t2017."CODGEO" 
left join "F3_MIX_LogementsSociaux_ResidencesPrinc".rpls_france_entiere t2018 on t2012."CODGEO" = t2018."CODGEO" 

where t2012."year"::int =2012 and t2013."year"::int =2013  and t2014."year"::int =2014  and t2015."year"::int =2015  and t2016."year"::int =2016  and t2017."year"::int =2017 and t2018."year"::int = 2018

order by t2012."CODGEO" );
--where t2013."year" =2014
--
-- t2016."Nb_log_parc_loc_soc" nb_log_parc_soc_2016 , t2017."Nb_log_parc_loc_soc" nb_log_parc_soc_2017 



------------------------------------------------
--Jointure entre RPLS et residences principales 
drop table if exists "F3_MIX_LogementsSociaux_ResidencesPrinc"."F3_MIX_LogementsSociaux_TotalLog_FRCE_ENTIERE" ; 
create table "F3_MIX_LogementsSociaux_ResidencesPrinc"."F3_MIX_LogementsSociaux_TotalLog_FRCE_ENTIERE"  as (
	select b."CODGEO" codgeo,com.libelle ,CAST(COALESCE(NULLIF(regexp_replace("PXX_RP_2012"::varchar, '[^-0-9.]+', '', 'g'), ''),'0') AS real) LOG_RP_2012,CAST(COALESCE(NULLIF(regexp_replace("PXX_RP_2013"::varchar, '[^-0-9.]+', '', 'g'), ''),'0') AS real)  LOG_RP_2013,
	CAST(COALESCE(NULLIF(regexp_replace("PXX_RP_2014"::varchar, '[^-0-9.]+', '', 'g'), ''),'0') AS real) LOG_RP_2014,CAST(COALESCE(NULLIF(regexp_replace("PXX_RP_2015"::varchar, '[^-0-9.]+', '', 'g'), ''),'0') AS real)  LOG_RP_2015,
		CAST(COALESCE(NULLIF(regexp_replace("PXX_RP_2016"::varchar, '[^-0-9.]+', '', 'g'), ''),'0') AS real)  LOG_RP_2016 , CAST(COALESCE(NULLIF(regexp_replace("PXX_RP_2017"::varchar, '[^-0-9.]+', '', 'g'), ''),'0') AS real) LOG_RP_2017,
		coalesce(nb_log_parc_soc_2012,0)nb_log_parc_soc_2012,coalesce(nb_log_parc_soc_2013,0)nb_log_parc_soc_2013,coalesce(nb_log_parc_soc_2014,0)nb_log_parc_soc_2014,coalesce(nb_log_parc_soc_2015,0)nb_log_parc_soc_2015,
		coalesce(nb_log_parc_soc_2016,0)nb_log_parc_soc_2016,coalesce(nb_log_parc_soc_2017,0)nb_log_parc_soc_2017
	from "F3_MIX_LogementsSociaux_ResidencesPrinc"."res_princ_france_entiere_TA" b  
	left join "F3_MIX_LogementsSociaux_ResidencesPrinc"."rpls_france_entiere_TA" a 
	on a."CODGEO"=b."CODGEO" 
	left join communes_01012019 com
	on com.com = b."CODGEO"
	order by CODGEO);


	
	select * from "F3_MIX_LogementsSociaux_TotalLog_FRCE_ENTIERE" where libelle is null

----------------------------------------------
----------------------------------------------
--- Calculs aux differentes échelles territoriales
	--7.6 sec
	
	-- ->en fait plus tellement Useless puisque l'on s'est rendu compte que l'API ne gererait pas le niveau "Polarites" (spe P-Vitré)
----------------------------------------------
----------------------------------------------


drop table if exists "F3_MIX_LogementsSociaux_ResidencesPrinc"."F3_MIX_lgt_soc_res_princ";
create table "F3_MIX_LogementsSociaux_ResidencesPrinc"."F3_MIX_lgt_soc_res_princ" as (

with t1 as  (
	select Table1.label,Table1.id_geom insee ,"year",sum("Nb_log_parc_loc_bailleurs_soc") as "Nb_log_parc_loc_bailleurs_soc",sum("Nb_log_parc_loc_soc") as "Nb_log_parc_loc_soc",sum("PXX_RP") as "PXX_RP", Table1.geom 
	FROM ( -- Données territoire
				SELECT label AS ColMaj, label, id_geom, geom
				FROM public."TerritoryTable_PF_2019" 
				GROUP BY ColMaj, label, id_geom, geom
			) AS Table1
	left join (
			select * from "F3_MIX_LogementsSociaux_ResidencesPrinc"."F3_MIX_LogementsSociaux_TotalLog_FRCE_ENTIERE" ea  
				where substring(codgeo,1,2) like '35' 
	) as Table0
	on Table0.codgeo like Table1.id_geom
	where Table1.id_geom is not null
	group by Table1.id_geom, Table0.year,Table1.geom, Table1.label
	order by Table1.id_geom,Table0.year
),
-- Géométries niveau 2 de la table territoire
rank2 as (
	SELECT label, id_geom, ST_Union(geom) geom
		FROM public."TerritoryTable_PF_2019" 
		WHERE rank = 2
		GROUP BY id_geom, label
),
-- Niv 2 : Polarités
t2 as (
	select rank2.label,rank2.id_geom as insee,t1.year,sum("Nb_log_parc_loc_bailleurs_soc") as "Nb_log_parc_loc_bailleurs_soc",sum("Nb_log_parc_loc_soc") as "Nb_log_parc_loc_soc",sum("PXX_RP") as "PXX_RP",rank2.geom
	from rank2
	LEFT JOIN t1
	ON ST_Intersects(ST_PointOnSurface(t1.geom),rank2.geom)
	GROUP BY rank2.id_geom, t1."year", rank2.geom,rank2.label
),
-- Géométries niveau 3 de la table territoire
rank3 as (
	SELECT label, id_geom, ST_Union(geom) geom
		FROM public."TerritoryTable_PF_2019" 
		WHERE rank = 3
		GROUP BY id_geom, label
),
-- Données à l'EPCI
t3 as (
	select rank3.label,rank3.id_geom as insee,t1.year,sum("Nb_log_parc_loc_bailleurs_soc") as "Nb_log_parc_loc_bailleurs_soc",sum("Nb_log_parc_loc_soc") as "Nb_log_parc_loc_soc",sum("PXX_RP")  as "PXX_RP", rank3.geom
	from rank3
	LEFT JOIN t1
	ON ST_Intersects(ST_PointOnSurface(t1.geom),rank3.geom)
	GROUP BY rank3.id_geom, t1."year", rank3.geom,rank3.label
)--,
-- Géométries niveau 4 de la table territoire

--rank4 as (
	--SELECT label, id_geom, ST_Union(geom) geom
		--FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154" 
		--WHERE rank = 4
		--GROUP BY id_geom, label
---),

-- Données au territoire (bon il suffirait de faire un SUM de tout dans l'absolu)

--t4 as (
	--select rank4.label, rank4.id_geom as insee,t1.year, sum("Nb_log_parc_loc_bailleurs_soc") as "Nb_log_parc_loc_bailleurs_soc", sum("Nb_log_parc_loc_soc") as "Nb_log_parc_loc_soc", sum("PXX_RP") as "PXX_RP", rank4.geom
	--from t1,rank4
	--WHERE t1.insee IN (
			--SELECT terr1.id_geom
			--FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154"  terr1, rank4
			--WHERE ST_Intersects(ST_PointOnSurface(terr1.geom),rank4.geom)
				--AND terr1.rank = 1
	--)
	--GROUP BY rank4.id_geom, t1."year", rank4.geom, rank4.label
--)

select insee,"year","Nb_log_parc_loc_soc" "Logements sociaux","PXX_RP"  "Résidences principales", "Nb_log_parc_loc_soc"+"PXX_RP" total FROM t1 where year is not null
UNION
select insee,"year","Nb_log_parc_loc_soc" "Logements sociaux","PXX_RP" "Résidences principales","Nb_log_parc_loc_soc"+"PXX_RP" total FROM t2 where year is not null
UNION 
SELECT insee,"year","Nb_log_parc_loc_soc" "Logements sociaux","PXX_RP" "Résidences principales", "Nb_log_parc_loc_soc"+"PXX_RP" total FROM t3 where year is not null
--UNION 
--SELECT insee,"year","Nb_log_parc_loc_soc" "Logements sociaux","PXX_RP" "Résidences principales","Nb_log_parc_loc_soc"+"PXX_RP" total FROM t4 where year is not null
ORDER BY insee, "year" 
)



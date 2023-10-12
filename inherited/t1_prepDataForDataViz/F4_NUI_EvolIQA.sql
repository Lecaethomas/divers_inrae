-- script de production utilisé pour l'indicateur F4_NUI_EvolIQA tel que proposé pour Vitré ou PST
-- pour PST seules 2/3 des EPCI avaient de la donnée à dispo, on a choisi l'une des deux
-- pour Vitré pas de données dispo sur le territoire donc on a pris la voisine -- rennes métropole
 

--//--//--//--//--//--//--//--//--//--//--//--//
--//--//--//--//--// 2021 --//--//--//--//--//--//
--//--//--//--//--//--//--//--//--//--//--//--//

--// Le calcul, la sémiologie, et les labels de l'IQA changent au 1er janvier 2021 ci-dessous le code pour les CClés selon cette nouvelle mouture

drop table if exists "F4_NUI_EvolIQA"."F4_NUI_EvolIQA_2021";
create table "F4_NUI_EvolIQA"."F4_NUI_EvolIQA_2021" as(
with t as (
    select * from "F4_NUI_EvolIQA"."AirBreizh_iqa_2021_22" --where code_zone in ('200039022','243500634')
),
t1 as (
select coalesce(count(code_qual),0) "Bon", code_zone, lib_zone from  t
where code_qual = 1 AND LEFT(date_ech, 4) = '2021'
group by  code_zone, lib_zone, LEFT(date_ech, 4)
),
t2 as (
select count(code_qual)  "Moyen", code_zone, lib_zone from t
where code_qual = 2  AND LEFT(date_ech, 4) = '2021'
group by  code_zone, lib_zone
),
t3 as (
select count(code_qual) "Dégradé", code_zone, lib_zone from t
where code_qual = 3 AND LEFT(date_ech, 4) = '2021'
group by  code_zone, lib_zone
),

t4 as (
select count(code_qual) "Mauvais", code_zone, lib_zone from t
where code_qual = 4 AND LEFT(date_ech, 4) = '2021'
group by  code_zone, lib_zone
),
t5 as (
select count(code_qual) "Très mauvais", code_zone, lib_zone from t
where code_qual = 5 AND LEFT(date_ech, 4) = '2021'
group by  code_zone, lib_zone
) ,
t6 as (
select count(code_qual) "Extrêmement mauvais", code_zone, lib_zone from t
where code_qual = 6 AND LEFT(date_ech, 4) = '2021'
group by  code_zone, lib_zone
) 
select t.code_zone:: varchar id_geom,t.lib_zone::varchar "label",coalesce("Bon",0)"Bon",coalesce("Moyen",0)"Moyen",coalesce("Dégradé",0)"Dégradé",coalesce("Mauvais",0)"Mauvais",
coalesce("Très mauvais",0)"Très mauvais",coalesce("Extrêmement mauvais",0)"Extrement mauvais"from t
left join t1 on t1.code_zone=t.code_zone
left join t2 on t2.code_zone=t.code_zone
left join t3 on t3.code_zone=t.code_zone
left join t4 on t4.code_zone=t.code_zone
left join t5 on t5.code_zone=t.code_zone
left join t6 on t6.code_zone=t.code_zone
group by t.code_zone,t.lib_zone, "Très mauvais","Moyen" , "Extrêmement mauvais","Mauvais","Dégradé", "Bon"
)


-- //// Pour l'IQA format 2020 -- //////

--//--//--//--//--//--//--//--//--//--//--//--//
--//--//--//--//--// 2020 (format different) --//--//--//--//--//--//
--//--//--//--//--//--//--//--//--//--//--//--//
drop table if exists "F4_NUI_EvolIQA"."F4_NUI_EvolIQA_2020";
create table "F4_NUI_EvolIQA"."F4_NUI_EvolIQA_2020" as(

with t as (
    select * from "F4_NUI_EvolIQA"."input_2020" --where code_zone in ('200039022','243500634')
),
t1 as (
select coalesce(count(valeur),0) "Très bon", code_zone, lib_zone from  t
where valeur = 1 or valeur = 2 
group by  code_zone, lib_zone
),
t2 as (
select count(valeur)  "Bon", code_zone, lib_zone from t
where valeur = 3 or valeur = 4
group by  code_zone, lib_zone
),
t3 as (
select count(valeur) "Moyen", code_zone, lib_zone from t
where valeur = 5
group by  code_zone, lib_zone
),

t4 as (
select count(valeur) "Médiocre", code_zone, lib_zone from t
where valeur = 6 or valeur = 7
group by  code_zone, lib_zone
),
t5 as (
select count(valeur) "Mauvais", code_zone, lib_zone from t
where valeur = 8 or valeur = 9
group by  code_zone, lib_zone
) ,
t6 as (
select count(valeur) "Très mauvais", code_zone, lib_zone from t
where valeur = 10
group by  code_zone, lib_zone
) 
select t.code_zone:: varchar id_geom,t.lib_zone::varchar "label",coalesce( "Très bon",0)"Très bon",coalesce("Bon",0)"Bon",coalesce("Moyen",0)"Moyen",coalesce("Médiocre",0)"Médiocre",
coalesce("Mauvais",0)"Mauvais",coalesce("Très mauvais",0)"Très mauvais" from t
left join t1 on t1.code_zone=t.code_zone
left join t2 on t2.code_zone=t.code_zone
left join t3 on t3.code_zone=t.code_zone
left join t4 on t4.code_zone=t.code_zone
left join t5 on t5.code_zone=t.code_zone
left join t6 on t6.code_zone=t.code_zone
group by t.code_zone,t.lib_zone, "Très bon","Bon", "Moyen","Médiocre","Mauvais", "Très mauvais"
)






select id_geom, "label" from public."TerritoryTable_PV_BDTopo_2020.08_full_2154" where rank ='3'
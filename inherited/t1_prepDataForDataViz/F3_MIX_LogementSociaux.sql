-- traitement données LOCALES logement sociaux et mise en rapport avec les fichiers logement insee


-- d'abord nous devons traiter les fichers de logements insee
with t1 as(
select res.id,codgeo,nom_commune,pxx_rp,"year" from res_princ_full_csv res,
public."TerritoryTable_PV_BDTopo_2020.08_full_2154" ttpbf 
where res.codgeo = ttpbf.id_geom
)
select * from t1;

-- on prepare des tables composée d'id_geom et d'une année pour les joindre afin d'avoir l'année
drop table if exists t1_;
create table t1_ as (
select id_geom as id_geom_ from lgmnt_soc_com
);
alter table t1_ add column "year" int;
update t1_ set "year" = '2016';

drop table if exists t2_;
create table t2_ as (
select id_geom as id_geom_ from lgmnt_soc_com
);
alter table t2_ add column "year" int;
update t2_ set "year" = '2017';

drop table if exists t3_;
create table t3_ as (
select id_geom as id_geom_ from lgmnt_soc_com
);
alter table t3_ add column "year" int;
update t3_ set "year" = '2018';

drop table if exists t4_;
create table t4_ as (
select id_geom as id_geom_ from lgmnt_soc_com
);
alter table t4_ add column "year" int;
update t4_ set "year" = '2019';

--->END

--- on peut ensuite travailler sur les logements sociaux, séparer les champs dans différentes subq 
-- pour y joindre un champ année issue des tables générées ci-dessus

drop table if exists lgmnt_soc_com_full;
create table lgmnt_soc_com_full as ( 
with t1 as (
select id_geom,"label","type",id_terr,"2016" as total_soc  from lgmnt_soc_com lgmt 
),
t2 as (
select id_geom,"label","type",id_terr,"2017" as total_soc  from lgmnt_soc_com lgmt 
),
t3 as (
select id_geom,"label","type",id_terr,"2018" as total_soc  from lgmnt_soc_com lgmt 
),
t4 as (
select id_geom,"label","type",id_terr,"2019" as total_soc  from lgmnt_soc_com lgmt 
)
select * from t1 left join t1_ on t1.id_geom = t1_.id_geom_
union 
select * from t2 left join t2_ on t2.id_geom = t2_.id_geom_
union 
select * from t3 left join t3_ on t3.id_geom = t3_.id_geom_
union 
select * from t4 left join t4_ on t4.id_geom = t4_.id_geom_
);

select * from lgmnt_soc_com_full
order by  id_geom , year asc;


-----> END


--il faut désormais réharmoniser la base des résidences principales sur le modèle des logements sociaux

select * from res_princ_full_csv res, lgmnt_soc_com_full soc 
where res.codgeo= soc.id_geom::varchar
and res.year= soc.year::varchar
order by codgeo, res."year";

drop table if exists evol_res_princ;
create table evol_res_princ as (

with t2015 as (
select * from res_princ_full_csv right join public."TerritoryTable_PV_BDTopo_2020.08_full_2154"as ttpbf 
on codgeo= ttpbf.id_geom where "year"= '2015'  
) ,

t2016 as (
select * from res_princ_full_csv right join public."TerritoryTable_PV_BDTopo_2020.08_full_2154"as ttpbf 
on codgeo= ttpbf.id_geom where "year"= '2016'  
),

t2017 as (
select * from res_princ_full_csv right join public."TerritoryTable_PV_BDTopo_2020.08_full_2154"as ttpbf 
on codgeo= ttpbf.id_geom where "year"= '2017'  
),

total as( 
select t2015.id_geom,t2015.pxx_rp "2015", t2016.pxx_rp "2016", t2017.pxx_rp "2017" from t2015 
inner join t2016 on t2015.codgeo=t2016.codgeo
inner join t2017 on t2015.codgeo=t2017.codgeo ),

evol as (
select id_geom, "2015", "2016","2017", "2016"::float::int-"2015"::float::int evol_2015, "2017"::float::int-"2016"::float::int evol_2016 
from total
)

select * from evol
);

----------

drop table if exists evol_res_princ_full;
create table evol_res_princ_full as ( 

with t1 as (
select id_geom,evol_2015::int  as total_res  from evol_res_princ
),

t2 as (
select id_geom,evol_2016::float::int  as total_res  from evol_res_princ
)

select * from t1 left join t1_ on t1.id_geom::float::int = t1_.id_geom_
union 
select * from t2 left join t2_ on t2.id_geom::float::int  = t2_.id_geom_
);

select * from evol_res_princ_full
order by  id_geom; --, year asc;

select lgmt.id_geom,lgmt."label",lgmt.id_terr,total_soc,lgmt."year",total_res,evol."year" from lgmnt_soc_com_full lgmt inner join evol_res_princ_full evol on lgmt.id_geom= evol.id_geom::int and lgmt.year= evol.year
order by evol.id_geom, evol.year;

select * from res_princ_full_csv rpfc where codgeo = '35006'








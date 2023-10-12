--Ce script permet de calculer l'évolution par EPCI et SCOT de leur dotation en équipements à partir d'une base bpe1419_nb_equip_epci.csv
-- Attention, cette base reste malgré tout très pauvre; la classe culture n'est pas étudiée, et la classe enseignement est faiblement représentée avec C303 - Lycée d'enseignement technologique/professionnel agricole
--C505 – École d’enseignement supérieur agricole

drop table if exists "F1_EQU_Evol_Equip".simplification_bpe_evol;
create table "F1_EQU_Evol_Equip".simplification_bpe_evol as (
with t1 as (select * from  "F1_EQU_Evol_Equip".bpe1419_epci left JOIN (select type_lib, type_code from "F1_EQU_Evol_Equip".libelles_table_jointure_bpe )as t2 
ON (bpe1419_epci.typequ = t2.type_code)
where epci  in ('243500634','200039022') and substring(typequ ,1,1) ~~ any ('{C%,D%,F%}')) --and nb_2014 <> nb_2019)
select epci,typequ,nb_2014,nb_2019,type_lib from t1
order by epci
);
-- select *from "F1_EQU_Evol_Equip".bpe1419_epci where typequ like 'C%' and epci  in ('243500634','200039022');


---------------------------------------------------------------------------------------------------------------

--on extrait les deux premiers caractères définissant la classe dans une colone DOMAINE

alter table "F1_EQU_Evol_Equip".simplification_bpe_evol drop column if exists domaine;

alter table "F1_EQU_Evol_Equip".simplification_bpe_evol add column domaine varchar;
update  "F1_EQU_Evol_Equip".simplification_bpe_evol  set domaine=
substring(typequ,1,1);

--on crée une colone avec des libellés pour les domaines

alter table "F1_EQU_Evol_Equip".simplification_bpe_evol drop column if exists domaine_lib;
alter table "F1_EQU_Evol_Equip".simplification_bpe_evol add column domaine_lib varchar;
update  "F1_EQU_Evol_Equip".simplification_bpe_evol  set domaine_lib=
	CASE 
	WHEN domaine= 'C' THEN 'Enseignement - Formation'
	WHEN domaine=  'D' THEN 'Equipements de sante'
	WHEN domaine= 'F' THEN 'Equipements sportifs'
end; 

select * from "F1_EQU_Evol_Equip".simplification_bpe_evol;

--alter table "F1_EQU_Evol_Equip".simplification_bpe_evol drop column if exists evol_1419;
--alter table "F1_EQU_Evol_Equip".simplification_bpe_evol add column evol_1419 int;
--update  "F1_EQU_Evol_Equip".simplification_bpe_evol set evol_1419 = nb_2019 - nb_2014;


drop table if exists "F1_EQU_Evol_Equip".simplification_bpe_evol_;
create table "F1_EQU_Evol_Equip".simplification_bpe_evol_ as (
	select t2.epci, sum(t2.nb_2014::int) as nb_2014, sum(t2.nb_2019::int) as nb_2019, domaine, domaine_lib 
	from "F1_EQU_Evol_Equip".simplification_bpe_evol as t2
	group by epci, domaine,domaine_lib);
select * from "F1_EQU_Evol_Equip".simplification_bpe_evol_;



-----/////////////////////////----- 2014 ------//////////////////////////////------



drop table if exists "F1_EQU_Evol_Equip".equipement_evol_ccles14;
create table "F1_EQU_Evol_Equip".equipement_evol_ccles14 as (
	
	-- On part d'une base à l'EPCI; on utilise donc le champs correspondant
	with t1 as (
	select Table1.id_geom as id_geom, sum(nb_2014::int) as count_entities, domaine as domaine, domaine_lib as domaine_lib,
	Table1.geom
	from ( select label as ColMaj,label,id_geom,geom from public."TerritoryTable_PV_BDTopo_2020.08_full_2154" ) as Table1
	left join (
		select epci,nb_2014,domaine,domaine_lib from "F1_EQU_Evol_Equip".simplification_bpe_evol_
	) as Table0
	on Table0.epci::varchar = Table1.id_geom
	where Table1.id_geom is not null 
	group by Table1.id_geom,Table1.geom,Table0.domaine,Table0.domaine_lib
	order by Table1.id_geom
	),
	
	
	-- GÃ©omÃ©tries niveau 4 de la table territoire ==== SCoT
	rank2 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154"
			WHERE rank = 4
			GROUP BY id_geom
	),
	-- Niv 2 : PolaritÃ©s
	t2 as (
		select rank2.id_geom as id_geom,sum(count_entities) as count_entities, domaine as domaine, domaine_lib as domaine_lib,
		rank2.geom
		from rank2
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank2.geom)
		GROUP BY rank2.id_geom,  rank2.geom, t1.domaine, t1.domaine_lib
	)
	
	
	SELECT id_geom,count_entities,domaine,domaine_lib FROM t1 WHERE count_entities is NOT NULL
	UNION
	SELECT id_geom,count_entities,domaine,domaine_lib FROM t2 WHERE count_entities is NOT null
	);
	
select * from "F1_EQU_Evol_Equip".equipement_evol_ccles14
order by id_geom;






------------------------------------
	


-----/////////////////////////----- 2019 ------//////////////////////////////------

drop table if exists "F1_EQU_Evol_Equip".equipement_evol_ccles19;
create table "F1_EQU_Evol_Equip".equipement_evol_ccles19 as (
	
	-- On part d'une base à l'EPCI; on utilise donc le champs correspondant
	with t1 as (
	select Table1.id_geom as id_geom, sum(nb_2019::int) as count_entities, domaine as domaine, domaine_lib as domaine_lib,
	Table1.geom
	from ( select label as ColMaj,label,id_geom,geom from public."TerritoryTable_PV_BDTopo_2020.08_full_2154" ) as Table1
	left join (
		select epci,nb_2019,domaine,domaine_lib from "F1_EQU_Evol_Equip".simplification_bpe_evol_
	) as Table0
	on Table0.epci::varchar = Table1.id_geom
	where Table1.id_geom is not null 
	group by Table1.id_geom,Table1.geom,Table0.domaine,Table0.domaine_lib
	order by Table1.id_geom
	),
	
	
	-- GÃ©omÃ©tries niveau 4 de la table territoire ==== SCoT
	rank2 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154"
			WHERE rank = 4
			GROUP BY id_geom
	),
	-- Niv 2 : PolaritÃ©s
	t2 as (
		select rank2.id_geom as id_geom,sum(count_entities) as count_entities, domaine as domaine, domaine_lib as domaine_lib,
		rank2.geom
		from rank2
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank2.geom)
		GROUP BY rank2.id_geom,  rank2.geom, t1.domaine, t1.domaine_lib
	)
	
	
	SELECT id_geom,count_entities,domaine,domaine_lib FROM t1 WHERE count_entities is NOT NULL
	UNION
	SELECT id_geom,count_entities,domaine,domaine_lib FROM t2 WHERE count_entities is NOT null
	);
	
select * from "F1_EQU_Evol_Equip".equipement_evol_ccles19
order by id_geom;

----------------------------------------------------------------------


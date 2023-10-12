-- la donnée d'étiage peut être téléchargée ici https://onde.eaufrance.fr/content/t%C3%A9l%C3%A9charger-les-donn%C3%A9es-des-campagnes-par-ann%C3%A9e
-- elle doit être jointe aux troncons hydro de la bt_topo

--- jointure du fichier onde national avec toutes les ann�es/dates---
create table troncons_hydro2017_etiage as (
	select onde.id ids,"<cdsitehydro>","<lbsitehydro>","<annee>","<typecampobservations>","<dtrealobservation>","<lbrsobservationdpt>","<rsobservationdpt>","<lbrsobservationnat>","<rsobservationnat>","<nomentitehydrographique>","<cdtronconhydrographique>","<lbcommune>","<cdcommune>","<cddepartement>","<lbregion>","<nomcircadminbassin>","<coordxsitehydro>","<coordysitehydro>","<projcoordsitehydro>",flg,geom,gid,idtronconh,numerotron,pkamonttro,pkavaltron,cdentitehy,nomentiteh,idnoeudhyd,idnoeudh_1,cdentite_1,cdtronconh,cdsousmili,etat,sens,largeur,nature,navigable,gabarit,possol,candidat1,toponyme2,candidat2 
	from "full_ONDE" onde 
	inner join troncon_hydro_2017 th on onde."<cdtronconhydrographique>"= th.cdtronconh 
	order by "<dtrealobservation>", "<cdtronconhydrographique>"
)
------ cr�ation d'un champ num�rique avec les donn�es cat�goriques - ----
alter table troncons_hydro2017_etiage add column statut int;
update troncons_hydro2017_etiage set statut = 
	case when "<lbrsobservationdpt>" = 'Ecoulement visible acceptable' then 5
	when "<lbrsobservationdpt>" = 'Ecoulement visible' then 4
	when "<lbrsobservationdpt>" = 'Ecoulement visible faible' then 3
	when "<lbrsobservationdpt>" = 'Ecoulement non visible' then 2
	when "<lbrsobservationdpt>" = 'Assec' then 1
	end;

------- cr�ation d'un vrai champs "date"

alter table troncons_hydro2017_etiage drop column date ;
alter table troncons_hydro2017_etiage add column date_obs date;
update troncons_hydro2017_etiage set date_obs = to_date("<dtrealobservation>",'yyyy-mm-dd');


----------Cr�er une table d'aggr�gation de toutes les stations du territoire, regroupant le nb de statuts par mois- an ---------


drop table if exists aggregation_hydro;
create table aggregation_hydro as (
		select 
       count(statut) nb_statut,
       --count(distinct(statut)),
       statut
from "tronconsEtiages_pst_2017"
group by date_trunc('month',date_obs), statut
order by 1
);
select * from aggregation_hydro
order by date_obs;

--------------s�paration des diff�rents statuts en diff�rentes colones / mois-ann�es --------------

drop table if exists test_evol_stat_pst;
create table test_evol_stat_pst as (

with date_test as(
select distinct(to_date(date_obs,'MM-YYYY')) date_obs
from aggregation_hydro
),
t1 as( 
select to_date(date_obs, 'MM-YYYY') date_obs1,nb_statut st1
from aggregation_hydro
where statut = '1'
),
t2 as (
select to_date(date_obs, 'MM-YYYY') date_obs2,nb_statut st2
from aggregation_hydro
where statut = '2'
),
t3 as (
select to_date(date_obs, 'MM-YYYY') date_obs3,nb_statut st3
from aggregation_hydro
where statut = '3'
),
t4 as (
select to_date(date_obs, 'MM-YYYY') date_obs4,nb_statut st4
from aggregation_hydro
where statut = '4'
),
t5 as (
select to_date(date_obs, 'MM-YYYY') date_obs5,nb_statut st5
from aggregation_hydro
where statut = '5'
),
t6 as(
select * from date_test dat
	left join t1 on dat.date_obs=t1.date_obs1
	left join t2 on dat.date_obs=t2.date_obs2
	left join t3 on dat.date_obs=t3.date_obs3
	left join t4 on dat.date_obs=t4.date_obs4
	left join t5 on dat.date_obs=t5.date_obs5
	order by dat.date_obs)
	select * from t6
);

select * from test_evol_stat_pst;

select * from test_evol_stat_pst
order by date_obs;


--------- calcul de l'indice ----------


drop table if exists indice;
create table indice as (
with t1 as (
select date_obs date_obs1,coalesce(sum(nb_statut),0) nb_continu from aggregation_hydro where statut >= '3'group by date_obs
),
t2 as (
select date_obs date_obs2,coalesce(sum(nb_statut),0) nb_discontinu from aggregation_hydro where statut <'3' group by date_obs
),
t3 as (
select date_obs date_obs3,coalesce(sum (nb_statut),0) total from aggregation_hydro group by date_obs
),
t4 as(
select * from t1 
full join t2 on t1.date_obs1=t2.date_obs2 
full join t3 on t1.date_obs1=t3.date_obs3 
order by to_date(t1.date_obs1,'MM-YYYY') 
),
t5 as(
select  t4.date_obs1,t4.nb_continu,coalesce(t4.nb_discontinu,0) nb_discontinu , t4.total,(5*coalesce(t4.nb_discontinu,0)::decimal+10*coalesce(t4.nb_continu,0)::decimal)/t4.total::decimal indice from t4
order by to_date(t4.date_obs1,'MM-YYYY') 
)
select * from  t5 
);

------ d�sormais on peut r�aliser une jointure entre la table contenant les observations par statut et celle des indices ------
select * from indiceleft join;

create table final_etiage as(
select date_obs,st1,st2,st3,st4,st5,indice from test_evol_stat_pst stat
join indice on stat.date_obs= to_date(indice.date_obs1,'MM-YYYY')
)



select * from indice







select distinct ("<lbrsobservationdpt>") from troncons_hydro2017_etiage
order by date asc;

select distinct "troncons_hydro2017_etiage";
select * from troncons_hydro2017_etiage;


select * from "full_ONDE" onde,troncon_hydro_2017 th   where onde."<cdtronconhydrographique>"= th.cdtronconh ;
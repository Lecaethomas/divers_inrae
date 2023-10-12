-- un petit script pour calculer le nombre de masses d'eau contenues à toutes les échelles administratives selon leur état (écologique/chimique)
------------------------------
--//////// Etat écologique
------------------------------

drop table if exists ccles_qual_eaux_intermed_eco;
create table ccles_qual_eaux_intermed_eco as (
with t1 as(
select "eco_2009Etat écologique des masses d'eau - cours d'eau en 2009" eco09 , count("eco_2009Etat écologique des masses d'eau - cours d'eau en 2009") nbeco09
from "F2_EAU_masses_d_eau" mde, public."TerritoryTable_PST_2020_2154" ttpbf  
where st_intersects(mde.geom,ttpbf.geom)  and ttpbf.rank='3'
group by eco09
),
t2 as( 
select  "eco_2015Etat écologique des masses d'eau - cours d'eau en 2015" eco15, count("eco_2015Etat écologique des masses d'eau - cours d'eau en 2015") nbeco15
from "F2_EAU_masses_d_eau" mde, public."TerritoryTable_PST_2020_2154" ttpbf  
where st_intersects(mde.geom,ttpbf.geom)  and ttpbf.rank='3'
group by eco15
)
select * from t1 full join t2 on t1.eco09=t2.eco15);


select * from ccles_qual_eaux_intermed_eco;


----Creation d'une table pour accueillir les chiffre clés proprement en vue de construire le graphique



DROP TABLE IF EXISTS ccles_qual_eaux_eco;

CREATE TABLE ccles_qual_eaux_eco (
	"year" int  not null,
	"etat_inconnu" int  NOT NULL,
	"etat_mauvais" int NOT NULL,
	"etat_mediocre" int  not null,
    "etat_moyen" int  not null,
    "etat_bon" int  not null
);

INSERT INTO ccles_qual_eaux_eco (year,etat_inconnu, etat_mauvais, etat_mediocre,etat_moyen,etat_bon)
VALUES (2009, 1,0,1,49,8);
select * from ccles_qual_eaux_eco;

INSERT INTO ccles_qual_eaux_eco (year,etat_inconnu, etat_mauvais, etat_mediocre,etat_moyen,etat_bon)
VALUES (2015, 0,0,2,43,14);
select * from ccles_qual_eaux_eco;


-----------------------------
--///////  Etat chimique
-----------------------------

drop table if exists ccles_qual_eaux_intermed_ch;
create table ccles_qual_eaux_intermed_ch as (
with t1 as(
select "ch_2009Etat chimique des masses d'eau - cours d'eau en 2009" ch09 , count("ch_2009Etat chimique des masses d'eau - cours d'eau en 2009") nbch09
from "F2_EAU_masses_d_eau" mde, public."TerritoryTable_PST_2020_2154" ttpbf  
where st_intersects(mde.geom,ttpbf.geom)  and ttpbf.rank='3'
group by ch09
),
t2 as( 
select  "ch_2015Etat chimique des masses d'eau - cours d'eau en 2015" ch15, count("ch_2015Etat chimique des masses d'eau - cours d'eau en 2015") nbch15
from "F2_EAU_masses_d_eau" mde, public."TerritoryTable_PST_2020_2154" ttpbf  
where st_intersects(mde.geom,ttpbf.geom)  and ttpbf.rank='3'
group by ch15
)
select * from t1 full join t2 on t1.ch09=t2.ch15);

select * from ccles_qual_eaux_intermed_ch;

----Creation d'une table pour accueillir les chiffre clés proprement en vue de construire le graphique



DROP TABLE IF EXISTS ccles_qual_eaux_ch;

CREATE TABLE ccles_qual_eaux_ch (
	"year" int  not null,
	"Non atteinte du bon état" int  NOT NULL,
	"Bon" int NOT NULL,
	"Inconnu" int  not null
);

INSERT INTO ccles_qual_eaux_ch (year,"Non atteinte du bon état", "Bon", "Inconnu")
VALUES (2009, 5,38,16);
select * from ccles_qual_eaux_ch;

INSERT INTO ccles_qual_eaux_ch (year,"Non atteinte du bon état","Bon","Inconnu")
VALUES (2015, 5,42,12);
select * from ccles_qual_eaux_ch;


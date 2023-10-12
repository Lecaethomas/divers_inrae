
-- group by class 2016
select "Classe" ,round((sum(st_area(geom))/10000)::numeric,2) as ha_area from "F1_NRJ_sequestrationCarbone"."OSO_Carca_20160101" op 
group by "Classe"
ORDER by "Classe" ;

-- group by class 2019
select "classe" ,round((sum(st_area(geom))/10000)::numeric,2) as ha_area from "F1_NRJ_sequestrationCarbone"."OSO_Carca_20200101" op 
group by "classe"
ORDER by "classe" ;

-- correspondance 2016
case when "Classe" in (11,12,34,36) then 56
  when "Classe" in (31,32) then 71
  when "Classe" in (41,42,43,44) then 0
  when "Classe" in (45,46,51,53) then 0
  when "Classe" in (211) then 70
  when "Classe" in (221,222) then 56
 else 999
END
  

-- correspondance 2019
case when "Classe" in (1,2,3,4) then 0
  when "Classe" in (5,6,7,8,9,10,11,12,18,19) then 56
  when "Classe" in (13) then 70
  when "Classe" in (14,15) then 51
  when "Classe" in (16,17) then 71
  when "Classe" in (20,21,22,23) then 0
 else 999
end



alter table "F1_NRJ_sequestrationCarbone"."OSO_Carca_20160101" add column classealdo  


-- creation de la structure aldo

CREATE TABLE "F1_NRJ_sequestrationCarbone".structure_aldo(
   id   INTEGER  NOT NULL PRIMARY KEY 
  ,niv1 VARCHAR(39) NOT NULL
  ,niv2 VARCHAR(39) NOT NULL
);
INSERT INTO structure_aldo(id,niv1,niv2) VALUES (1,'cultures','cultures');
INSERT INTO structure_aldo(id,niv1,niv2) VALUES (2,'prairies','prairies zones herbacées');
INSERT INTO structure_aldo(id,niv1,niv2) VALUES (3,'prairies','prairies zones arbustives');
INSERT INTO structure_aldo(id,niv1,niv2) VALUES (4,'prairies','prairies zones arborées');
INSERT INTO structure_aldo(id,niv1,niv2) VALUES (5,'forêts','feuillus');
INSERT INTO structure_aldo(id,niv1,niv2) VALUES (6,'forêts','mixtes');
INSERT INTO structure_aldo(id,niv1,niv2) VALUES (7,'forêts','coniferes');
INSERT INTO structure_aldo(id,niv1,niv2) VALUES (8,'forêts','peupleraies');
INSERT INTO structure_aldo(id,niv1,niv2) VALUES (9,'zones humides','zones humides');
INSERT INTO structure_aldo(id,niv1,niv2) VALUES (10,'vergers','vergers');
INSERT INTO structure_aldo(id,niv1,niv2) VALUES (11,'vignes','vignes');
INSERT INTO structure_aldo(id,niv1,niv2) VALUES (12,'sols artificiels imperméabilisés*','sols artificiels imperméabilisés');
INSERT INTO structure_aldo(id,niv1,niv2) VALUES (13,'sols artificiels enherbés*','sols artificiels arbustifs');
INSERT INTO structure_aldo(id,niv1,niv2) VALUES (14,'sols artificiels arborés et buissonants','sols artificiels arborés et buissonants');
INSERT INTO structure_aldo(id,niv1,niv2) VALUES (15,'haies','Haies associées aux espaces agricoles');



--coresspondance OSO aldo
alter table "F1_NRJ_sequestrationCarbone"."OSO_Carca_20160101" add column classealdo int;
alter table "F1_NRJ_sequestrationCarbone"."OSO_Carca_20200101" add column classealdo int;

-- OSO 2016
update "F1_NRJ_sequestrationCarbone"."OSO_Carca_20160101" set classealdo = case 
  when "Classe" in (11,12) then 1 
  when "Classe" in (31) then 5 
  when "Classe" in (32) then 7 
  when "Classe" in (34,211) then 2 
  when "Classe" in (36) then 3
  when "Classe" in (41,42,43,44) then 12
  when "Classe" in (51) then 9
  when "Classe" in (221) then 10
  when "Classe" in (222) then 11
  ELSE NULL
end;


-- OSO 2019
update "F1_NRJ_sequestrationCarbone"."OSO_Carca_20200101" set classealdo = case 
  when "classe" in (1,2,3,4) then 12
  when "classe" in (5,6,7,8,9,10,11,12) then 1 
  when "classe" in (13,18) then 2
  when "classe" in (14) then 10
  when "classe" in (15) then 11
  when "classe" in (16) then 5
  when "classe" in (17) then 7
  when "classe" in (19) then 3
  when "classe" in (23) then 9
  ELSE NULL
end;

SELECT DISTINCT "Classe" FROM "F1_NRJ_sequestrationCarbone"."OSO_Carca_20160101"
ORDER BY "Classe"

SELECT sum(st_area(geom)) FROM "F1_NRJ_sequestrationCarbone"."OSO_Carca_20200101" WHERE "classealdo" = 12;
SELECT sum(st_area(geom)) FROM "F1_NRJ_sequestrationCarbone"."OSO_Carca_20160101" WHERE "classealdo" = 12
--stats 

-- aggregate EPCI
DROP TABLE IF EXISTS "F1_NRJ_sequestrationCarbone".chiffres_cles_2016;
CREATE TABLE "F1_NRJ_sequestrationCarbone".chiffres_cles_2016 AS (
select classealdo,cc.id_geom ,round((sum(st_area(op.geom))/10000)::numeric,2) as ha_area 
from "F1_NRJ_sequestrationCarbone"."OSO_Carca_20160101" op ,
public."TerritoryTable_CA_Carca_2020" tt,
public."TerritoryTable_CA_Carca_2020" cc
where ST_intersects(tt.geom,op.geom) and st_within(st_centroid(op.geom),tt.geom) and tt.rank=1 
and cc.rank=2  
and st_within(st_centroid(tt.geom),cc.geom)   
group by cc.id_geom,classealdo
ORDER by cc.id_geom,classealdo)

SELECT st_area(geom) FROM public."TerritoryTable_CA_Carca_2020" ttcc 
WHERE RANK = '2'


-- aggregate à la Commune
-- USELESS
DROP TABLE IF EXISTS "F1_NRJ_sequestrationCarbone".chiffres_cles_2020;
CREATE TABLE "F1_NRJ_sequestrationCarbone".chiffres_cles_2020 AS (
select tt.id_geom,classealdo,cc.id_geom cc_id_geom,round((sum(st_area(op.geom))/10000)::numeric,2) as ha_area 
from "F1_NRJ_sequestrationCarbone"."OSO_Carca_20200101" op ,
public."TerritoryTable_CA_Carca_2020" tt,
public."TerritoryTable_CA_Carca_2020" cc
where ST_intersects(tt.geom,op.geom) and st_within(st_centroid(op.geom),tt.geom) and tt.rank=1 
and cc.rank=2
and st_within(st_centroid(tt.geom),cc.geom)   
group by tt.id_geom,cc.id_geom,classealdo
ORDER by tt.id_geom,cc.id_geom,classealdo
)




-- 




select distinct "Classe",st_area(geom)/10000 from "F1_NRJ_sequestrationCarbone"."OSO_Carca_20160101" where classealdo is null




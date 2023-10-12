-- Boucle pour extraire les g�om�tries sur mon territoire de test (-st Brieuc)
DO $$
DECLARE
    tables CURSOR FOR
        SELECT lower(tablename) tablename
        FROM pg_tables
        where schemaname = 'Dev_TU_TB'
        and right(lower(tablename),4)<> 'test'
        ORDER BY tablename;
    --nbRow geometry;
BEGIN
    FOR table_record IN tables LOOP
        EXECUTE 'Drop table if exists "Dev_TU_TB".'||table_record.tablename||'_test;
				Create TABLE "Dev_TU_TB".'||table_record.tablename||'_test as (
				 Select t1.*, st_intersection(t1.geom, t2.geom) the_geom
					from "Dev_TU_TB".'||table_record.tablename||' t1
					left join "SANDBOX"."PSB_TerritoryTable2019_2154" t2
					on st_intersects(t1.geom,t2.geom)
						where t2.id_geom=''22278''
					);
				
					Drop index if exists '||table_record.tablename||'_test_idx;
					Create index '||table_record.tablename||'_test_idx 
						on '||table_record.tablename||'_test  using gist(geom);
		
					SELECT Populate_Geometry_Columns('''||table_record.tablename||'_test''::regclass);';
				
    END LOOP;
END$$;


-------///////------////////
-- // -- Prod TU -- // -- 
-------///////------////////
--drop table if exists indicateur_tache_urbaine;
--create table indicateur_tache_urbaine as (
-- Create variable buffers depending on road's nature property

-- 17min57s
drop table if exists "F1_OCS_TacheUrbaine".routes_buf;
create TABLE "F1_OCS_TacheUrbaine".routes_buf as(
select st_union(st_buffer(geom, CASE
		WHEN "nature" LIKE  'Type autoroutier'  THEN 10
		WHEN "nature" LIKE  'Route à 2 chaussées' THEN 6
		WHEN "nature" LIKE  'Route à 1 chaussée' THEN 3
		WHEN "nature" LIKE  'Bretelle' THEN 3
		WHEN "nature" LIKE  'Piste cyclable' THEN 1.5
		WHEN "nature" LIKE  'Rond-point' THEN 3
		ELSE 1
END)) geom from "F1_OCS_TacheUrbaine".ign_bdtopo_troncroutes_20211215);

CREATE INDEX routes_buf_idx
  ON "F1_OCS_TacheUrbaine".routes_buf
  USING GIST (geom);

-- 1sec
-- create fixed buffer (default : 5m) around train ways
drop table if EXISTS "F1_OCS_TacheUrbaine".vf_buf;
create table "F1_OCS_TacheUrbaine".vf_buf as(
select st_buffer(t1.geom, 5) geom from "F1_OCS_TacheUrbaine".ign_bdtopo_vf_20211215 t1
);

CREATE INDEX vf_buf_idx
  ON "F1_OCS_TacheUrbaine".vf_buf
  USING GIST (geom);
 
-- Merge both networks. 
 --140min 17s
drop table if EXISTS "F1_OCS_TacheUrbaine".viaire_merged;
create TABLE "F1_OCS_TacheUrbaine".viaire_merged as (
	with t1 as (
	-- first, only keep train network that doesn't overlap road network (trick equivalent to union + dissolve in qgis)
	select st_difference(t1.geom, t2.geom) geom from "F1_OCS_TacheUrbaine".vf_buf t1, "F1_OCS_TacheUrbaine".routes_buf t2
	),
	t2 as (
	-- union both networks
	select geom from t1 
	union 
	select geom from "F1_OCS_TacheUrbaine".routes_buf
	)
	-- dissolve shared boundaries
	select st_union(t2.geom) geom from t2
);
CREATE INDEX viaire_merged_idx
  ON "F1_OCS_TacheUrbaine".viaire_merged
  USING GIST (geom);


 
drop table if EXISTS "F1_OCS_TacheUrbaine".poly_buf ;
create TABLE "F1_OCS_TacheUrbaine".poly_buf as(
WITH poly_merged AS (
--select geom from bd_topo_terrains_sport_route_202112_test
--union 
--select geom from bd_topo_cimetieres_route_202112_test
--union
select geom from "F1_OCS_TacheUrbaine".ign_bdtopo_bati_20211215
)
select st_makevalid(st_buffer(st_makevalid(st_union(st_makevalid(st_buffer(st_makevalid(t1.geom), 50)))),-25)) geom 
from poly_merged t1);

DROP INDEX IF EXISTS poly_buf_idx;
CREATE INDEX poly_buf_idx
  ON "F1_OCS_TacheUrbaine".poly_buf
  USING GIST (geom);
-- create infrastructure geometry (the part of network that doesn't overlap building spot)
 
drop table if EXISTS "F1_OCS_TacheUrbaine".tache_infra; 
create TABLE "F1_OCS_TacheUrbaine".tache_infra as(
select st_difference( st_makevalid(t1.geom), st_makevalid(t2.geom)) geom from "F1_OCS_TacheUrbaine".viaire_merged t1, "F1_OCS_TacheUrbaine".poly_buf t2
);

CREATE INDEX tache_infra_idx
  ON "F1_OCS_TacheUrbaine".tache_infra
  USING GIST (geom);
--merge it all together !
 
drop table if EXISTS "F1_OCS_TacheUrbaine"."tacheUrbaine"; 
create TABLE "F1_OCS_TacheUrbaine"."tacheUrbaine" as (
	with t1 as (
	-- union of infrastructure spot + buiding spot
	select * from "F1_OCS_TacheUrbaine".tache_infra
	union
	select * from "F1_OCS_TacheUrbaine".poly_buf
	)
	-- dissolving of shared boundaries
	select st_union(t1.geom) geom from t1
)

DROP TABLE IF EXISTS "F1_OCS_TacheUrbaine"."chiffresCles";
CREATE TABLE "F1_OCS_TacheUrbaine"."chiffresCles" AS (
SELECT tt.id_geom, st_Area(st_intersection(tt.geom, tu.geom)) "Area_ENTITIES", st_area(tt.geom) "Area_TERRITORIES"
FROM "F1_OCS_TacheUrbaine"."tacheUrbaine" tu 
LEFT JOIN public."TerritoryTable_PSB_2019_2154" tt
ON st_intersects(tt.geom, tu.geom))



select st_area(geom) from "F1_OCS_TacheUrbaine".indicateur_tache_urbaine


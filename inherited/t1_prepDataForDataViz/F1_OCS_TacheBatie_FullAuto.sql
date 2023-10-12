DROP TABLE IF EXISTS "F1_OCS_TacheBatie".indicateur_tache_batie ;
CREATE TABLE "F1_OCS_TacheBatie".indicateur_tache_batie AS (
SELECT st_makevalid(st_buffer(st_makevalid(st_union(st_makevalid(st_buffer(st_makevalid(t1.geom), 50)))),-25)) geom 
FROM "F1_OCS_TacheBatie".ign_bdtopo_batiments_202112 t1)
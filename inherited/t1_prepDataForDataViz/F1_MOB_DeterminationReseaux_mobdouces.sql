

DROP TABLE IF EXISTS "F1_MOB_DeterminationReseaux_mobdouces".chiffres_cles;
CREATE TABLE "F1_MOB_DeterminationReseaux_mobdouces".chiffres_cles AS (
WITH t_rando AS (
SELECT round((st_length(st_intersection(st_union(tr.geom), tt.geom))/1000)::NUMERIC,2) len_rando, tt.id_geom 
FROM "F1_MOB_DeterminationReseaux_mobdouces"."CAP_troncons_rando_092021" tr
LEFT JOIN public."territory_table_CAP20" tt 
ON st_intersects(tt.geom,tr.geom)
--WHERE tt.RANK = '3'
GROUP BY id_geom, tt.geom
),
t_velo AS (
SELECT round((st_length(st_intersection(st_union(tv.geom), tt.geom))/1000)::NUMERIC,2) len_velo, tt.id_geom 
FROM "F1_MOB_DeterminationReseaux_mobdouces"."CAP_troncons_velo_2021" tv
LEFT JOIN public."territory_table_CAP20" tt 
ON st_intersects(tt.geom,tv.geom)
--WHERE tt.RANK = '3'
WHERE tv.etat_avancement NOT IN ('Projet', 'En attente', 'Non retenu')
GROUP BY id_geom, tt.geom
)
SELECT tt.id_geom , len_rando , len_velo FROM public."territory_table_CAP20" tt
LEFT JOIN t_velo 
ON tt.id_geom= t_velo.id_geom
LEFT JOIN t_rando
ON tt.id_geom = t_rando.id_geom
)

SELECT distinct(etat_avancement) FROM "F1_MOB_DeterminationReseaux_mobdouces"."CAP_troncons_velo_2021"


WHERE len_rando NOT in(0, null)


SELECT * FROM "F1_MOB_DeterminationReseaux_mobdouces"."CAP_troncons_velo_2021" tv

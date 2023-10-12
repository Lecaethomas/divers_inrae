-- Rien de compliqué - on travaille avec une couche de CDAC fournie pas le territoire

DROP TABLE IF EXISTS "spe_F4_EQU_ProjetsRequalificationParcsCommerciaux"."chiffres_cles";
CREATE TABLE  "spe_F4_EQU_ProjetsRequalificationParcsCommerciaux"."chiffres_cles" AS (
SELECT id_geom,  COALESCE(count(*),0) "Count_ENTITIES" FROM "spe_F4_EQU_ProjetsRequalificationParcsCommerciaux"."CAP_CADAC_T0MAJ" cd
LEFT JOIN public."territory_table_CAP20" tt
ON st_intersects(tt.geom, cd.geom)
--WHERE année <> '2018'
GROUP BY id_geom
)
SELECT * FROM "spe_F4_EQU_ProjetsRequalificationParcsCommerciaux"."CAP_CADAC_T0MAJ"
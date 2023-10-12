-- script de calcul pour l'indicateur risques technologiques et pollution
-- author THL
-- 20220322
--Summary :
-- on compte des choses dans des polygones
-- Warning :
-- on a initialisé avec basol et lors de l'actualisation cette donnée avait migré vers "sites et sol pollués ex-basol". En dépit du nom on avait un donnée avec des points et des polygones 
-- aucun point mais 20 entités multipoly sur le territoire dont 5 avec une information d'instruction ='en cours' parmi lesquelles 3 recouvrent les 3 points présernts à l'initialisation. 
-- j'écris ça au cas où.
-- Car on a finalement trouvé une donnée basol au 09-2020 (derniere actualisation) chez cquest donc on actualise avec ça et on verra plus tard pour l'autre donnée
DROP TABLE IF EXISTS "spe_F4_NUI_SitesBruit_SitesEtSolsPollues".chiffres_cles;
CREATE TABLE "spe_F4_NUI_SitesBruit_SitesEtSolsPollues".chiffres_cles AS (
--basias : 
SELECT tt.id_geom, 'Basias'::TEXT "Location",count(*) "Count_ENTITIES" FROM "spe_F4_NUI_SitesBruit_SitesEtSolsPollues"."georisques_BASIAS_44_46_20220318" basias 
LEFT JOIN public."territory_table_CAP20" tt
ON st_intersects(tt.geom, basias.geom)
WHERE st_intersects(tt.geom, basias.geom)
GROUP BY tt.id_geom
UNION all
-- seveso :
SELECT tt.id_geom, 'Seveso'::TEXT "Location",count(*) "Count_ENTITIES" FROM "spe_F4_NUI_SitesBruit_SitesEtSolsPollues"."opendatasft_sitesSeveso_202203" seveso
LEFT JOIN public."territory_table_CAP20" tt
ON st_intersects(tt.geom, seveso.geom)
WHERE st_intersects(tt.geom, seveso.geom)
GROUP BY tt.id_geom
UNION all
-- basol : 
SELECT tt.id_geom, 'Basol'::TEXT "Location",count(*) "Count_ENTITIES" FROM "spe_F4_NUI_SitesBruit_SitesEtSolsPollues"."opndataarchves_basol_20200924" basol
LEFT JOIN public."territory_table_CAP20" tt
ON st_intersects(tt.geom, basol.geom)
WHERE st_intersects(tt.geom, basol.geom)
GROUP BY tt.id_geom
)

-- si besoin de bosser avec les sites et sols pollués : 
SELECT tt.id_geom,--stat_instr, 
CASE
WHEN stat_instr = 'Clôturée' THEN 'exBasolClot'
WHEN stat_instr = 'En cours' THEN 'exBasolEnCours' 
END "Location", 
count(*) "Count_ENTITIES" FROM "spe_F4_NUI_SitesBruit_SitesEtSolsPollues"."georisques_exBasol_poly_20220318" exbasol 
LEFT JOIN public."territory_table_CAP20" tt
ON st_intersects(tt.geom, st_centroid(exbasol.geom))
WHERE st_intersects(tt.geom, exbasol.geom)
GROUP BY tt.id_geom, stat_instr
ORDER BY tt.id_geom 

-- les geo pour la dataviz
-- basias 
DROP TABLE IF EXISTS dataviz_basias_2022;
CREATE TABLE dataviz_basias_2022 AS (
SELECT basias.geom, "Raison sociale" "Raison soc", "Libellé activité" "Libellé a" FROM "spe_F4_NUI_SitesBruit_SitesEtSolsPollues"."georisques_BASIAS_44_46_20220318" basias,
public."territory_table_CAP20" tt
WHERE tt.RANK = '3' AND st_intersects(tt.geom, basias.geom)
);

DROP TABLE IF EXISTS dataviz_basol_2022;
CREATE TABLE dataviz_basol_2022 AS (
SELECT basol.geom, "sp1_site" "Nom usuel"  FROM "spe_F4_NUI_SitesBruit_SitesEtSolsPollues"."opndataarchves_basol_20200924" basol,
public."territory_table_CAP20" tt
WHERE tt.RANK = '3' AND st_intersects(tt.geom, basol.geom)
);

DROP TABLE IF EXISTS dataviz_seveso_2022;
CREATE TABLE dataviz_seveso_2022 AS (
SELECT seveso.geom, "c_nom_ets" "name", "c_famill_l" "lib"  FROM "spe_F4_NUI_SitesBruit_SitesEtSolsPollues"."opendatasft_sitesSeveso_202203" seveso,
public."territory_table_CAP20" tt
WHERE tt.RANK = '3' AND st_intersects(tt.geom, seveso.geom)
);



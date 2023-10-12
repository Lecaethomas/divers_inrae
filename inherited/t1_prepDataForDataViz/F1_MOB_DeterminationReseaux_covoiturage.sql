
-- + Changer le nom du champ qui contient le nom de l'aire de covoiturage

drop table if exists "F1_MOB_RecensementAiresCovoiturages"."F1_MOB_RecensementAiresCovoiturages";
create table "F1_MOB_RecensementAiresCovoiturages"."F1_MOB_RecensementAiresCovoiturages" as (
SELECT b.id_geom, Count(a.geom) "Count_ENTITIES"
FROM public."territory_table_CAP20" b 
LEFT JOIN pt_acces_nat_basenatlieuxcovoit_20220110 a
ON ST_Intersects(a.geom, b.geom)
GROUP BY b.id_geom
)

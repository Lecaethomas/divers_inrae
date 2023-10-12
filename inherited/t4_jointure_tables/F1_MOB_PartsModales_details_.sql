DROP TABLE IF EXISTS "PST_actualisation"."F1_MOB"."F1_MOB_parts_mod";
CREATE TABLE "F1_MOB"."F1_MOB_parts_mod" AS (
		SELECT b.id_geom, a.*
		FROM public."TerritoryTable_PST_2019_maj_2020.01.14" AS b
		Left JOIN "F1_MOB"."Parts_Modales_PST_GEO_2019" AS a
		on a."NOM_COM"=b."label");
		
		
SELECT * FROM "PST_actualisation"."F1_MOB"."F1_MOB_parts_mod";
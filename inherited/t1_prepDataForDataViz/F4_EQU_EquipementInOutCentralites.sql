drop table if exists sirene2020cap;
create table sirene2020cap as(
Select ttc.id_geom,siren,nic,siret,statutdiffusionetablissement,datecreationetablissement,trancheeffectifsetablissement,anneeeffectifsetablissement,activiteprincipaleregistremetiersetablissement,datederniertraitementetablissement,etablissementsiege,nombreperiodesetablissement,complementadresseetablissement,numerovoieetablissement,indicerepetitionetablissement,typevoieetablissement,libellevoieetablissement,codepostaletablissement,libellecommuneetablissement,libellecommuneetrangeretablissement,distributionspecialeetablissement,codecommuneetablissement,codecedexetablissement,libellecedexetablissement,codepaysetrangeretablissement,libellepaysetrangeretablissement,complementadresse2etablissement,numerovoie2etablissement,indicerepetition2etablissement,typevoie2etablissement,libellevoie2etablissement,codepostal2etablissement,libellecommune2etablissement,libellecommuneetranger2etablissement,distributionspeciale2etablissement,codecommune2etablissement,codecedex2etablissement,libellecedex2etablissement,codepaysetranger2etablissement,libellepaysetranger2etablissement,datedebut,etatadministratifetablissement,enseigne1etablissement,enseigne2etablissement,enseigne3etablissement,denominationusuelleetablissement,activiteprincipaleetablissement,nomenclatureactiviteprincipaleetablissement,caractereemployeuretablissement,longitude,latitude,geo_score,geo_type,geo_adresse,geo_id,geo_ligne,geo_l4,geo_l5
from stocketablissementactif_utf8_geo_csv sugc ,
public."TerritoryTable_CAP20" ttc 
where ttc.id_geom= sugc.codecommuneetablissement::varchar);

alter table sirene2020cap drop column if exists geom ;
alter table sirene2020cap add column geom geometry(Point,4326);
update sirene2020cap set geom =ST_SetSRID(ST_MakePoint(longitude, latitude), 4326);
alter table sirene2020cap ALTER COLUMN geom TYPE geometry(Point,2154) USING ST_Transform(geom,2154);


DROP INDEX if exists sidxsirene2020cap;


select * from sirene2020cap

select count(st_intersects(ttc.geom,sir.geom)), ttc.id_geom
from sirene2020cap sir, public."TerritoryTable_CAP20" ttc 
group by ttc.id_geom

DROP TABLE IF EXISTS "F4_EQU_EvolEquCentralites"."F4_EQU_EvoEquCentralitesCC";
CREATE TABLE "F4_EQU_EvolEquCentralites"."F4_EQU_EvoEquCentralitesCC" AS (
	-- Nombre total de locaux par commune. Les communes sans locaux n'apparaitront pas dans la table finale
	WITH total_by_com AS ( 
		SELECT t.id_geom id_geom, Count(a.geom) "Count_ENTITIES"
		FROM "F4_EQU_EvolEquCentralites"."sirene2020cap" a, public."territory_table_CAP20" t
		WHERE ST_Intersects(a.geom,t.geom)
		GROUP BY t.id_geom
	),
	-- Nombre de locaux dans la centralité par commune
	total_by_com_in_env AS (
		SELECT t.id_geom id_geom, Count(a.geom) "Count_ENTITIES",'IN' "Location"
		FROM "F4_EQU_EvolEquCentralites"."sirene2020cap" a, public."territory_table_CAP20" t, "F4_EQU_EvolEquCentralites"."centralite_deter_per_REALLYclean" env
		WHERE ST_Intersects(a.geom,t.geom) AND ST_Intersects(a.geom,env.geom)
		GROUP BY t.id_geom, "Location"
	),
	-- Nombre de locaux hors centralités par commune
	total_by_com_out_env AS (
		SELECT total_by_com.id_geom id_geom, SUM(total_by_com."Count_ENTITIES" - COALESCE(total_by_com_in_env."Count_ENTITIES",0)) "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com, total_by_com_in_env
		WHERE total_by_com.id_geom = total_by_com_in_env.id_geom
		GROUP BY total_by_com.id_geom, "Location"
		UNION 
		-- Ça c'est pour gérer les communes qui auraient des locaux, mais aucun dans le périmètre de centralité
		-- Attention à cette étape, si la commune est multi-partie on aura sans doute un problème
		SELECT total_by_com.id_geom id_geom, total_by_com."Count_ENTITIES" "Count_ENTITIES", 'OUT' "Location"
		FROM total_by_com, total_by_com_in_env
		WHERE total_by_com.id_geom NOT IN (SELECT id_geom FROM total_by_com_in_env)
		GROUP BY total_by_com.id_geom, total_by_com."Count_ENTITIES", "Location"
	)
	-- Union par commune du nombre de locaux dans/hors la centralité
	SELECT id_geom::text, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_in_env
	UNION
	SELECT id_geom::text, "Count_ENTITIES"::int, "Location"::text FROM total_by_com_out_env
	ORDER BY id_geom, "Location"
);
DELETE FROM "F4_EQU_EvolEquCentralites"."F4_EQU_EvoEquCentralitesCC"
WHERE "Count_ENTITIES" = 0; -- On supprime les lignes avec un compte à zéro, c'est pour coller au code de la dataviz.
SELECT * FROM "F4_EQU_EvolEquCentralites"."F4_EQU_EvoEquCentralitesCC";


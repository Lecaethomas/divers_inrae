-- pour l'indicateur F3_MIX_EvolutionParc_Locatif

-- avec l'indicateur F3_MIX_LogementsSociaux_ResidencesPrinc j'ai créé une table france entière "F3_MIX_LogementsSociaux_TotalLog_FRCE_ENTIERE" 
-- elle contient le nombre de logements sociaux entre autre 
-- Export pour l'indicateur F3_MIX_EvolutionParc_Locatif

ALTER TABLE "F3_MIX_EvolutionParc_Locatif".rpls_france_entiere 
add COLUMN "year" text 
UPDATE "F3_MIX_EvolutionParc_Locatif".rpls_france_entiere SET "year" = '2021'

select *
from  "F3_MIX_EvolutionParc_Locatif_PSB_2022".rpls_france_entiere a where "CODGEO" = '22278'


drop table if exists "F3_MIX_EvolutionParc_Locatif_PSB_2022"."F3_MIX_EvolutionParc_Locatif";
create table "F3_MIX_EvolutionParc_Locatif"."F3_MIX_EvolutionParc_Locatif_PSB_2022" as (
with t1 as (
select ttp.geom,"CODGEO" insee,"year","Nb_log_parc_loc_soc"
from  "F3_MIX_EvolutionParc_Locatif".rpls_france_entiere a, public."TerritoryTable_PF_2019" ttp  
	where ttp.id_geom = a."CODGEO"),
rank2 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."TerritoryTable_PF_2019"
			WHERE rank = '2'
			GROUP BY id_geom
	),
	-- Niv 2 : Polarités
t2 as (
		select rank2.id_geom insee,"year",sum("Nb_log_parc_loc_soc") "Nb_log_parc_loc_soc"
		from rank2
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank2.geom)
		GROUP BY rank2.id_geom, t1."year", rank2.geom
	),
	-- Géométries niveau 3 de la table territoire
rank3 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."TerritoryTable_PF_2019"
			WHERE rank = '3'
			GROUP BY id_geom
	),
	-- Données à l'EPCI
t3 as (
		select rank3.id_geom insee,"year",sum("Nb_log_parc_loc_soc") "Nb_log_parc_loc_soc"
			from rank3
			LEFT JOIN t1
			ON ST_Intersects(ST_PointOnSurface(t1.geom),rank3.geom)
			GROUP BY rank3.id_geom, t1."year", rank3.geom
	)
	select insee,"year","Nb_log_parc_loc_soc" from t1
	union all
	select insee,"year","Nb_log_parc_loc_soc" from t2
	union all
	select insee,"year","Nb_log_parc_loc_soc" from t3
	);
	
	select * from "F3_MIX_EvolutionParc_Locatif_PSB_2022"."F3_MIX_EvolutionParc_Locatif_PSB_2022" order by insee
with t1 as(
select siret.id,geom,siren,nic,siret,libellecommuneetablissement,datedebut,etatadministratifetablissement,activiteprincipaleetablissement , naf."intitulés de la  naf rév. 2, version finale"
from geo_siret_35 siret 
left join naf 
on  naf.code=siret.activiteprincipaleetablissement
where siret.etatadministratifetablissement = 'A'
and substring(activiteprincipaleetablissement,1,2) in ('45','46','47')
),
total_by_com as(
select t.id_geom id_geom, Count(a.geom) "Count_ENTITIES"
from "TerritoryTable_PV_BDTopo_2020.08_full_2154" t, 
t1 a
WHERE ST_Intersects(a.geom,t.geom)
		GROUP BY id_geom
),
----------Centralites--------
total_by_com_in_env AS (
		SELECT t.id_geom id_geom, Count(a.geom) "Count_ENTITIES",'IN' "centralite"
		FROM t1 a, "TerritoryTable_PV_BDTopo_2020.08_full_2154" t, perimetres_centralites env
		WHERE ST_Intersects(a.geom,t.geom) AND ST_Intersects(a.geom,env.geom)
		GROUP BY id_geom, "centralite"
	),
total_by_com_out_env AS (
		SELECT total_by_com.id_geom id_geom, SUM(total_by_com."Count_ENTITIES" - COALESCE(total_by_com_in_env."Count_ENTITIES",0)) "Count_ENTITIES", 'OUT' "centralite"
		FROM total_by_com, total_by_com_in_env
		WHERE total_by_com.id_geom = total_by_com_in_env.id_geom
		GROUP BY total_by_com.id_geom, "centralite"
		UNION 
		-- Ça c'est pour gérer les communes qui auraient des locaux, mais aucun dans le périmètre de centralité
		-- Attention à cette étape, si la commune est multi-partie on aura sans doute un problème
		SELECT total_by_com.id_geom id_geom, total_by_com."Count_ENTITIES" "Count_ENTITIES", 'OUT' "centralite"
		FROM total_by_com, total_by_com_in_env
		WHERE total_by_com.id_geom NOT IN (SELECT id_geom FROM total_by_com_in_env)
		GROUP BY total_by_com.id_geom, total_by_com."Count_ENTITIES", "centralite"
	),
	-------sites periphériques------
total_by_com_in_periph AS (
		SELECT t.id_geom id_geom, Count(a.geom) "Count_ENTITIES_periph",'IN' "sites_periph"
		FROM t1 a, "TerritoryTable_PV_BDTopo_2020.08_full_2154" t, sites_periph_pv_2020 periph
		WHERE ST_Intersects(a.geom,t.geom) AND ST_Intersects(a.geom,periph.geom)
		GROUP BY id_geom, "sites_periph"
	) ,
total_by_com_out_periph AS (
		SELECT total_by_com.id_geom id_geom, SUM(total_by_com."Count_ENTITIES" - COALESCE(total_by_com_in_periph."Count_ENTITIES_periph",0)) "Count_ENTITIES_periph", 'OUT' "sites_periph"
		FROM total_by_com, total_by_com_in_periph
		WHERE total_by_com.id_geom = total_by_com_in_periph.id_geom
		GROUP BY total_by_com.id_geom, "sites_periph"
		UNION 
		-- Ça c'est pour gérer les communes qui auraient des locaux, mais aucun dans le périmètre de centralité
		-- Attention à cette étape, si la commune est multi-partie on aura sans doute un problème
		SELECT total_by_com.id_geom id_geom, total_by_com."Count_ENTITIES" "Count_ENTITIES_periph", 'OUT' "sites_periph"
		FROM total_by_com, total_by_com_in_periph
		WHERE total_by_com.id_geom NOT IN (SELECT id_geom FROM total_by_com_in_periph)
		GROUP BY total_by_com.id_geom, total_by_com."Count_ENTITIES", "sites_periph"
	),
	t2 as(
	SELECT * FROM total_by_com_in_env
	UNION
	SELECT * FROM total_by_com_out_env),
	t3 as(
	SELECT * FROM total_by_com_in_periph
	UNION
	SELECT * FROM total_by_com_out_periph)
	select * from t2 left join t3 on t2.id_geom = t3.id_geom
	--select * from t2 left join t3 on t2.id_geom = t3.id_geom
	ORDER BY t2.id_geom, "centralite"



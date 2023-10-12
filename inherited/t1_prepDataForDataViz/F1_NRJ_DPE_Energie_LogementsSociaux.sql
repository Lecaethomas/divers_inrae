-- Pour l'actualisation je préfère utiliser les géométries des RPLS géocodés, plutôt que des jointures attributaires. Au moins en cas de fusion/défusion de commune il suffit de relancer la requête avec la nouvelle table territoire. Sinon il faudrait faire de la COGugaison.
-- J'ai pas vérifié la donnée, mais en l'état si un logement n'a pas de période de renseignée, il est classé en '2013 à aujourd hui'

-- 12.03.2020:
-- Je recommence le traitement avec le RPLS géocodé selon la méthode de Quest.
-- Pour rappel: Virginie avaiat fait un 1er module de géocodage sur la BAN qui a donné les fichiers ..._VID de RPLS. J'étais pas convaincu des résultat alors j'ai fais en sorte de les géocoder selon le script de Quest en comparant BAN & BANO. Mais cet indicateur était déjà produit. Je relance les traitements pour voir, comme on est à la commune on devrait pas voir trop de différence. Comme on a pas encore fait la livraison des données il est encore temps de remplacer la donnée (parce qu'éventuellent y'aura quelques différences à la commune mais au SCoT ça devrait pas bouger)
-- Verdict: on a 5 logements qui changent de catégorie avec le nouveau fichier. Dans ma version il y a un genre de décalage au niveau des colonnes. Résultat j'ai des logements avec un DPE à "01/02/2013". Je sais pas trop comment ça a pu arriver mais ça me gène pas plus que ça. Au moins on a le même nombre de logements. Je vais quand même mettre à jour ma la dataviz avec ma version du fichier pour coller à la livraison qu'on leur envoie et aux autres indicateurs.


-- 20220315 : 
-- THL : je suis ce que Simon conseille ci-dessus, géocodage 'façon cquest et ça roule tout seul

-- Variables:
-- schema:				"F1_NRJ_DPE_Energie_LogementsSociaux"
-- RPLS: 				"geo_RPLS_2019_id2"
-- couche en sortie: 	"F1_NRJ_DPE_Energie_LogementsSociaux"

-- 3 secs 272 msec.
DROP TABLE IF EXISTS "F1_NRJ_DPE_Energie_LogementsSociaux"."F1_NRJ_DPE_Energie_LogementsSociaux";
CREATE TABLE "F1_NRJ_DPE_Energie_LogementsSociaux"."F1_NRJ_DPE_Energie_LogementsSociaux" AS (
	SELECT 	t.id_geom id_geom,
		'2021' lot,
		(
			-- Ça pourrait être bien d'avoir une valeur NR ici aussi
			CASE 
			WHEN a.construct<1949 THEN 'avant 1949'
			WHEN a.construct>=1949 AND a.construct<=1974 THEN '1949-1974'
			WHEN a.construct>=1975 AND a.construct<=1981 THEN '1975-1981'
			WHEN a.construct>=1982 AND a.construct<=1989 THEN '1982-1989'
			WHEN a.construct>=1990 AND a.construct<=2000 THEN '1990-2000'
			WHEN a.construct>=2001 AND a.construct<=2012 THEN '2001-2012' 
			ELSE '2013 à aujourd hui'
			END
		) period,
		(
			CASE
			-- Rajout de la condition NOT IN () pour gérer les valeurs à 'nan' et éventuels décalages de colonne
			WHEN a.dpeenergie is NULL OR a.dpeenergie NOT IN ('A','B','C','D','E','F','G') THEN 'Non Renseigné' 
			ELSE a.dpeenergie
			END
		) dpe,
		Count(a.geom) "Count_ENTITES",
		(
			CASE 
			WHEN a.construct<1949 THEN '1'
			WHEN a.construct>=1949 AND a.construct<=1974 THEN '2'
			WHEN a.construct>=1975 AND a.construct<=1981 THEN '3'
			WHEN a.construct>=1982 AND a.construct<=1989 THEN '4'
			WHEN a.construct>=1990 AND a.construct<=2000 THEN '5'
			WHEN a.construct>=2001 AND a.construct<=2012 THEN '6' 
			ELSE '7'
			END
		) period_code,
		(
			CASE 
			--WHEN a.dpeenergie is NULL THEN 'Non Renseigné' --Alors ça c'est rigolo parce qu'en fait ça fait planter la dataviz (la heatMap). C'était bien dans le code de base mais je sais pas, comme j'ai ré-écrit la requête pour qu'elle soit plus simple, peut-être que ça marchait pas avant. En tout cas les logements sans dpeenergie doivent avoir un dpe_code à '8' et pas 'Non Renseigné'.
			WHEN a.dpeenergie='A' THEN '1'
			WHEN a.dpeenergie='B' THEN '2'
			WHEN a.dpeenergie='C' THEN '3'
			WHEN a.dpeenergie='D' THEN '4'
			WHEN a.dpeenergie='E' THEN '5'
			WHEN a.dpeenergie='F' THEN '6'
			WHEN a.dpeenergie='G' THEN '7' 
			ELSE '8'
			END
		) dpe_code,
		'Energie' type_dpe
	FROM "F1_NRJ_DPE_Energie_LogementsSociaux"."F3_MIX_LogementsSociaux_points_2021" a, public."TerritoryTable_PF_2019" t
	WHERE ST_Intersects(a.geom,t.geom)
	GROUP BY id_geom, lot, period, dpe, period_code, dpe_code, type_dpe
);

SELECT sum("Count_ENTITES") FROM "F1_NRJ_DPE_Energie_LogementsSociaux"."F1_NRJ_DPE_Energie_LogementsSociaux"
WHERE id_geom ='248' --AND dpe  = 'C'

SELECT * FROM "F1_NRJ_DPE_Energie_LogementsSociaux"."F1_NRJ_DPE_Energie_LogementsSociaux"

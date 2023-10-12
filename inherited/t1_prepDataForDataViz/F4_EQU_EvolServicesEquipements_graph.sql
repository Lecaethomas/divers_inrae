-- F4_EQU_EvolServicesEquipements_Centralite_carto

-- Attention, ça ne marche que si on a déjà effectué les traitements de l'indicateur version carto, on ne fait que remettre en forme la donnée pour la dataviz dc.js ici.

-- Pour la version graphique

--//--//--//--//--//--//--//--//
--//2021
--//--//--//--//--//--//--//--//

DROP TABLE IF EXISTS "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_graph_2021;
CREATE TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_graph_2021 AS (
	WITH NbTe AS (
		SELECT t.label commune, chiffres_cles.id_geom insee, '2021'::integer "year", SUM("Count_ENTITIES") "NbTe"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles.id_geom
		GROUP BY commune, insee
	),
	NbIn AS (
		SELECT t.label commune, chiffres_cles.id_geom insee, SUM("Count_ENTITIES") "NbIn"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles.id_geom
		WHERE chiffres_cles."Location" LIKE 'IN'
		GROUP BY commune, insee
	),
	NbOut AS (
		SELECT t.label commune, chiffres_cles.id_geom insee, SUM("Count_ENTITIES") "NbOut"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles.id_geom
		WHERE chiffres_cles."Location" LIKE 'OUT'
		GROUP BY commune, insee
	),
	CoIn AS (
		SELECT t.label commune, chiffres_cles.id_geom insee, SUM("Count_ENTITIES") "CoIn"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles.id_geom
		WHERE chiffres_cles."Categorie" = 1 AND chiffres_cles."Location" LIKE 'IN'
		GROUP BY commune, insee
	),
	CoOut AS (
		SELECT t.label commune, chiffres_cles.id_geom insee, SUM("Count_ENTITIES") "CoOut"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles.id_geom
		WHERE chiffres_cles."Categorie" = 1 AND chiffres_cles."Location" LIKE 'OUT'
		GROUP BY commune, insee
	),
	InIn AS (
		SELECT t.label commune, chiffres_cles.id_geom insee, SUM("Count_ENTITIES") "InIn"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles.id_geom
		WHERE chiffres_cles."Categorie" = 3 AND chiffres_cles."Location" LIKE 'IN'
		GROUP BY commune, insee
	),
	InOut AS (
		SELECT t.label commune, chiffres_cles.id_geom insee, SUM("Count_ENTITIES") "InOut"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles.id_geom
		WHERE chiffres_cles."Categorie" = 3 AND chiffres_cles."Location" LIKE 'OUT'
		GROUP BY commune, insee
	),
	EsIn AS (
		SELECT t.label commune, chiffres_cles.id_geom insee, SUM("Count_ENTITIES") "EsIn"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles.id_geom
		WHERE chiffres_cles."Categorie" = 2 AND chiffres_cles."Location" LIKE 'IN'
		GROUP BY commune, insee
	),
	EsOut AS (
		SELECT t.label commune, chiffres_cles.id_geom insee, SUM("Count_ENTITIES") "EsOut"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles.id_geom
		WHERE chiffres_cles."Categorie" = 2 AND chiffres_cles."Location" LIKE 'OUT'
		GROUP BY commune, insee
	)
	SELECT  NbTe.*, NbIn."NbIn", NbOut."NbOut", CoIn."CoIn", CoOut."CoOut", InIn."InIn", InOut."InOut", EsIn."EsIn", EsOut."EsOut"
	FROM NbTe
	LEFT JOIN NbIn
	ON NbTe.insee = NbIn.insee
	LEFT JOIN NbOut
	ON NbTe.insee = NbOut.insee
	LEFT JOIN CoIn
	ON NbTe.insee = CoIn.insee
	LEFT JOIN CoOut
	ON NbTe.insee = CoOut.insee
	LEFT JOIN InIn
	ON NbTe.insee = InIn.insee
	LEFT JOIN InOut
	ON NbTe.insee = InOut.insee
	LEFT JOIN EsIn
	ON NbTe.insee = EsIn.insee
	LEFT JOIN EsOut
	ON NbTe.insee = EsOut.insee
);
SELECT * FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_graph_2021;

-- On rajoute la colonne EPCI avec la table de correspondance
-- THL 2022 : j'ai pas cette table, je vais faire autrement (voir requete suivante)
DROP TABLE IF EXISTS "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_graph_2021_epci;
CREATE TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_graph_2021_epci AS (
	SELECT a.*, b."TYPE_EPCI" epci
	FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_graph_2021 a
	LEFT JOIN ( -- SQ parce qu'il y a des "doublons" dans la table
		SELECT "INSEE_COM2", "TYPE_EPCI"
		FROM public."FOUGERES_Communes_EPCI_ante2019"
		GROUP BY "INSEE_COM2", "TYPE_EPCI"
	) b
	ON a.insee = b."INSEE_COM2"::text
	ORDER BY year
);
SELECT * FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_graph_epci;

DROP TABLE IF EXISTS "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_graph_2021_epci;

CREATE TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_graph_2021_epci AS (
WITH t1 AS (
SELECT
	tt.geom,
	cc.*
FROM
	public."TerritoryTable_PF_2019" tt
LEFT JOIN
"F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_graph_2021 cc
ON
	tt.id_geom = cc.insee
WHERE
	tt.RANK = '1'),
rank2 AS (
SELECT
	geom,
	"label"
FROM
	public."TerritoryTable_PF_2019" tt
WHERE
	tt.RANK = '2'
)
SELECT
	commune,
	insee,
	"year",
	"NbTe",
	"NbIn",
	"NbOut",
	"CoIn",
	"CoOut",
	"InIn",
	"InOut",
	"EsIn",
	"EsOut" ,
	r2."label" epci
FROM
	t1
LEFT JOIN rank2 r2
ON
	st_intersects(st_pointonsurface(t1.geom),
	r2.geom)
);
--//--//--//--//--//--//--//--//
--//2020
--//--//--//--//--//--//--//--//
DROP TABLE IF EXISTS "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_graph;
CREATE TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_graph AS (
	WITH NbTe AS (
		SELECT t.label commune, chiffres_cles.id_geom insee, '2020'::integer "year", SUM("Count_ENTITIES") "NbTe"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles.id_geom
		GROUP BY commune, insee
	),
	NbIn AS (
		SELECT t.label commune, chiffres_cles.id_geom insee, SUM("Count_ENTITIES") "NbIn"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles.id_geom
		WHERE chiffres_cles."Location" LIKE 'IN'
		GROUP BY commune, insee
	),
	NbOut AS (
		SELECT t.label commune, chiffres_cles.id_geom insee, SUM("Count_ENTITIES") "NbOut"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles.id_geom
		WHERE chiffres_cles."Location" LIKE 'OUT'
		GROUP BY commune, insee
	),
	CoIn AS (
		SELECT t.label commune, chiffres_cles.id_geom insee, SUM("Count_ENTITIES") "CoIn"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles.id_geom
		WHERE chiffres_cles."Categorie" = 1 AND chiffres_cles."Location" LIKE 'IN'
		GROUP BY commune, insee
	),
	CoOut AS (
		SELECT t.label commune, chiffres_cles.id_geom insee, SUM("Count_ENTITIES") "CoOut"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles.id_geom
		WHERE chiffres_cles."Categorie" = 1 AND chiffres_cles."Location" LIKE 'OUT'
		GROUP BY commune, insee
	),
	InIn AS (
		SELECT t.label commune, chiffres_cles.id_geom insee, SUM("Count_ENTITIES") "InIn"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles.id_geom
		WHERE chiffres_cles."Categorie" = 3 AND chiffres_cles."Location" LIKE 'IN'
		GROUP BY commune, insee
	),
	InOut AS (
		SELECT t.label commune, chiffres_cles.id_geom insee, SUM("Count_ENTITIES") "InOut"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles.id_geom
		WHERE chiffres_cles."Categorie" = 3 AND chiffres_cles."Location" LIKE 'OUT'
		GROUP BY commune, insee
	),
	EsIn AS (
		SELECT t.label commune, chiffres_cles.id_geom insee, SUM("Count_ENTITIES") "EsIn"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles.id_geom
		WHERE chiffres_cles."Categorie" = 2 AND chiffres_cles."Location" LIKE 'IN'
		GROUP BY commune, insee
	),
	EsOut AS (
		SELECT t.label commune, chiffres_cles.id_geom insee, SUM("Count_ENTITIES") "EsOut"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles.id_geom
		WHERE chiffres_cles."Categorie" = 2 AND chiffres_cles."Location" LIKE 'OUT'
		GROUP BY commune, insee
	)
	SELECT  NbTe.*, NbIn."NbIn", NbOut."NbOut", CoIn."CoIn", CoOut."CoOut", InIn."InIn", InOut."InOut", EsIn."EsIn", EsOut."EsOut"
	FROM NbTe
	LEFT JOIN NbIn
	ON NbTe.insee = NbIn.insee
	LEFT JOIN NbOut
	ON NbTe.insee = NbOut.insee
	LEFT JOIN CoIn
	ON NbTe.insee = CoIn.insee
	LEFT JOIN CoOut
	ON NbTe.insee = CoOut.insee
	LEFT JOIN InIn
	ON NbTe.insee = InIn.insee
	LEFT JOIN InOut
	ON NbTe.insee = InOut.insee
	LEFT JOIN EsIn
	ON NbTe.insee = EsIn.insee
	LEFT JOIN EsOut
	ON NbTe.insee = EsOut.insee
);
SELECT * FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_graph;

-- On rajoute la colonne EPCI avec la table de correspondance
DROP TABLE IF EXISTS "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_graph_epci;
CREATE TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_graph_epci AS (
	SELECT a.*, b."TYPE_EPCI" epci
	FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_graph a
	LEFT JOIN ( -- SQ parce qu'il y a des "doublons" dans la table
		SELECT "INSEE_COM2", "TYPE_EPCI"
		FROM public."FOUGERES_Communes_EPCI_ante2019"
		GROUP BY "INSEE_COM2", "TYPE_EPCI"
	) b
	ON a.insee = b."INSEE_COM2"::text
	ORDER BY year
);
SELECT * FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_graph_epci;


--/--/--/--/--/--/--/--/--/--/--/--/
-- Pour la vieille donnée de 2017 --
--/--/--/--/--/--/--/--/--/--/--/--/

-- F4_EQU_EvolServicesEquipements_Centralite_carto

-- Attention, ça ne marche que si on a déjà effectué les traitements de l'indicateur version carto, on ne fait que remettre en forme la donnée pour la dataviz dc.js ici.

-- Pour la version graphique
DROP TABLE IF EXISTS "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_2017_graph;
CREATE TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_2017_graph AS (
	WITH NbTe AS (
		SELECT t.label commune, chiffres_cles_2017.id_geom insee, '2017'::integer "year", SUM("Count_ENTITIES") "NbTe"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_2017
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles_2017.id_geom
		GROUP BY commune, insee
	),
	NbIn AS (
		SELECT t.label commune, chiffres_cles_2017.id_geom insee, SUM("Count_ENTITIES") "NbIn"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_2017
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles_2017.id_geom
		WHERE chiffres_cles_2017."Location" LIKE 'IN'
		GROUP BY commune, insee
	),
	NbOut AS (
		SELECT t.label commune, chiffres_cles_2017.id_geom insee, SUM("Count_ENTITIES") "NbOut"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_2017
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles_2017.id_geom
		WHERE chiffres_cles_2017."Location" LIKE 'OUT'
		GROUP BY commune, insee
	),
	CoIn AS (
		SELECT t.label commune, chiffres_cles_2017.id_geom insee, SUM("Count_ENTITIES") "CoIn"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_2017
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles_2017.id_geom
		WHERE chiffres_cles_2017."Categorie" = 1 AND chiffres_cles_2017."Location" LIKE 'IN'
		GROUP BY commune, insee
	),
	CoOut AS (
		SELECT t.label commune, chiffres_cles_2017.id_geom insee, SUM("Count_ENTITIES") "CoOut"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_2017
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles_2017.id_geom
		WHERE chiffres_cles_2017."Categorie" = 1 AND chiffres_cles_2017."Location" LIKE 'OUT'
		GROUP BY commune, insee
	),
	InIn AS (
		SELECT t.label commune, chiffres_cles_2017.id_geom insee, SUM("Count_ENTITIES") "InIn"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_2017
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles_2017.id_geom
		WHERE chiffres_cles_2017."Categorie" = 3 AND chiffres_cles_2017."Location" LIKE 'IN'
		GROUP BY commune, insee
	),
	InOut AS (
		SELECT t.label commune, chiffres_cles_2017.id_geom insee, SUM("Count_ENTITIES") "InOut"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_2017
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles_2017.id_geom
		WHERE chiffres_cles_2017."Categorie" = 3 AND chiffres_cles_2017."Location" LIKE 'OUT'
		GROUP BY commune, insee
	),
	EsIn AS (
		SELECT t.label commune, chiffres_cles_2017.id_geom insee, SUM("Count_ENTITIES") "EsIn"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_2017
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles_2017.id_geom
		WHERE chiffres_cles_2017."Categorie" = 2 AND chiffres_cles_2017."Location" LIKE 'IN'
		GROUP BY commune, insee
	),
	EsOut AS (
		SELECT t.label commune, chiffres_cles_2017.id_geom insee, SUM("Count_ENTITIES") "EsOut"
		FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_2017
		LEFT JOIN public."TerritoryTable_PF_2019" t
		ON t.id_geom = chiffres_cles_2017.id_geom
		WHERE chiffres_cles_2017."Categorie" = 2 AND chiffres_cles_2017."Location" LIKE 'OUT'
		GROUP BY commune, insee
	)
	SELECT  NbTe.*, NbIn."NbIn", NbOut."NbOut", CoIn."CoIn", CoOut."CoOut", InIn."InIn", InOut."InOut", EsIn."EsIn", EsOut."EsOut"
	FROM NbTe
	LEFT JOIN NbIn
	ON NbTe.insee = NbIn.insee
	LEFT JOIN NbOut
	ON NbTe.insee = NbOut.insee
	LEFT JOIN CoIn
	ON NbTe.insee = CoIn.insee
	LEFT JOIN CoOut
	ON NbTe.insee = CoOut.insee
	LEFT JOIN InIn
	ON NbTe.insee = InIn.insee
	LEFT JOIN InOut
	ON NbTe.insee = InOut.insee
	LEFT JOIN EsIn
	ON NbTe.insee = EsIn.insee
	LEFT JOIN EsOut
	ON NbTe.insee = EsOut.insee
);
SELECT * FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_2017_graph;

-- On rajoute la colonne EPCI avec la table de correspondance
DROP TABLE IF EXISTS "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_2017_graph_epci;
CREATE TABLE "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_2017_graph_epci AS (
	SELECT a.*, b."TYPE_EPCI" epci
	FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_2017_graph a
	LEFT JOIN ( -- SQ parce qu'il y a des "doublons" dans la table
		SELECT "INSEE_COM2", "TYPE_EPCI"
		FROM public."FOUGERES_Communes_EPCI_ante2019"
		GROUP BY "INSEE_COM2", "TYPE_EPCI"
	) b
	ON a.insee = b."INSEE_COM2"::text
	ORDER BY year
);
SELECT * FROM "F4_EQU_EvolServicesEquipements_Centralites_carto".chiffres_cles_2017_graph_epci;













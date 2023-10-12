--La BPE utilise une nomenclature permettant la distinction de ~120 services et équipements;
--nous devons donc la simplifier afin d'en rendre possible l'examen aux différentes échelles territoriales et temporelles.


---------------------------------------------------------------------------------------------------------------

--on extrait les deux premiers caractères définissant la classe dans une colone DOMAINE


alter table "F1_EQU_Evol_Equip"."F4_EQU_EvolServicesEquipements_geo" drop column if exists domaine;

alter table "F1_EQU_Evol_Equip"."F4_EQU_EvolServicesEquipements_geo" add column domaine varchar;
update  "F1_EQU_Evol_Equip"."F4_EQU_EvolServicesEquipements_geo"  set domaine= substring(typequ,1,2);

--on crée une colone avec des libellés pour les domaines

alter table "F1_EQU_Evol_Equip"."F4_EQU_EvolServicesEquipements_geo" drop column if exists domaine_lib;

alter table "F1_EQU_Evol_Equip"."F4_EQU_EvolServicesEquipements_geo" add column domaine_lib varchar;
update  "F1_EQU_Evol_Equip"."F4_EQU_EvolServicesEquipements_geo"  set domaine_lib=
	CASE 
	WHEN domaine like 'C%' THEN 'Enseignement - Formation'
	WHEN domaine like  'D%' THEN 'Equipement de sante' 
	WHEN domaine = 'F1' THEN 'Equipement sportif'
	WHEN domaine = 'F3' THEN 'Equipement culturel'
end; 
select * from "F1_EQU_Evol_Equip"."F4_EQU_EvolServicesEquipements_geo";


alter table "F1_EQU_Evol_Equip"."F4_EQU_EvolServicesEquipements_geo" drop column if exists subdomaine_lib;

alter table "F1_EQU_Evol_Equip"."F4_EQU_EvolServicesEquipements_geo" add column subdomaine_lib varchar;
update  "F1_EQU_Evol_Equip"."F4_EQU_EvolServicesEquipements_geo"  set subdomaine_lib=
	case "F1_EQU_Evol_Equip"."F4_EQU_EvolServicesEquipements_geo".subdomaine 
	WHEN 'A1' THEN 'Services publics'
	WHEN 'A2' THEN 'Services generaux'
	WHEN 'A3' THEN 'Services automobiles'
	WHEN 'A4' THEN 'Artisanat du batiment'
	WHEN 'A5' THEN 'Autres services a la population'
	WHEN 'B1' THEN 'Grandes surfaces'
	WHEN 'B2' THEN 'Commerces alimentaires'
	WHEN 'B3' THEN 'Commerces specialises non alimentaires'
	WHEN 'C1' THEN 'Enseignement du premier degre'
	WHEN 'C2' THEN 'Enseignement du second degre premier cycle'
	WHEN 'C3' THEN 'Enseignement du second degre second cycle'
	WHEN 'C4' THEN 'Enseignement superieur non universitaire'
	WHEN 'C5' THEN 'Enseignement superieur universitaire'
	WHEN 'C6' THEN 'Formation continue'
	WHEN 'C7' THEN 'Autres services de l education'
	WHEN 'D1' THEN 'Etablissments et services de sante'
	WHEN 'D2' THEN 'Fonctions medicales et para medicales'
	WHEN 'D3' THEN 'Autres etablissement et services a caractere sanitaire'
	WHEN 'D4' THEN 'Action sociale pour personnes agees'
	WHEN 'D5' THEN 'Action sociale pour enfants en bas age'
	WHEN 'D6' THEN 'Action sociale pour handicapes'
	WHEN 'D7' THEN 'Autres services d action sociale'
	WHEN 'E1' THEN 'Infrastructures de transports'
	WHEN 'F1' THEN 'Equipement sportifs'
	WHEN 'F2' THEN 'Equipements de loisirs'
	WHEN 'F3' THEN 'Equipements culturels et socioculturels'
	WHEN 'G1' THEN 'Tourisme'
	end;
select * from "F1_EQU_Evol_Equip"."F4_EQU_EvolServicesEquipements_geo"

where subdomaine like 'F3%'

order by subdomaine asc;

DROP TABLE IF EXISTS "F1_EQU_Evol_Equip"."equipements_ccles";
CREATE TABLE "F1_EQU_Evol_Equip"."equipements_ccles" AS (
		SELECT b.id_geom, Count(a.geom) as "count_entities",a.domaine_lib
		FROM public."TerritoryTable_PV_BDTopo_2020.08_full_2154" AS b
		LEFT JOIN "F1_EQU_Evol_Equip"."F4_EQU_EvolServicesEquipements_geo"  AS a
		ON ST_Intersects(a.geom, b.geom) and domaine_lib is not null
		GROUP BY b.id_geom,  a.domaine_lib)
		;
SELECT * FROM "F1_EQU_Evol_Equip"."equipements_ccles";



create table scot_metadata_datecleaned as (
select id,content_name,identifier,doc_name,geo_project_id,rapport,producer,project_name,"version",to_char(to_date(substring(publish_date,0,11),'dd/mm/yyyy'), 'YYYYMMDD') publish_date,status
from "TA_Territoires".scot_metadata t1
);


select "coordonneesXY",regexp_matches("coordonneesXY", '([A-Za-z0-9],) +', 'g') :: text"X"
from "TA_CARTO_SOCLE".irve_consolidation_v2_20210818 icv 

select id,nom_amenageur,siren_amenageur,contact_amenageur,nom_operateur,contact_operateur,telephone_operateur,nom_enseigne,id_station_itinerance,id_station_local,nom_station,implantation_station,adresse_station,code_insee_commune,"coordonneesXY",regexp_matches("coordonneesXY", '([A-Za-z0-9_],)', 'g')"X",
nbre_pdc,id_pdc_itinerance,id_pdc_local,puissance_nominale,prise_type_ef,prise_type_2,prise_type_combo_ccs,prise_type_chademo,prise_type_autre,gratuit,paiement_acte,paiement_cb,paiement_autre,tarification,condition_acces,reservation,horaires,accessibilite_pmr,restriction_gabarit,station_deux_roues,raccordement,num_pdl,date_mise_en_service,observations,date_maj,last_modified,resource_id 
from "TA_CARTO_SOCLE".irve_consolidation_v2_20210818 icv 
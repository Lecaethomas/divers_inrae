--L'actualisation de l'indicateur repose sur 


--\\\\\\\\--\\\\\\\\--\\\\\\\\--\\\\\\\\--\\\\\\\\
--\\\\\\\\--\\\\\\\\ 2019 --\\\\\\\\--\\\\\\\\
--\\\\\\\\--\\\\\\\\--\\\\\\\\--\\\\\\\\--\\\\\\\\

WITH logmnt AS (
SELECT logm.* FROM "F4_RIS_ExpositionZI_BatisHabitants"."CAP_ZI_LOGEMENTS_V4_2019" logm, public."territory_table_CAP20" tt
WHERE tt.RANK = '3' and st_intersects(tt.geom, logm.geom)
)
SELECT 'freq'::varchar "Location",count(*) "Count_bati", sum(nb_hab) "Cout_pop" FROM logmnt 
WHERE exposition = 'Submersion fréquente'
UNION 
SELECT 'moy'::varchar "Location" ,  count(*) "Count_bati", sum(nb_hab) "Cout_pop" FROM logmnt
WHERE exposition IN ( 'Submersion fréquente','Submersion moyenne (Xynthia + 20cm)')
UNION 
SELECT 'moy_cc'::varchar "Location" ,  count(*) "Count_bati", sum(nb_hab) "Cout_pop" FROM logmnt 
WHERE exposition IN ( 'Submersion fréquente','Submersion moyenne (Xynthia + 20cm)',  'Submersion moyenne avec changement climatique (Xynthia + 60cm)')
UNION 
SELECT 'excep'::varchar "Location" ,  count(*) "Count_bati", sum(nb_hab) "Cout_pop" FROM logmnt 
WHERE exposition IN ( 'Submersion fréquente','Submersion moyenne (Xynthia + 20cm)',  'Submersion moyenne avec changement climatique (Xynthia + 60cm)','Submersion exceptionnelle');

--\\\\\\\\--\\\\\\\\--\\\\\\\\--\\\\\\\\--\\\\\\\\
--\\\\\\\\--\\\\\\\\ 2020 --\\\\\\\\--\\\\\\\\
--\\\\\\\\--\\\\\\\\--\\\\\\\\--\\\\\\\\--\\\\\\\\
WITH logmnt AS (
SELECT logm.* FROM "F4_RIS_ExpositionZI_BatisHabitants"."CAP_ZI_LOGEMENTS_V4_20220307" logm, public."territory_table_CAP20" tt
WHERE tt.RANK = '3' and st_intersects(tt.geom, logm.geom)
)
SELECT 'freq'::varchar "Location",count(*) "Count_bati", sum(nb_hab) "Cout_pop" FROM logmnt 
WHERE exposition = 'Submersion fréquente'
UNION 
SELECT 'moy'::varchar "Location" ,  count(*) "Count_bati", sum(nb_hab) "Cout_pop" FROM logmnt
WHERE exposition IN ( 'Submersion fréquente','Submersion moyenne (Xynthia + 20cm)')
UNION 
SELECT 'moy_cc'::varchar "Location" ,  count(*) "Count_bati", sum(nb_hab) "Cout_pop" FROM logmnt 
WHERE exposition IN ( 'Submersion fréquente','Submersion moyenne (Xynthia + 20cm)',  'Submersion moyenne avec changement climatique (Xynthia + 60cm)')
UNION 
SELECT 'excep'::varchar "Location" ,  count(*) "Count_bati", sum(nb_hab) "Cout_pop" FROM logmnt 
WHERE exposition IN ( 'Submersion fréquente','Submersion moyenne (Xynthia + 20cm)',  'Submersion moyenne avec changement climatique (Xynthia + 60cm)','Submersion exceptionnelle')





SELECT distinct(exposition) 
FROM "F4_RIS_ExpositionZI_BatisHabitants"."CAP_ZI_LOGEMENTS_V4_2019" 
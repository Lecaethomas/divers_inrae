Case 
when  "eco_2009Etat écologique des masses d'eau - cours d'eau en 2009" =  "eco_2015Etat écologique des masses d'eau - cours d'eau en 2015" and "eco_2009Etat écologique des masses d'eau - cours d'eau en 2009" <> 'Inconnu' and  "eco_2015Etat écologique des masses d'eau - cours d'eau en 2015" <> 'Inconnu' then 'Stabilité'
when  "eco_2009Etat écologique des masses d'eau - cours d'eau en 2009" = 'Médiocre' or  "eco_2009Etat écologique des masses d'eau - cours d'eau en 2009" = 'Moyen' and  "eco_2015Etat écologique des masses d'eau - cours d'eau en 2015" = 'Mauvais' then 'Dégradation'
when "eco_2009Etat écologique des masses d'eau - cours d'eau en 2009" = 'Moyen'  and "eco_2015Etat écologique des masses d'eau - cours d'eau en 2015" = 'Médiocre' then 'Dégradation'
when "eco_2009Etat écologique des masses d'eau - cours d'eau en 2009" = 'Mauvais' and "eco_2015Etat écologique des masses d'eau - cours d'eau en 2015" = 'Médiocre' or "eco_2015Etat écologique des masses d'eau - cours d'eau en 2015" = 'Moyen' then 'Amélioration'
when "eco_2009Etat écologique des masses d'eau - cours d'eau en 2009" = 'Médiocre' and "eco_2015Etat écologique des masses d'eau - cours d'eau en 2015" = 'Moyen' then 'Amélioration'
when  "eco_2009Etat écologique des masses d'eau - cours d'eau en 2009" = 'Inconnu' then 'Inconnu en 2009'
end


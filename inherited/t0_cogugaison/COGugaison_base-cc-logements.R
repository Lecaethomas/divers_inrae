library(stringi)
library(COGugaison)
library(readxl)
library(jsonlite)

#MyData <- read.csv(file= paste(path_to_data, files, sep = '/'), header=TRUE, sep=",")
#MyData[] <- lapply(MyData, gsub, pattern='-', replacement=0)


year_geom_desired = 2019

path_to_data = 'D:/_Default_Run_Environment_Test/3_Results_Step_n1_DATA_valide/base-cc-logements'
path_to_save = paste('D:/_Default_Run_Environment_Test/4_Results_Step_n2_DATA_COGugaison_2019/base-cc-logements',
                     sep='')

lst_files = list.files(path = path_to_data)

for (files in lst_files){
  
  year_geom = as.numeric(substr(files, nchar(files)-7, nchar(files)-4))
  
  MyData <- read.csv(file= paste(path_to_data, files, sep = '/'), header=TRUE, sep=";")
  
  # Supression des arrondissements, conserver doublon pour ne pas sommer les colonnes
  Table_sans_arron <- enlever_PLM(table_entree=MyData,libgeo='données',agregation = F,vecteur_entree=F)
  
  # Application de la cogugaison
  Table <- changement_COG_varNum(table_entree=Table_sans_arron, annees=c(year_geom:year_geom_desired), agregation=T,libgeo=F,donnees_insee=T)
  
  # Save to csv
  new_csv_name = paste(substr(files, 0, nchar(files)-8),'geom',year_geom_desired,'.csv',sep="")
  print(new_csv_name)
  
  write.csv(Table, file = paste(path_to_save, new_csv_name, sep = '/'), row.names=FALSE)
  
  print(paste0('Le fichier : ', new_csv_name, ', a bien été enregistré'))
}
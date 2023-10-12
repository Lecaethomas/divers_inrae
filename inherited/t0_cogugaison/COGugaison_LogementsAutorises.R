library(stringi)
library(COGugaison)
library(readxl)
library(jsonlite)

#MyData <- read.csv(file= paste(path_to_data, files, sep = '/'), header=TRUE, sep=",")
#MyData[] <- lapply(MyData, gsub, pattern='-', replacement=0)


year_geom_desired = 2019

path_to_data = 'D:/_Default_Run_Environment_Test/3_Results_Step_n1_DATA_valide/SitadelAutorises'
path_to_save = paste('D:/_Default_Run_Environment_Test/4_Results_Step_n2_DATA_COGugaison_2019/SitadelAutorises',
                     sep='')

lst_files = list.files(path = path_to_data)

for (files in lst_files){
  
  year_geom = as.numeric(substr(files, nchar(files)-7, nchar(files)-4))
  
  MyData <- read.csv(file= paste(path_to_data, files, sep = '/'), header=TRUE, sep=",")
  
  #Replace values
  MyData[MyData == "-"] <- 0

  #Convert as numeric
  MyData[,2] <- as.numeric(as.character(MyData[,2]))
  MyData[,3] <- as.numeric(as.character(MyData[,3]))
  MyData[,4] <- as.numeric(as.character(MyData[,4]))
  MyData[,5] <- as.numeric(as.character(MyData[,5]))
  MyData[,6] <- as.numeric(as.character(MyData[,6]))
  
  # Supression des arrondissements, conserver doublon pour ne pas sommer les colonnes
  #Table_sans_arron <- enlever_PLM(table_entree=MyData,libgeo='données',agregation = F,vecteur_entree=F)
  
  # Application de la cogugaison
  Table <- changement_COG_varNum(table_entree=MyData, annees=c(year_geom:year_geom_desired), agregation=T,libgeo=T,donnees_insee=F)
  
  # Save to csv
  write.csv(Table, file = paste(path_to_save, files, sep = '/'), row.names=FALSE)
  
  print(paste0('Le fichier : ', files, ', a bien été enregistré'))
}
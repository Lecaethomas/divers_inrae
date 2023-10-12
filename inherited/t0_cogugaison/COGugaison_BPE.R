library(stringi)
library(COGugaison)
library(readxl)
library(jsonlite)

#MyData <- read.csv(file= paste(path_to_data, files, sep = '/'), header=TRUE, sep=",")
#MyData[] <- lapply(MyData, gsub, pattern='-', replacement=0)


year_geom_desired = 2019

path_to_data = 'D:/_Default_Run_Environment_Test/1_DATA_brute/BPE'
path_to_save = paste('D:/_Default_Run_Environment_Test/4_Results_Step_n2_DATA_COGugaison_2019/BPE',
                     sep='')

lst_files = list.files(path = path_to_data)

for (files in lst_files){
  
  year_geom = as.numeric(substr(files, nchar(files)-7, nchar(files)-4))
  
  MyData <- read.csv(file= paste(path_to_data, files, sep = '/'), header=TRUE, sep=";")
  
  #Delete useless columns
  MyData2 <- subset(MyData, select=-c(DCIRIS,REG,DEP,AN))
  
  # Supression des arrondissements, conserver doublon pour ne pas sommer les colonnes
  #Table_sans_arron <- enlever_PLM(table_entree=MyData,libgeo='données',agregation = F,vecteur_entree=F)
  
  # Application de la cogugaison
  Table <- changement_COG_varNum(table_entree=MyData2, annees=c(year_geom:year_geom_desired), agregation=F,libgeo=F,donnees_insee=T)
  
  # Save to csv
  write.csv(Table, file = paste(path_to_save, files, sep = '/'), row.names=FALSE)
  
  print(paste0('Le fichier : ', files, ', a bien été enregistré'))
}
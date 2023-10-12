library(stringi)
library(COGugaison)
library(readxl)
library(jsonlite)
library(stringr) 


path_to_data = 'D:/_Default_Run_Environment_Test/3_Results_Step_n1_DATA_valide/Sitadel'

lst_files = list.files(path = path_to_data)

for (files in lst_files){
  
  MyData <- read.csv(file= paste(path_to_data, files, sep = '/'), header=TRUE, sep=",")
  
  
  #code_insee_clean <- stringr::str_replace(MyData$données, '\\0', '')
  #code_insee_clean <- gsub( '"', "", paste(MyData$données))
  
  code_insee_vector <- as.vector(MyData$données)
  #print(code_insee_vector)
  
  print(files)
  print(COG_akinator(vecteur_codgeo=code_insee_vector, donnees_insee = FALSE))
  
}
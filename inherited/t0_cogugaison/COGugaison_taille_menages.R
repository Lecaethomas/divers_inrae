library(stringi)
library(COGugaison)
library(readxl)
library(jsonlite)
library(magrittr) # needs to be run every time you start R and want to use %>%
library(dplyr)    # alternatively, this also loads %>%
library(readr)

year_geom_desired = 2020

path_to_data = 'C:/_DEV/CODE/DIVERS/r/cogugaison/data'
path_to_save = paste("C:/_DEV/CODE/DIVERS/r/cogugaison/output",sep='')

lst_files = list.files(path = path_to_data)

for (files in lst_files){
  year_geom = as.numeric(substr(files, nchar(files)-7, nchar(files)-4))
  print(year_geom)
  year_data = as.numeric(substr(files, nchar(files)-12, nchar(files)-9))
  print(year_data)
  MyData <- read.csv(file= paste(path_to_data, files, sep = '/'), header=TRUE, sep=",")
  head(MyData,10)
  # Supression des arrondissements, conserver doublons pour ne pas sommer les colonnes
  
  Table_sans_arron <- enlever_PLM(table_entree=MyData,libgeo=NULL,agregation = F,vecteur_entree=F)  
  # Application de la Cogugaison
  Table <- changement_COG_varNum(table_entree=Table_sans_arron, annees=c(year_geom:year_geom_desired), agregation=T,libgeo=T,donnees_insee=F)
  Table['year_data'] = year_data
  # Save to csv
  write.csv(Table, file = paste(path_to_save, files, sep = '/') ,  row.names = FALSE)
  
  print(paste0('Le fichier : ', files, ', a bien été enregistré'))
}

lst_n_files = list.files(path = path_to_save, full.names = TRUE)
print(lst_n_files)
#import and merge all three CSV files into one data frame
df <- list.files(path=path_to_save, full.names = TRUE) %>% 
  lapply(read_csv) %>% 
  bind_rows  
print(head(df,10)) 
write.csv(df, file = paste(path_to_save, 'merged.csv', sep = '/'),  row.names = FALSE)

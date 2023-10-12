library(stringi)
library(COGugaison)
library(readxl)
library(jsonlite)

#MyData <- read.csv(file= paste(path_to_data, files, sep = '/'), header=TRUE, sep=",")
#MyData[] <- lapply(MyData, gsub, pattern='-', replacement=0)


year_geom_desired = 2020

path_to_data = 'C:/Users/salah/OneDrive/Bureau/TRAVAIL/GIT/scripts_sgevt/PROD/t0_cogugaison/1_DATA_brute/Emploi/'
path_to_save = paste('C:/Users/salah/OneDrive/Bureau/TRAVAIL/GIT/scripts_sgevt/PROD/t0_cogugaison/4_Results_Step_n2_DATA_COGugaison_2019/Emploi/',sep='')

lst_files = list.files(path = path_to_data)

for (files in lst_files){
  
  year_geom = as.numeric(substr(files, nchar(files)-7, nchar(files)-4))
  print(year_geom)
  # 
  MyData <- read.csv(file= paste(path_to_data, files, sep = '/'),encoding = "UTF-8", header=TRUE, sep=";")
  MyData<-subset(MyData,select=-c(2,3,4,5))
  # #Convert as numeric (only the numeric fields)
  colnames(MyData)[1]<-'INSEE'
  for(i in 2:dim(MyData)[2]){
    MyData[,i] = as.numeric(as.character(MyData[,i]))
  }
  
  #Application of the cogugaison process
  Table <- changement_COG_varNum(table_entree=MyData, annees=c(year_geom:year_geom_desired), agregation=T,libgeo=T,donnees_insee=T)
  
  # Save result to .csv
  write.csv(Table,file=file(paste(path_to_save,files,sep='/'),encoding = 'UTF-8'),row.names = FALSE)
  print(paste0('Le fichier : ', files, ', a bien été enregistré'))

}


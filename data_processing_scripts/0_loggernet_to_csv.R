## Convert raw loggernet file to a CSV and perform a rolling clean on the data that will be kept in the L2 files 
#produce visualization for data before and after cleaning. 

#Load Libraries and necessary functions 
source("functions/read_datalogger_file.R")


#directories
loggernet_dir <- paste0(Sys.getenv("dropbox_filepath") , "Chapada_Stem_Data/0_RawData/current_data/")
loggernet_archive_dir <- paste0(Sys.getenv("dropbox_filepath"),"Chapada_Stem_Data/0_RawData/archive_data/")
csv_dir <- paste0(Sys.getenv("dropbox_filepath") , "Chapada_Stem_Data/1_RawCSVData/")


#list files for conversion 
files <- list.files(loggernet_dir, full.names = T)


#load the files and save as a csv in a for loop 
for (file in files){
  
  #load in the data 
  dt <- read_datalogger_file(file)
  
  #write it out as a csv file
  filename <- substr(basename(file),1,(nchar(basename(file))-4))
  write.csv(dt, paste0(csv_dir, filename, ".csv"))
  
  #move the raw data file into the archive
  file.rename(file, paste0(loggernet_archive_dir, basename(file)))
  
}



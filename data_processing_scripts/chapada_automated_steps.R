## Convert raw loggernet file to a CSV 

## Put the data in long format based on design tables  (normalize)
##perform a rolling clean on the data that will be kept in the L2 files 

#Load Libraries and necessary functions 
source("functions/read_datalogger_file.R")
source("functions/normalize_loggernet_csv_data.R")

#directories
loggernet_dir <- paste0(Sys.getenv("dropbox_filepath") , "Chapada_Stem_Data/0_RawData/current_data/")
loggernet_archive_dir <- paste0(Sys.getenv("dropbox_filepath"),"Chapada_Stem_Data/0_RawData/archive_data/")
csv_dir <- paste0(Sys.getenv("dropbox_filepath") , "Chapada_Stem_Data/1_RawCSVData/")
normal_csv_dir <- paste0(Sys.getenv("dropbox_filepath"), "Chapada_Stem_Data/2_NormalCSVData/")


#### Step 1 ####
#Load the raw loggernet files and save them as CSVs. Then archive the raw loggernet file. 

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


#### Step 2 #### 
#Put the data in long format using the design table (normalize it)
#add a column fro utc time stamps


##Load in the design tables 
plotnames <- read.csv("design_tables/chapada_plotnames.csv")
varnames <- read.csv("design_tables/chapada_design-type.csv")
design <- read.csv("design_tables/chapada_design.csv")

#get the names of the tables from the design document
table_names <- unique(design$Table)

#one table at a time
for (table in table_names){

normal_data <- normalize_loggernet_csv_data(design, plotnames, varnames, table, csv_dir)

write.csv(normal_data, paste0(Sys.getenv("dropbox_filepath"),"Chapada_Stem_Data/2_NormalizedCSVData/", table, ".csv"), row.names = F)
}



  







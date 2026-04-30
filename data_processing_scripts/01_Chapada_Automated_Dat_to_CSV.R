###Step one -- Conversion of .DAT files to .CSV and aggregation into monthly or yearly chunks. 
#This step is meant to be run as an automated pre-processing step before normalization.
#It takes a while to run this on a lot of data because of the aggregation function. 

library(tidyverse)
library(data.table)

#Load functions, directories, and unprocessed file names-------------------------------------------------------------

#Load all functions 
invisible(lapply(list.files(Sys.getenv("github_functions"), pattern = "\\.R$", full.names = TRUE), source))

#relevant directories
rawData_dir <- paste0(Sys.getenv("dropbox_filepath") , "Chapada_Stem_Data/sensor_data/0_RawData/unprocessed_archive_data/")
rawDataArchive_dir <- paste0(Sys.getenv("dropbox_filepath") , "Chapada_Stem_Data/sensor_data/0_RawData/archive_data/") 
rawCSVData_dir <- paste0(Sys.getenv("dropbox_filepath") , "Chapada_Stem_Data/sensor_data/1_RawCSVData/unprocessed/")

#list files in the raw data folder to be converted. 
files <- list.files(rawData_dir, full.names = T)%>%
  str_subset(pattern = 'backup',negate = TRUE)%>% #We are not processing backup tables
  str_subset(pattern = 'FLUX_7810',negate = TRUE)%>% #We are not currently processing licor data
  str_subset(pattern = 'FLUX_COMB',negate = TRUE)%>% #we are not currently processing licor data
  str_subset(pattern = 'NewConstTable',negate = TRUE) # We are not processing the NewConstTable 

#Processing occurs one file at a time
for (file in files){
  
  #Load the .DAT file into R with this special function (from Ben Bond-Lamberty)--------------------------------------------------------------------------- 
  dt <- read_datalogger_file_chapada(file)
  #filter out any weird time stamps that are marked before 2025 (Changes on a project to project basis)
  dt <- dt %>%
    filter(year(TIMESTAMP) > 2024)
  
  #Make sure timestamps are stored properly
  dt$TIMESTAMP <- as.character(format(as.POSIXct(dt$TIMESTAMP, format = "%Y-%m-%d %H:%M:%S"), format = "%Y-%m-%d %H:%M:%S"))
  
  tablename <- substr(basename(file),1,(nchar(basename(file))-19)) 
  
  
  #Aggregate the data into monthly chunks and write them out to the correct place---------------------------------------------------------------------------
  write_monthly_data_chapada(dt, rawCSVData_dir, tablename)
  
  
  #Move the Raw Loggernet data file into the archive----------------------------------------------------------------------------------
  file.rename(file, paste0(rawDataArchive_dir, basename(file)))
  
}



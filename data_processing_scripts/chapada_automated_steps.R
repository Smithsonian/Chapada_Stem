## Convert raw loggernet file to a CSV 
##perform a rolling clean on the data that will be kept in the L2 files 
## Put the data in long format based on design tables  (normalize)

#Load Libraries and necessary functions 
source("functions/read_datalogger_file.R")
source("functions/normalize_loggernet_csv_data.R")
source("functions/load_design_table.R")
source("functions/apply_rolling_clean.R")
source("functions/plot_variable.R")


#directory to the general data folder for the project
data_dir <- paste0(Sys.getenv("dropbox_filepath") , "Chapada_Stem_Data/")


#### Step 1  -- Convert to CSV ####
#Description -- Load the raw Loggernet files and save them as .csv files Then archive the raw Loggernet file. 

#list files in the raw data folder to be converted 
files <- list.files(paste0(data_dir,"0_RawData/current_data/"), full.names = T)


#load the files and save as a csv in a for loop 
for (file in files){
  
  #load in the data 
  dt <- read_datalogger_file(file)
  
  #write it out as a csv file
  filename <- substr(basename(file),1,(nchar(basename(file))-4))
  write.csv(dt, paste0(csv_dir, filename, ".csv"))
  
  #move the raw loggernet data file into the archive
  file.rename(file, paste0(data_dir, "0_RawData/archive_data/", basename(file)))
  
}


#### Step 2 -- Normalization and Automatic Rolling Clean #### 
#Description -- 
#Clean the data in each table based on a rolling mean and a variability constant (defined in the design table)
#Put the data in long format using the design table (normalize it)
#add a column for utc time stamps and ensure correct time stamp formating 

merged_design <- load_design_table()

#get the names of the tables from the design document
table_names <- unique(merged_design$Table)

#one table at a time
for (table in table_names){
  
  #filter the design table to just the specific loggernet table we are working with and get the cr1000_names
  design_table <- filter(merged_design, Table == table)
  headers <- design_table$cr1000_name
  
  #get the CSV file associated with that table and change headers to cr1000 names. 
  csv_data <- read.csv(list.files(paste0(data_dir,"1_RawCSVData/"), pattern = table, full.names = T)) %>%
    select(-X, -Logger, -Table, -Format) #may change when applied to other projects. 
  
  colnames(csv_data) <- headers 
  
  #Clean the variables in this table that have been marked in the design table for automatic cleaning 
  csv_data <- apply_rolling_clean(design_table, csv_data)
  
  
  ##You can use the below lines when setting up the design tables to check if the variability constants you are using are appropriate. 
  # plot <- plot_variable(csv_data, csv_data$vpd)
  # plot


  normal_data <- normalize_loggernet_csv_data(design, plotnames, varnames, table, data_dir)
  
  
  normal_data <- normal_data %>%
    filter(timestamp_local >= as.Date("2025-01-01"))
  

  write.csv(normal_data, paste0(data_dir,"2_NormalizedCSVData/", table, ".csv"), row.names = F)
}



  







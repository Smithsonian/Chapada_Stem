#### Step 2 -- Normalization and Range Clean #### 
#Description -- 
#Put the data in long format using the design table (normalize it)
#Clean the data in each table based on a low and high limit (data range)
#ensure correct time stamp formatting and add a time ladder to the data 
#write the processed file and move the rawCSV file to an archive. 


#### Load Functions, Directories, and Design Tables ####
#Load all functions 
invisible(lapply(list.files("functions/", pattern = "\\.R$", full.names = TRUE), source))

#Required User Input-------------------------------------------------------------------------------------------------
#We only want to do this on monthly files that have ALL of their loggernet data.
#enter in the vector below any months that may not have a complete data set yet in the format yyyy-mm
#reccommend excluding the current month and the previous month 
exclude_months <- c("2025-11", "2025-10")%>%
  paste(collapse = "|")


#Load directories and Design Table ---------------------------------------------------------------------------------

#relevant directories
rawCSVData_dir <- paste0(Sys.getenv("dropbox_filepath") , "Chapada_Stem_Data/1_RawCSVData/unprocessed/")
rawCSVDataArchive_dir <- paste0(Sys.getenv("dropbox_filepath") , "Chapada_Stem_Data/1_RawCSVData/processed/")
L0_NormalizedData_dir <- paste0(Sys.getenv("dropbox_filepath") , "Chapada_Stem_Data/2_L0_NormalizedData/")

#design table 
merged_design <- load_design_table()
#get the names of the tables from the design document
table_names <- unique(merged_design$Table)



#File Selection for Processing ---------------------------------------------------------------------------------------
for (table in table_names){
  
  #filter the design table to just the specific loggernet table we are working with and get the cr1000_names
  design_table <- filter(merged_design, Table == table)
  headers <- design_table$cr1000_name
  #define all the files that are to be processed based on the table name and the excluded months. 
  files <- list.files(rawCSVData_dir, pattern = table, recursive = T, full.names = T)%>%
    str_subset(pattern = exclude_months, negate = TRUE)
  
  for (file in files){ 
    
    #get the CSV file associated with that table and change headers to cr1000 names. 
    csv_data <- read.csv(file) %>%
      select(-Table, -Format)
    colnames(csv_data) <-headers
    
    
    #Data Normalization and Cleaning----------------------------------------------------------------------------------
    
    #Normalize the data. this function spits out warnings and I can't figure out how to fix it. It does not affect the data. I tested every which way. 
    normalized_data <- normalize_loggernet_csv_data_chapada(csv_data, design_table, data_dir)
    #Apply range limitation cleaning for variables that have been marked with a range 
    normalized_data <- apply_range_limitation_chapada(design_table, normalized_data)

    ##You can use the below lines when setting up the design tables to check if the range limitation constants you are using are appropriate. 
    #plot <- plot_variable_chapada(normalized_data,normalized_data$air_temperature)
    #plot
    
    
    #TimeStamp Handling-------------------------------------------------------------------------------------------------------
    
    #Format the time stamps for time stamp handling 
    normalized_data$timestamp_local <- as.POSIXct(normalized_data$timestamp_local, tz = "America/Sao_Paulo")
    
    #get the time resolution of the data from the design table. 
    resolution <- design_table$resolution %>%
      unique()
    
    #compare against a time ladder and see 
    normalized_data <- time_ladder_chapada(normalized_data,resolution, table)
    
    #now I want to put the timestamps back in character format to save in the CSV
    normalized_data$timestamp_local <- format(normalized_data$timestamp_local,"%Y-%m-%d %H:%M:%S")
    
    
    
    #File Writing and Moving-------------------------------------------------------------------------------------------------------
    
    #write the normalized file out int he correct folder. 
    if (!dir.exists(paste0(L0_NormalizedData_dir,table,"/"))){
      dir.create(paste0(L0_NormalizedData_dir,table,"/"), recursive = TRUE)
    }
    filename <- basename(file)
    write.csv(normalized_data, paste0(L0_NormalizedData_dir, table,"/",filename), row.names = F)
    
    
    #put the file that you just processed in the archive so that it does not needlessly get processed again. 
    if (!dir.exists(paste0(rawCSVDataArchive_dir,table,"/"))){
      dir.create(paste0(rawCSVDataArchive_dir,table,"/"), recursive = TRUE)
    }
    file.rename(file, paste0(rawCSVDataArchive_dir, table, "/", basename(file)))
  }
}











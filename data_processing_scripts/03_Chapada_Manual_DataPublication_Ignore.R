### These are just draft components for a script to put this data in oublication format. Please ignore this script for now. 



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


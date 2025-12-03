## function that checks out the start and end dates of the variables in the design table and filter the design table
#to just the current variables for that month. 


filter_to_active_variables_chapada <- function(csv_data, design_table) {
  
  #get the start and end datetimes in the csv data file and put them in timstamp format. 
  file_start_time <- as.POSIXct(min(csv_data$TIMESTAMP, na.rm=T), tz = "America/Sao_Paulo")
  file_end_time <-  as.POSIXct(max(csv_data$TIMESTAMP, na.rm=T), tz = "America/Sao_Paulo")
  
  #filter the design table to only include the variables in the same time frame as the file. 
  design_table_limited <- design_table %>%
    mutate(variable_start_date_local = as.POSIXct(variable_start_date_local, tz = "America/Sao_Paulo"))%>%
    mutate(variable_end_date_local = as.POSIXct(variable_end_date_local, tz = "America/Sao_Paulo"))%>%
    filter(variable_start_date_local < file_start_time)%>%
    filter(variable_end_date_local > file_end_time | is.na(variable_end_date_local))
  
  return(design_table_limited)
  
}
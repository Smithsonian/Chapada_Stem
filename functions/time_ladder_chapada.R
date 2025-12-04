#Function --  This function will create an array of all the times that should be present in the data set and count how many are missing. 
#This is a check to see if we over cleaned the data. 

time_ladder_chapada <- function(dt, resolution, table) {
  #create a new data frame of timestamps from strt to end of the data that increases the time resolution of the table
  #(listed in the design table) 
  timestamp_local <- seq.POSIXt(min(dt$timestamp_local, na.rm = TRUE), max(dt$timestamp_local, na.rm = TRUE), by = (resolution*60)) 
  time_ladder <- as.data.frame(timestamp_local)

  #limit the timeladder dataset to just the timestamps that are not present and should be present. 
  time_ladder <- anti_join(time_ladder, dt, copy = TRUE) 
  
  # make raw data with time ladder incorporated. This will add a row for the missing timestamps where they should be with NA data points since no data was collected. 
  dt_joined <- full_join(dt, time_ladder, copy = TRUE)%>% 
  
  #put the data back in time order 
  arrange(timestamp_local)
  
  
  #check on number of missing obs - this could be built into a QC check/test
  print(paste("There were", nrow(time_ladder), "missing observations in the normalized data for ",table))
  return(dt_joined)
}
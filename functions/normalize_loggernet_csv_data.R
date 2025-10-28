### This function will take data from a raw CSV format directly read from loggernet.
#Reference a design table with a standard set of columns, and then "normalize" the data based on the values of the design table. 


##Arguements: 
#design -- full name/directory of the main design table for the project. 
#plotnames -- full name/directory of the plotnames design table for the project.
#varnames -- full name/directory of the design-type design table for the project.
#table -- the name of the loggernet table that you would like to process
#csv_dir  --  the directory to the raw loggernet data in csv format 



library(data.table)
library(tidyverse)

normalize_loggernet_csv_data <- function(design, plotnames, varnames, table, data_dir) {
  
  #identify the non-chamber level variables to leave out of the normalization
  id_cols <- design_table%>%
    filter(var_type %in% c("zone","experiment"))%>%
    pull(cr1000_name)
  
  
  #check that there are chamber level variables. If not, you can skip the normalization. 
  non_id_cols <- design_table%>%
    filter(var_type == "chamber")%>%
    pull(cr1000_name)
  
  if (length(non_id_cols) > 0){
  
  #normalize the data. See below comments for specific steps. 
  normalized_data <- csv_data %>%
    #put the table in long format except for the ID columns defined above. 
    pivot_longer(cols = -id_cols, names_to = "cr1000_name",values_to = "value")%>%
    #merge the data table with the design table based on the cr1000_names. 
    left_join(design_table, by = "cr1000_name")%>%
    #filter to just the columns of the design table that get published. 
    select(logger, id_cols, treatment, zone, chamber, value, research_name)%>%
    #now when you put the table back in wide format using research_name, it is in it's normalized form. 
    pivot_wider(names_from=research_name, values_from=value)
  }
  
  else {
    normalized_data <- csv_data
  }
  
  
  # final step: get the research names for the ID cols from above and rename them in the final table. 
  research_ID_names <- design_table%>%
    filter(cr1000_name == id_cols)
  
  setnames(normalized_data, old  = research_ID_names$cr1000_name, new = research_ID_names$research_name)
  
  
  return(normalized_data)
  
}
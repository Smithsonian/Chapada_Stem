#this function will first check that the loggernet variables in the final filtered design table for the file being processed are correct and
#are in the correct order. If you get the error on this function, it means there is a missmatch between the variables listed in "design_table_month"
#and the variables in the actual file. Check the design table thoroughly to see if there are any inaccuracies in variable order, loggernet name spelling, 
#or the start and end dates of each variable (variable_start_data_local and variable_end_date_local). 

convert_loggernet_headers_chapada <- function(design_table_limited, dt){
  
  new_headers <- design_table_limited$cr1000_name
  expected_current_headers <- gsub(",", ".", 
                                   gsub("[()]", ".", design_table_limited$loggernet_variable))
  actual_current_headers <- colnames(dt)
  
  if (identical(actual_current_headers,expected_current_headers)){
    colnames(dt) <-new_headers
  } else {
    stop("Design table loggernet variables do not match the variables in the file.
             Please check variable date ranges, names, and order for accuracy.")
  }
  
  return(dt)
  
}
library(readr)
library(dplyr)
library(tidyr)
library(xlsx)
library(stringr)
  
Isotonizer <- function(iso_var_lists, data){
  
  pos_vars_lists <- iso_var_lists[[1]]

  for (i in 1:length(pos_vars_lists)){
    
    target_var_name <- pos_vars_lists[i]
    iso_value <- 
      cut(2, c(-1, jump_points_list[[target_var_name]]), labels = fitted_y_norm_list[[target_var_name]]) %>% 
      as.character() %>% 
      as.numeric()
    iso_value <- ifelse(is.na(iso_value), 1, iso_value)
    
    data[,target_var_name] <- iso_value
  }
  
  return(data)
  }
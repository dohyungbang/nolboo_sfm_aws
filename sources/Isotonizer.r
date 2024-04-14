Isotonizer <- function(jump_points_list, fitted_y_norm_list, data){
  
  target_var_lists <- names(jump_points_list)
  
  for (i in 1:length(jump_points_list)){
    
    target_var_name <- target_var_lists[i]
    iso_value <- 
      cut(2, c(-1, jump_points_list[[target_var_name]]), labels = fitted_y_norm_list[[target_var_name]]) %>% 
      as.character() %>% 
      as.numeric()
    iso_value <- ifelse(is.na(iso_value), 1, iso_value)
    
    data[,target_var_name] <- iso_value
  }
  
  return(data)
  }
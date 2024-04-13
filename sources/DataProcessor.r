calAverageRange <- function(x) {strsplit(x, "~")[[1]] %>% as.numeric %>% mean}
calCAGR <- function(x) {p <- length(x); yrs <- p-1; PV <- x[1]; FV <- x[p]; ((FV/PV)^(1/yrs)-1)}

DataProcessor <- function(data, sgbiz_var_lists){
  
  names(data) <- "value"
  data$value <- str_replace_all(data$value, ",", "")
  data <- c(data[3:186,], unlist(str_replace_all(data[187:191,], "[)]", "") %>% str_split("[(]")), data[192:193,]) %>% t() %>% as.data.frame()
  names(data) <- sgbiz_var_lists[3:length(sgbiz_var_lists)]

  data$sgbiz_sales_amt_avg <- data %>% select(contains("sgbiz_sales_amt")) %>% as.numeric() %>% mean(na.rm = T)
  data$sgbiz_sales_n_avg <- data %>% select(contains("sgbiz_sales_n")) %>% as.numeric() %>% mean(na.rm = T)
  
  data$sgbiz_sales_amt_cagr <- calCAGR(data %>% select(contains("sgbiz_sales_amt")) %>% as.numeric) %>% round(digit = 5)
  data$sgbiz_sales_n_cagr <- calCAGR(data %>% select(contains("sgbiz_sales_n")) %>% as.numeric) %>% round(digit = 5) 
  data$sgbiz_store_n_cagr <- calCAGR(data %>% select(sgbiz_store_n_1:sgbiz_store_n_13) %>% as.numeric) %>% round(digit = 5) 
  data$sgbiz_pop_fl_cagr <- calCAGR(data %>% select(sgbiz_pop_fl_1:sgbiz_pop_fl_13) %>% as.numeric) %>% round(digit = 5)
  
  data$sgbiz_pop_res_cagr <- calCAGR(data %>% select(sgbiz_pop_res_1:sgbiz_pop_res_3) %>% as.numeric) %>% round(digit = 5) 
  data$sgbiz_pop_work_cagr <- calCAGR(data %>% select(sgbiz_pop_work_1:sgbiz_pop_work_3) %>% as.numeric) %>% round(digit = 5) 
  
  data$sgbiz_income_res_male <- apply(data %>% select(sgbiz_income_res_male), 1, calAverageRange)
  data$sgbiz_income_res_female <- apply(data %>% select(sgbiz_income_res_female), 1, calAverageRange)
  data$sgbiz_income_res_age_1 <- apply(data %>% select(sgbiz_income_res_age_1), 1, calAverageRange)
  data$sgbiz_income_res_age_2 <- apply(data %>% select(sgbiz_income_res_age_2), 1, calAverageRange)
  data$sgbiz_income_res_age_3 <- apply(data %>% select(sgbiz_income_res_age_3), 1, calAverageRange)
  data$sgbiz_income_res_age_4 <- apply(data %>% select(sgbiz_income_res_age_4), 1, calAverageRange)
  data$sgbiz_income_res_age_5 <- apply(data %>% select(sgbiz_income_res_age_5), 1, calAverageRange)
  
  data$sgbiz_exp_res_male <- apply(data %>% select(sgbiz_exp_res_male), 1, calAverageRange)
  data$sgbiz_exp_res_female <- apply(data %>% select(sgbiz_exp_res_female), 1, calAverageRange)
  data$sgbiz_exp_res_age_1 <- apply(data %>% select(sgbiz_exp_res_age_1), 1, calAverageRange)
  data$sgbiz_exp_res_age_2 <- apply(data %>% select(sgbiz_exp_res_age_2), 1, calAverageRange)
  data$sgbiz_exp_res_age_3 <- apply(data %>% select(sgbiz_exp_res_age_3), 1, calAverageRange)
  data$sgbiz_exp_res_age_4 <- apply(data %>% select(sgbiz_exp_res_age_4), 1, calAverageRange)
  data$sgbiz_exp_res_age_5 <- apply(data %>% select(sgbiz_exp_res_age_5), 1, calAverageRange)
  
  data$sgbiz_income_work_male <- apply(data %>% select(sgbiz_income_work_male), 1, calAverageRange)
  data$sgbiz_income_work_female <- apply(data %>% select(sgbiz_income_work_female), 1, calAverageRange)
  data$sgbiz_income_work_age_1 <- apply(data %>% select(sgbiz_income_work_age_1), 1, calAverageRange)
  data$sgbiz_income_work_age_2 <- apply(data %>% select(sgbiz_income_work_age_2), 1, calAverageRange)
  data$sgbiz_income_work_age_3 <- apply(data %>% select(sgbiz_income_work_age_3), 1, calAverageRange)
  data$sgbiz_income_work_age_4 <- apply(data %>% select(sgbiz_income_work_age_4), 1, calAverageRange)
  data$sgbiz_income_work_age_5 <- apply(data %>% select(sgbiz_income_work_age_5), 1, calAverageRange)
  
  data$sgbiz_exp_work_male <- apply(data %>% select(sgbiz_exp_work_male), 1, calAverageRange)
  data$sgbiz_exp_work_female <- apply(data %>% select(sgbiz_exp_work_female), 1, calAverageRange)
  data$sgbiz_exp_work_age_1 <- apply(data %>% select(sgbiz_exp_work_age_1), 1, calAverageRange)
  data$sgbiz_exp_work_age_2 <- apply(data %>% select(sgbiz_exp_work_age_2), 1, calAverageRange)
  data$sgbiz_exp_work_age_3 <- apply(data %>% select(sgbiz_exp_work_age_3), 1, calAverageRange)
  data$sgbiz_exp_work_age_4 <- apply(data %>% select(sgbiz_exp_work_age_4), 1, calAverageRange)
  data$sgbiz_exp_work_age_5 <- apply(data %>% select(sgbiz_exp_work_age_5), 1, calAverageRange) 
  
  final_data <- cbind.data.frame(data[,c(1,2)], data[,3:ncol(data)] %>%  mutate_if(is.character, as.numeric))
  
  return(final_data)
}

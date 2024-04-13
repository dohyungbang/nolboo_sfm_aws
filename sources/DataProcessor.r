calAverageRange <- function(x) {strsplit(x, "~")[[1]] %>% as.numeric %>% mean}
calCAGR <- function(x) {p <- length(x); yrs <- p-1; PV <- x[1]; FV <- x[p]; ((FV/PV)^(1/yrs)-1)}

DataProcessor <- function(data){
  
  data$sgbiz_sales_amt_avg <- apply(sgbiz %>% select(contains("sgbiz_sales_amt")), 1, mean)
  data$sgbiz_sales_n_avg <- apply(sgbiz %>% select(contains("sgbiz_sales_n")), 1, mean)
  
  data$sgbiz_sales_amt_cagr <- apply(sgbiz %>% select(contains("sgbiz_sales_amt")), 1, calCAGR) %>% round(digit = 5)
  data$sgbiz_sales_n_cagr <- apply(sgbiz %>% select(contains("sgbiz_sales_n")), 1, calCAGR) %>% round(digit = 5)
  data$sgbiz_store_n_cagr <- apply(sgbiz %>% select(sgbiz_store_n_1:sgbiz_store_n_13), 1, calCAGR) %>% round(digit = 5)
  data$sgbiz_pop_fl_cagr <- apply(sgbiz %>% select(sgbiz_pop_fl_1:sgbiz_pop_fl_13), 1, calCAGR) %>% round(digit = 5)
  
  data$sgbiz_pop_res_cagr <- apply(sgbiz %>% select(sgbiz_pop_res_1:sgbiz_pop_res_3), 1, calCAGR) %>% round(digit = 5)
  data$sgbiz_pop_work_cagr <- apply(sgbiz %>% select(sgbiz_pop_work_1:sgbiz_pop_work_3), 1, calCAGR) %>% round(digit = 5)
  
  data$sgbiz_income_res_male <- apply(sgbiz %>% select(sgbiz_income_res_male), 1, calAverageRange)
  data$sgbiz_income_res_female <- apply(sgbiz %>% select(sgbiz_income_res_female), 1, calAverageRange)
  data$sgbiz_income_res_age_1 <- apply(sgbiz %>% select(sgbiz_income_res_age_1), 1, calAverageRange)
  data$sgbiz_income_res_age_2 <- apply(sgbiz %>% select(sgbiz_income_res_age_2), 1, calAverageRange)
  data$sgbiz_income_res_age_3 <- apply(sgbiz %>% select(sgbiz_income_res_age_3), 1, calAverageRange)
  data$sgbiz_income_res_age_4 <- apply(sgbiz %>% select(sgbiz_income_res_age_4), 1, calAverageRange)
  data$sgbiz_income_res_age_5 <- apply(sgbiz %>% select(sgbiz_income_res_age_5), 1, calAverageRange)
  
  data$sgbiz_exp_res_male <- apply(sgbiz %>% select(sgbiz_exp_res_male), 1, calAverageRange)
  data$sgbiz_exp_res_female <- apply(sgbiz %>% select(sgbiz_exp_res_female), 1, calAverageRange)
  data$sgbiz_exp_res_age_1 <- apply(sgbiz %>% select(sgbiz_exp_res_age_1), 1, calAverageRange)
  data$sgbiz_exp_res_age_2 <- apply(sgbiz %>% select(sgbiz_exp_res_age_2), 1, calAverageRange)
  data$sgbiz_exp_res_age_3 <- apply(sgbiz %>% select(sgbiz_exp_res_age_3), 1, calAverageRange)
  data$sgbiz_exp_res_age_4 <- apply(sgbiz %>% select(sgbiz_exp_res_age_4), 1, calAverageRange)
  data$sgbiz_exp_res_age_5 <- apply(sgbiz %>% select(sgbiz_exp_res_age_5), 1, calAverageRange)
  
  data$sgbiz_income_work_male <- apply(sgbiz %>% select(sgbiz_income_work_male), 1, calAverageRange)
  data$sgbiz_income_work_female <- apply(sgbiz %>% select(sgbiz_income_work_female), 1, calAverageRange)
  data$sgbiz_income_work_age_1 <- apply(sgbiz %>% select(sgbiz_income_work_age_1), 1, calAverageRange)
  data$sgbiz_income_work_age_2 <- apply(sgbiz %>% select(sgbiz_income_work_age_2), 1, calAverageRange)
  data$sgbiz_income_work_age_3 <- apply(sgbiz %>% select(sgbiz_income_work_age_3), 1, calAverageRange)
  data$sgbiz_income_work_age_4 <- apply(sgbiz %>% select(sgbiz_income_work_age_4), 1, calAverageRange)
  data$sgbiz_income_work_age_5 <- apply(sgbiz %>% select(sgbiz_income_work_age_5), 1, calAverageRange)
  
  data$sgbiz_exp_work_male <- apply(sgbiz %>% select(sgbiz_exp_work_male), 1, calAverageRange)
  data$sgbiz_exp_work_female <- apply(sgbiz %>% select(sgbiz_exp_work_female), 1, calAverageRange)
  data$sgbiz_exp_work_age_1 <- apply(sgbiz %>% select(sgbiz_exp_work_age_1), 1, calAverageRange)
  data$sgbiz_exp_work_age_2 <- apply(sgbiz %>% select(sgbiz_exp_work_age_2), 1, calAverageRange)
  data$sgbiz_exp_work_age_3 <- apply(sgbiz %>% select(sgbiz_exp_work_age_3), 1, calAverageRange)
  data$sgbiz_exp_work_age_4 <- apply(sgbiz %>% select(sgbiz_exp_work_age_4), 1, calAverageRange)
  data$sgbiz_exp_work_age_5 <- apply(sgbiz %>% select(sgbiz_exp_work_age_5), 1, calAverageRange) 
  
  return(data)
  }
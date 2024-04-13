Collector <- function(address, radius){
  
  remDr <- rsDriver(browser = "chrome", 
                    port = 4444L,
                    chromever = "latest", 
                    extraCapabilities = list(chromeOptions = list(args = list('--headless', '--no-sandbox'))))$client
  
  # Navigate to the login page
  remDr$navigate("https://sso.sbiz.or.kr/sso/subLoginAction.do?joinSite=SG&reqSite=https://sg.sbiz.or.kr/godo/index.sg#")
  Sys.sleep(3)
  
  # Send ID & PW
  remDr$findElement(using = "css selector", value = "#id")$clickElement()
  remDr$findElement(using = "css selector", value = "#id")$clearElement()
  remDr$findElement(using = "css selector", value = "#id")$sendKeysToElement(list("bdh718"))
  Sys.sleep(3)
  remDr$findElement(using = "css selector", value = "#id")$clickElement()
  remDr$findElement(using = "css selector", value = "#pass")$clearElement()
  remDr$findElement(using = "css selector", value = "#pass")$sendKeysToElement(list("@@qkd90718"))
  Sys.sleep(3)
  
  # LOGIN
  remDr$findElement(using = "css selector", value = "body > div > div.l_content > form > div > input")$clickElement()
  Sys.sleep(3)
  
  remDr$navigate("https://sg.sbiz.or.kr/godo/analysis.sg")
  remDr$findElement(using = "css selector", value = "#container > div:nth-child(17) > div > div.head.close-option > div > label:nth-child(4)")$clickElement()
  Sys.sleep(3)
  
  # TARGET ADDRESS
  remDr$findElement(using = 'css selector', "#searchAddress")$clearElement()
  remDr$findElement(using = 'css selector', "#searchAddress")$sendKeysToElement(list(address))
  remDr$findElement(using = 'css selector', '#layerPopAddressMove')$clickElement()
  
  tryCatch({
    remDr$findElement(using = 'css selector', "#container > div:nth-child(1) > div:nth-child(3) > div.foot > a:nth-child(2)")$clickElement()
  }, error = function(e) {
    remDr$findElement(using = 'css selector', "#container > div:nth-child(11) > div:nth-child(3) > div.foot > a:nth-child(2)")$clickElement()
  })
  
  Sys.sleep(5)
  
  # SELECT UPJONG
  remDr$findElement(using = 'css selector', "#upjong > ul > li:nth-child(2) > label")$clickElement()
  Sys.sleep(3)
  remDr$findElement(using = 'css selector', "#container > div:nth-child(17) > div > div.midd > div.midd > div.searchview.scrollbarView.z-index0 > div > ul > li:nth-child(2) > div > ul > li:nth-child(3) > label > span")$clickElement()
  Sys.sleep(3)
  remDr$findElement(using = 'css selector', "#checkTypeConfirm")$clickElement()
  Sys.sleep(5)
  
  # SET RADIUS
  remDr$findElement(using = 'css selector', "#map > div:nth-child(1) > div > div:nth-child(6) > div:nth-child(2) > div > ul > li.child > label > svg")$clickElement()
  Sys.sleep(5)
  remDr$findElement(using = 'css selector', "#map > div:nth-child(1) > div > div:nth-child(6) > div:nth-child(2) > div > ul > li.child > div > ul > li:nth-child(2) > label")$clickElement()
  Sys.sleep(5)
  
  tryCatch({
    remDr$findElement(using = 'css selector', "#auto_circle > div > div.midd > ul > li:nth-child(8)")$clickElement()
    Sys.sleep(5)
    remDr$findElement(using = 'css selector', "#auto_circle > div > div.foot > a:nth-child(2)")$clickElement()
    Sys.sleep(5)
    remDr$findElement(using = 'css selector', "#auto_circle > div > div.midd > div > input[type=text]")$clickElement()
    remDr$findElement(using = 'css selector', "#auto_circle > div > div.midd > div > input[type=text]")$sendKeysToElement(list(radius))
    Sys.sleep(5)
    remDr$findElement(using = 'css selector', "#auto_circle > div > div.foot > a:nth-child(2)")$clickElement()
    Sys.sleep(5)
  }, error = function(e) {
    remDr$findElement(using = 'css selector', "#auto_circle > div > div.midd > div > input[type=text]")$clickElement()
    remDr$findElement(using = 'css selector', "#auto_circle > div > div.midd > div > input[type=text]")$sendKeysToElement(list(radius))
    Sys.sleep(5)
    remDr$findElement(using = 'css selector', "#container > div:nth-child(11) > div:nth-child(3) > div.foot > a:nth-child(2)")$clickElement()
    Sys.sleep(5)
  })
  
  # ANALYSIS
  remDr$findElement(using = 'css selector', "#map > div:nth-child(1) > div > div:nth-child(6) > div:nth-child(3) > img")$clickElement()
  Sys.sleep(25)
  
  # ANALYSIS - SUMMARY #
  remDr$findElement(using = 'css selector', "#menu2")$clickElement()
  Sys.sleep(3)
  
  ### No. of stores
  last_month <- remDr$findElement(using = "xpath", "//*[@id='page2']/div[3]/table/thead/tr/th[15]")$getElementText()
  
  store_n <- remDr$findElement(using = "xpath", "//*[@id='page2']/div[3]/table/tbody/tr[1]")$getElementText() %>%
    gsub("\n", " ", .) %>%
    strsplit(" ") %>%
    .[[1]][2:length(.[[1]])]
  
  ## Click on 매출분석 menu
  remDr$findElement(using = "css selector", "#menu3")$clickElement()
  Sys.sleep(3)
  
  ### Sales
  sales_amt <- remDr$findElement(using = "xpath", "//*[@id='page3']/div[3]/table/tbody/tr[1]")$getElementText() %>%
    gsub("\n", " ", .) %>%
    strsplit(" ") %>%
    .[[1]][2:length(.[[1]])]
  
  sales_n <- remDr$findElement(using = "xpath", "//*[@id='page3']/div[5]/table/tbody/tr[1]")$getElementText() %>%
    gsub("\n", " ", .) %>%
    strsplit(" ") %>%
    .[[1]][2:length(.[[1]])]
  
  ### 요일별 Sales
  sales_day_amt <- remDr$findElement(using = "xpath", "//*[@id='page3']/div[7]/table/tbody/tr[1]")$getElementText() %>%
    gsub(" ", " ", .) %>%
    strsplit(" ") %>%
    .[[1]][5:length(.[[1]])]
  
  sales_day_n_ratio <- remDr$findElement(using = "xpath", "//*[@id='page3']/div[7]/table/tbody/tr[3]")$getElementText() %>%
    gsub(" ", " ", .) %>%
    strsplit(" ") %>%
    .[[1]][4:length(.[[1]])]
  
  ### 시간대별 Sales
  sales_time_amt <- remDr$findElement(using = "xpath", "//*[@id='page3']/div[8]/table/tbody/tr[1]")$getElementText() %>%
    gsub(" ", " ", .) %>%
    strsplit(" ") %>%
    .[[1]][3:length(.[[1]])]
  
  sales_time_n_ratio <- remDr$findElement(using = "xpath", "//*[@id='page3']/div[8]/table/tbody/tr[3]")$getElementText() %>%
    gsub(" ", " ", .) %>%
    strsplit(" ") %>%
    .[[1]][2:length(.[[1]])]
  
  ### 성별/연령별 Sales
  sales_age_amt <- remDr$findElement(using = "xpath", "//*[@id='page3']/div[9]/table/tbody/tr[1]")$getElementText() %>%
    gsub(" ", " ", .) %>%
    strsplit(" ") %>%
    .[[1]][3:length(.[[1]])]
  
  sales_age_n_ratio <- remDr$findElement(using = "xpath", "//*[@id='page3']/div[9]/table/tbody/tr[3]")$getElementText() %>%
    gsub(" ", " ", .) %>%
    strsplit(" ") %>%
    .[[1]][2:length(.[[1]])]
  
  ## Click on 인구분석 menu
  remDr$findElement(using = "css selector", "#menu4")$clickElement()
  Sys.sleep(3)
  
  ### 유동인구
  pop_fl <- remDr$findElement(using = "xpath", "//*[@id='page4']/div[3]/table/tbody/tr[1]")$getElementText() %>%
    gsub(" ", " ", .) %>%
    strsplit(" ") %>%
    .[[1]][3:length(.[[1]])]
  
  ### 성별/연령대별 유동인구
  pop_fl_sexage <- remDr$findElement(using = "xpath", "//*[@id='page4']/div[4]/table/tbody/tr[1]")$getElementText() %>%
    gsub(" ", " ", .) %>%
    strsplit(" ") %>%
    .[[1]][4:length(.[[1]])]
  
  ### 요일별 유동인구
  pop_fl_day <- remDr$findElement(using = "xpath", "//*[@id='page4']/div[5]/table/tbody/tr[1]")$getElementText() %>%
    gsub(" ", " ", .) %>%
    strsplit(" ") %>%
    .[[1]][5:length(.[[1]])]
  
  ### 시간대별 유동인구
  pop_fl_time <- remDr$findElement(using = "xpath", "//*[@id='page4']/div[6]/table/tbody/tr[1]")$getElementText() %>%
    gsub(" ", " ", .) %>%
    strsplit(" ") %>%
    .[[1]][3:length(.[[1]])]
  
  ### 주거인구
  pop_res <- remDr$findElement(using = "xpath", "//*[@id='page4']/div[9]/table/tbody/tr[1]")$getElementText() %>%
    gsub(" ", " ", .) %>%
    strsplit(" ") %>%
    .[[1]][2:length(.[[1]])]
  
  ### 성별/연령대별 주거인구
  pop_res_sexage <- remDr$findElement(using = "xpath", "//*[@id='page4']/div[10]/table/tbody/tr[1]")$getElementText() %>%
    gsub(" ", " ", .) %>%
    strsplit(" ") %>%
    .[[1]][4:length(.[[1]])]
  
  
  ### 주거인구 성별 소득소비
  income_res_male <- remDr$findElement(using = "xpath", "//*[@id='page4']/div[13]/table/tbody/tr[1]")$getElementText() %>%
    gsub(" ~ ", "~", .) %>%
    strsplit(" ") %>%
    .[[1]][3]
  
  income_res_female <- remDr$findElement(using = "xpath", "//*[@id='page4']/div[13]/table/tbody/tr[2]")$getElementText() %>%
    gsub(" ~ ", "~", .) %>%
    strsplit(" ") %>%
    .[[1]][3]
  
  exp_res_male <- remDr$findElement(using = "xpath", "//*[@id='page4']/div[13]/table/tbody/tr[1]")$getElementText() %>%
    gsub(" ~ ", "~", .) %>%
    strsplit(" ") %>%
    .[[1]][5]
  
  exp_res_female <- remDr$findElement(using = "xpath", "//*[@id='page4']/div[13]/table/tbody/tr[2]")$getElementText() %>%
    gsub(" ~ ", "~", .) %>%
    strsplit(" ") %>%
    .[[1]][5]
  
  ### 주거인구 연령대별 소득소비
  income_res_age <- c()
  for (i in 1:4) {
    text <- remDr$findElement(using = "xpath", paste0("//*[@id='page4']/div[14]/table/tbody/tr[", i, "]"))$getElementText()
    text <- gsub(" ~ ", "~", text)
    income_res_age[i] <- unlist(strsplit(text, " "))[3]
  }
  
  income_res_age[5] <- unlist(strsplit(gsub(" ~ ", "~", remDr$findElement(using = "xpath", "//*[@id='page4']/div[14]/table/tbody/tr[5]")$getElementText()), " "))[4]
  
  exp_res_age <- c()
  for (i in 1:4) {
    text <- remDr$findElement(using = "xpath", paste0("//*[@id='page4']/div[14]/table/tbody/tr[", i, "]"))$getElementText()
    text <- gsub(" ~ ", "~", text)
    exp_res_age[i] <- unlist(strsplit(text, " "))[5]
  }
  
  exp_res_age[5] <- unlist(strsplit(gsub(" ~ ", "~", remDr$findElement(using = "xpath", "//*[@id='page4']/div[14]/table/tbody/tr[5]")$getElementText()), " "))[6]
  
  ### 직장인구
  pop_work <- remDr$findElement(using = "xpath", "//*[@id='page4']/div[19]/table/tbody/tr[1]")$getElementText() %>%
    gsub(" ", " ", .) %>%
    strsplit(" ") %>%
    .[[1]][2:length(.[[1]])]
  
  ### 성별/연령대별 직장인구
  pop_work_sexage <- remDr$findElement(using = "xpath", "//*[@id='page4']/div[20]/table/tbody/tr[1]")$getElementText() %>%
    gsub(" ", " ", .) %>%
    strsplit(" ") %>%
    .[[1]][4:length(.[[1]])]
  
  ### 주거인구 성별 소득소비
  income_work_male <- remDr$findElement(using = "xpath", "//*[@id='page4']/div[23]/table/tbody/tr[1]")$getElementText() %>%
    gsub(" ~ ", "~", .) %>%
    strsplit(" ") %>%
    .[[1]][3]
  
  income_work_female <- remDr$findElement(using = "xpath", "//*[@id='page4']/div[23]/table/tbody/tr[2]")$getElementText() %>%
    gsub(" ~ ", "~", .) %>%
    strsplit(" ") %>%
    .[[1]][3]
  
  exp_work_male <- remDr$findElement(using = "xpath", "//*[@id='page4']/div[23]/table/tbody/tr[1]")$getElementText() %>%
    gsub(" ~ ", "~", .) %>%
    strsplit(" ") %>%
    .[[1]][5]
  
  exp_work_female <- remDr$findElement(using = "xpath", "//*[@id='page4']/div[23]/table/tbody/tr[2]")$getElementText() %>%
    gsub(" ~ ", "~", .) %>%
    strsplit(" ") %>%
    .[[1]][5]
  
  ### 주거인구 연령대별 소득소비
  income_work_age <- c()
  for (i in 1:4) {
    text <- remDr$findElement(using = "xpath", paste0("//*[@id='page4']/div[24]/table/tbody/tr[", i, "]"))$getElementText()
    text <- gsub(" ~ ", "~", text)
    income_work_age[i] <- unlist(strsplit(text, " "))[3]
  }
  
  income_work_age[5] <- unlist(strsplit(gsub(" ~ ", "~", remDr$findElement(using = "xpath", "//*[@id='page4']/div[24]/table/tbody/tr[5]")$getElementText()), " "))[4]
  
  exp_work_age <- c()
  for (i in 1:4) {
    text <- remDr$findElement(using = "xpath", paste0("//*[@id='page4']/div[24]/table/tbody/tr[", i, "]"))$getElementText()
    text <- gsub(" ~ ", "~", text)
    exp_work_age[i] <- unlist(strsplit(text, " "))[5]
  }
  
  exp_work_age[5] <- unlist(strsplit(gsub(" ~ ", "~", remDr$findElement(using = "xpath", "//*[@id='page4']/div[24]/table/tbody/tr[5]")$getElementText()), " "))[6]
  
  ## 지역현황
  remDr$findElement(using = "css selector", "#menu5")$clickElement()
  Sys.sleep(1)
  
  ### 세대 수
  region_household_n <- remDr$findElement(using = "xpath", "//*[@id='page5']/div[3]/table/tbody/tr[1]")$getElementText() %>%
    gsub(" ", " ", .) %>%
    strsplit(" ") %>%
    .[[1]][5]
  
  ### 주거지 수
  region_villa_n <- remDr$findElement(using = "xpath", "//*[@id='page5']/div[6]/table/tbody/tr[1]")$getElementText() %>%
    gsub(" ", " ", .) %>%
    strsplit(" ") %>%
    .[[1]][4]
  
  ### 아파트 동 수
  region_aptdong_n <- remDr$findElement(using = "xpath", "//*[@id='page5']/div[7]/table/tbody/tr[1]")$getElementText() %>%
    gsub(" ", " ", .) %>%
    strsplit(" ") %>%
    .[[1]][6]
  
  ### 아파트 호 수
  region_aptho_n <- remDr$findElement(using = "xpath", "//*[@id='page5']/div[7]/table/tbody/tr[1]")$getElementText() %>%
    gsub(" ", " ", .) %>%
    strsplit(" ") %>%
    .[[1]][7]
  
  ### 아파트 면적 별 수
  region_area_n <- remDr$findElement(using = "xpath", "//*[@id='page5']/div[9]/table/tbody/tr[1]")$getElementText() %>%
    gsub(" ", " ", .) %>%
    strsplit(" ") %>%
    .[[1]][2:length(.[[1]])]
  
  ### 시설 현황
  element <- remDr$findElement(using = "xpath", "//*[@id='page5']/div[12]/table/tbody/tr[1]")
  region_facility <- strsplit(element$getElementText()[[1]], " ")[[1]][-1]
  
  element <- remDr$findElement(using = "xpath", "//*[@id='page5']/div[13]/table/tbody/tr[1]")
  region_school <- strsplit(element$getElementText()[[1]], " ")[[1]][-1]
  
  ### 지하철역/버스정류장
  tryCatch({
    element <- remDr$findElement(using = "xpath", "//*[@id='page5']/div[17]/table/tbody/tr[1]")
    region_subway_bus <- strsplit(element$getElementText()[[1]], " ")[[1]]
    region_subway_n <- region_subway_bus[2]
    region_bus_n <- region_subway_bus[3]
  }, error = function(e) {
    element <- remDr$findElement(using = "xpath", "//*[@id='page5']/div[16]/table/tbody/tr[1]")
    region_subway_bus <- strsplit(element$getElementText()[[1]], " ")[[1]]
    region_subway_n <- region_subway_bus[2]
    region_bus_n <- region_subway_bus[3]
  })
  
  each_row <- c(last_month, store_n, sales_amt, sales_n, sales_day_amt, sales_day_n_ratio,
                sales_time_amt, sales_time_n_ratio, sales_age_amt, sales_age_n_ratio,
                pop_fl, pop_fl_day, pop_fl_sexage, pop_fl_time, pop_res, pop_res_sexage,
                income_res_male, income_res_female, income_res_age, exp_res_male,
                exp_res_female, exp_res_age, pop_work, pop_work_sexage, income_work_male,
                income_work_female, income_work_age, exp_work_male, exp_work_female,
                exp_work_age, region_household_n, region_villa_n, region_aptdong_n,
                region_aptho_n, region_area_n, region_facility, region_school,
                region_subway_n, region_bus_n) %>% as.data.frame()
  remDr$closeall()
  
  return(each_row)
  }
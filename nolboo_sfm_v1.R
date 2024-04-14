# --- SETTING --- #
.packages = c("shiny", "shinymanager", "shinyjs", "shinydashboard", "shinycssloaders",
              "dplyr", "lubridate", "sysfonts", "plotly", "stringr", "glmnet", "reticulate", "kableExtra", "gridExtra")

.inst <- .packages %in% installed.packages()
if(length(.packages[!.inst]) > 0) install.packages(.packages[!.inst])

lapply(.packages, require, character.only=TRUE)

source("./sources/DataProcessor.r")
source("./sources/Isotonizer.r")
jump_points_list <- readRDS("./sources/jump_points_list.rds")
fitted_y_norm_list<- readRDS("./sources/fitted_y_norm_list.rds")
sgbiz_var_lists <- readRDS("./sources/sgbiz_var_lists.rds")
model <- readRDS("./sources/elasNet_optimal.rds")
source_python("./sources/DataCollector_python.py")

write.csv.utf8.BOM <- function(df, filename) {
  con <- file(filename, "w")
  tryCatch({
    for (i in 1:ncol(df))
      df[,i] = iconv(df[,i], to = "UTF-8") 
    writeChar(iconv("\ufeff", to = "UTF-8"), con, eos = NULL)
    write.csv(df, file = con)
  },finally = {close(con)})
}

credentials <- data.frame(
  user = c("testuser1", "user_nolboo1"),
  password = c("test123", "nolboo123"), stringsAsFactors = FALSE)

# --- HEADER --- #
Header <- dashboardHeader(
  title = span(img(src = "white_wo_bg.png", height = "35px"), "솔루션"),
  titleWidth = 300
)

# --- SIDEBAR --- #
Sidebar <- dashboardSidebar(
  width = 300,
  sidebarMenu(
    hr(),
    menuItem(
      "출점지 평가 솔루션",
      tabName ="site-selection-solution",
      icon = icon("location-dot"),
      startExpanded = TRUE,
      menuItem("매출예측모형",
               tabName = "sales-forecasting-model",
               icon = icon("chart-simple")),
      menuItem("출점지스코어링모형",
               tabName = "site-scoring-model",
               icon = icon("calculator"))
    ),
    hr(),
    div(style = "margin-left:13px; test-align:left; font-size: 18px; color:black", textOutput("current_user")),
    actionButton(
      inputId = "logout",
      label = "Logout",
      tooltip = "logout",
      icon = icon("sign-out")
    )
    
  )
)

# --- BODY --- #

kakao_post_code_api <-
  column(12,
         tags$head(
           tags$script(src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"),
           tags$script(HTML("
          function sample4_execDaumPostcode() {
            new daum.Postcode({
                oncomplete: function(data) {
                    var roadAddr = data.roadAddress;
                    document.getElementById('sample4_roadAddress').value = roadAddr;
                    
                    Shiny.setInputValue('roadAddress', roadAddr);
                    
                    document.getElementById('sample4_roadAddress').focus();

                }
            }).open();
          }
        "))
         ),
         fluidRow(
           column(8, 
                  div(class = "align-top",
                      h4(strong('후보지 주소:'), stype = "font-size: 70%; margin-bottom: 20px; "),
                      tags$input(type="button", onclick="sample4_execDaumPostcode()", value = "검색",
                                 style="font-size: 16px; font-weight: bold; height: 40px; width: 100px; background-color: #1C3C87; color: white;"),
                      tags$input(type="text", id="sample4_roadAddress", placeholder = "주소",
                                 style="width: 500px; height: 40px;")
                  )
           ),
           column(4,
                  div(class = "align-top",
                      selectInput("sfm_input_radius", h4(strong("목표 반경 (미터):")), choices = c(seq(500, 1500,by=100)) )
                  )
           )
         ),
         tags$span(id="guide", style="color:#999;display:none")
  )


sfm_body <- tabItem(
  tabName = "sales-forecasting-model",
  tabsetPanel(
    
    tabPanel("출점지 Input Data",
             
             br(),
             fluidRow(
               box(
                 title= strong("잠재후보지 정보 입력"),
                 status="primary",
                 width = 12,
                 color="black",
                 
                 h4(strong('목표 후보지 그룹 지정')),
                 fluidRow(
                   column(4, textInput("sfm_input_name", "평가후보지 이름:")),
                   column(4, textInput("sfm_input_sv", "담당자명:")),
                   column(4, selectInput("sfm_input_brand", "목표 브랜드: ", choices = c("부대 단독형", "보쌈부대 통합형"), selected = "부대 단독형"))
                   
                 ),
                 tags$hr(),
                 
                 h4(strong('목표 후보지 주소 및 목표 반경')),
                 fluidRow(kakao_post_code_api),
                 tags$hr(),
                 
                 h4(strong('목표 후보지 브랜드 및 매장 특성 ')),
                 fluidRow(
                   column(4, numericInput("sfm_input_area_hall", "홀 면적 (평방미터): ", value = 0)),
                   column(4, numericInput("sfm_input_area_kitchen", "주방 면적 (평방미터): ", value = 0)),
                   column(4, numericInput("sfm_input_ntable", "테이블 수 (개): ", value = 0))
                 ),
                 fluidRow(
                   column(4, numericInput("sfm_input_nchair", "좌석 수 (개): ", value = 0)),
                   column(4, numericInput("sfm_input_floor_store", "매장 층 수 (층): ", value = 0)),
                   column(4, numericInput("sfm_input_floor_bldg", "건물전체 층 수 (층): ", value = 0)),
                 ),
                 fluidRow(
                   column(4, numericInput("sfm_input_opertime", "일 평균 영업시간 (시간): ", value = 0)),
                   column(4, numericInput("sfm_input_operday", "월 평균 영업일수 (일): ", value = 0)),
                   column(4, selectInput("sfm_input_parking", "주차가능 여부:", choices = c("가능", "불가능"), selected = "가능")),
                 ),
                 fluidRow(
                   column(4, numericInput("sfm_input_emp_full", "직원 수-풀타임 (명): ", value = 0)),
                   column(4, numericInput("sfm_input_emp_part", "직원 수-파트타임 (명): ", value = 0)),
                   column(4, numericInput("sfm_input_rentcost", "예상 월 임대료 (원): ", value = 0))
                 ),
                 fluidRow(
                   column(4, numericInput("sfm_input_del_ad_cost", "예상 월 배달판촉비(원): ", value = 0)),
                   column(4, selectInput("sfm_input_del_tpl", "배달대행:", choices = c("이용", "이용안함"), selected = "이용")),
                   column(4, selectInput("sfm_input_del_store", "직접배달: ", choices = c("이용", "이용안함"), selected = "이용"))
                 ),
                 tags$hr(),
                 
                 tags$head(
                   tags$style(HTML("
                      #sfm_run_button {
                        background-color: #1C3C87;
                        color: white;
                        padding: 15px 30px;
                        font-size: 18px;
                        font-weight: bold;
                      }"))
                 ),
                 
                 fluidRow(
                   column(12, align = "center", actionButton("sfm_run_button", "목표 후보지 평가"))
                 ),
                 fluidRow(
                   column(12, align = "center", h5("목표 후보지 상권데이터 수집으로 인해 매출예측은 1-2분가량 소요됩니다.")))
                 
               ),
               
             )
             
    ),
    
    tabPanel("출점지 평가 결과",
             
             br(),
             fluidRow(
               column(3, downloadButton("sfm_result_report", "report 다운로드(.html)")),
               column(3, downloadButton("sfm_result_csv", "데이터 다운로드(.csv)"))
             ),
             tags$br(),
             
             fluidRow(
               # --- STORE SUMMARY --- #
               box(
                 title = strong("목표 후보지 SUMMARY"),
                 status ="primary",
                 width = 12,
                 color ="black",
                 fluidRow(
                   column(12,
                          h3(strong(withSpinner(textOutput(outputId = "sfm_target_site_summary"))))
                   )
                 ),
                 fluidRow(
                   column(12,
                          div(class = "narrow-value-box",
                              withSpinner(valueBoxOutput("sfm_output_area_hall", width=3)),
                              withSpinner(valueBoxOutput("sfm_output_area_kitchen", width=3)),
                              withSpinner(valueBoxOutput("sfm_output_ntable", width=3)),
                              withSpinner(valueBoxOutput("sfm_output_nchair", width=3)))
                   )
                 ),
                 fluidRow(
                   column(12,
                          withSpinner(valueBoxOutput("sfm_output_floor_store", width=3)),
                          withSpinner(valueBoxOutput("sfm_output_floor_bldg", width=3)),
                          withSpinner(valueBoxOutput("sfm_output_opertime", width=3)),
                          withSpinner(valueBoxOutput("sfm_output_operday", width=3))
                   )
                   
                 ),
                 fluidRow(
                   column(12,
                          withSpinner(valueBoxOutput("sfm_output_parking", width=3)),
                          withSpinner(valueBoxOutput("sfm_output_emp_full", width=3)),
                          withSpinner(valueBoxOutput("sfm_output_emp_part", width=3)),
                          withSpinner(valueBoxOutput("sfm_output_rentcost", width=3)))
                 ),
                 
                 fluidRow(
                   column(12,
                          withSpinner(valueBoxOutput("sfm_output_del_tpl", width=3)),
                          withSpinner(valueBoxOutput("sfm_output_del_store", width=3))
                   )
                 )
                 
               ),
               
               # --- PREDICTION RESULT --- #
               box(
                 title= strong("매출예측결과"),
                 status="primary",
                 width = 12,
                 color="black",
                 fluidRow(
                   column(7,
                          withSpinner(plotlyOutput("sfm_pred_plot"))
                   ),
                   column(5,
                          strong(withSpinner(textOutput("sfm_pred_text1"))),
                          strong(withSpinner(textOutput("sfm_pred_text2"))),
                          style="font-size: 20px;"
                   )
                 )
               ),
               
               
               # --- SANGKWON DATA SUMMARY --- #
               box(
                 title= strong("상권 및 경쟁정보 요약"),
                 status="primary",
                 width = 12,
                 color="black",
                 
                 h3(strong('동종 업체 수 추이')),
                 fluidRow(
                   column(12,
                          withSpinner(plotlyOutput("sfm_sgbiz_store_trend"))
                   )
                 ),
                 tags$hr(),
                 
                 h3(strong('상권 내 가구 및 인구분포')),
                 fluidRow(
                   column(12,
                          withSpinner(plotlyOutput("sfm_sgbiz_pop"))
                   )
                 ),
                 tags$hr(),
                 
                 h3(strong('성별/나이별 유동인구 비중')),
                 fluidRow(
                   column(6,
                          withSpinner(plotlyOutput("sfm_sgbiz_fl_sex_ratio"))),
                   column(6,
                          withSpinner(plotlyOutput("sfm_sgbiz_fl_age_ratio")))
                 ),
                 tags$hr(),
                 
                 h3(strong('요일별 유동인구 분포')),
                 fluidRow(
                   column(12,
                          withSpinner(plotlyOutput("sfm_sgbiz_fl_day")))
                 ),
                 tags$hr(),
                 
                 h3(strong('시간대별 유동인구 분포')),
                 fluidRow(
                   column(12,
                          withSpinner(plotlyOutput("sfm_sgbiz_fl_time")))
                 ),
                 tags$hr(),
                 
                 h3(strong('상권구매력')),
                 fluidRow(
                   column(12,
                          withSpinner(plotlyOutput("sfm_sgbiz_incomeexp"))
                   )
                 ),
                 tags$hr(),
                 
                 h3(strong('상권 배후시설 특성')),
                 fluidRow(
                   column(6,
                          withSpinner(tableOutput("sfm_sgbiz_fac_table1"))),
                   column(6,
                          withSpinner(tableOutput("sfm_sgbiz_fac_table2")))
                 )
                 
               )
             )       
    )
  )
)

ssm_body <- tabItem(
  tabName = "site-scoring-model",
  tabsetPanel(
    tabPanel("출점지 스코어링 Input Data",
             fluidRow(
               column(12, align = "center", h3("서비스 준비 중"))
             )
             ),
    tabPanel("출점지 스코어링 결과",
             fluidRow(
               column(12, align = "center", h3("서비스 준비 중"))
                    )))
)

Body <- dashboardBody(
  tags$style(HTML(".sidebar-menu {font-size: 18px;}
                   .sidebar-menu .menu-item a{ font-size: 18px; margin-top: 10px; margin-bottom: 10px;}
                   label { font-size:120%; }
                   .nav-tabs {font-size: 18px}
                   .skin-blue .main-header .logo {background-color: #1C3C87;}
                   .skin-blue .main-header .logo:hover {background-color: #1C3C87;}
                   .skin-blue .main-header .navbar {background-color: #1C3C87;}
                   .skin-blue .main-sidebar {background-color: #FFFFFF;}
                   .skin-blue .main-sidebar .sidebar .sidebar-menu .active a{ background-color: #1C3C87; color: #FFFFFF;}
                   .skin-blue .main-sidebar .sidebar .sidebar-menu a{ background-color: #FFFFFF; color: #000000;}
                  "
  )),
  tabItems(
    sfm_body,
    ssm_body
  )
  
)

ui <- dashboardPage(title = "Betabrain Solution",
                    Header,
                    Sidebar,
                    Body)

ui <- secure_app(ui)

# --- SERVER --- #
server <- function(input, output, session) {
  
  res_auth <- secure_server(check_credentials = check_credentials(credentials))
  
  output$auth_output <- renderPrint({
    reactiveValuesToList(res_auth)
  })
  
  current_user <- reactive({
    res_auth$user  
  })
  
  output$current_user <- renderText({
    paste0("사용자ID: ", current_user())
  })
  
  observeEvent(session$input$logout,{
    session$reload()
  })
  
  observeEvent(input$sfm_run_button, {
    
    # Invalidate previous outputs to show spinners
    output$sfm_target_site_summary <- renderText({ invalidateLater(100, session); NULL })
    output$sfm_output_area_hall <- renderValueBox({ withSpinner(NULL) })
    output$sfm_output_area_kitchen <- renderValueBox({ withSpinner(NULL) })
    output$sfm_output_ntable <- renderValueBox({ withSpinner(NULL) })
    output$sfm_output_nchair <- renderValueBox({ withSpinner(NULL) })
    output$sfm_output_floor_store <- renderValueBox({ withSpinner(NULL) })
    output$sfm_output_floor_bldg <- renderValueBox({ withSpinner(NULL) })
    output$sfm_output_opertime <- renderValueBox({ withSpinner(NULL) })
    output$sfm_output_operday <- renderValueBox({ withSpinner(NULL) })
    output$sfm_output_parking <- renderValueBox({ withSpinner(NULL) })
    output$sfm_output_emp_full <- renderValueBox({ withSpinner(NULL) })
    output$sfm_output_emp_part <- renderValueBox({ withSpinner(NULL) })
    output$sfm_output_rentcost <- renderValueBox({ withSpinner(NULL) })
    output$sfm_output_del_tpl <- renderValueBox({ withSpinner(NULL) })
    output$sfm_output_del_store <- renderValueBox({ withSpinner(NULL) })
    output$sfm_pred_plot <- renderPlotly({ withSpinner(NULL) })
    output$sfm_pred_text1 <- renderText({ withSpinner(NULL) })
    output$sfm_pred_text2 <- renderText({ withSpinner(NULL) })
    output$sfm_sgbiz_store_trend <- renderPlotly({ withSpinner(NULL) })
    output$sfm_sgbiz_pop <- renderPlotly({ withSpinner(NULL) })
    output$sfm_sgbiz_fl_sex_ratio <- renderPlotly({ withSpinner(NULL) })
    output$sfm_sgbiz_fl_age_ratio <- renderPlotly({ withSpinner(NULL) })
    output$sfm_sgbiz_fl_day <- renderPlotly({ withSpinner(NULL) })
    output$sfm_sgbiz_fl_time <- renderPlotly({ withSpinner(NULL) })
    output$sfm_sgbiz_incomeexp <- renderPlotly({ withSpinner(NULL) })
    output$sfm_sgbiz_fac_table1 <- renderTable({ withSpinner(NULL) })
    output$sfm_sgbiz_fac_table2 <- renderTable({ withSpinner(NULL) })
    
    # Delay processing to allow UI to update
    invalidateLater(200, session)
    
    sgbiz_data <- ExtractData(input$roadAddress, input$sfm_input_radius)
    sgbiz_data_new <- DataProcessor(sgbiz_data, sgbiz_var_lists)
    seoul <- ifelse(str_detect(input$roadAddress, "서울"), 1, 0)
    
    # Input Page
    input_data <- data.frame(nolbu_name = input$sfm_input_name,
                             sv = input$sfm_input_sv,
                             nolbu_address = input$roadAddress,
                             nolbu_seoul = seoul,
                             nolbu_brand = input$sfm_input_brand,
                             nolbu_radius = input$sfm_input_radius,
                             nolbu_store_area_hall = input$sfm_input_area_hall,
                             nolbu_store_area_kitchen = input$sfm_input_area_kitchen,
                             nolbu_store_table = input$sfm_input_ntable,
                             nolbu_store_chair = input$sfm_input_nchair,
                             nolbu_store_floor = input$sfm_input_floor_store,
                             nolbu_bldg_floor = input$sfm_input_floor_bldg,
                             nolbu_store_oper_time = input$sfm_input_opertime,
                             nolbu_store_oper_day = input$sfm_input_operday,
                             nolbu_bldg_parking = input$sfm_input_parking,
                             nolbu_store_emp_full = input$sfm_input_emp_full,
                             nolbu_store_emp_part = input$sfm_input_emp_part,
                             nolbu_rent = input$sfm_input_rentcost,
                             nolbu_delivery_ad_cost = input$sfm_input_del_ad_cost, 
                             nolbu_delivery_rider_tpl = input$sfm_input_del_tpl,
                             nolbu_delivery_rider_store = input$sfm_input_del_store
    )
    
    input_data$nolbu_brand <- ifelse(input_data$nolbu_brand == "부대 단독형", 1, 0) %>% as.numeric()
    input_data$nolbu_bldg_parking <- ifelse(input_data$nolbu_bldg_parking == "가능", 1, 0) %>% as.numeric()
    input_data$nolbu_delivery_rider_tpl <- ifelse(input_data$nolbu_delivery_rider_tpl == "이용", 1, 0) %>% as.numeric()
    input_data$nolbu_delivery_rider_store <- ifelse(input_data$nolbu_delivery_rider_store == "이용", 1, 0) %>% as.numeric()
    
    output$sfm_target_site_summary <- renderText({
      
      print(paste0("평가후보지: ", input_data$nolbu_name,
                   " | ", ifelse(input_data$nolbu_brand == 1, "부대 단독형", "부대보쌈 통합형"),
                   " | ", input_data$nolbu_address,
                   " | ", "반경 ", input_data$nolbu_radius, "m", collapse=NULL))
    })
    
    # Collected SG BIZ data
    input_data_final <- cbind.data.frame(input_data, sgbiz_data_new) %>% as.data.frame()
    input_isotonized <- Isotonizer(jump_points_list, fitted_y_norm_list, input_data_final)
    
    x_inputs <- input_isotonized %>% select(model$beta@Dimnames[[1]]) %>% as.matrix()
    
    # Predict
    pred_value <- predict(model, x_inputs)
    input_data_final$nolbu_sales_total <- pred_value
    
    #### --- VALUE BOX --- ####
    output$sfm_output_area_hall <- renderValueBox({
      
      valueBox(input_data_final$nolbu_store_area_hall, "홀 면적(m2)", color="blue")
    })
    
    output$sfm_output_area_kitchen <- renderValueBox({
      
      valueBox(input_data_final$nolbu_store_area_kitchen, "주방 면적(m2)", color="blue")
      
    })
    
    output$sfm_output_ntable <- renderValueBox({
      
      valueBox(input_data_final$nolbu_store_table, "테이블 수(개)", color="blue")
    })
    
    output$sfm_output_nchair <- renderValueBox({
      
      valueBox(input_data_final$nolbu_store_chair, "좌석 수 (개)", color="blue")
      
    })
    
    output$sfm_output_floor_store <- renderValueBox({
      
      valueBox(input_data_final$nolbu_store_floor, "후보지 층수(층)", color="orange")
      
    })
    
    output$sfm_output_floor_bldg <- renderValueBox({
      
      valueBox(input_data_final$nolbu_bldg_floor, "건물 총 층수(층)", color="orange")
      
    })
    
    output$sfm_output_opertime <- renderValueBox({
      
      valueBox(input_data_final$nolbu_store_oper_time, "일 평균 운영시간(시간)", color="orange")
      
    })
    
    output$sfm_output_operday <- renderValueBox({
      
      valueBox(input_data_final$nolbu_store_oper_day, "월 평균 운영일수(일)", color="orange")
      
    })
    
    output$sfm_output_parking <- renderValueBox({
      
      valueBox(ifelse(input_data_final$nolbu_bldg_parking==1, "가능", "불가능"), "주차가능 여부", color="olive")
      
    })
    
    output$sfm_output_emp_full <- renderValueBox({
      
      valueBox(input_data_final$nolbu_store_emp_full, "풀타임 직원 수(명)", color="olive")
      
    })
    
    output$sfm_output_emp_part <- renderValueBox({
      
      valueBox(input_data_final$nolbu_store_emp_part, "파트타임 직원 수 (명)", color="olive")
      
    })
    
    output$sfm_output_rentcost <- renderValueBox({
      
      valueBox(formatC(input_data_final$nolbu_rent, big.mark = ","), "예상 월 임대료(만원)", color="olive")
      
    })
    
    output$sfm_output_del_tpl <- renderValueBox({
      
      valueBox(ifelse(input_data_final$nolbu_delivery_rider_tpl==1, "이용", "미이용"), "배달대행 이용여부", color="purple")
      
    })
    
    output$sfm_output_del_store <- renderValueBox({
      
      valueBox(ifelse(input_data_final$nolbu_delivery_rider_store==1, "직접배달", "직접배달 안함"), "직접배달 여부", color="purple")
      
    })
    
    output$sfm_pred_plot <- renderPlotly({
      
      sales_df <-
        data.frame(label = c("후보지 예상 매출액(만원)", "상권 내 동종업체 매출액(만원)"),
                   value = c(input_data_final$nolbu_sales_total/10, input_data_final$sgbiz_sales_amt_avg)) %>%
        mutate(value_str = paste(formatC(round(value, digits = 1), big.mark = ","), "만원"))
      
      ggplot(sales_df, aes(x = label, y = value, fill = label)) +
        geom_bar(stat = "identity") +
        ggtitle("후보지 및 상권 내 동종업체 월 평균 예상 매출액 비교") +
        geom_text(aes(label = value_str), stat = "identity", vjust = 2, size = 5) +
        theme(legend.position = "none",
              plot.title = element_text(size = 15, colour = "black", face = "bold"),
              panel.background = element_rect(fill="white"),
              panel.grid.major.y = element_line(colour = "grey", linetype="dashed"),
              axis.text.x = element_text(size = 12, colour = "black", angle =),
              axis.text.y = element_blank(),
              axis.ticks.y = element_blank(),
              axis.title.x = element_blank(),
              axis.title.y = element_blank(),
        )
      
    })
    
    output$sfm_pred_text1 <- renderText({
      
      diff <- input_data_final$nolbu_sales_total/10 - input_data_final$sgbiz_sales_amt_avg
      
      paste0("- 목표 후보지의 예상 매출액은 ",
             formatC(input_data_final$nolbu_sales_total/10, big.mark = ","),
             "만원 입니다. ")
      
    })
    
    output$sfm_pred_text2 <- renderText({
      
      diff <- input_data_final$nolbu_sales_total/10 - input_data_final$sgbiz_sales_amt_avg
      
      paste0("- 목표 후보지의 예상 매출액은 상권 평균 대비 ",
             formatC(abs(diff), big.mark = ","),
             "만원", ifelse(diff > 0, " 높습니다.", " 낮습니다."))
      
    })
    
    output$sfm_sgbiz_store_trend <- renderPlotly({
      
      year_mon_labels <- format(c(ym(input_data_final$store_last_month) - months(12:1), ym(input_data_final$store_last_month)), "%Y년 %m월")
      store_n_trend <-
        data.frame(label = 1:13,
                   label_str = year_mon_labels,
                   value = input_data_final[,paste0("sgbiz_store_n_", 1:13)] %>% as.numeric) %>%
        mutate(value_str = paste(formatC(value, big.mark = ","), "개"))
      
      ggplot(store_n_trend, aes(x = label, y = value)) +
        geom_line() +
        geom_point() +
        xlab(" ") +
        ylab(" ") +
        ylim(0, max(store_n_trend$value)*1.2) +
        scale_x_continuous(breaks = 1:13, labels = store_n_trend$label_str) +
        geom_text(size = 5, aes(label = value_str), position = position_nudge(y = 1), stat = "identity") +
        theme(legend.position = "none",
              panel.background = element_rect(fill="white"),
              panel.grid.major.y = element_line(colour = "grey", linetype="dashed"),
              axis.text.x = element_text(size = 13, colour = "black", angle = 45, vjust = 0.5),
              axis.text.y = element_blank(),
              axis.ticks.y = element_blank(),
              axis.title.x = element_blank(),
              axis.title.y = element_blank()
        )
      
    })
    
    output$sfm_sgbiz_pop <- renderPlotly({
      
      pop_df <-
        data.frame(label = c("일 평균 유동인구(명)", "목표반경 내 주거인구(명)",
                             "목표반경 내 직장인구(명)", "목표반경 내 가구 수(가구)"),
                   value = c(input_data_final$sgbiz_pop_fl_13, input_data_final$sgbiz_pop_res_3,
                             input_data_final$sgbiz_pop_work_3, input_data_final$sgbiz_region_household_n)) %>%
        mutate(value_str = c(paste(formatC(c(input_data_final$sgbiz_pop_fl_13,
                                             input_data_final$sgbiz_pop_res_3,
                                             input_data_final$sgbiz_pop_work_3), digit = 0, format = "f", big.mark = ","), "명"),
                             paste(formatC(input_data_final$sgbiz_region_household_n, digit = 0, format = "f", big.mark = ","), "가구")))
      
      ggplot(pop_df, aes(x = label, y = value, fill = label)) +
        geom_bar(stat = "identity") +
        ggtitle("목표반경 내 가구 수 (가구) 및 주거인구/직장인구/유동인구 수(명)") +
        geom_text(aes(size = 5, label = value_str), stat = "identity", vjust = 2) +
        theme(legend.position = "none",
              panel.background = element_rect(fill="white"),
              plot.title = element_text(size = 13, colour = "black", face = "bold"),
              panel.grid.major.y = element_line(colour = "grey", linetype="dashed"),
              axis.text.x = element_text(size = 13, colour = "black", face = "bold"),
              axis.text.y = element_blank(),
              axis.ticks.y = element_blank(),
              axis.title.x = element_blank(),
              axis.title.y = element_blank()
        )
      
    })
    
    output$sfm_sgbiz_fl_sex_ratio <- renderPlotly({
      
      pop_sex_ratio <-
        data.frame(label = c("남성", "여성"),
                   value = c(round(input_data_final$sgbiz_pop_fl_male/(input_data_final$sgbiz_pop_fl_male + input_data_final$sgbiz_pop_fl_female)*100, digits = 1),
                             round(input_data_final$sgbiz_pop_fl_female/(input_data_final$sgbiz_pop_fl_male + input_data_final$sgbiz_pop_fl_female)*100, digits = 1))) %>%
        mutate(value_str = paste0(label, "\n(", value, " %)"))
      
      plot_ly(pop_sex_ratio, labels = ~label, values = ~value, type = 'pie',
              textposition = 'inside',
              textinfo = 'label+percent',
              hoverinfo = 'text',
              text = ~value_str,
              insidetextfont = list(size = 20)) %>%
        layout(title = list(text = '성별 유동인구 비중(%)',
                            font = list(size = 20, bold = TRUE)),
               showlegend = F,
               xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
               yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
               margin = list(t = 50))
      
    })
    
    output$sfm_sgbiz_fl_age_ratio <- renderPlotly({
      
      total_fl <- sum(input_data_final %>% select(sgbiz_pop_fl_age_1:sgbiz_pop_fl_age_6))
      
      pop_age_ratio <-
        data.frame(label = c("10대", "20대", "30대", "40대", "50대", "60대 이상"),
                   value = c(round(input_data_final$sgbiz_pop_fl_age_1/total_fl*100, digits = 1),
                             round(input_data_final$sgbiz_pop_fl_age_2/total_fl*100, digits = 1),
                             round(input_data_final$sgbiz_pop_fl_age_3/total_fl*100, digits = 1),
                             round(input_data_final$sgbiz_pop_fl_age_4/total_fl*100, digits = 1),
                             round(input_data_final$sgbiz_pop_fl_age_5/total_fl*100, digits = 1),
                             round(input_data_final$sgbiz_pop_fl_age_6/total_fl*100, digits = 1))
        ) %>%
        mutate(value_str = paste0(label, "\n(", value, " %)"))
      
      plot_ly(pop_age_ratio, labels = ~label, values = ~value, type = 'pie',
              textposition = 'inside',
              textinfo = 'label+percent',
              hoverinfo = 'text',
              text = ~value_str,
              insidetextfont = list(size = 20)) %>%
        layout(title = list(text = "연령대별 유동인구 비중(%)",
                            font = list(size = 20, bold = TRUE)),
               showlegend = F,
               xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
               yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
               margin = list(t = 50))
      
    })
    
    output$sfm_sgbiz_fl_day <- renderPlotly({
      
      pop_fl_day <-
        data.frame(label = c("월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"),
                   value = c(input_data_final$sgbiz_pop_fl_day_1, input_data_final$sgbiz_pop_fl_day_2,
                             input_data_final$sgbiz_pop_fl_day_3, input_data_final$sgbiz_pop_fl_day_4,
                             input_data_final$sgbiz_pop_fl_day_5, input_data_final$sgbiz_pop_fl_day_6,
                             input_data_final$sgbiz_pop_fl_day_7)
        ) %>%
        mutate(value_str = paste(formatC(value, format = "f", digit = 0, big.mark = ","), "명"))
      
      ggplot(pop_fl_day, aes(x = label, y = value, fill = label)) +
        geom_bar(stat = "identity") +
        geom_text(aes(label = value_str), stat = "identity", vjust = 2, size=5) +
        theme(legend.position = "none",
              panel.background = element_rect(fill="white"),
              panel.grid.major.y = element_line(colour = "grey", linetype="dashed"),
              plot.title = element_blank(),
              axis.text.x = element_text(size = 13, colour = "black"),
              axis.text.y = element_blank(),
              axis.ticks.y = element_blank(),
              axis.title.x = element_blank(),
              axis.title.y = element_blank()
        )
      
    })
    
    output$sfm_sgbiz_fl_time <- renderPlotly({
      
      pop_fl_time <-
        data.frame(label = c("00~06시", "06~11시", "11~14시", "14~17시", "17~21시", "21~24시"),
                   value = c(input_data_final$sgbiz_pop_fl_time_1,
                             input_data_final$sgbiz_pop_fl_time_2,
                             input_data_final$sgbiz_pop_fl_time_3,
                             input_data_final$sgbiz_pop_fl_time_4,
                             input_data_final$sgbiz_pop_fl_time_5,
                             input_data_final$sgbiz_pop_fl_time_6)
        ) %>%
        mutate(value_str = paste(formatC(value, format = "f", digit = 0, big.mark = ","), "명"))
      
      ggplot(pop_fl_time, aes(x = label, y = value, fill = label)) +
        geom_bar(stat = "identity") +
        geom_text(aes(label = value_str), stat = "identity", vjust = 2, size=5) +
        theme(legend.position = "none",
              panel.background = element_rect(fill="white"),
              panel.grid.major.y = element_line(colour = "grey", linetype="dashed"),
              plot.title = element_blank(),
              axis.text.x = element_text(size = 13, colour = "black", face = "bold"),
              axis.text.y = element_blank(),
              axis.ticks.y = element_blank(),
              axis.title.x = element_blank(),
              axis.title.y = element_blank()
        )
      
    })
    
    output$sfm_sgbiz_incomeexp <- renderPlotly({
      
      pop_income_exp <-
        data.frame(label = c("남성", "여성", "남성", "여성", "남성", "여성", "남성", "여성"),
                   category = rep(c("주거인구 - 소득", "주거인구 - 소비", "직장인구 - 소득", "직장인구 - 소비"), each = 2),
                   value = c(input_data_final$sgbiz_income_res_male,
                             input_data_final$sgbiz_income_res_female,
                             input_data_final$sgbiz_exp_res_male,
                             input_data_final$sgbiz_exp_res_female,
                             input_data_final$sgbiz_income_work_male,
                             input_data_final$sgbiz_income_work_female,
                             input_data_final$sgbiz_exp_work_male,
                             input_data_final$sgbiz_exp_work_female)
        ) %>%
        mutate(value_str = paste(formatC(value, big.mark = ","), "백만원"))
      
      ggplot(pop_income_exp, aes(x = label, y = value, fill = label)) +
        facet_wrap(~category, nrow = 1) +
        geom_bar(stat = "identity") +
        xlab(" ") +
        geom_text(aes(label = value_str), stat = "identity", vjust = 2, size=5) +
        theme(legend.position = "none",
              panel.background = element_rect(fill="white"),
              panel.grid.major.y = element_line(colour = "grey", linetype="dashed"),
              plot.title = element_blank(),
              axis.text.x = element_text(size = 13, colour = "black", face = "bold"),
              axis.text.y = element_blank(),
              strip.text = element_text(size = 13, colour = "black", face = "bold"),
              axis.ticks.y = element_blank(),
              axis.title.x = element_blank(),
              axis.title.y = element_blank()
        )
      
    })
    
    output$sfm_sgbiz_fac_table1 <- renderTable({
      
      data.frame(`시설구분` = c("공공기관", "금융기관", "의료/복지시설", "학교", "대형유통시설"),
                 `개수`= c(input_data_final$sgbiz_region_facility_1,
                         input_data_final$sgbiz_region_facility_2,
                         input_data_final$sgbiz_region_facility_3,
                         input_data_final$sgbiz_region_facility_4,
                         input_data_final$sgbiz_region_facility_5))
      
    }, width = "100%")
    
    output$sfm_sgbiz_fac_table2 <- renderTable({
      
      data.frame(`시설구분` = c("문화시설", "숙박시설", "지하철역", "버스정류장"),
                 `개수` = c(input_data_final$sgbiz_region_facility_6,
                          input_data_final$sgbiz_region_facility_7,
                          input_data_final$sgbiz_subway_n,
                          input_data_final$sgbiz_bus_n))
      
    }, width = "100%")
    
    
    output$sfm_result_csv <- downloadHandler(
      filename = function() {
        
        paste("nolboo_sfm_data_", input_data_final$nolbu_name, "_",
              format(Sys.time(), "%Y-%m-%d %H:%M:%S"), ".csv", sep="")
      },
      content = function(file) {
        write.csv.utf8.BOM(input_data_final, file)
      }
    )
    
    
    output$sfm_result_report <- downloadHandler(
      
      filename <- function() {
        
        paste('nolboo_sfm_report_', input_data_final$nolbu_name, "_",
              format(Sys.time(), "%Y-%m-%d %H:%M:%S"), '.html', sep='')
      },
      
      content <- function(file) {
        
        src <- normalizePath('sources/AutoReporting.Rmd')
        rmarkdown::render(src,
                          output_file = file,
                          params = list(data = input_data_final),
                          envir = new.env(parent = globalenv()))
      }
    )
    
  })
  
}  

# --- RUN APP --- # 
shinyApp(ui = ui, server = server)
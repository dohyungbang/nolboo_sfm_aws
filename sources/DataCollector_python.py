import time
import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options

chrome_options = Options()
chrome_options.add_experimental_option("detach", True)
chrome_options.add_argument("--disable-gpu")  # Recommended for compatibility

def ExtractData(address, radius):
    
    driver = webdriver.Chrome(options = chrome_options)
    driver.get("https://sso.sbiz.or.kr/sso/subLoginAction.do?joinSite=SG&reqSite=https://sg.sbiz.or.kr/godo/index.sg#")
    time.sleep(3)
    try:
        # SEND ID & PW 
        driver.find_element("css selector", '#id').click()
        driver.find_element("css selector", '#id').clear()
        driver.find_element("css selector", '#id').send_keys("bdh718")
        time.sleep(3)
        driver.find_element("css selector", '#pass').click()
        driver.find_element("css selector", '#pass').clear()
        driver.find_element("css selector", '#pass').send_keys("@@qkd90718")
        time.sleep(3)

        # LOGIN
        driver.find_element("css selector", 'body > div > div.l_content > form > div > input').click()
        time.sleep(3)
        
        driver.get("https://sg.sbiz.or.kr/godo/analysis.sg")
        driver.find_element("css selector","#container > div:nth-child(17) > div > div.head.close-option > div > label:nth-child(4)").click()
        time.sleep(3)
        
        # Send target Address
        driver.find_element("css selector", "#searchAddress").clear()
        driver.find_element("css selector", "#searchAddress").send_keys(address)
        driver.find_element("css selector", '#layerPopAddressMove').click()
        try:
          driver.find_element("css selector", "#container > div:nth-child(1) > div:nth-child(3) > div.foot > a:nth-child(2)").click()
        except:
            driver.find_element("css selector", "#container > div:nth-child(11) > div:nth-child(3) > div.foot > a:nth-child(2)").click()
        time.sleep(5)

        # Select Upjong
        driver.find_element("css selector", "#upjong > ul > li:nth-child(2) > label").click()
        time.sleep(3)
        driver.find_element("css selector", "#container > div:nth-child(17) > div > div.midd > div.midd > div.searchview.scrollbarView.z-index0 > div > ul > li:nth-child(2) > div > ul > li:nth-child(3) > label > span").click()
        time.sleep(3)
        driver.find_element("css selector", "#checkTypeConfirm").click()
        time.sleep(5)

        # Select Radius
        driver.find_element("css selector", "#map > div:nth-child(1) > div > div:nth-child(6) > div:nth-child(2) > div > ul > li.child > label > svg").click()
        time.sleep(5)
        driver.find_element("css selector", "#map > div:nth-child(1) > div > div:nth-child(6) > div:nth-child(2) > div > ul > li.child > div > ul > li:nth-child(2) > label").click()
        time.sleep(5)

        try:
          driver.find_element("css selector", "#auto_circle > div > div.midd > ul > li:nth-child(8)").click()
          time.sleep(5)
          driver.find_element("css selector", "#auto_circle > div > div.foot > a:nth-child(2)").click()
          time.sleep(5)
          driver.find_element("css selector", "#auto_circle > div > div.midd > div > input[type=text]").clear()
          driver.find_element("css selector", "#auto_circle > div > div.midd > div > input[type=text]").send_keys(radius/10)
          time.sleep(5)
          driver.find_element("css selector", "#auto_circle > div > div.foot > a:nth-child(2)").click()
          time.sleep(5)
            
        except:
          driver.find_element("css selector", "#auto_circle > div > div.midd > div > input[type=text]").clear()
          driver.find_element("css selector", "#auto_circle > div > div.midd > div > input[type=text]").send_keys(radius/10)
          time.sleep(5)
          driver.find_element("css selector", "#auto_circle > div > div.foot > a:nth-child(2)").click()
          time.sleep(5)
            
        # Click Analysis
        driver.find_element("css selector", "#map > div:nth-child(1) > div > div:nth-child(6) > div:nth-child(3) > img").click()
        time.sleep(30)

        driver.find_element("css selector", "#menu2").click()
        time.sleep(1)

        ### store Last month
        store_last_month = driver.find_element(By.XPATH, "//*[@id='page2']/div[3]/table/thead/tr/th[15]").text

        ### No. of stores
        store_n = driver.find_element(By.XPATH, "//*[@id='page2']/div[3]/table/tbody/tr[1]").text.split("\n")[1:]

        ## 매출분석
        driver.find_element("css selector", "#menu3").click()
        time.sleep(1)

        ### sales Last month
        sales_last_month = driver.find_element(By.XPATH, "//*[@id='page3']/div[3]/table/thead/tr/th[15]").text

        ### Sales
        sales_amt = driver.find_element(By.XPATH, "//*[@id='page3']/div[3]/table/tbody/tr[1]").text.split("\n")[1:]
        sales_n = driver.find_element(By.XPATH, "//*[@id='page3']/div[5]/table/tbody/tr[1]").text.split("\n")[1:]

        ### 요일별 Sales
        sales_day_amt = driver.find_element(By.XPATH, "//*[@id='page3']/div[7]/table/tbody/tr[1]").text.split(" ")[4:]
        sales_day_n_ratio = driver.find_element(By.XPATH, "//*[@id='page3']/div[7]/table/tbody/tr[3]").text.split(" ")[3:]

        ### 시간대별 Sales
        sales_time_amt = driver.find_element(By.XPATH, "//*[@id='page3']/div[8]/table/tbody/tr[1]").text.split(" ")[2:]
        sales_time_n_ratio = driver.find_element(By.XPATH, "//*[@id='page3']/div[8]/table/tbody/tr[3]").text.split(" ")[1:]

        ### 성별/연령별 Sales
        sales_age_amt = driver.find_element(By.XPATH, "//*[@id='page3']/div[9]/table/tbody/tr[1]").text.split(" ")[2:]
        sales_age_n_ratio = driver.find_element(By.XPATH, "//*[@id='page3']/div[9]/table/tbody/tr[3]").text.split(" ")[1:]

        ## 인구분석
        driver.find_element("css selector", "#menu4").click()
        time.sleep(1)

        ### 유동인구
        pop_fl = driver.find_element(By.XPATH, "//*[@id='page4']/div[3]/table/tbody/tr[1]").text.split(" ")[2:]

        ### 성별/연령대별 유동인구
        pop_fl_sexage = driver.find_element(By.XPATH, "//*[@id='page4']/div[4]/table/tbody/tr[1]").text.split(" ")[3:]

        ### 요일별 유동인구
        pop_fl_day = driver.find_element(By.XPATH, "//*[@id='page4']/div[5]/table/tbody/tr[1]").text.split(" ")[4:]

        ### 시간대별 유동인구
        pop_fl_time = driver.find_element(By.XPATH, "//*[@id='page4']/div[6]/table/tbody/tr[1]").text.split(" ")[2:]

        ### 주거인구
        pop_res = driver.find_element(By.XPATH, "//*[@id='page4']/div[9]/table/tbody/tr[1]").text.split(" ")[1:]

        ### 성별/연령대별 주거인구
        pop_res_sexage = driver.find_element(By.XPATH, "//*[@id='page4']/div[10]/table/tbody/tr[1]").text.split(" ")[3:]

        ### 주거인구 소득/소비
        # driver.find_element(By.XPATH, "//*[@id='page4']/div[12]/table/tbody").text.replace(" ~ ", "~").replace("\n", " ").split(" ")

        ### 주거인구 성별 소득소비
        income_res_male = driver.find_element(By.XPATH, "//*[@id='page4']/div[13]/table/tbody/tr[1]").text.replace(" ~ ", "~").split(" ")[2]
        income_res_female = driver.find_element(By.XPATH, "//*[@id='page4']/div[13]/table/tbody/tr[2]").text.replace(" ~ ", "~").split(" ")[2]

        exp_res_male = driver.find_element(By.XPATH, "//*[@id='page4']/div[13]/table/tbody/tr[1]").text.replace(" ~ ", "~").split(" ")[4]
        exp_res_female = driver.find_element(By.XPATH, "//*[@id='page4']/div[13]/table/tbody/tr[2]").text.replace(" ~ ", "~").split(" ")[4]

        ### 주거인구 연령대별 소득소비
        income_res_age = []
        income_res_age.append(driver.find_element(By.XPATH, "//*[@id='page4']/div[14]/table/tbody/tr[1]").text.replace(" ~ ", "~").split(" ")[2])
        income_res_age.append(driver.find_element(By.XPATH, "//*[@id='page4']/div[14]/table/tbody/tr[2]").text.replace(" ~ ", "~").split(" ")[2])
        income_res_age.append(driver.find_element(By.XPATH, "//*[@id='page4']/div[14]/table/tbody/tr[3]").text.replace(" ~ ", "~").split(" ")[2])
        income_res_age.append(driver.find_element(By.XPATH, "//*[@id='page4']/div[14]/table/tbody/tr[4]").text.replace(" ~ ", "~").split(" ")[2])
        income_res_age.append(driver.find_element(By.XPATH, "//*[@id='page4']/div[14]/table/tbody/tr[5]").text.replace(" ~ ", "~").split(" ")[3])

        exp_res_age = []
        exp_res_age.append(driver.find_element(By.XPATH, "//*[@id='page4']/div[14]/table/tbody/tr[1]").text.replace(" ~ ", "~").split(" ")[4])
        exp_res_age.append(driver.find_element(By.XPATH, "//*[@id='page4']/div[14]/table/tbody/tr[2]").text.replace(" ~ ", "~").split(" ")[4])
        exp_res_age.append(driver.find_element(By.XPATH, "//*[@id='page4']/div[14]/table/tbody/tr[3]").text.replace(" ~ ", "~").split(" ")[4])
        exp_res_age.append(driver.find_element(By.XPATH, "//*[@id='page4']/div[14]/table/tbody/tr[4]").text.replace(" ~ ", "~").split(" ")[4])
        exp_res_age.append(driver.find_element(By.XPATH, "//*[@id='page4']/div[14]/table/tbody/tr[5]").text.replace(" ~ ", "~").split(" ")[5])

        ### 직장인구
        pop_work = driver.find_element(By.XPATH, "//*[@id='page4']/div[19]/table/tbody/tr[1]").text.split(" ")[1:]

        ### 성별/연령대별 직장인구
        pop_work_sexage = driver.find_element(By.XPATH, "//*[@id='page4']/div[20]/table/tbody/tr[1]").text.split(" ")[3:]

        ### 직장인구 성별 소득소비
        income_work_male = driver.find_element(By.XPATH, "//*[@id='page4']/div[23]/table/tbody/tr[1]").text.replace(" ~ ", "~").split(" ")[2]
        income_work_female = driver.find_element(By.XPATH, "//*[@id='page4']/div[23]/table/tbody/tr[2]").text.replace(" ~ ", "~").split(" ")[2]

        exp_work_male = driver.find_element(By.XPATH, "//*[@id='page4']/div[23]/table/tbody/tr[1]").text.replace(" ~ ", "~").split(" ")[4]
        exp_work_female = driver.find_element(By.XPATH, "//*[@id='page4']/div[23]/table/tbody/tr[2]").text.replace(" ~ ", "~").split(" ")[4]

        ### 직장인구 연령대별 소득소비
        income_work_age = []
        income_work_age.append(driver.find_element(By.XPATH, "//*[@id='page4']/div[24]/table/tbody/tr[1]").text.replace(" ~ ", "~").split(" ")[2])
        income_work_age.append(driver.find_element(By.XPATH, "//*[@id='page4']/div[24]/table/tbody/tr[2]").text.replace(" ~ ", "~").split(" ")[2])
        income_work_age.append(driver.find_element(By.XPATH, "//*[@id='page4']/div[24]/table/tbody/tr[3]").text.replace(" ~ ", "~").split(" ")[2])
        income_work_age.append(driver.find_element(By.XPATH, "//*[@id='page4']/div[24]/table/tbody/tr[4]").text.replace(" ~ ", "~").split(" ")[2])
        income_work_age.append(driver.find_element(By.XPATH, "//*[@id='page4']/div[24]/table/tbody/tr[5]").text.replace(" ~ ", "~").split(" ")[3])

        exp_work_age = []
        exp_work_age.append(driver.find_element(By.XPATH, "//*[@id='page4']/div[24]/table/tbody/tr[1]").text.replace(" ~ ", "~").split(" ")[4])
        exp_work_age.append(driver.find_element(By.XPATH, "//*[@id='page4']/div[24]/table/tbody/tr[2]").text.replace(" ~ ", "~").split(" ")[4])
        exp_work_age.append(driver.find_element(By.XPATH, "//*[@id='page4']/div[24]/table/tbody/tr[3]").text.replace(" ~ ", "~").split(" ")[4])
        exp_work_age.append(driver.find_element(By.XPATH, "//*[@id='page4']/div[24]/table/tbody/tr[4]").text.replace(" ~ ", "~").split(" ")[4])
        exp_work_age.append(driver.find_element(By.XPATH, "//*[@id='page4']/div[24]/table/tbody/tr[5]").text.replace(" ~ ", "~").split(" ")[5])

        ## 지역현황
        driver.find_element("css selector", "#menu5").click()
        time.sleep(1)

        ### 세대 수
        region_household_n = driver.find_element(By.XPATH, "//*[@id='page5']/div[3]/table/tbody/tr[1]").text.split(" ")[4]

        ### 주거지 수
        region_villa_n = driver.find_element(By.XPATH, "//*[@id='page5']/div[6]/table/tbody/tr[1]").text.split(" ")[3]

        region_aptdong_n = driver.find_element(By.XPATH, "//*[@id='page5']/div[7]/table/tbody/tr[1]").text.split(" ")[5]
        region_aptho_n = driver.find_element(By.XPATH, "//*[@id='page5']/div[7]/table/tbody/tr[1]").text.split(" ")[6]

        region_area_n = driver.find_element(By.XPATH, "//*[@id='page5']/div[9]/table/tbody/tr[1]").text.split(" ")[1:]

        ### 시설 현황

        region_facility = driver.find_element(By.XPATH, "//*[@id='page5']/div[12]/table/tbody/tr[1]").text.split(" ")[1:]
        region_school = driver.find_element(By.XPATH, "//*[@id='page5']/div[13]/table/tbody/tr[1]").text.split(" ")[1:]

        ### 지하철역/버스정류장
        try:
            region_subway_n = driver.find_element(By.XPATH, "//*[@id='page5']/div[17]/table/tbody/tr[1]").text.split(" ")[1]
            region_bus_n = driver.find_element(By.XPATH, "//*[@id='page5']/div[17]/table/tbody/tr[1]").text.split(" ")[2]
        except: 
            region_subway_n = driver.find_element(By.XPATH, "//*[@id='page5']/div[16]/table/tbody/tr[1]").text.split(" ")[1]
            region_bus_n = driver.find_element(By.XPATH, "//*[@id='page5']/div[16]/table/tbody/tr[1]").text.split(" ")[2]
            
        

        each_row = [address, radius, store_last_month, sales_last_month]
        each_row.extend(store_n)
        each_row.extend(sales_amt)
        each_row.extend(sales_n)
        each_row.extend(sales_day_amt)
        each_row.extend(sales_day_n_ratio)
        each_row.extend(sales_time_amt)
        each_row.extend(sales_time_n_ratio)
        each_row.extend(sales_age_amt)
        each_row.extend(sales_age_n_ratio)
        each_row.extend(pop_fl)
        each_row.extend(pop_fl_day)
        each_row.extend(pop_fl_sexage)
        each_row.extend(pop_fl_time)
        each_row.extend(pop_res)
        each_row.extend(pop_res_sexage)
        each_row.append(income_res_male)
        each_row.append(income_res_female)
        each_row.extend(income_res_age)
        each_row.append(exp_res_male)
        each_row.append(exp_res_female)
        each_row.extend(exp_res_age)
        each_row.extend(pop_work)
        each_row.extend(pop_work_sexage)
        each_row.append(income_work_male)
        each_row.append(income_work_female)
        each_row.extend(income_work_age)
        each_row.append(exp_work_male)
        each_row.append(exp_work_female)
        each_row.extend(exp_work_age)
        each_row.append(region_household_n)
        each_row.append(region_villa_n)
        each_row.append(region_aptdong_n)
        each_row.append(region_aptho_n)
        each_row.extend(region_area_n)
        each_row.extend(region_facility)
        each_row.extend(region_school)
        each_row.append(region_subway_n)
        each_row.append(region_bus_n)

        target_row = pd.DataFrame(each_row)
        
        driver.close()
        return target_row

    except Exception as error:
        print("An error occurred:", error)
        driver.close()


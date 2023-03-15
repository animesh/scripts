import time
from selenium import webdriver
options = webdriver.ChromeOptions()
options.headless = True
driver = webdriver.Chrome("/home/animeshs/bin/chromedriver", options=options)
driver.get('https://bluetid-mntnu.bluegarden.net/Kindis/mobil/worktime/clockout');
driver.save_screenshot('screen.png')
time.sleep(5) 
import os
consumer_key = os.getenv('API_KEY')
consumer_secret = os.getenv('API_KEY_SECRET')
bearer_token = os.getenv('BEARER_TOKEN')
access_token = os.getenv('ACCESS_TOKEN')
access_token_secret = os.getenv('ACCESS_TOKEN_SECRET')
username = consumer_key#"uni-animeshs"
password = consumer_secret#"Passwrd123"
driver.find_element_by_id("username").send_keys(username)
driver.find_element_by_id("password").send_keys(password)
driver.find_element_by_name("Submit1").click()
driver.save_screenshot('screen2.png')
time.sleep(5) 
driver.find_element_by_xpath('//input[@type="submit"]').click()
driver.save_screenshot('screen2.png')
time.sleep(5) 
driver.quit()

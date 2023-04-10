#python pagesDown.py <link> start end
import sys
link = sys.argv[1]
start = sys.argv[2]
end = sys.argv[3]
import os
import time
import codecs
from selenium import webdriver
from selenium.webdriver.common.by import By
options = webdriver.ChromeOptions()
options.headless = True
driver = webdriver.Chrome("/home/animeshs/bin/chromedriver", options=options)
driver.maximize_window()
for pages in range(int(start),int(end)):
  print(pages)
  driver.get(link+str(pages));
  time.sleep(5)
  pageS = codecs.open("Page."+str(pages)+".html", "w", "utf-8")
  handS = driver.page_source
  pageS.write(handS)
#scheight = .1
#while scheight < 9.9:
#  driver.execute_script("window.scrollTo(0, document.body.scrollHeight/%s);" % scheight)
#  scheight += .01
#  S = lambda X: driver.execute_script('return document.body.parentNode.scroll'+X)
#  driver.set_window_size(1920,S('Width'))
#  driver.find_element(By.TAG_NAME, 'body').screenshot("Page."+str(pages)+str(scheight)+'.png')
#driver.save_screenshot('screen.png')
#driver.find_element_by_name("Submit1").click()
#driver.save_screenshot('screen2.png')
#time.sleep(5) 
driver.quit()
#tar cvzf pages.tgz Page.*.html

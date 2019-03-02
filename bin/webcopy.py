import os
from os.path import expanduser

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

from bs4 import BeautifulSoup

HOME_DIR = expanduser('~')

# https://sites.google.com/a/chromium.org/chromedriver/downloads
CHROME_DIRVER_PATH = os.path.join(HOME_DIR, 'Downloads', 'chromedriver')

# http://phantomjs.org/download.html
PHANTOMJS_DIRVER_PATH = os.path.join(HOME_DIR, 'Downloads', 'phantomjs-2.1.1-macosx', 'bin', 'phantomjs')

WIDTH = 1920
HEIGHT = 1080
IMPLICITLY_WAIT_SECONDS = 3

next_url = 'https://blog.naver.com/userid/000000000000'

if os.path.isfile(CHROME_DIRVER_PATH):
    driver = webdriver.Chrome(CHROME_DIRVER_PATH)
elif os.path.isfile(PHANTOMJS_DIRVER_PATH):
    driver = webdriver.PhantomJS(PHANTOMJS_DIRVER_PATH)
else:
    print('Not found drivers.')
    exit(1)

driver.set_window_size(WIDTH, HEIGHT)
driver.implicitly_wait(IMPLICITLY_WAIT_SECONDS)

driver.get(next_url)

#WebDriverWait(driver, 10).until(
#    EC.presence_of_element_located((By.ID, "postListBody"))
#)

main_frame = driver.find_element_by_id('mainFrame')
driver.switch_to.default_content()
driver.switch_to.frame(main_frame)

#html = driver.page_source
#result = driver.save_screenshot(save_image_path)

#soup = BeautifulSoup(html, 'html.parser')
#post = soup.find(id='postListBody')

last = 166
for i in range(0, last):
    post_title = driver.find_element_by_id('title_1').find_elements_by_tag_name('span')[0].text
    post_body = driver.find_element_by_id('postListBody').text

    bottom_body = driver.find_element_by_id('postBottomTitleListBody')
    next_items = bottom_body.find_elements_by_tag_name('tr')
    next_item_01 = next_items[0]
    next_item_02 = next_items[1]
    next_link = next_item_02.find_element_by_partial_link_text('find link text')
    next_url = next_link.get_attribute('href')

    print('Title: {}'.format(post_title))

    with open(post_title + '.txt', 'w') as f:
        f.write(post_body)

    print('[{}/{}] done, next: {}'.format(i, last, next_url))

    if i < last:
        driver.get(next_url)

print('Done.')


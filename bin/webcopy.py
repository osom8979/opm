import os
from os.path import expanduser

# pip install selenium
# pip install BeautifulSoup4

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

from bs4 import BeautifulSoup

HOME_DIR = expanduser('~')

# check the chrome version: chrome://settings/help
# and download driver: https://sites.google.com/a/chromium.org/chromedriver/downloads
CHROME_DIRVER_PATH = os.path.join(HOME_DIR, 'Downloads', 'chromedriver')

# http://phantomjs.org/download.html
PHANTOMJS_DIRVER_PATH = os.path.join(HOME_DIR, 'Downloads', 'phantomjs-2.1.1-macosx', 'bin', 'phantomjs')

WIDTH = 1920
HEIGHT = 1080
IMPLICITLY_WAIT_SECONDS = 3

# N
#FIRST_URL = 'https://blog.naver.com/userid/000000000000'
#SELECT_FRAME = True

# T
#url_base = 'https://userid.tistory.com/category/xxx/yyy.?page='
#FIRST_URL = url_base + str(url_index)
#SELECT_FRAME = False

# WordPress
#FIRST_URL = 'https://xxx.wordpress.com/yyy'
SELECT_FRAME = False

if os.path.isfile(CHROME_DIRVER_PATH):
    driver = webdriver.Chrome(CHROME_DIRVER_PATH)
elif os.path.isfile(PHANTOMJS_DIRVER_PATH):
    driver = webdriver.PhantomJS(PHANTOMJS_DIRVER_PATH)
else:
    print('Not found drivers.')
    exit(1)

driver.set_window_size(WIDTH, HEIGHT)
driver.implicitly_wait(IMPLICITLY_WAIT_SECONDS)
driver.get(FIRST_URL)

#WebDriverWait(driver, 10).until(
#    EC.presence_of_element_located((By.ID, "postListBody"))
#)

if SELECT_FRAME:
    main_frame = driver.find_element_by_id('mainFrame')
    driver.switch_to.default_content()
    driver.switch_to.frame(main_frame)

#html = driver.page_source
#result = driver.save_screenshot(save_image_path)

#soup = BeautifulSoup(html, 'html.parser')
#post = soup.find(id='postListBody')

"""
https://selenium-python.readthedocs.io/locating-elements.html
4. Locating Elements
Selenium provides the following methods to locate elements in a page:
* find_element_by_id
* find_element_by_name
* find_element_by_xpath
* find_element_by_link_text
* find_element_by_partial_link_text
* find_element_by_tag_name
* find_element_by_class_name
* find_element_by_css_selector
To find multiple elements (these methods will return a list):
* find_elements_by_name
* find_elements_by_xpath
* find_elements_by_link_text
* find_elements_by_partial_link_text
* find_elements_by_tag_name
* find_elements_by_class_name
* find_elements_by_css_selector
"""

def find_next_url_by_link_text(text):
    try:
        return driver.find_element_by_class_name('entry-content').find_elements_by_link_text(text)[-1].get_attribute('href')
    except:
        return ''

def find_next_url_by_link_text_list(text_list):
    temp = ''
    for text in text_list:
        if temp:
            return temp
        else:
            temp = find_next_url_by_link_text(text)
    return ''


#start = 0
#last = 370
start = 268
last = 500
next_url = FIRST_URL
loop_range = range(start, last)
loop_count = len(loop_range)
for i in loop_range:
    # N
    #post_title = driver.find_element_by_id('title_1').find_elements_by_tag_name('span')[0].text
    #post_body = driver.find_element_by_id('postListBody').text
    #bottom_body = driver.find_element_by_id('postBottomTitleListBody')
    #next_items = bottom_body.find_elements_by_tag_name('tr')
    #next_item_01 = next_items[0]
    #next_item_02 = next_items[1]
    #next_link = next_item_02.find_element_by_partial_link_text('find link text')
    #next_url = next_link.get_attribute('href')

    # T
    #post_title = driver.find_element_by_id('content-inner').find_element_by_class_name('head').text
    #post_body = driver.find_element_by_id('content-inner').find_element_by_class_name('article').text
    #url_index = url_index + 1
    #next_url = url_base + str(url_index)

    save_index_text = str(i).zfill(3)
    save_prefix = 'Tsuki ga Michibiku Isekai Douchuu {}'.format(save_index_text)
    save_filename = save_prefix + '.txt'
    post_title = driver.find_element_by_class_name('entry-header').text
    post_body = driver.find_element_by_class_name('entry-content').text

    print('[{}/{}] {}'.format(i, last, save_prefix))
    print(' - URL={}'.format(next_url))
    print(' - Filename={}'.format(save_filename))
    print(' - Title={}'.format(post_title))

    with open(save_filename, 'w') as f:
        f.write('URL: ' + next_url)
        f.write('TITLE: ' + post_title)
        f.write('====')
        f.write(post_body)

    next_url = find_next_url_by_link_text_list(['Next Chapter', 'Next Chapterr', 'Next chapter', 'Next chapterr'])
    print(' - Next URL: {}'.format(next_url))

    if next_url and i < last:
        print(' * Refresh.')
        driver.get(next_url)
    else:
        print(' * Break.')
        break

print('Done.')


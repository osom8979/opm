import os
from os.path import expanduser

# pip install selenium
# pip install BeautifulSoup4

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException

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
PREFIX_NAME = 'Title'

# N 01
#FIRST_URL = 'https://blog.naver.com/userid/000000000000'
#SELECT_FRAME = True

# T
#url_base = 'https://{userid}.tistory.com/category/xxx/yyy.?page='
#url_base = 'https://{userid}.tistory.com/{}?category=xxx'
#FIRST_URL = url_base.format(2)
#SELECT_FRAME = False

# WordPress
#FIRST_URL = 'https://xxx.wordpress.com/yyy'
#SELECT_FRAME = False

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

#def find_next_url_by_link_text(text):
#    try:
#        return driver.find_element_by_class_name('entry-content').find_elements_by_link_text(text)[-1].get_attribute('href')
#    except:
#        return ''
#
#def find_next_url_by_link_text_list(text_list):
#    temp = ''
#    for text in text_list:
#        if temp:
#            return temp
#        else:
#            temp = find_next_url_by_link_text(text)
#    return ''
#
#next_url = find_next_url_by_link_text_list(['Next Chapter', 'Next Chapterr', 'Next chapter', 'Next chapterr'])


start = 40
last = 41

next_url = FIRST_URL
loop_range = range(start, last)
loop_count = len(loop_range)
for i in loop_range:
    save_index_text = str(i).zfill(3)
    save_prefix = '{} {}'.format(PREFIX_NAME, save_index_text)
    save_filename = save_prefix + '.txt'

    ## --------------
    ## Find Contents.
    ## --------------

    post_title = ''
    post_body = ''
    try:
        # N 01
        #post_title = driver.find_element_by_id('title_1').find_elements_by_tag_name('span')[0].text
        #post_body = driver.find_element_by_id('postListBody').text
        #bottom_body = driver.find_element_by_id('postBottomTitleListBody')

        # N 02
        post_title = driver.find_element_by_tag_name('h3').text
        post_body = driver.find_element_by_id('viewTypeSelector').text

        # T
        #post_title = driver.find_element_by_id('content-inner').find_element_by_class_name('head').text
        #post_body = driver.find_element_by_id('content-inner').find_element_by_class_name('article').text
        #url_index = url_index + 1
        #next_url = url_base + str(url_index)

        # W
        #post_title = driver.find_element_by_class_name('link_title').text
        #post_body = driver.find_element_by_class_name('article_view').text
    except NoSuchElementException as e:
        print('Not post contents: ', e)
    except:
        print('Not post contents.')

    ## -----------
    ## Write File.
    ## -----------

    print('[{}/{}] {}'.format(i, last, save_prefix))
    print(' - URL={}'.format(next_url))
    print(' - Filename={}'.format(save_filename))
    print(' - Title={}'.format(post_title))

    with open(save_filename, 'w') as f:
        f.write('TITLE: ' + post_title + '\n')
        f.write('URL: ' + next_url + '\n')
        f.write('====================\n')
        f.write(post_body)

    ## ----------------
    ## Update Next URL.
    ## ----------------

    next_url = ''
    try:
        # N 01
        #next_items = bottom_body.find_elements_by_tag_name('tr')
        #next_item_01 = next_items[0]
        #next_item_02 = next_items[1]
        #next_link = next_item_02.find_element_by_partial_link_text('find link text')
        #next_url = next_link.get_attribute('href')

        # N 02
        elem1 = driver.find_element_by_id('_relatedCategoryPostListFlickingPage_0')
        elem2 = elem1.find_elements_by_class_name('item')[1]
        elem3 = elem2.find_element_by_tag_name('a')
        next_url = elem3.get_attribute('href')

        # W
        # next_url = url_base.format(i + 1)
    except:
        print('Not found next url.')
        break

    print(' - Next URL: {}'.format(next_url))

    if next_url and i < last:
        print(' * Refresh.')
        driver.get(next_url)
    else:
        print(' * Break.')
        break

print('Done.')


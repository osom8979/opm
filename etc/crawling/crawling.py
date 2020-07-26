# -*- coding: utf-8 -*-

import sys
import os
import argparse

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.common.exceptions import NoSuchElementException


HOME_DIR = os.path.expanduser('~')

# Chrome version:
# - chrome://settings/help
# - google-chrome --version
# Download driver:
# - https://sites.google.com/a/chromium.org/chromedriver/downloads
CHROME_DIRVER_PATH = os.path.join(HOME_DIR, 'Downloads', 'chromedriver')

DEFAULT_TITLE = 'page'
DEFAULT_WIDTH = 1920
DEFAULT_HEIGHT = 1080
IMPLICITLY_WAIT_SECONDS = 3
INFINITY_LAST = -1
LOGGING_PREFIX = '[crawling] '
LOGGING_SUFFIX = '\n'
AUTO_FLUSH = True


def print_out(message):
    sys.stdout.write(LOGGING_PREFIX + message + LOGGING_SUFFIX)
    if AUTO_FLUSH:
        sys.stdout.flush()


def print_error(message):
    sys.stderr.write(LOGGING_PREFIX + message + LOGGING_SUFFIX)
    if AUTO_FLUSH:
        sys.stderr.flush()


class WebCrawler:
    """
    https://selenium-python.readthedocs.io/locating-elements.html
    """

    def __init__(self,
                 first_url,
                 start_index=1,
                 last_index=INFINITY_LAST,
                 title=DEFAULT_TITLE,
                 driver_path=CHROME_DIRVER_PATH,
                 frame_id=None,
                 width=DEFAULT_WIDTH,
                 height=DEFAULT_HEIGHT,
                 wait=IMPLICITLY_WAIT_SECONDS,
                 skip_error=False,
                 verbose=False):
        self.first_url = first_url
        self.start_index = start_index
        self.last_index = last_index
        self.title = title
        self.driver_path = driver_path
        self.frame_id = frame_id
        self.width = width
        self.height = height
        self.wait = wait
        self.skip_error = skip_error
        self.verbose = verbose

        if not self.first_url:
            raise ValueError('Url is empty')

        if not os.path.isfile(self.driver_path):
            raise FileNotFoundError('Not found webdriver: ' + self.driver_path)

        self.driver = webdriver.Chrome(CHROME_DIRVER_PATH)

        if verbose:
            print_out(f'first_url: {self.first_url}')
            print_out(f'start_index: {self.start_index}')
            print_out(f'last_index: {self.last_index}')
            print_out(f'title: {self.title}')
            print_out(f'driver_path: {self.driver_path}')
            print_out(f'frame_id: {self.frame_id}')
            print_out(f'width: {self.width}')
            print_out(f'height: {self.height}')
            print_out(f'wait: {self.wait}')
            print_out(f'skip_error: {self.skip_error}')
            print_out(f'verbose: {self.verbose}')

    @staticmethod
    def find_element_by_id(elem, query):
        return elem.find_element_by_id(query)

    @staticmethod
    def find_element_by_name(elem, query):
        return elem.find_element_by_name(query)

    @staticmethod
    def find_element_by_xpath(elem, query):
        return elem.find_element_by_xpath(query)

    @staticmethod
    def find_element_by_link_text(elem, query):
        return elem.find_element_by_link_text(query)

    @staticmethod
    def find_element_by_partial_link_text(elem, query):
        return elem.find_element_by_partial_link_text(query)

    @staticmethod
    def find_element_by_tag_name(elem, query):
        return elem.find_element_by_tag_name(query)

    @staticmethod
    def find_element_by_class_name(elem, query):
        return elem.find_element_by_class_name(query)

    @staticmethod
    def find_element_by_css_selector(elem, query):
        return elem.find_element_by_css_selector(query)

    @staticmethod
    def find_elements_by_name(elem, query):
        return elem.find_elements_by_name(query)

    @staticmethod
    def find_elements_by_xpath(elem, query):
        return elem.find_elements_by_xpath(query)

    @staticmethod
    def find_elements_by_link_text(elem, query):
        return elem.find_elements_by_link_text(query)

    @staticmethod
    def find_elements_by_partial_link_text(elem, query):
        return elem.find_elements_by_partial_link_text(query)

    @staticmethod
    def find_elements_by_tag_name(elem, query):
        return elem.find_elements_by_tag_name(query)

    @staticmethod
    def find_elements_by_class_name(elem, query):
        return elem.find_elements_by_class_name(query)

    @staticmethod
    def find_elements_by_css_selector(elem, query):
        return elem.find_elements_by_css_selector(query)

    @staticmethod
    def get_attribute(elem, query):
        return elem.get_attribute(query)

    def _wait_until(self):
        from selenium.webdriver.support.ui import WebDriverWait
        from selenium.webdriver.support import expected_conditions as EC
        WebDriverWait(self.driver, 10).until(
            EC.presence_of_element_located((By.ID, "postListBody"))
        )

    def _select_frame(self, frame_id='mainFrame'):
        frame = self.driver.find_element_by_id(frame_id)
        self.driver.switch_to.default_content()
        self.driver.switch_to.frame(frame)
        return frame

    def _get_page_source(self):
        return self.driver.page_source

    def _screenshot(self, image_path):
        return driver.save_screenshot(image_path)

    def _get(self, url):
        self.driver.get(url)

    def find_title(self, index):
        raise NotImplementedError('Not implement find_title() method.')

    def find_body(self, index):
        raise NotImplementedError('Not implement find_body() method.')

    def get_next_url(self, index):
        raise NotImplementedError('Not implement get_next_url() method.')

    def get_content(self, url, index):
        self._get(url)
        return self.find_title(index), self.find_body(index)

    def write_content(self, path, url, title, body):
        with open(path, 'w') as f:
            f.write('====================\n')
            f.write('TITLE: ' + title + '\n')
            f.write('URL: ' + url + '\n')
            f.write('--------------------\n')
            f.write(body)
            f.write('\n')
            f.write('--------------------\n\n\n')

    def run_iterator(self, index, url):
        prefix = self.title + '-' + str(index).zfill(3)
        filename = prefix + '.txt'

        title, body = self.get_content(url, index)

        if self.verbose:
            print_out(f' - Filename: {filename}')
            print_out(f' - Title: {title}')

        if os.path.isfile(filename):
            raise FileExistsError('Exists file: ' + filename)

        self.write_content(filename, url, title, body)

    def run(self):
        self.driver.set_window_size(self.width, self.height)
        self.driver.implicitly_wait(self.wait)

        if self.frame_id:
            self._select_frame(self.frame_id)

        url = self.first_url
        index = self.start_index
        if self.last_index == INFINITY_LAST:
            size = INFINITY_LAST
        else:
            size = self.last_index - self.start_index + 1

        while index >= size:
            print_out(f'[{index}/{size}] {url}')

            try:
                self.run_iterator(index, url)
            except Exception as e:
                print_error(e)
                if not self.skip_error:
                    break

            url = self.get_next_url(index)
            index += 1


class NcodeCrawler(WebCrawler):

    def __init__(self,
                 ncode_id,
                 start_index=1,
                 last_index=INFINITY_LAST,
                 title=None,
                 verbose=False):
        self.ncode_id = ncode_id
        self.base_url = f'https://ncode.syosetu.com/{ncode_id}/'

        super().__init__(first_url=self.base_url+str(start_index),
                         start_index=start_index,
                         last_index=last_index,
                         title=title if title else ncode_id,
                         verbose=verbose)

    def find_title(self, index):
        return self.driver.find_element_by_class_name('novel_subtitle').text

    def find_body(self, index):
        return self.driver.find_element_by_id('novel_honbun').text

    def get_next_url(self, index):
        return self.base_url + str(index+1)


class NaverBlogPcType1Crawler(WebCrawler):

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def _find_title_01(self, index):
        return self.driver.find_element_by_id('title_1').find_elements_by_tag_name('span')[0].text

    def _find_title_02(self, index):
        return self.driver.find_element_by_class_name('se_title').text

    def _find_title_03(self, index):
        elem = self.driver.find_element_by_class_name('se-documentTitle')
        elem = elem.find_element_by_class_name('pcol1')
        return elem.text

    def find_title(self, index):
        return self._find_title_03(index)

    def find_body(self, index):
        return self.driver.find_element_by_id('postListBody').text

    def get_next_url(self, index):
        bottom_body = self.driver.find_element_by_id('postBottomTitleListBody')
        next_items = bottom_body.find_elements_by_tag_name('tr')

        prev_item = None
        current_item = None

        for item in next_items:
            current_item = item
            if item.get_attribute('class') == 'on':
                if prev_item:
                    return prev_item.find_element_by_tag_name('a').get_attribute('href')
                else:
                    raise EOFError('This is the last post.')
            else:
                prev_item = current_item

        raise KeyError("Not found 'on' class.")


# N 02
# post_title = driver.find_element_by_tag_name('h3').text
# post_body = driver.find_element_by_id('viewTypeSelector').text
#
# elem1 = driver.find_element_by_id('_relatedCategoryPostListFlickingPage_0')
# elem2 = elem1.find_elements_by_class_name('item')[1]
# elem3 = elem2.find_element_by_tag_name('a')
# next_url = elem3.get_attribute('href')

# T
#post_title = driver.find_element_by_id('content-inner').find_element_by_class_name('head').text
#post_body = driver.find_element_by_id('content-inner').find_element_by_class_name('article').text
#url_index = url_index + 1
#next_url = url_base + str(url_index)

# W
#post_title = driver.find_element_by_class_name('link_title').text
#post_body = driver.find_element_by_class_name('article_view').text


def main(args):
    NaverBlogPcType1Crawler(first_url=args.url,
                            start_index=int(args.start),
                            last_index=int(args.last),
                            title=str(args.title),
                            verbose=bool(args.verbose)).run()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Crawling APP')
    parser.add_argument('--url', '-u', help='Base URL')
    parser.add_argument('--start', '-s', type=int, default=1, help='Start index')
    parser.add_argument('--last', '-l', type=int, default=INFINITY_LAST, help='Last index')
    parser.add_argument('--title', '-t', default=DEFAULT_TITLE, help='Title prefix')
    parser.add_argument('--verbose', '-v', action='count')
    main(parser.parse_args())


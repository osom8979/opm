# -*- coding: utf-8 -*-

import sys

from argparse import ArgumentParser, Namespace
from base64 import b64decode
from dataclasses import dataclass
from io import StringIO
from re import compile as re_compile
from typing import List, Optional, Sequence
from urllib.parse import urlparse

from helium import kill_browser, start_chrome, start_firefox
from selenium.common import TimeoutException
from selenium.webdriver import ChromeOptions
from selenium.webdriver import FirefoxOptions
from selenium.webdriver.chrome.webdriver import WebDriver as ChromeWebDriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.print_page_options import PrintOptions
from selenium.webdriver.firefox.webdriver import WebDriver as FirefoxWebDriver
from selenium.webdriver.remote.webdriver import WebDriver

CM_CHROME = "chrome"
CM_CHROME_PDF = "chrome-pdf"
CM_FIREFOX_PDF = "firefox-pdf"
CRAWLING_METHODS: Sequence[str] = (CM_CHROME, CM_CHROME_PDF, CM_FIREFOX_PDF)


def start_firefox_driver(
    args: Namespace,
    options: Optional[FirefoxOptions] = None,
) -> FirefoxWebDriver:
    assert isinstance(args.uri, str)
    assert isinstance(args.headless, bool)
    assert isinstance(args.page_load_timeout, int)
    assert isinstance(args.implicitly_wait, int)

    driver = start_firefox(headless=args.headless, options=options)
    assert isinstance(driver, FirefoxWebDriver)
    driver.set_page_load_timeout(args.page_load_timeout)
    driver.implicitly_wait(args.implicitly_wait)

    try:
        driver.get(args.uri)
    except TimeoutException:
        pass

    return driver


def start_chrome_driver(
    args: Namespace,
    options: Optional[ChromeOptions] = None,
) -> ChromeWebDriver:
    assert isinstance(args.uri, str)
    assert isinstance(args.headless, bool)
    assert isinstance(args.page_load_timeout, int)
    assert isinstance(args.implicitly_wait, int)

    driver = start_chrome(headless=args.headless, options=options)
    assert isinstance(driver, ChromeWebDriver)
    driver.set_page_load_timeout(args.page_load_timeout)
    driver.implicitly_wait(args.implicitly_wait)

    try:
        driver.get(args.uri)
    except TimeoutException:
        pass

    return driver


def crawling_firefox_pdf(args: Namespace) -> None:
    options = FirefoxOptions()
    options.add_argument("--start-maximized")
    options.set_preference("print.always_print_silent", True)
    options.set_preference("print.printer_Mozilla_Save_to_PDF.print_to_file", True)
    options.set_preference("print_printer", "Mozilla Save to PDF")
    driver = start_firefox_driver(args, options)
    try:
        driver.execute_script("window.print();")
    finally:
        driver.quit()


def crawling_chrome_pdf(args: Namespace) -> None:
    driver = start_chrome_driver(args)
    try:
        options = PrintOptions()
        content = driver.print_page(options)
        buffer = b64decode(content)
        with open(f"{driver.title}.pdf", "wb") as f:
            f.write(buffer)
    finally:
        driver.quit()


@dataclass
class ResponseContent:
    url: str
    title: str
    body: str

    @property
    def content(self) -> str:
        buffer = StringIO()
        buffer.write(self.url)
        buffer.write("\n" + self.title)
        buffer.write("\n" + "=" * 80)
        buffer.write("\n\n")
        buffer.write("\n" + self.body)
        return buffer.getvalue()

    @property
    def filename(self) -> str:
        return re_compile(r"[/\\:*?\"<>|]").sub("-", self.title)

    def print_content(self) -> None:
        print(self.content)

    def save_as_title_txt(self) -> None:
        with open(self.filename + ".txt", "w") as f:
            f.write(self.content)

    def run(self, args: Namespace) -> None:
        assert isinstance(args.use_title_filename, bool)
        if args.use_title_filename:
            self.save_as_title_txt()
        else:
            self.print_content()


def print_fandom_com_wiki_image_gallery_url(driver: WebDriver) -> None:
    css_path = "#LightboxModal > div > div > div.media > img"
    while True:
        html = driver.find_element(By.TAG_NAME, "html")
        src = driver.find_element(By.CSS_SELECTOR, css_path).get_attribute("src")
        print(src)
        html.send_keys(Keys.ARROW_RIGHT)


def retrieve_naver_com_blog(driver: WebDriver):
    frame_css_path = "#mainFrame"
    main_frame = driver.find_element(By.CSS_SELECTOR, frame_css_path)
    driver.switch_to.frame(main_frame)

    body_css_path = "#postListBody"
    body = driver.find_element(By.CSS_SELECTOR, body_css_path).text

    return ResponseContent(url=driver.current_url, title=driver.title, body=body)


def retrieve_dcinside_com_board(driver: WebDriver):
    css_path = "#container > section > article:nth-child(3) > div.view_content_wrap"
    body = driver.find_element(By.CSS_SELECTOR, css_path).text
    return ResponseContent(url=driver.current_url, title=driver.title, body=body)


def retrieve_ncode_syosetu_com_novel(driver: WebDriver):
    css_path = "#novel_contents"
    body = driver.find_element(By.CSS_SELECTOR, css_path).text
    return ResponseContent(url=driver.current_url, title=driver.title, body=body)


def crawling_chrome(args: Namespace) -> None:
    assert isinstance(args.uri, str)
    url = urlparse(args.uri)

    driver = start_chrome_driver(args)
    try:
        if url.hostname.endswith(".fandom.com"):
            if url.path.startswith("/wiki/") and url.query.index("&file="):
                print_fandom_com_wiki_image_gallery_url(driver)
        elif url.hostname == "blog.naver.com":
            retrieve_naver_com_blog(driver).run(args)
        elif url.hostname == "gall.dcinside.com":
            if url.path.index("/board/view"):
                retrieve_dcinside_com_board(driver).run(args)
        elif url.hostname == "ncode.syosetu.com":
            retrieve_ncode_syosetu_com_novel(driver).run(args)

        # TODO: insert your crawling codes

        raise NotImplementedError
    finally:
        driver.quit()


def get_default_arguments(
    cmdline: Optional[List[str]] = None,
    namespace: Optional[Namespace] = None,
) -> Namespace:
    parser = ArgumentParser(prog="opy-helium-crawling")
    parser.add_argument("--headless", action="store_true")
    parser.add_argument("--method", "-m", choices=CRAWLING_METHODS, default=CM_CHROME)
    parser.add_argument("--page-load-timeout", metavar="{sec}", type=int, default=8)
    parser.add_argument("--implicitly-wait", metavar="{sec}", type=int, default=8)
    parser.add_argument("--use-title-filename", action="store_true")
    parser.add_argument("uri")
    return parser.parse_known_args(cmdline, namespace)[0]


def main() -> None:
    args = get_default_arguments()
    assert isinstance(args.method, str)

    try:
        if args.method == CM_CHROME:
            crawling_chrome(args)
        elif args.method == CM_CHROME_PDF:
            crawling_chrome_pdf(args)
        elif args.method == CM_FIREFOX_PDF:
            crawling_firefox_pdf(args)
        else:
            assert False, "Inaccessible section"
    except BaseException as e:
        print(e, file=sys.stderr)
    finally:
        kill_browser()


if __name__ == "__main__":
    main()

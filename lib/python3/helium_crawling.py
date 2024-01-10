# -*- coding: utf-8 -*-

import sys

from argparse import ArgumentParser, Namespace
from base64 import b64decode
from typing import List, Optional, Sequence

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
    driver.execute_script("window.print();")


def crawling_chrome_pdf(args: Namespace) -> None:
    driver = start_chrome_driver(args)
    options = PrintOptions()
    content = driver.print_page(options)
    buffer = b64decode(content)
    with open(f"{driver.title}.pdf", "wb") as f:
        f.write(buffer)


def _print_img_src(driver: WebDriver) -> None:
    html = driver.find_element(By.TAG_NAME, "html")
    css_path = "#LightboxModal > div > div > div.media > img"
    while True:
        print(driver.find_element(By.CSS_SELECTOR, css_path).get_attribute("src"))
        html.send_keys(Keys.ARROW_RIGHT)


def crawling_chrome(args: Namespace) -> None:
    driver = start_chrome_driver(args)

    # TODO: insert your crawling codes

    _print_img_src(driver)


def get_default_arguments(
    cmdline: Optional[List[str]] = None,
    namespace: Optional[Namespace] = None,
) -> Namespace:
    parser = ArgumentParser(prog="opy-helium-crawling")
    parser.add_argument("--headless", action="store_true")
    parser.add_argument("--method", "-m", choices=CRAWLING_METHODS, default=CM_CHROME)
    parser.add_argument("--page-load-timeout", metavar="{sec}", type=int, default=8)
    parser.add_argument("--implicitly-wait", metavar="{sec}", type=int, default=8)
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

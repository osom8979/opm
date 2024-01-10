# -*- coding: utf-8 -*-

import sys

from base64 import b64decode
from argparse import ArgumentParser, Namespace
from typing import List, Optional, Sequence

from helium import kill_browser, start_chrome, start_firefox
from selenium.webdriver import FirefoxOptions
from selenium.webdriver.chrome.webdriver import WebDriver as ChromeWebDriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.print_page_options import PrintOptions
from selenium.webdriver.firefox.webdriver import WebDriver as FirefoxWebDriver
from selenium.webdriver.remote.webelement import WebElement

CM_CHROME = "chrome"
CM_CHROME_PDF = "chrome-pdf"
CM_FIREFOX_PDF = "firefox-pdf"
CRAWLING_METHODS: Sequence[str] = (CM_CHROME, CM_CHROME_PDF, CM_FIREFOX_PDF)


def crawling_firefox_pdf(args: Namespace) -> None:
    assert isinstance(args.uri, str)
    assert isinstance(args.headless, bool)

    options = FirefoxOptions()
    options.add_argument("--start-maximized")
    options.set_preference("print.always_print_silent", True)
    options.set_preference("print.printer_Mozilla_Save_to_PDF.print_to_file", True)
    options.set_preference("print_printer", "Mozilla Save to PDF")

    driver = start_firefox(args.uri, headless=args.headless, options=options)
    assert isinstance(driver, FirefoxWebDriver)

    driver.execute_script("window.print();")


def crawling_chrome_pdf(args: Namespace) -> None:
    assert isinstance(args.uri, str)
    assert isinstance(args.headless, bool)

    driver = start_chrome(args.uri, headless=args.headless)
    assert isinstance(driver, ChromeWebDriver)

    options = PrintOptions()
    content = driver.print_page(options)
    buffer = b64decode(content)
    with open(f"{driver.title}.pdf", "wb") as f:
        f.write(buffer)


def crawling_chrome(args: Namespace) -> None:
    assert isinstance(args.uri, str)
    assert isinstance(args.headless, bool)

    driver = start_chrome(args.uri, headless=args.headless)
    assert isinstance(driver, ChromeWebDriver)

    html = driver.find_element(By.TAG_NAME, "html")
    head = html.find_element(By.TAG_NAME, "head")
    body = html.find_element(By.TAG_NAME, "body")
    assert isinstance(html, WebElement)
    assert isinstance(head, WebElement)
    assert isinstance(body, WebElement)
    assert html.tag_name == "html"
    assert head.tag_name == "head"
    assert body.tag_name == "body"

    # TODO: insert your crawling codes


def get_default_arguments(
    cmdline: Optional[List[str]] = None,
    namespace: Optional[Namespace] = None,
) -> Namespace:
    parser = ArgumentParser(prog="opy-helium-crawling")
    parser.add_argument("--headless", action="store_true")
    parser.add_argument("--method", "-m", choices=CRAWLING_METHODS, default=CM_CHROME)
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

#python mqrunDash_playwright_test.py --db "Z:\Download\mqrun.duckdb" --mode peptide --term HLSGEFGK
import argparse
import subprocess
import sys
import time
from pathlib import Path

import requests
from playwright.sync_api import TimeoutError as PlaywrightTimeoutError
from playwright.sync_api import sync_playwright

APP_FILE = Path(__file__).with_name("mqrunDash.py")


def wait_for_server(url, timeout=240):
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            resp = requests.get(url, timeout=5)
            if resp.status_code == 200:
                return True
        except requests.RequestException:
            pass
        time.sleep(0.5)
    raise RuntimeError(f"Server did not respond at {url} within {timeout}s")


def click_top_panel(page, panel_id, description, expected_input_selector):
    selector = f"#{panel_id} span[style*='cursor: pointer']"
    page.wait_for_selector(selector, timeout=30000)
    locator = page.locator(selector).first
    if locator.count() == 0:
        raise RuntimeError(f"No clickable element found in {description} ({panel_id})")
    term = locator.inner_text().strip()
    locator.click()
    page.wait_for_selector("#profile-summary", state="visible", timeout=30000)
    page.wait_for_function(
        "([selector, expected]) => { const el = document.querySelector(selector); return el && el.value === expected; }",
        arg=[expected_input_selector, term],
        timeout=30000,
    )
    input_value = page.locator(expected_input_selector).input_value().strip()
    if input_value != term:
        raise AssertionError(
            f"Expected {expected_input_selector} value to be '{term}', got '{input_value}'"
        )
    print(f"{description} click passed: {term}")
    return term


def run_browser_test(base_url, mode, term):
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        page.goto(base_url, wait_until="networkidle")
        page.wait_for_selector("#tbl-genes", timeout=30000)

        print("Clicking top gene link...")
        click_top_panel(page, "tbl-genes", "gene panel", "#inp-gene")

        print("Clicking top UniProt link...")
        click_top_panel(page, "tbl-uniprot", "UniProt panel", "#inp-uniprot")

        print("Clicking top peptide link...")
        click_top_panel(page, "tbl-peptides", "peptide panel", "#inp-peptide")

        search_map = {
            'gene': ('#inp-gene', 'gene'),
            'uniprot': ('#inp-uniprot', 'UniProt'),
            'peptide': ('#inp-peptide', 'peptide'),
        }
        if mode not in search_map:
            raise ValueError(f"Unsupported search mode: {mode}")

        input_selector, desc = search_map[mode]
        print(f"Typing an exact {desc} term into the search box...")
        search_input = page.locator(input_selector)
        search_input.click()
        search_input.fill(term)
        if search_input.input_value().strip() != term:
            raise AssertionError(f"Failed to fill the {desc} input field")
        search_input.press("Enter")
        search_input.evaluate("el => el.blur()")
        page.wait_for_selector("#profile-summary", state="visible", timeout=30000)
        page.wait_for_function(
            "expected => { const summary = document.querySelector('#profile-summary'); return summary && summary.innerText.includes(expected); }",
            arg=term,
            timeout=30000,
        )
        summary_text = page.locator("#profile-summary").inner_text().strip()
        if term not in summary_text:
            raise AssertionError(f"Expected {desc} search summary to mention {term}, got: {summary_text!r}")
        print(f"{desc.capitalize()} search input passed: {term}")
        print("Dashboard summary:\n" + summary_text)

        browser.close()


def main():
    parser = argparse.ArgumentParser(description="Run browser automation checks for mqrunDash.")
    parser.add_argument("--db", default=None,
                        help="Path to the DuckDB file to use when launching mqrunDash.py")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8050)
    parser.add_argument("--mode", choices=["gene", "uniprot", "peptide"], default="peptide",
                        help="Search mode to verify in the app")
    parser.add_argument("--term", default="HLSGEFGK",
                        help="Exact search term to type into the selected input")
    args = parser.parse_args()

    if not APP_FILE.exists():
        raise FileNotFoundError(f"Could not find mqrunDash.py at {APP_FILE}")

    cmd = [sys.executable, str(APP_FILE)]
    if args.db:
        cmd.append(args.db)

    proc = subprocess.Popen(
        cmd,
        cwd=APP_FILE.parent,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )

    try:
        base_url = f"http://{args.host}:{args.port}"
        wait_for_server(base_url)
        print(f"Server is up at {base_url}")
        run_browser_test(base_url, args.mode, args.term)
        print("All browser checks passed.")
    finally:
        proc.terminate()
        proc.wait(timeout=10)


if __name__ == "__main__":
    main()

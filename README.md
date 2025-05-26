#  git reset HEAD~
#[dockerImage](https://github.com/animesh/scripts/blob/master/Dockerfile):
# docker.io/animesh1977/scripts
#ignore MS/DOS endings (on windows machines):
# git config --global core.autocrlf true
#[aliases](https://youtu.be/f-Br8cud2eI?t=1918)
# rebase
# beflog
# stash
# log --graph
# bisect
# merge
# push --force-with-lease
#config setup
# git clone http://github.com/animesh/scripts
# cd scripts
# ln -s $PWD/config.bash $HOME/.bashrc
*
!*.*
*.pdf
*.asv
*.csv
*.txt
*.history
*swp
*gz
*tsv

# Auto Login and Form Submission Script

This script uses Selenium to automatically log in to a website and submit a form using credentials and data from environment variables.

## Requirements
- Python 3.x
- Google Chrome browser
- ChromeDriver (matching your Chrome version)
- `selenium` Python package

## Setup
1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```
2. **Download ChromeDriver:**
   - Download from: https://sites.google.com/a/chromium.org/chromedriver/downloads
   - Place the `chromedriver` binary in your PATH or specify its location with the `CHROMEDRIVER_PATH` environment variable.

3. **Set environment variables:**
   - `LOGIN_URL`: The URL of the login page.
   - `LOGIN_USERNAME`: Your username.
   - `LOGIN_PASSWORD`: Your password.
   - `FORM_FIELD_1`: Data for the form field (example; add more as needed).
   - `CHROMEDRIVER_PATH`: (Optional) Path to your `chromedriver` binary.

   Example (Linux/macOS):
   ```bash
   export LOGIN_URL='https://example.com/login'
   export LOGIN_USERNAME='your_username'
   export LOGIN_PASSWORD='your_password'
   export FORM_FIELD_1='your_form_data'
   export CHROMEDRIVER_PATH='/path/to/chromedriver'
   ```

## Usage
Run the script:
```bash
python auto_login_form.py
```

## Customization
- Update the field selectors in `auto_login_form.py` to match the actual names or XPaths of the login and form fields on your target website.
- Add more environment variables and form fields as needed.

## Notes
- The script runs Chrome in headless mode by default.
- For troubleshooting, remove the `--headless` option to see the browser window.

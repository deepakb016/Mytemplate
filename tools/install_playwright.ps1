#!/usr/bin/env pwsh
# Install Python test deps and Playwright browsers (Windows PowerShell)
Write-Host "Installing test dependencies from requirements.txt..."
python -m pip install -r requirements.txt

Write-Host "Installing Playwright browsers (chromium)..."
python -m playwright install chromium

Write-Host "Done. You can run UI tests with: pytest --browser chromium tests/test_ui.py"

Test Running Instructions
=========================

Backend tests
-------------
Run the backend tests (may require env vars / DB setup):

```bash
pytest tests/test_backend.py
```

UI (browser) tests
-------------------
These use Playwright via `pytest-playwright`. First install dependencies and the browser binaries:

PowerShell (Windows):

```powershell
.\tools\install_playwright.ps1
```

Or with pip directly:

```bash
python -m pip install -r requirements.txt
python -m playwright install chromium
```

Run the UI tests:

```bash
pytest --browser chromium tests/test_ui.py
```

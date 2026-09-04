PY := python
PIP := $(PY) -m pip

.PHONY: help install install-playwright test ui lint security reports clean

help:
	@echo "Makefile targets: install, install-playwright, test, ui, lint, security, reports, clean"

install:
	$(PIP) install -r requirements.txt

install-playwright:
	$(PY) -m playwright install chromium

reports:
	$(PY) -c "import pathlib; pathlib.Path('reports').mkdir(exist_ok=True)"

test: reports
	$(PY) -m pytest --junitxml=reports/unit.xml --cov=app --cov-report=xml --cov-report=html

ui: reports
	$(PY) -m pytest tests/test_ui.py --junitxml=reports/ui.xml

lint:
	ruff check .

security: reports
	bandit -r app -f json -o reports/security.json

clean:
	$(PY) -c "import shutil
import pathlib
shutil.rmtree('reports', ignore_errors=True)
shutil.rmtree('.pytest_cache', ignore_errors=True)
shutil.rmtree('htmlcov', ignore_errors=True)
print('cleaned')"
.PHONY: docs test agent-setup agent-resetdb agent-smoke agent-test

VENV_PYTHON=env/bin/python
AGENT_TEST_FILES=$(shell git ls-files 'tests/*.py')

help:
	@echo "  env         create a development environment using virtualenv"
	@echo "  deps        install dependencies using pip"
	@echo "  clean       remove unwanted files like .pyc's"
	@echo "  lint        check style with flake8"
	@echo "  test        run all your tests using py.test"
	@echo "  agent-setup install dependencies in ./env for AI/code agents"
	@echo "  agent-resetdb reset and seed local development database"
	@echo "  agent-smoke run fast smoke tests"
	@echo "  agent-test  run full test suite with coverage"

env:
	python3 -m venv env && \
	. env/bin/activate && \
	make deps

deps:
	pip install -r requirements.txt

clean:
	find . | grep -E "(__pycache__|\.pyc|\.DS_Store|\.db|\.pyo$\)" | xargs rm -rf

lint:
	flake8 --exclude=env .

test:
	py.test tests

agent-setup:
	python3 -m venv env
	$(VENV_PYTHON) -m pip install --upgrade pip
	$(VENV_PYTHON) -m pip install -r requirements.txt

agent-resetdb:
	@if [ ! -x "$(VENV_PYTHON)" ]; then echo "Run 'make agent-setup' first."; exit 1; fi
	APPNAME_ENV=dev $(VENV_PYTHON) manage.py resetdb

agent-smoke:
	@if [ ! -x "$(VENV_PYTHON)" ]; then echo "Run 'make agent-setup' first."; exit 1; fi
	APPNAME_ENV=test $(VENV_PYTHON) -m pytest -q tests/test_urls.py tests/test_login.py

agent-test:
	@if [ ! -x "$(VENV_PYTHON)" ]; then echo "Run 'make agent-setup' first."; exit 1; fi
	APPNAME_ENV=test $(VENV_PYTHON) -m pytest --cov-report=term-missing --cov=appname $(AGENT_TEST_FILES)

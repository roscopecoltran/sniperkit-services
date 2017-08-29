# Some simple testing tasks (sorry, UNIX only).

FLAGS=

APP_NAME := motortwit
APP_DB_TYPE := mongo

PYTHON := $(shell which python)
PYFLAKES := $(shell which pyflakes)
PEP8 := $(shell which pep8)

env:
	@echo -e "   python=$(PYTHON)"
	@echo -e "   pyflakes=$(PYFLAKES)"
	@echo -e "   pep8=$(PEP8)"

flake: env
	$(PYFLAKES) $(APP_NAME)
	$(PEP8) $(APP_NAME) setup.py

clean:
	rm -rf `find . -name __pycache__`
	rm -f `find . -type f -name '*.py[co]' `
	rm -f `find . -type f -name '*~' `
	rm -f `find . -type f -name '.*~' `
	rm -f `find . -type f -name '@*' `
	rm -f `find . -type f -name '#*#' `
	rm -f `find . -type f -name '*.orig' `
	rm -f `find . -type f -name '*.rej' `
	rm -f .coverage
	rm -rf coverage
	rm -rf build
	rm -rf htmlcov
	rm -rf dist

run: env
	@$(PYTHON) -m $(APP_NAME)

fake_data: env
	@$(PYTHON) ./$(APP_NAME)/generate_data.py

docker_start_mongo:
	docker-compose -f ../../docker-compose.yml up -d $(APP_DB_TYPE)

docker_stop_mogo:
	docker-compose -f ../../docker-compose.yml stop $(APP_DB_TYPE)

.PHONY: flake clean

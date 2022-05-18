# Target section and Global definitions
# -----------------------------------------------------------------------------
.PHONY: all clean test run_server down black flake8 code_checks

.DEFAULT_GOAL := help

help: ## Help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | sed 's/Makefile:*//'| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: clean test install run down ## The whole process run, test, generate ...etc

test: ## Run unit tests
	poetry run pytest app/tests/api_tests.py --cov=app

poetry: ## Install poetry & its dependencies
	pip3 install --upgrade pip
	pip3 install poetry
	poetry install

precommit: ## Install & configure pre-commit
	pip install pre-commit
	pre-commit install

run_dbt: ## Run dbt models
	poetry run dbt seed --profiles-dir test_bq --project-dir test_bq
	poetry run dbt run --profiles-dir test_bq --project-dir test_bq

run_dq_tests: ## Run data quality tests using dbt
	poetry run dbt test --profiles-dir test_bq --project-dir test_bq

run_catalog_server: ## Run dbt catalog server locally
	$(info Make: Generate dbt docs)
	poetry run dbt docs generate --profiles-dir test_bq --project-dir test_bq
	$(info Make: Run catalog server)
	poetry run dbt docs serve --profiles-dir test_bq --project-dir test_bq

flake8: ## Run flake8 for python code
	poetry run flake8

sqlfluff: ## Run sqlfluff for sql code
	poetry run sqlfluff lint

black: ## format python code
	poetry run black --check . || echo "Please run black to format your code"

code_checks: flake8 black test ## Run needed code checks
	$(info Make: checks done!)

clean: ## Clean up generated compiled/generated files
	$(info Make: Cleanup the project)

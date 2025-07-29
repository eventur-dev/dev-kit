.DEFAULT_GOAL := help

DOCKER_COMPOSE := docker compose
EXEC = $(DOCKER_COMPOSE) exec $(SERVICE)

PHPUNIT := php -d memory_limit=-1 vendor/bin/phpunit --testdox --colors=always --fail-on-warning --display-deprecations
PHPSTAN := vendor/bin/phpstan
CS_FIXER := vendor/bin/php-cs-fixer
RECTOR := vendor/bin/rector

help:
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}'

build: ## Build and start container in background
	$(DOCKER_COMPOSE) up -d --build

down: ## Stop and remove container, image, volumes, orphans
	$(DOCKER_COMPOSE) down --rmi local --volumes --remove-orphans

start: ## Start container
	$(DOCKER_COMPOSE) start

stop: ## Stop container
	$(DOCKER_COMPOSE) stop

shell: ## Open bash in container
	$(EXEC) bash

docker-logs: ## Follow container logs
	$(DOCKER_COMPOSE) logs -f

install: ## Run Composer install
	$(EXEC) composer install --no-interaction --prefer-dist

req: ## Run Composer require
	$(EXEC) composer require $(n)

autoload: ## Run Composer dump autoload
	$(EXEC) composer dumpautoload

test-all: ## Run all tests
	$(EXEC) $(PHPUNIT)

test-single: ## Run single test (c=TestName)
	$(EXEC) $(PHPUNIT) --filter $(c)

test-group: ## Run group (g=group)
	$(EXEC) $(PHPUNIT) --group $(g)

test-unit: ## Run unit tests
	$(EXEC) $(PHPUNIT) --testsuite unit

test-integration: ## Run integration tests
	$(EXEC) $(PHPUNIT) --testsuite integration

test-config-migrate: ## Migrate phpunit.xml config
	$(EXEC) $(PHPUNIT) --migrate-configuration

test-coverage: ## Generate coverage report (HTML)
	$(EXEC) $(PHPUNIT) --coverage-html coverage-report

test-coverage-strict: ## Fail if coverage < 100%
	$(DOCKER_COMPOSE) exec $(SERVICE) bash -c "\
		php -d memory_limit=-1 vendor/bin/phpunit \
			--testdox \
			--colors=never \
			--coverage-text \
			--display-deprecations \
			--fail-on-incomplete \
			--fail-on-risky \
			--fail-on-skipped \
			--fail-on-warning \
		| tee /tmp/coverage.out && \
		grep 'Lines:   100.00%' /tmp/coverage.out > /dev/null || { \
			echo '\n\033[0;31m❌ Code coverage is below 100%.\033[0m\n'; \
			exit 1; \
		}"

phpstan: ## Run PHPStan
	$(EXEC) $(PHPSTAN) --memory-limit=1G

cs-fix: ## Run PHP CS Fixer
	$(EXEC) $(CS_FIXER) fix --allow-risky=yes

cs-check: ## Run PHP CS Fixer in dry-run mode
	$(EXEC) $(CS_FIXER) fix --dry-run --diff --allow-risky=yes

fix-perms: ## Fix file ownership issues
	sudo chown -R $(UID):$(GID) .cache coverage-report vendor composer.lock

composer-validate: ## Validate composer.json
	$(DOCKER_COMPOSE) exec $(SERVICE) composer validate --strict

rector-check: ## Dry-run Rector (no changes, only report)
	$(EXEC) $(RECTOR) process --dry-run --no-progress-bar

rector-fix: ## Apply Rector changes
	$(EXEC) $(RECTOR) process --no-progress-bar

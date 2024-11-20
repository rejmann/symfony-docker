.PHONY: tests
all: help

help: ## show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-24s\033[0m %s\n", $$1, $$2}'

##### Setup and Infra #####
env: .env.dist ## install .env.dist into .env
	cp -n .env.dist .env

git/hooks/pre-commit: ## install pre-commit hook
	cp cli/pre-commit-hook .git/hooks/pre-commit

fix-permissions: ## fix directories and file permissions
	cli/fix-permissions

composer-install: ## run composer install
	cli/composer install -n

docker-up: ## start the dev server
	docker compose up -d --remove-orphans

up: docker-up composer-install npm-install npm-build migrate fix-permissions ## prepare and start the dev server

setup: env git/hooks/pre-commit up ## initialize the project
	grep -qxF '127.0.0.1	setup.test' /etc/hosts || echo '127.0.0.1	isp.test' | sudo tee -a /etc/hosts

##### Doctrine #####
doctrine-diff: ## create a new migration based on the changes of the entities
	cli/console doctrine:migrations:diff
	make fix-permissions

empty-migration: ## create a new empty migration
	cli/console doctrine:migrations:generate
	make fix-permissions

migrate: ## run migrations
	cli/console doctrine:migrations:migrate --no-interaction

##### static analysis #####
GET_GIT=-d
php-cs-fixer: fix-permissions ## run php-cs-fixer
	cli/run-at-container ./cli/php-cs-fixer $(GET_GIT) || true

php-cs-fixer-check: fix-permissions ## run php-cs-fixer
	cli/run-at-container ./cli/php-cs-fixer $(GET_GIT) --dry-run

auto-fix: php-cs-fixer ## run php-cs-fixer

auto-fix-all: ## run php-cs-fixer
	make auto-fix GET_GIT=--all

auto-fix-diff: ## run php-cs-fixer
	make auto-fix GET_GIT=--diff

phpstan: ## run phpstan
	cli/run-at-container ./cli/phpstan $(GET_GIT)

phpmd: ## run phpmd
	cli/run-at-container ./cli/phpmd $(GET_GIT)

GET_GIT=-d
static-analysis:
	make phpstan
	make phpmd
	make php-cs-fixer-check

##### tests #####
tests:
	cli/run-at-container ./cli/tests

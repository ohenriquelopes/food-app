include docker/.env-local-tests
export
init:
	cp docker/.env-local-example .env
	cp docker/docker-compose-local.yml docker-compose.yml
	docker-compose up -d
	make composer
	make migrate
	make seed
	@docker exec laravel chmod 777 -R .
deploy: 
	git pull
	cp docker/.env-production-example .env
	cp docker/docker-compose-prod.yml docker-compose.yml
	docker-compose up -d app
	make composer
	make migrate
deploy-stagging: 
	git pull
	cp docker/.env-local-example .env
	docker-compose up -d app
	make composer
	make migrate
make-controller:
	@docker exec -i laravel php artisan make:controller
	make permission
make-model:
	@docker exec -i laravel php artisan make:model
	make permission
make-migration:
	@docker exec -i laravel php artisan make:migration
	make permission
make-seed:
	@docker exec -i laravel php artisan make:seeder
	make permission
mix-dev:
	@docker exec laravel npm install
	@docker exec laravel npm run dev
mix-prod:
	@docker exec laravel npm install
	@docker exec laravel npm run prod
permission:
	@docker exec laravel chmod 777 -R .
down:
	@docker-compose down -v	
migrate:
	@echo "Running migrations"
	@echo "------------------------"
	@docker exec laravel php artisan migrate --force
seed:
	@echo "Running seed"
	@echo "------------------------"
	@docker exec laravel php artisan db:seed
rollback:
	@echo "Rollback migrations"
	@echo "------------------------"
	@docker exec laravel php artisan migrate:rollback --force
composer:
	@echo "Running composer clear-cache"
	@echo "------------------------"
	@docker exec laravel composer clear-cache
	@echo "Running composer self-update"
	@echo "------------------------"
	@docker exec laravel composer self-update
	@echo "Running composer install --no-interaction"
	@echo "------------------------"
	@docker exec laravel composer install --no-interaction
db-test:
	@docker exec -i mysql mysql -u${DB_USERNAME} -p${DB_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS testing"
	cp docker/.env-local-tests .env.testing
	@docker exec laravel php artisan migrate --env=testing
	@docker exec laravel php artisan db:seed --env=testing
test:
	@docker exec laravel php artisan test
.PHONY: clean test code-sniff init
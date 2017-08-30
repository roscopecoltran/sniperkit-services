PROJECT_DIR=$(shell pwd)
POSTGRES_USER=sps_admin
POSTGRES_PASSWORD=djangochannels
POSTGRES_DB=sps
POSTGRES_HOST=docker_db

all:
	docker-compose up -d
	docker-compose build aiohttp
	@sleep 1
	docker-compose up -d aiohttp
	docker-compose logs -f aiohttp

log:
	docker-compose logs -f aiohttp

restart:
	docker-compose kill aiohttp
	docker-compose up -d aiohttp
	docker-compose logs -f aiohttp

up:
	docker-compose up --build --force-recreate -d
	@sleep 1
	docker-compose restart aiohttp
	docker-compose logs -f aiohttp

link_dev:
	rm $(PROJECT_DIR)/docker-compose.yml -f
	ln -s $(PROJECT_DIR)/configs/dev/docker-compose.yml $(PROJECT_DIR)/docker-compose.yml

link_prod:
	rm $(PROJECT_DIR)/docker-compose.yml -f
	ln -s $(PROJECT_DIR)/configs/prod/docker-compose.yml $(PROJECT_DIR)/docker-compose.yml

dump:
	docker-compose exec db pg_dump $(POSTGRES_DB) -U $(POSTGRES_USER) > sps-$(shell date +%Y-%m-%d-%H:%M:%S).sql

clean:
	docker-compose stop
	docker-compose rm -vf
	docker rmi $(docker images | grep "^<none>" | awk "{print $3}")

admin_conf:
	python sps/manage.py admin_config

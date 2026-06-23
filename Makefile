ifneq ("$(wildcard .env)", "")
	include .env
	export $(shell sed 's/=.*//' .env)
endif

DOCKER_COMPOSE_FILE = ./.docker/compose.yml
DOCKER_NETWORK = neuraclinic-network

create-envs:
	test -f .env || cp .env.example .env

create-network:
	docker network inspect $(DOCKER_NETWORK) >/dev/null 2>&1 || docker network create $(DOCKER_NETWORK)

compose:
	$(MAKE) create-envs
	$(MAKE) create-network
	docker compose -f $(DOCKER_COMPOSE_FILE) up

compose-detached:
	$(MAKE) create-envs
	$(MAKE) create-network
	docker compose -f $(DOCKER_COMPOSE_FILE) up -d

compose-down:
	docker compose -f $(DOCKER_COMPOSE_FILE) down

submodules:
	git submodule update --init --recursive

.PHONY: create-envs create-network compose compose-detached compose-down submodules


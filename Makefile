ifneq ("$(wildcard .env)", "")
	include .env
	export $(shell sed 's/=.*//' .env)
endif

DOCKER_COMPOSE_FILE = ./.docker/compose.yml
DOCKER_NETWORK = neuraclinic-network
SUBMODULE_COMPOSE_DIRS = \
	neuraclinic-auth \
	neuraclinic-file-management \
	neuraclinic-location \
	neuraclinic-notifications \
	neuraclinic-records

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

compose-submodules-detached:
	$(MAKE) compose-detached
	@for dir in $(SUBMODULE_COMPOSE_DIRS); do \
		$(MAKE) -C $$dir compose-build-detached; \
	done

compose-submodules-down-remove-orphans:
	@for dir in $(SUBMODULE_COMPOSE_DIRS); do \
		docker compose -f $$dir/.docker/compose.yml down --remove-orphans; \
	done
	docker compose -f $(DOCKER_COMPOSE_FILE) down --remove-orphans

submodules:
	git submodule update --init --recursive

.PHONY: create-envs create-network compose compose-detached compose-down compose-submodules-detached compose-submodules-down-remove-orphans submodules

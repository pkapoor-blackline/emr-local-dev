# Makefile for devcontainers setup

COMPOSE_FILE=./devcontainer/docker-compose.yml
PROJECT_NAME=emr-local-dev

SERVICES = spark glue zookeeper kafka kafka-ui kafka-connect postgres registry

.PHONY: help build up down restart logs ps clean \
        $(addprefix up-,$(SERVICES)) \
        $(addprefix down-,$(SERVICES)) \
        $(addprefix logs-,$(SERVICES)) \
        $(addprefix restart-,$(SERVICES)) \
        $(addprefix bash-,$(SERVICES))

help:
	@echo "Global commands:"
	@echo "  make build       - Build all services"
	@echo "  make up          - Start all services (detached)"
	@echo "  make down        - Stop all services"
	@echo "  make restart     - Restart all services"
	@echo "  make logs        - Tail logs for all services"
	@echo "  make ps          - List running containers"
	@echo "  make clean       - Remove volumes and reset state"
	@echo ""
	@echo "Service-level commands (example: make up-spark):"
	@echo "  up-<service>     - Start one service"
	@echo "  down-<service>   - Stop one service"
	@echo "  restart-<service>- Restart one service"
	@echo "  logs-<service>   - Tail logs for one service"
	@echo "  bash-<service>   - Open bash inside a running service container"

# -----------------
# Global targets
# -----------------

build:
	docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME) build

up:
	docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME) up -d

down:
	docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME) down

restart: down up

logs:
	docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME) logs -f

ps:
	docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME) ps

clean:
	docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME) down -v --remove-orphans

# -----------------
# Per-service targets
# -----------------

$(addprefix up-,$(SERVICES)):
	docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME) up -d $(@:up-%=%)

$(addprefix down-,$(SERVICES)):
	docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME) stop $(@:down-%=%)

$(addprefix restart-,$(SERVICES)):
	docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME) restart $(@:restart-%=%)

$(addprefix logs-,$(SERVICES)):
	docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME) logs -f $(@:logs-%=%)

$(addprefix bash-,$(SERVICES)):
	docker exec -it $(@:bash-%=%) bash

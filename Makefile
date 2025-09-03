.PHONY: up down logs

setup-gcp:
	sh ./script/setup.sh

cleanup-gcp:
	sh ./script/cleanup.sh

up:
	docker compose -f docker/docker-compose.yaml up -d

down:
	docker compose -f docker/docker-compose.yaml down

logs:
	docker compose -f docker/docker-compose.yaml logs -f

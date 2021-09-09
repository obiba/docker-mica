#
# Docker helper
#

no_cache=false

docker_compose_file=docker-compose.yml

up:
	docker-compose -f $(docker_compose_file) up -d --remove-orphans

down:
	docker-compose -f $(docker_compose_file) down

stop:
	docker-compose -f $(docker_compose_file) stop

start:
	docker-compose -f $(docker_compose_file) start

restart:
	docker-compose -f $(docker_compose_file) restart

pull:
	docker-compose -f $(docker_compose_file) pull

logs:
	docker-compose -f $(docker_compose_file) logs -f

# Build Docker image
build:
	sudo docker build --no-cache=$(no_cache) -t="obiba/mica:snapshot" .

clean:
	sudo rm -rf target

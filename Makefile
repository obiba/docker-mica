#
# Docker helper
#

no_cache=false

docker_compose_file=docker-compose.yml

up:
	sudo docker-compose -f $(docker_compose_file) up -d --remove-orphans

down:
	sudo docker-compose -f $(docker_compose_file) down

stop:
	sudo docker-compose -f $(docker_compose_file) stop

start:
	sudo docker-compose -f $(docker_compose_file) start

restart:
	sudo docker-compose -f $(docker_compose_file) restart

pull:
	sudo docker-compose -f $(docker_compose_file) pull

logs:
	sudo docker-compose -f $(docker_compose_file) logs -f

build:
	sudo docker-compose -f $(docker_compose_file) build --no-cache

# Build Docker image
build-image:
	sudo docker build --no-cache=$(no_cache) -t="obiba/mica:snapshot" .

push-image:
	sudo docker image push obiba/mica:snapshot

clean:
	sudo rm -rf target

#
# Docker helper
#

no_cache=false
tag=5.3

all:
	sudo docker build --no-cache=true -t="obiba/mica:$(tag)" . && \
	sudo docker build -t="obiba/mica:latest" . && \
	sudo docker image push obiba/mica:$(tag) && \
	sudo docker image push obiba/mica:latest

# Build Docker image
build:
	docker build --no-cache=$(no_cache) -t="obiba/mica:$(tag)" .

push:
	docker image push obiba/mica:$(tag)

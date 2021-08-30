#
# Docker helper
#

no_cache=false

# Build Docker image
build:
	sudo docker build --no-cache=$(no_cache) -t="obiba/mica:$(tag)" .

push:
	sudo docker image push obiba/mica:$(tag)


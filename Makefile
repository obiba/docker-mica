#
# Docker helper
#

no_cache=true

# Build Docker image
build:
	docker build --pull --no-cache=$(no_cache) -t="obiba/mica:$(tag)" .

push:
	docker image push obiba/mica:$(tag)

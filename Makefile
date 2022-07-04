#
# Docker helper
#

no_cache=false

# Build Docker image
build:
	docker build --no-cache=$(no_cache) -t="obiba/mica:$(tag)" .

push:
	docker image push obiba/mica:$(tag)


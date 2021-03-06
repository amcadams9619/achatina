#
# A simple top level Makefile for the achatina examples
#
# Targets for dev and test:
#   test                  (build and test an example locally)
#   register-pattern      (register the host for an example using a pattern)
#   register-policy       (register the host for an example using a policy)
#   clean                 (stop and remove all of the example containers)
#   stop                  (stop and remove all containers, except anax)
#   deep-clean            (clean, stop, and also remove all container images except anax, and the docker network used for testing)
#
# Targets for publishing to any Horizon Exchange
#   publish-local-services  (build, push, and publish all of the services in all of the examples, for just the local architecture)
#   publish-all-services  (build, push, and publish all of the services in all of the examples, for all supported architectures)
#   publish-all-patterns  (publish all of the deployment patterns supported by all of the examples)
#   publish-all-policies  (publish all of the business/deployment policies provided by all of the examples)
#

test: test-yolocpu
register-pattern: register-yolocpu-pattern
register-policy: register-yolocpu-policy

all-local:
	@echo "Building, docker-pushing, and publishing everything for this architecture only..."
	$(MAKE) build-local-services
	$(MAKE) push-local-services
	$(MAKE) publish-local-services
	@echo "NOTE: after you have done this on each architecture, publish the pattern too."
	@echo "      E.g.:  make publish-all-patterns"

build-local-services:
	@echo "Building the shared services..."
	# Add additional makes here for any added examples
	$(MAKE) -C shared build-local-services
	@echo "Building the example services..."
	$(MAKE) -C yolocpu build-local-services
	$(MAKE) -C yolocuda build-local-services

push-local-services:
	@echo "Docker-pushing the shared services..."
	$(MAKE) -C shared push-local-services
	@echo "Docker-pushing the example services..."
	$(MAKE) -C yolocpu push-local-services
	$(MAKE) -C yolocuda push-local-services
	# Add additional makes here for any added examples

publish-local-services:
	@echo "Publishing the shared services..."
	$(MAKE) -C shared publish-local-services
	@echo "Publishing all the example services..."
	$(MAKE) -C yolocpu publish-local-services
	$(MAKE) -C yolocuda publish-local-services
	# Add additional makes here for any added examples

publish-all-services:
	@echo "Building and publishing the shared services..."
	$(MAKE) -C shared publish-all-services
	@echo "Building and publishing all the example services..."
	$(MAKE) -C yolocpu publish-all-services
	$(MAKE) -C yolocuda publish-all-services
	# Add additional makes here for any added examples

publish-all-patterns:
	@echo "Publishing the patterns for all of the examples..."
	$(MAKE) -C yolocpu publish-all-patterns
	$(MAKE) -C yolocuda publish-all-patterns
	# Add additional makes here for any added examples

publish-all-policies:
	@echo "Publishing the business/deployment policies for all of the examples..."
	$(MAKE) -C yolocpu publish-all-policies
	$(MAKE) -C yolocuda publish-all-policies
	# Add additional makes here for any added examples

clean:
	$(MAKE) -C shared clean
	$(MAKE) -C yolocpu clean
	$(MAKE) -C yolocuda clean
	# Add additional makes here for any added examples

ANAX_CONTAINER:=$(word 1, $(shell sh -c "docker ps | grep 'openhorizon/amd64_anax'"))
EXTRA:=$(if $(ANAX_CONTAINER), | grep -v $(ANAX_CONTAINER), )
stop:
	@echo "Stopping and removing Docker containers."
	-docker rm -f `docker ps -aq ${EXTRA}` 2>/dev/null || :

ANAX_IMAGE:=$(word 3, $(shell sh -c "docker images | grep 'openhorizon/amd64_anax'"))
foo:
deep-clean: clean stop
	@echo "Removing Docker container images."
	-docker rmi -f `docker images -aq | grep -v "${ANAX_IMAGE}"` 2>/dev/null || :
	@echo "Removing the Docker network used for testing."
	-docker network rm mqtt-net 2>/dev/null || :

.PHONY: test register-patter register-policy clean stop deep-clean publish-all-services publish-all-patterns publish-all-policies

#
# Provide convenience targets for any added examples here, if desired:
#

# YOLO for CPU
test-yolocpu:
	@echo "Performing  local test (outside of Horizon) for YOLOv3 (CPU)..."
	$(MAKE) -C yolocpu test
register-yolocpu-pattern:
	$(MAKE) -C yolocpu register-pattern
register-yolocpu-policy:
	$(MAKE) -C yolocpu register-policy
.PHONY: test-yolocpu register-yolocpu-pattern register-yolocpu-policy


# YOLO for CUDA
test-yolocuda:
	@echo "Performing  local test (outside of Horizon) for YOLO (CUDA)..."
	$(MAKE) -C yolocuda test
register-yolocuda-pattern:
	$(MAKE) -C yolocuda register-pattern
register-yolocuda-policy:
	$(MAKE) -C yolocuda register-policy
.PHONY: test-yolocuda register-yolocuda-pattern register-yolocuda-policy




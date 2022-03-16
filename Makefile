

BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
DOCKER_RELEASE_REG=rayruan
DOCKER_IMAGE=bookstack
DOCKER_IMAGE_DEV=${DOCKER_IMAGE}-dev
#DOCKER_INTERNAL_TAG := "sha-$(shell git rev-parse --short HEAD:Dockerfile)"
#DOCKER_INTERNAL_TAG:="base-$(shell docker images -q linuxserver/bookstack:latest)"
DOCKER_IMAGE_BASE_VERSION := 21.12.5
DOCKER_INTERNAL_TAG:="base-$(shell docker images -q linuxserver/bookstack:${DOCKER_IMAGE_BASE_VERSION})"
#DOCKER_RELEASE_TAG := $(shell git describe)
DOCKER_RELEASE_TAG := ${DOCKER_IMAGE_BASE_VERSION}

.PHONY: pullbase build  push pull release

pullbase:
	docker pull linuxserver/bookstack:${DOCKER_IMAGE_BASE_VERSION}

build: pullbase
	DOCKER_INTERNAL_TAG="base-$(shell docker images -q linuxserver/bookstack:${DOCKER_IMAGE_BASE_VERSION})"
	#docker rmi $(DOCKER_RELEASE_REG)/$(DOCKER_IMAGE_DEV):$(DOCKER_INTERNAL_TAG)
	docker image build . \
		--build-arg "BASE_VERSION=${DOCKER_IMAGE_BASE_VERSION}" \
		-t $(DOCKER_RELEASE_REG)/$(DOCKER_IMAGE_DEV):$(DOCKER_INTERNAL_TAG)

push-dev:
	docker push $(DOCKER_RELEASE_REG)/$(DOCKER_IMAGE_DEV):$(DOCKER_INTERNAL_TAG)

pull:
	docker pull $(DOCKER_RELEASE_REG)/$(DOCKER_IMAGE_DEV):$(DOCKER_INTERNAL_TAG) 

release:
	docker tag $(DOCKER_RELEASE_REG)/$(DOCKER_IMAGE_DEV):$(DOCKER_INTERNAL_TAG) $(DOCKER_RELEASE_REG)/$(DOCKER_IMAGE):$(DOCKER_RELEASE_TAG)
	docker tag $(DOCKER_RELEASE_REG)/$(DOCKER_IMAGE_DEV):$(DOCKER_INTERNAL_TAG) $(DOCKER_RELEASE_REG)/$(DOCKER_IMAGE):latest

push-release:
	docker push $(DOCKER_RELEASE_REG)/$(DOCKER_IMAGE):$(DOCKER_RELEASE_TAG)
	docker push $(DOCKER_RELEASE_REG)/$(DOCKER_IMAGE):latest




DOCKER_RELEASE_REG=rayruan
DOCKER_IMAGE=bookstack
DOCKER_IMAGE_DEV=${DOCKER_IMAGE}-dev
DOCKER_INTERNAL_TAG := "sha-$(shell git rev-parse --short HEAD:Dockerfile)"
#DOCKER_RELEASE_TAG := $(shell git describe)
DOCKER_RELEASE_TAG := linuxserver_chs
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

.PHONY: build  push pull release

build:
	docker pull linuxserver/bookstack
	docker image build . \
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


SHELL = bash
# .ONESHELL:
# .SHELLFLAGS = -e
# See https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html
.PHONY: default all build circleci-local-build check-binaries check-buildx check-docker-login docker-login-if-possible buildx-prepare prepare install-qemu uninstall-qemu \
        buildx

# DOCKER_REGISTRY: Nothing, or 'registry:5000/'
DOCKER_REGISTRY ?= docker.io/
# DOCKER_USERNAME: Nothing, or 'biarms'
DOCKER_USERNAME ?=
# DOCKER_PASSWORD: Nothing, or '********'
DOCKER_PASSWORD ?=
# BETA_VERSION: Nothing, or '-beta-123'
BETA_VERSION ?=
DOCKER_IMAGE_NAME = biarms/docker-toolbox
DOCKER_IMAGE_VERSION = 0.0.3
DOCKER_IMAGE_TAGNAME = ${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}${BETA_VERSION}
# See https://www.gnu.org/software/make/manual/html_node/Shell-Function.html
BUILD_DATE=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
# See https://microbadger.com/labels
VCS_REF=$(shell git rev-parse --short HEAD)

# This build can't currently be a multi-arch build, because the Dockerfile hardcode 'amd64'.
# Not a big deal, because we just want this toolbox on amd64 for building purpose (all build are 'multiarch' build done on amd64 hosts)
# PLATFORM ?= linux/arm/v6,linux/arm/v7,linux/arm64/v8,linux/amd64
PLATFORM ?= linux/amd64

default: all

all: check-docker-login build uninstall-qemu

build: buildx

# Launch a local build as on circleci, that will call the default target, but inside the 'circleci build and test env'
circleci-local-build: check-docker-login
	@ circleci local execute -e DOCKER_USERNAME="${DOCKER_USERNAME}" -e DOCKER_PASSWORD="${DOCKER_PASSWORD}"

check-binaries:
	@ which docker > /dev/null || (echo "Please install docker before using this script" && exit 1)
	@ which git > /dev/null || (echo "Please install git before using this script" && exit 2)
	@ # deprecated: which manifest-tool > /dev/null || (echo "Ensure that you've got the manifest-tool utility in your path. Could be downloaded from  https://github.com/estesp/manifest-tool/releases/" && exit 3)
	@ DOCKER_CLI_EXPERIMENTAL=enabled docker manifest --help | grep "docker manifest COMMAND" > /dev/null || (echo "docker manifest is needed. Consider upgrading docker" && exit 4)
	@ DOCKER_CLI_EXPERIMENTAL=enabled docker version -f '{{.Client.Experimental}}' | grep "true" > /dev/null || (echo "docker experimental mode is not enabled" && exit 5)
	# Debug info
	@ echo "DOCKER_REGISTRY: ${DOCKER_REGISTRY}"
	@ echo "BUILD_DATE: ${BUILD_DATE}"
	@ echo "VCS_REF: ${VCS_REF}"
	# Next line will fail if docker server can't be contacted
	docker version

check-docker-login: check-binaries
	@ if [[ "${DOCKER_USERNAME}" == "" ]]; then \
	    echo "DOCKER_USERNAME and DOCKER_PASSWORD env variables are mandatory for this kind of build"; \
	    echo "Consider one of these alternatives: "; \
	    echo "  - make build"; \
	    echo "  - DOCKER_USERNAME=biarms DOCKER_PASSWORD=******** BETA_VERSION='-local-test-pushed-on-docker-io' make"; \
	    echo "  - DOCKER_USERNAME=biarms DOCKER_PASSWORD=******** make circleci-local-build"; \
	    exit -1; \
	  fi

docker-login-if-possible: check-binaries
	if [[ ! "${DOCKER_USERNAME}" == "" ]]; then echo "${DOCKER_PASSWORD}" | docker login --username "${DOCKER_USERNAME}" --password-stdin; fi

# Test are qemu based. SHOULD_DO: use `docker buildx bake`. See https://github.com/docker/buildx#buildx-bake-options-target
install-qemu: check-binaries
	# @ # From https://github.com/multiarch/qemu-user-static:
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

uninstall-qemu: check-binaries
	docker run --rm --privileged multiarch/qemu-user-static:register --reset

# See https://docs.docker.com/buildx/working-with-buildx/
check-buildx: check-binaries
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx version

buildx-prepare: install-qemu check-buildx
	DOCKER_CLI_EXPERIMENTAL=enabled docker context create buildx-multi-arch-context || true
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx create buildx-multi-arch-context --name=buildx-multi-arch || true
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx use buildx-multi-arch
	# Debug info
	@ echo "DOCKER_IMAGE_TAGNAME: ${DOCKER_IMAGE_TAGNAME}"

buildx: docker-login-if-possible buildx-prepare
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --progress plain -f Dockerfile --push --platform "${PLATFORM}" --tag "${DOCKER_IMAGE_TAGNAME}" --build-arg VERSION="${DOCKER_IMAGE_VERSION}" --build-arg VCS_REF="${VCS_REF}" --build-arg BUILD_DATE="${BUILD_DATE}" .
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --progress plain -f Dockerfile --push --platform "${PLATFORM}" --tag "$(DOCKER_REGISTRY)${DOCKER_IMAGE_NAME}:latest${BETA_VERSION}" --build-arg VERSION="${DOCKER_IMAGE_VERSION}" --build-arg VCS_REF="${VCS_REF}" --build-arg BUILD_DATE="${BUILD_DATE}" .

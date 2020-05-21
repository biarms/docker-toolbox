SHELL = bash
# .ONESHELL:
# .SHELLFLAGS = -e
# See https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html
.PHONY: default all circleci-local-build check-binaries check-buildx check-docker-login buildx-prepare docker-login-if-possible buildx

DOCKER_IMAGE_NAME=biarms/docker-toolbox
DOCKER_IMAGE_VERSION = 0.0.1
DOCKER_IMAGE_TAGNAME=${DOCKER_REGISTRY}${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}
# See https://www.gnu.org/software/make/manual/html_node/Shell-Function.html
BUILD_DATE=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
VCS_REF=$(shell git rev-parse --short HEAD)

# This build can't currently be a multi-arch build, because the Dockerfile hardcode 'amd64'.
# Not a big deal, because we just want this toolbox on amd64 for building purpose (all build are 'multiarch' build done on amd64 hosts)
# PLATFORM ?= linux/arm/v6,linux/arm/v7,linux/arm64/v8,linux/amd64
PLATFORM ?= linux/amd64

default: all

all: buildx

# Launch a local build as on circleci, that will call the default target, but inside the 'circleci build and test env'
`circleci-local-build`: check-docker-login
	circleci local execute -e DOCKER_USERNAME="${DOCKER_USERNAME}" -e DOCKER_PASSWORD="${DOCKER_PASSWORD}"

check-binaries:
	@ which docker > /dev/null || (echo "Please install docker before using this script" && exit 1)
	@ which git > /dev/null || (echo "Please install git before using this script" && exit 2)
	@ # deprecated: which manifest-tool > /dev/null || (echo "Ensure that you've got the manifest-tool utility in your path. Could be downloaded from  https://github.com/estesp/manifest-tool/releases/" && exit 3)
	@ DOCKER_CLI_EXPERIMENTAL=enabled docker manifest --help | grep "docker manifest COMMAND" > /dev/null || (echo "docker manifest is needed. Consider upgrading docker" && exit 4)
	@ DOCKER_CLI_EXPERIMENTAL=enabled docker version -f '{{.Client.Experimental}}' | grep "true" > /dev/null || (echo "docker experimental mode is not enabled" && exit 5)
	# Debug info
	@echo "DOCKER_IMAGE_TAGNAME: ${DOCKER_IMAGE_TAGNAME}"
	@echo "BUILD_DATE: ${BUILD_DATE}"
	@echo "VCS_REF: ${VCS_REF}"

check-buildx: check-binaries
	# Next line will fail if docker server can't be contacted
	docker version
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx version

check-docker-login: check-binaries
	@ if [[ "${DOCKER_USERNAME}" == "" ]]; then echo "DOCKER_USERNAME and DOCKER_PASSWORD env variables are mandatory for this kind of build"; exit -1; fi

buildx-prepare: check-buildx
	DOCKER_CLI_EXPERIMENTAL=enabled docker context create buildx-multi-arch-context || true
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx create buildx-multi-arch-context --name=buildx-multi-arch || true
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx use buildx-multi-arch
	# @ # From https://github.com/multiarch/qemu-user-static:
	# docker run --rm --privileged multiarch/qemu-user-static:register --reset
	# docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

docker-login-if-possible: check-binaries
	if [[ ! "${DOCKER_USERNAME}" == "" ]]; then echo "${DOCKER_PASSWORD}" | docker login --username "${DOCKER_USERNAME}" --password-stdin; fi

buildx: docker-login-if-possible buildx-prepare
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --progress plain -f Dockerfile --push --platform "${PLATFORM}" --tag "$(DOCKER_REGISTRY)${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}${BETA_VERSION}" --build-arg VERSION="${DOCKER_IMAGE_VERSION}" --build-arg VCS_REF="${VCS_REF}" --build-arg BUILD_DATE="${BUILD_DATE}" .
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --progress plain -f Dockerfile --push --platform "${PLATFORM}" --tag "$(DOCKER_REGISTRY)${DOCKER_IMAGE_NAME}:latest${BETA_VERSION}" --build-arg VERSION="${DOCKER_IMAGE_VERSION}" --build-arg VCS_REF="${VCS_REF}" --build-arg BUILD_DATE="${BUILD_DATE}" .

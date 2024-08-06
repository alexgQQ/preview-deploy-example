GO_DIR ?= $(shell pwd)
GO_PKG ?= $(shell go list -e -f "{{ .ImportPath }}")
GOOS ?= $(shell go env GOOS || echo linux)
GOARCH ?= $(shell go env GOARCH || echo amd64)
CGO_ENABLED ?= 0

PROJECT_VERSION ?= 0.0.1
DOCKER_IMAGE ?= preview-deploy-example-app
TAG ?= latest

install: init ## install dev tools
	go install github.com/air-verse/air@latest

start: ## start air for hot reloading
	cd client-app && ~/go/bin/air --build.cmd "go build -o bin/app main.go" --build.bin "bin/app"

docker-image: ## build docker image
	docker build --build-arg PROJECT_VERSION=${PROJECT_VERSION} -t ${DOCKER_IMAGE}:${TAG} .

docker-push: ## push image to docker hub
	docker tag ${DOCKER_IMAGE}:${TAG} alexgqq/${DOCKER_IMAGE}:${TAG}
	docker image push alexgqq/${DOCKER_IMAGE}:${TAG}

test: ## test application

.PHONY: install

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
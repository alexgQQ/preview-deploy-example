GO_DIR ?= $(shell pwd)
GO_PKG ?= $(shell go list -e -f "{{ .ImportPath }}")
GOOS ?= $(shell go env GOOS || echo linux)
GOARCH ?= $(shell go env GOARCH || echo amd64)
CGO_ENABLED ?= 0

APP_VERSION ?= 0.0.1
DOCKER_IMAGE ?= preview-deploy-example-app
IMAGE_TAG ?= $(shell git rev-parse --short HEAD)
COMMIT_SHA ?= $(shell git rev-parse HEAD)

install: init ## install dev tools
	go install github.com/air-verse/air@latest
	go install github.com/securego/gosec/v2/cmd/gosec@latest
	go install golang.org/x/vuln/cmd/govulncheck@latest

start: ## start air for hot reloading
	cd app && ~/go/bin/air --build.cmd "go build -o bin/app main.go" --build.bin "bin/app"

scan: ## check app code for vulnerabilities
	~/go/bin/gosec ./app/...
	~/go/bin/govulncheck ./app

docker-image: ## build docker image
	docker build --build-arg APP_VERSION=${APP_VERSION} --build-arg COMMIT_SHA=${COMMIT_SHA} -t ${DOCKER_IMAGE}:${IMAGE_TAG} .

docker-push: ## push image to docker hub
	docker tag ${DOCKER_IMAGE}:${IMAGE_TAG} alexgqq/${DOCKER_IMAGE}:${IMAGE_TAG}
	docker image push alexgqq/${DOCKER_IMAGE}:${IMAGE_TAG}

test: ## test application
	go test -cover app/*.go

test-coverage: ## create a coverage report
	go test -coverprofile=cover.out app/*.go
	go tool cover -html=cover.out

.PHONY: install

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
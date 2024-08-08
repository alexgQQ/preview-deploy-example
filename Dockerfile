# syntax=docker/dockerfile:1
# https://docs.docker.com/build/building/multi-stage/

# Image from https://hub.docker.com/_/golang
FROM golang:1.22.2-bookworm AS builder
RUN go version

ARG PROJECT_VERSION

COPY app /go/src/
WORKDIR /go/src/

RUN GOOS=linux GOARCH=amd64 \
    go build \
    -trimpath \
    -ldflags="-w -s -X 'main.Version=${PROJECT_VERSION}'" \
    -o app main.go
# RUN go test -cover -v ./...

FROM gcr.io/distroless/base-debian12

ARG COMMIT_SHA
ENV COMMIT_SHA=${COMMIT_SHA}

WORKDIR /root
COPY app/templates templates
COPY --from=builder /go/src/app .

EXPOSE 8080
CMD ["./app"]

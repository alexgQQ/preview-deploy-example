# syntax=docker/dockerfile:1
# https://docs.docker.com/build/building/multi-stage/

# Image from https://hub.docker.com/_/golang
FROM golang:1.22.2 AS builder
RUN go version

ARG PROJECT_VERSION

COPY client-app /go/src/
WORKDIR /go/src/

RUN GOOS=linux GOARCH=amd64 \
    go build \
    -trimpath \
    -ldflags="-w -s -X 'main.Version=${PROJECT_VERSION}'" \
    -o app main.go
# RUN go test -cover -v ./...

# If you need SSL certificates for HTTPS, replace `FROM SCRATCH` with:
#
#   FROM alpine:3.17.1
#   RUN apk --no-cache add ca-certificates
#
# FROM scratch
# WORKDIR /root/
# COPY --from=builder /go/src/app .

EXPOSE 8080
ENTRYPOINT ["./app"]

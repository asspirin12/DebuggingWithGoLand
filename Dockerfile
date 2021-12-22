FROM golang:1.17-alpine3.15 as build-env

ENV CGO_ENABLED 0

# Allow Go to retreive the dependencies for the build step
RUN apk add --no-cache git

WORKDIR /goland-debugging/
ADD . /goland-debugging/

RUN go build -o /goland-debugging/srv .

# Get Delve from a GOPATH not from a Go Modules project
WORKDIR /go/src/
RUN go install github.com/go-delve/delve/cmd/dlv@latest

# final stage
FROM alpine:3.15.0

WORKDIR /
COPY --from=build-env /goland-debugging/srv /
COPY --from=build-env /go/bin/dlv /

EXPOSE 8080 40000

CMD ["/dlv", "--listen=:40000", "--headless=true", "--api-version=2", "exec", "/srv"]
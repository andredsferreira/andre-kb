# syntax=docker/dockerfile:1
ARG GO_VERSION=1.26-alpine
ARG ALPINE_VERSION=3.24

FROM golang:${GO_VERSION} AS build

WORKDIR /app
# copy these seperatly to benefit from layer caching
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download
COPY . .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux go build -o lab02 .

FROM build AS test

CMD ["go", "test", "./..."]

FROM alpine:${ALPINE_VERSION} AS final

WORKDIR /app
COPY --from=build /app/lab02 .
EXPOSE 8080
CMD ["./lab02"]
# syntax=docker/dockerfile:1
ARG GO_VERSION=1.26-alpine

FROM golang:${GO_VERSION} AS build

WORKDIR /app
# copy these seperatly to benefit from layer caching
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download
COPY . .
# CGO_ENABLED is set to 0 so we build statically without needing OS
# dependencies (runs directly on kernel)
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux go build -o lab02 .

FROM build AS test

# CMD instead of Run so it runs cleanly on Docker compose
CMD ["go", "test", "./..."]

FROM gcr.io/distroless/static-debian12 AS final

WORKDIR /app
COPY --from=build /app/lab02 .
EXPOSE 8080
USER nonroot:nonroot
CMD ["./lab02"]
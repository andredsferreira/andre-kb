# syntax=docker/dockerfile:1
ARG GO_VERSION=1.26-alpine

FROM --platform=$BUILDPLATFORM golang:${GO_VERSION} AS build

# provided automatically by buildx for each target platform
ARG TARGETARCH

WORKDIR /app
# copy these seperatly to benefit from layer caching
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download
COPY . .
# CGO_ENABLED is set to 0 so we build statically without needing OS
# dependencies (runs directly on kernel). GOARCH cross-compiles for the
# target platform while the compiler itself runs natively.
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH go build -o lab02 .

FROM build AS test

# CMD instead of Run so it runs cleanly on Docker compose
CMD ["go", "test", "./..."]

FROM gcr.io/distroless/static-debian12 AS final

WORKDIR /app
COPY --from=build /app/lab02 .
EXPOSE 8080
USER nonroot:nonroot
CMD ["./lab02"]
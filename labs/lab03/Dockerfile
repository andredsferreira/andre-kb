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
    CGO_ENABLED=0 GOOS=linux go build -o lab03 .

FROM build AS test

CMD ["go", "test", "./..."]

FROM gcr.io/distroless/static-debian12 AS final

WORKDIR /app
COPY --from=build /app/lab03 .

ENV PGDB_HOST=ep-fragrant-sound-asdvrrbf-pooler.c-4.eu-central-1.aws.neon.tech \
    PGDB_PORT=5432 \
    PGDB_USER=neondb_owner \
    PGDB_PASSWORD=npg_24fKtdMzEkDI \
    PGDB_DATABASE=lab03 \
    PGDB_SSLMODE=require \
    PGDB_CHANNEL_BINDING=require

EXPOSE 3000
USER nonroot:nonroot
CMD ["./lab03"]
# syntax=docker/dockerfile:1

FROM golang:1.26-alpine AS build

WORKDIR /app

COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

COPY . .

# Buildkit mount cache persists between builds and speeds up the building
# process dramatically.
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux go build -o lab03 .

################################################################################

FROM gcr.io/distroless/static-debian12 AS final

WORKDIR /app

COPY --from=build /app/lab03 .

EXPOSE 8080

USER nonroot:nonroot

CMD ["./lab03"]

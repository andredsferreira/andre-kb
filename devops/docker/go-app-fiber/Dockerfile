# Build 

FROM golang:1.24-alpine AS builder

WORKDIR /app
COPY . .
RUN go build -o go-app-fiber .

# Run

FROM alpine:latest

WORKDIR /app
COPY --from=builder /app/go-app-fiber .
CMD ["./hello"]

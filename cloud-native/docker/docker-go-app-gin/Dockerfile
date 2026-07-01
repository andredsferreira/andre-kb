# Build 

FROM golang:1.24-alpine AS builder

WORKDIR /app
COPY . .
RUN go build -o hello .

# Run

FROM alpine:latest

WORKDIR /app
COPY --from=builder /app/hello .
CMD ["./hello"]

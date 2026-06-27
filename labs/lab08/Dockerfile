ARG GO_VERSION=1.26-alpine
ARG ALPINE_VERSION=3.24

FROM golang:${GO_VERSION} AS build

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o lab08 .

FROM build AS test

CMD ["go", "test", "./..."] 

FROM alpine:${ALPINE_VERSION} as final

WORKDIR /app
COPY --from=build /app/lab08 .
EXPOSE 8080
CMD [ "./lab08" ]

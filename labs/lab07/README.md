# Lab07

Deploys an S3 bucket for serving a frontend application. The bucket is behind a
Cloudfront distribution.

## Architecture Overview

![](lab07.gif)


## Building

On ./src directory run:

```bash
GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -tags lambda.norpc -o bootstrap main.go
zip function.zip bootstrap
```

## Running

Simply run terraform apply and visit the output url for the cloudfront
distribution.
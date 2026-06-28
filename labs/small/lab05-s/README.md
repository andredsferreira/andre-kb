## Building the Go Binary

Need to specify the GOOS to linux and GOARCH to amd64 since the go lambda
runtime only works on linux amd64.

```bash
GOOS=linux GOARCH=amd64 go build -o main
```
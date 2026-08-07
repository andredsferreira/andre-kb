## LAB03: Go Fiber with Prometheus and Grafana

### Description

Lab that demonstrates a simple implementation of a Go Fiber API instrumeted with
Prometheus metrics and a simple Grafana dashboard to visualize everything.

The Go API simply exposes two metrics of type Counter and Histogram
(api_http_requests_total and api_http_request_duration_seconds). The default Go
metrics are disabled (by registring a new prometheus registry).

### Architecture

Containerized API monolith. The Prometheus and Grafana services also run inside
containers.

### Local Development

Local development is done through Docker Compose using the usual commands.

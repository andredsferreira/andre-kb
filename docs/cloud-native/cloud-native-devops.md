# DevOps

DevOps practices applied to cloud native applications differ significantly from
traditional development and operation practices. Automation is the king of
DevOps in the cloud native world.

## Testing

Testing automation is crucial for cloud native applications.

For testing to make sense in seperate environments (dev and stage) these
environments need to be as close as production as possible. Stage should
particularly try not use mocks and use real dependencies as well as similar
infrastructure to production.

There are several types of tests in software, and they are posisioned
differently in the CI/CD pipeline. Below is a (non compreheensive) table with
some common types of tests and their characteristics.

| Type                   | Scope                                 | Purpose                                                                                             | Mocks                                                                    | Automation and Regularity                                                                           |
| ---------------------- | ------------------------------------- | --------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------- |
| Unit Tests             | Single modules (functions or classes) | Verify the smallest units of code work correctly                                                    | Mocks and stubs are heavily used for dependencies                        | Fully automated and executed first on the pipeline, after every commit                              |
| Service Tests          | Service                               | Verify a full service works as expected (for example in a microservices arch)                       | Mocks are only used for other services that interact with the tested one | Fully automated and usually executed after the unit tests on the pipeline, after every commit       |
| Integration Tests      | Multiple modules                      | Verify different modules work together correctly                                                    | Rarely used                                                              | Fully automated and usually executed on merges to staging environment                               |
| End to End (E2E) Tests | Whole system, including client apps   | Simulate and test real user interactions                                                            | Not used                                                                 | Can be automated but E2E tests are heavy and usually prefered to be ran after important deployments |
| Load Tests             | Whole system, excluding client apps   | Test the non functional requirements of the system and how it performs under expected or peak load  | Not used                                                                 | Can be automated but are executed periodically (pre-release or quarterly)                           |
| Penetration Tests      | Whole system, including client apps   | Tests the security of the full application to find vulnerabilities across the entire attack surface | Not used                                                                 | Not automated, performed by cybsersecurity experts periodically                                     |

## Monitoring

*Monitoring is important during the stages of CI/CD but it's specially important
in the release stage.*

Examples of monitoring tools include: Grafana (with Prometheus), AWS CloudWatch.
Prometheus scrapes metrics and stores them, Grafana connects to Pormetheus to
create visualization dashboards from the metrics.

Primary metrics in monitoring:

- *Error rate*: The number of requests that returned errors, usually in the form
  of HTTP 500 responses.

- *Incoming request rate*: The rate of the incoming traffic that's hitting the
  application.

- *Latency*: The time it takes to process requests.

- *Utilization*: How the resources in different nodes are being used (for
  example in a Kubernetes cluster).

## Observability

Captures everything that monitoring doesn't. Monitoring provides general
information about system health while observability goes into morre details on
each service providing tools for logging, tracing, etc. Example tools: ELK
Stack, Splunk, Datadog (full observability platform including metrics).

### Logging

Logging is crucial and you should develop your services with this considerations
in mind:

- Use structured logging so that other tools can parse it (JSON will be the most
  common).

- Provide detailed timestamps for each log.

- Categorize logs (debug, info, error, for example).

- Store logs in a central place so they can be processed by tools like Grafana
  (S3 buckets are a great option).

- You should use correlation IDs (CIDs) for a request that may hit multiple
  services. This way it helps to aggregate those requests as belonging to the
  same flow.

### Distributed Tracing

*Distributed Tracing*: Helps you understand what happens when a request goes
through multiple services. Distributed tracing tools can manage the generation
of CIDs, and can also include logging. Example tools: Jaeger, Zipkin, Grafana
Tempo, AWS X-Ray.

## Configuration Management

Like the twelve factor app manifesto entails, configuration variables should be
seperate from the application. You can either store configuration in environment
variables or configuration files for example. Usually what is considered
configuration data is something that changes between environments common
examples include:

- Database connection info: url, password, user, port.

- External services API URLs (like a payment gateway).

- Feature flags.

- TLS certificates.



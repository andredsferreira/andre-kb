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


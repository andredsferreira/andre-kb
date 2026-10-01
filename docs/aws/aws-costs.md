## Networking

| Description                   | Cost                                                                                                                      |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| Internet Ingress              | FREE                                                                                                                      |
| Internet Egress               | FREE for the first 100GB in month; then around €0.09/GB up to 10TB, reducing gradually to a maximum of €0.05 above 150TB. |
| Same AZ network traffic.      | FREE                                                                                                                      |
| Cross-AZ network traffic.     | Around €0.01/GB in both directions.                                                                                       |
| Cross-Region network traffic. | Around €0.02/GB between EU and US; €0.08/GB for distant regions.                                                          |
| Same Region from EC2 to S3    | FREE (if it doesn't go through NAT gateway)                                                                               |
| NAT Gateway                   | Around €0.045 per hour and €0.045/GB processing.                                                                          |

Most costs accumulate doe to NAT gateway standbys and internet egress.
# AWS Cloudwatch

Metrics are specific to an AWS region.

*Basic monitoring*: AWS services send metrics every five minutes to cloudwatch
(they may however collect data points between every minute, EC2 collects CPU
utilization every minute by default and sends the average to cloudwatch every 5
minutes). In other words, the minimum resolution for basic monitoring is 5
minutes. Basic monitoring is free.

*Detailed monitoring*: AWS services send metrics every minute (or less) to
cloudwatch. Costs can vary but they are aproximate to 0.015$ per instance per
hour in the case of the EC2 service.

## Metrics Expiration

Metrics cannot be deleted. They expire based on their resolution. They progress
from higher resolution metrics (measured within less than a minute) to low
resolution metrics. When the reach the resolution of 1 hour the remain available
for 15 months.

## Cloudwatch Logs


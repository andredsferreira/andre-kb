# AWS CloudWatch

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

## CloudWatch Logs

*Log streams*: A group log events (activity recorded by an application or
service) from the same source.

*Log group*: A group of log streams. A log group can have infinite streams but
one stream can only belong to one log group.

## Metric Alarms

The period of an alarm should be equal or greater than the metric's resolution.
For example, a metric has a resolution of 5 minutes and you want to montitor CPU
usage over a 15 minute period. You should set the alarm to gather data points
every 5 minutes (same as metric's resolution) and average them for the 15 minute
period.

Alarms can be triggered if n out of m data points cross the alarm threshold.
Where n is the number of data points that need to cross the threshold for the
alarm to trigger; and the m is the evaluation period (the total number of points
that will be gathered)

## Actions

Certain actions can be performed when an alarm transitions state (not limited to
OK -> ALARM state).

| Action              | Description                                                      |
| ------------------- | ---------------------------------------------------------------- |
| SNS Action          | An alarm can send a notification to an SNS topic.                |
| Auto Scaling Policy | An alarm can trigger an existing auto scaling policy.            |
| EC2 Action          | An alarm can stop, terminate, recover or reboot an EC2 instance. |


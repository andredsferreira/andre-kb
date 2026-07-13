# Amazon EventBridge 

Triggers actions based on specific events (CloudWatch triggers based on metric
values). For example, subscribing to an SNS topic as soon as an EC2 instance
stops.

*Event Bus*: Receives events for AWS services and can trigger actions based on
them. By default every account has a bus that receives events from all AWS
services.

When EventBridge triggers an action it acts as a principal
(events.amazonaws.com) therefore it needs resource based permissions and cannot
assume IAM roles (sames as the SNS and SQS services).
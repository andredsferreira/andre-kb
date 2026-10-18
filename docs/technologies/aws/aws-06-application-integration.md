## Amazon Simple Notification Service (SNS)

SNS is a fully managed **pub-sub** message service. It has no storage, just
pushes messages from publishers to subscribers.

**Publisher**: Your own application code (through the SDK) or AWS Service
(CloudWatch alarms, S3 Event Notifications, AWS Lambda, or EventBridge) that
sends messages to endpoints called topics.

**Topic**: An endpoint on SNS that is responsible for receiving requests from
publishers asynchronously and sending notifications to clients.

**Subscriber**: Subscribe to SNS topics. They receive messages from the topics.
Can be multiple of them on one topic. Much like publishers they can be HTTP
endpoints or an AWS Service, or notification service like Email or SMS.

You can have several examples with SNS but a common one is having an API service
publish a message on an SNS topic when an order is processed for example. Then
clients like Email Notification Services (delivered through an AWS Lambda) or
SQS react to that message.

## Amazon Simple Queue Service (SQS)

When a consumer receives a message (by calling **ReceiveMessage**) SQS does not
immedietly remove that message from the queue, it places a **visibility timeout** on
that message (30 sec by default), aka, that message is invisible to other
consumers. If the consumer successfully processed the message it should call the
**DeleteMessage** endpoint so that the message can be deleted from the queue. If the
consumer failed to process the message in the time span of the visibility
timeout, SQS will restore the message's visiblity. Another consumer (maybe the
same) can then try to process it, if the **maxReceiveCount** is reached then the
message is placed on the Dead Letter Queue.

**Dead Letter Queue (DLQ)**: A queue where message that have reached the maximum
retries by the consumer are placed. They can be replaced in the normal SQS queue
for processing again if needed.

## Amazon EventBridge

EventBridge is a serverless event bus service that integrates tightly with AWS
Services. **Sources** emit **events** to a **bus**. **Rules** then match
(through the use of **event patterns**) and deliver the events to **targets**.
Finally targets perform a specific action.

EventBridge comes with a **default bus** that receives events from all AWS
Services that work with EventBridge.

**Publishers (event sources)** in EventBridge are AWS Services (many of them can
publish to EventBridge), SDK Clients (code), SaaS partners (Github, Datadog,
etc), and the EventBridge Scheduler itself.

More than one rule can match the same event. Each rule has a maximum of five
targets. 

EventBridge also has a DLQ for failed events deliveries. By default it retries
the event delivery up to 24h.

One of the main features of EventBridge is also the capability of event
transformation (input transformation).








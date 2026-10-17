## EC2

[Terraform examples](../../cloud-native/aws/aws-core-services/aws-ec2/)

| Instance Family       | Description | Prefix  |
| --------------------- | ----------- | ------- |
| General Purpose       |             | M, T    |
| Compute Optimized     |             | C       |
| Memory Optimized      |             | X, R, Z |
| Accelerated Computing |             | G, P    |
| Storage Optimized     |             | I       |
| HPC Workloads         |             |         |

AWS uses the APIPA address: 169.254.169.254 for EC2 instance metadata. You can
easily see with, for example: curl http://169.254.169.254/latest/meta-data/instance-id

### Instance Pricing

| Instance Pricing  | Description                                                                         |
| ----------------- | ----------------------------------------------------------------------------------- |
| On Demand         | Default, pay by the hour.                                                           |
| Spot Instances    | Up to 90% discount on regular instances. May be shutted down whenever AWS needs to. |
| Reserved Capacity | Reserve capacity for 1-3 years and save (being replaced by savings plans).          |
| Savings Plans     | Similar to reserved capacity but more flexible, opt for this one.                   |

### Tenancy

| Tenancy            | Description                                                                               |
| ------------------ | ----------------------------------------------------------------------------------------- |
| Shared             | Default, your instance shares the hardware with other AWS accounts.                       |
| Dedicated Instance | Hardware is assigned only to your account. Instances on your account share that hardware. |
| Dedicated Host     | You get separate hardware to run your instances.                                          |

**Root Volume**: An EBS volume that is created with the instance and stores the
OS and everything the instance needs to boot. You can persist the root volume
even if you delete the EC2 instance, depending on how you setup the
DeleteOnTermination parameter.

**AMI (Amazon Machine Image)**: EC2 instances are launched from AMIs which
contain infromation about the OS, disk layout, launch permissions and optional
pre-installed software. You can think of them the same as a Dockerfile creates
containers, with specified configuration, AMIs create EC2 instances.

**Launch Templates**: Launch templates represent a template which configures an
EC2 instance further than an AMI. A Launch template contains information about
the AMI, Instance Type, SGs, etc. They are requried for ASGs. All of the fields
on a launch template **are optional**, so you can only indicate what you want
configured. **Versioning** is enabled on Launch Templates, meaning when you modify
one you never touch the previous version, you automatically create a new
version.

### Auto Scaling Groups (ASG)

**Min Size**: The minimum threshold of an ASG. The number of instances will
never drop below this.

**Max Size**: The maximum threshold of an ASG. The number of instances will
never go above this.

**Desired Capacity**: The number of instances the ASG will start immediatly,
when you launch it. It must be between min and max size inclusive.

It is very common to have an ELB in front of your ASG. If you are building a
service with an ASG this most likely means you will need to distribute traffic
across multiple EC2 instances, that's where an ELB comes (depending on the type
of service the ELB is an ALB or NLB). Also ELB provides application level
health checking.

You don't need an ELB in front if say you only have a fleet of EC2 instances
that poll from a queue.

ASGs need **launch templates** in order two autoscale the EC2 instances they
manage. This is a requirement.

ASGs monitor your EC2 instances replacing ones that are unealthy. There are two
types of monitoring. **EC2 monitoring** is enabled by default and tracks hardware
failures, network, etc. Then there is **ELB health checking**, which provides
application level health checking.

#### ASGs Scaling Policies

**Target Tracking**: ASG will try to maintain a certain metric and value that
you define for your EC2 instances, and it will scale accordingly. For example,
maintain average CPU usage at 60%, or average request count at 3000.

**Step Scaling**: Specifically define how you scale at different steps. For
example, add an extra instance if average CPU exceeds 70%, add 3 more if it
exceeds 90%.

**Scheduled Scaling**: The ASG will scale on a schedule you define. For example,
scale to 10 instances between 9am and 12 am; scale to 4 from 12 am to 6 pm; and
scale to 2 from 6pm to 9am.

You can combine **multiple scaling policies** in one ASG. Is there are conflicts
they are resolved by assuming the policy that provides the biggest capacity.

For starting out it's recommended that you define target tracking scaling policy
on CPU average or request count. Then you can move to more complex scaling
policies when you understand your app's traffic patterns.

## AWS Lambda

AWS Lambda is serverless code that runs **short lived tasks** in **event
driven** architectures. Lambda functions can trigger from events like: HTTP
request; S3 events; SNS Topics; SQS Queues; EventBridge Events; etc.

Lambda excels at short lived tasks (it has a maximum runtime of 15 minutes). At
**sustained throughputs** it's better to use other compute options like EC2 or
EKS. Lambda functions don't maintain state between executions.

Lambda scales automatically, depending on requests. If a 100 or 1000 requests
for a function execution come in, Lambda spins 100 or 1000 seperate environments
in **parallel**.

**Cold start**: Happens when a Lambda function executes for the first time: it
needs to spin up an execution environment causing some latency (latency varies a
lot depending on the runtime Java, Python, etc. But it's roughly between 100-500
ms). The subsequent executions don't suffer from this, they start from a **warm
environment**. After a while of not executing the environment is shutted down
again and if the Lambda is called it starts from a cold start again.

**Provisioned Concurrency**: Provisioned concurrency let's you pre initializes a
static number of execution environments for Lambda functions so that they don't
suffer from cold starts. You can also autoscale the number of concurrency
environments but this is something that is not available on the Web Console only
through the CLI or IaC tools like Terraform (resource like
aws_appautoscaling_target, aws_appautoscaling_policy,
aws_appautoscaling_scheduled_action, etc).

**Execution Role**: Every Lambda runs with an Execution Role which is an IAM
Role that Lambda assumes at runtime and specifies which services the function
can interact with. If you want your function to interact with S3 or DynamoDB for
example, you should specify that in the role's policy.

Lambda comes automatically configured with CloudWatch. This can be a surprise in
the bill. Lambda sends logs to cloudwatch for every stderr and stdlog output of
your function. You cannot disable this, however you can revoke the permissions
to write to cloudwatch in the Execution's Role policy (deny logs:CreateLogGroup,
logs:CreateLogStream, and logs:PutLogEvents).

Lambda is cheap, good for starting projects and POCs: "A concrete example, a 128
MB function that runs for 200ms and handles 5 million requests per month costs
roughly 1.70€ in duration charges plus 0.80€ in request charges, under 3€ total.
At low to moderate volumes, Lambda is inexpensive"

You should store initialization code and importing libraries in module level
code and not inside the function handler. Otherwise it will take more time to
run the actual function.
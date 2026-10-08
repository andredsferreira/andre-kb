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

| Instance Pricing  | Description                                                                         |
| ----------------- | ----------------------------------------------------------------------------------- |
| On Demand         | Default, pay by the hour.                                                           |
| Spot Instances    | Up to 90% discount on regular instances. May be shutted down whenever AWS needs to. |
| Reserved Capacity | Reserve capacity for 1-3 years and save (being replaced by savings plans).          |
| Savings Plans     | Similar to reserved capacity but more flexible, opt for this one.                   |

| Tenancy            | Description                                                                               |
| ------------------ | ----------------------------------------------------------------------------------------- |
| Shared             | Default, your instance shares the hardware with other AWS accounts.                       |
| Dedicated Instance | Hardware is assigned only to your account. Instances on your account share that hardware. |
| Dedicated Host     | You get separate hardware to run your instances.                                          |

**Root Volume**: An EBS volume that is created with the instance and stores the
OS and everything the instance needs to boot. You can persist the root volume
even if you delete the EC2 instance, depending on how you setup the
DeleteOnTermination parameter.


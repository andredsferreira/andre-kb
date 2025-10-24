# AWS EC2

AWS EC2 service provides compute power in the cloud, using VM's. In AWS
terminology a VM is called an instance.

In every reboot an instance may get a different IP address, if you need a
persistent static IP address you need to provide the instance an EIP (Elastic IP
Address). EIPs have no charge as long as they are attached to a running
instance.

## Tenancy models

| Tenancy            | Description                                                                 |
| ------------------ | --------------------------------------------------------------------------- |
| Dedicated Instance | Instance runs on a dedicated physical server.                               |
| Dedicated Host     | Provides a physical server, that you have full control, for your instances. |

## Instance Pricing

| Pricing Model     | Description                                                                      |
| ----------------- | -------------------------------------------------------------------------------- |
| On Demand         | The default model you pay per hour of use.                                       |
| Reserved Instance | You reserve an instance for 2-3 years of use.                                    |
| Spot Instances    | You bid on an instance in the marketplace and it runs until someone outbids you. |

## EC2 Storage Volumes

There are two main types of storage volumes: *elastic block store volumes (EBS)*
and *instance volumes*.

### Elastic Block Store Volumes (EBS)

You can have multiple storage volumes, but storage volumes can only be attached
to a single instance at once. The data is durable and reliable.

*Snapshots*: Are copies/backups that are created of the data in the volumes.

| Type                     | Description                                                                              |
| ------------------------ | ---------------------------------------------------------------------------------------- |
| EBS General-Purpose SSD  | Most regular servers will work fine with this type.                                      |
| EBS Provisioned IOPS SSD | Used for intense rates of I/O operations.                                                |
| HDD Volume               | For large data stores where quick access to the data isn't important and cost saving is. |

### Instance Volumes

Unlike EBS, the data in instance volumes is lost once the machine is shutted
down. Every instance created has an instance volume attached to it by default.

## Accessing an EC2 instance

The safest way to access an EC2 instance nowadays is to use AWS SSM. Assuming
the instance is in a private subnet (if the instance is in a public subnet step
3 is skipped) these are the steps required to successfully access the instance
(see[this](../../iac/terraform/aws/ec2/simple_arm_instance.tf) for a practical
Terraform configuration that creates an instance and the minimal resources
necessary to connect to it via SSM).

1. The instance must have the SSM agent installed (AML, Ubuntu, and Windows AMIs
   have it preinstalled).

2. The instance must have an IAM role attached to it with the following managed
   policy: AmazonSSMManagedInstanceCore.

3. Have an outbound internet connection via NAT gateway. Or if you want to avoid
   internet connection have a VPC endpoint to SSM.

4. Have a security group that allows outbound HTTPS traffic.

### Auto Scaling

Launch templates can be modified by creating new versions of it, however launch
configurations cannot be modified at all. Launch templates are the recommended
way to launch ASG instances.
# Fundamentals Of DevOps

This document contains some notes regarding the book "Fundamentals of Devops and
Software Delivery - A Hands-On Guide to Deplying and Managing Software in
Production" by Yevgeniy Brikman.

---

The goal of DevOps is to make software delivery vastly more efficient.

## Deploying an application

You can choose either *on prem*, *cloud*, or an *hybrid* environment that
combines both.

## PaaS and IaaS

*PaaS*: Takes care of most of the deployment for your app. Usually more
expensive, less flexibility and more limitations.

*IaaS*: Provides the enviornment, but you take care of the deployment. Less
expensive, more flexibility and less limitions. Harder to execute.

In general you should go PaaS when you can, transfer to IaaS when you need to.

## Mutable and Immutable Infrastructure

*Mutable infrastructure*: The infrastructure you have is considered long running
(years) and you apply changes to it over time. This can cause configuration
drift.

*Immutable infrastructure*: The infrastructure you have is short lived. You
replace servers with new ones everytime you change something, discarding the old
ones.

Immutable infrastructure is the norm today thanks to cloud and virtualization.

## IaC

Infrastructure and server configuration should always be defined in code
(declarative state).

| Type of IaC Tool        | Example        | Description                                                               |
| ----------------------- | -------------- | ------------------------------------------------------------------------- |
| Provisioning Tools      | Terraform      | Directly provision (build) the infrastructure.                            |
| Configuration Tools     | Ansible        | Configure servers/VMs through the use of declarative configuration files. |
| Server Templating Tools | Packer, Docker | Templates for creating VMs, or containers.                                |

## Deployment Strategies

### Core

*Downtime Deployment*: The system becomes unavailable while undergoing deployment.

*Rolling-Release Deployment*: You provide extra servers with the new versions of
the system. When the start passing health checks the traffic is redirected to
them. The consequence is that will be a brief period where both the old and new
versions coexist. But once the new version servers are all functioning the old
ones are destroyed.

*Blue-Green Deployment*: Similar to rolling-release except you deploy the new
version and wait for it to pass all health checks. Then, after that traffic is
redirected to the new version at once and the old one is destroyed.

### Extra

*Canary Deployment*: You deploy a single instance of the new version to test and
see how the system reacts to user traffic. If everything goes well you can apply
the full deployment by using one of core strategies.

*Feature-Toggle*: This is a very cool pattern from DevOps and very powerfull. It
boils down to seperating the *deployment* from the *release* of the new version.
You deploy the new version on top of the old one but you add a toggle to it,
which is initially off. Users only see the new version when you toggle on. You
can gradually toggle new versions on different servers.
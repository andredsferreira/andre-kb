# Fundamentals Of DevOps

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

| Type of IaC Tool        | Example        | Description |
| ----------------------- | -------------- | ----------- |
| Provisioning Tools      | Terraform      |             |
| Configuration Tools     | Ansible        |             |
| Server Templating Tools | Packer, Docker |             |
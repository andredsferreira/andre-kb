output "instance_arn" {
  value = tolist(data.aws_ssoadmin_instances.organization_instance.arns)
}

output "identity_store_id" {
  value = tolist(data.aws_ssoadmin_instances.organization_instance.identity_store_ids)
}
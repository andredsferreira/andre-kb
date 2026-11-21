output "submit_command" {
  value = "aws batch submit-job --region ${data.aws_region.current.region} --job-name test-1 --job-queue ${aws_batch_job_queue.main.name} --job-definition ${aws_batch_job_definition.hello.name}"
}

output "log_group" {
  value = aws_cloudwatch_log_group.batch.name
}

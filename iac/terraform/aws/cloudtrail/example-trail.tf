resource "aws_cloudtrail" "write_only_trail" {
  name                          = "write-only-management-events"
  s3_bucket_name                = aws_s3_bucket.trail_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "WriteOnly"
    include_management_events = true
  }
}

resource "aws_dynamodb_table" "table" {
  name         = "dynamodb-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  range_key    = "order_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "order_id"
    type = "S"
  }

  # Default
  server_side_encryption {
    enabled = true
  }

  tags = {
    Name = "dynamodb-table"
  }
}

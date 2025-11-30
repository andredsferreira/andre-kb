# Creating a dynamo db table specifying the write and read capacities.
# Auto-scaling and reserved capacity options are also avaialable for read and
# write capacities.

resource "aws_dynamodb_table" "authors" {
  name           = "Authors"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1

  hash_key  = "LastName"
  range_key = "FirstName"

  attribute {
    name = "LastName"
    type = "S"
  }

  attribute {
    name = "FirstName"
    type = "S"
  }
}

# DynamoDB table with streams enabled

resource "aws_dynamodb_table" "books" {
  name           = "Books"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1

  hash_key = "Title"

  attribute {
    name = "Title"
    type = "S"
  }

  # Enabling streams on the DynamoDB table
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
}

# DynamoDB table with TTL enabled
resource "aws_dynamodb_table" "sessions" {
  name           = "Sessions"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1

  hash_key = "SessionId"

  attribute {
    name = "SessionId"
    type = "S"
  }

  attribute {
    name = "ExpiresAt"
    type = "N"
  }

  # Enabling TTL on the DynamoDB table
  ttl {
    attribute_name = "ExpiresAt"
    enabled        = true
  }
}

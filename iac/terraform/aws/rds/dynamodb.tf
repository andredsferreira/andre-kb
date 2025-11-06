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

##########################################################################################

# A terraform backend provides a safe way to store the infrastructure state
# (.tfstate). We need a bucket to store the state, a database to prevent race
# conditions on terraform apply, i.e, to lock the state, and the backend
# resource itself.

# VERY IMPORTANT NOTE: The way a backend is created is a bit awkward. First you
# have to create the infrastructure necessary for the backend, using "terraform
# apply", in this step you should comment the backend configuration. After this
# is done you uncomment the backend configuration and run "terraform init".

# OTHER IMPORTANT NOTE: The backend block does not allow variables! Sad...

# Backend configuration:

terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "terraform-locks"
    encryp         = true
  }
}

##########################################################################################

# Creating the bucket for state file

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state"

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }
}

# Enable bucket versioning

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server side encryption by default

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Explicitly block all public access to the S3 bucket

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

##########################################################################################

# Creating DynamoDB table for locking

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

##########################################################################################


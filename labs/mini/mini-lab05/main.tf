module "function" {
  source  = "brikis98/devops/book//modules/lambda"
  version = "1.0.0"

  name        = "lambda-sample"
  src_dir     = "${path.module}/src"
  runtime     = "provided.al2"
  handler     = "bootstrap" # name of the Go binary must be "bootstrap"
  memory_size = 128
  # Timeout in seconds (max: 900 seconds, i.e., 15 minutes)
  timeout     = 5

  create_url = true
}

################################################################################

# Public zone

resource "aws_route53_zone" "pub_zone" {
  name = "akb.pt"
}

# Private zone (within the VPC)

resource "aws_route53_zone" "priv_zone" {
  name = "akb.priv.pt"

  vpc {
    vpc_id = "vpc-1234567890abcdef"
  }
}

################################################################################

# Registering an A record for the previous public zone. 
# This A record points to an existing Application Load Balancer.

data "aws_lb" "alb" {
  name = "my-alb"
}

resource "aws_route53_record" "alb_alias" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app.akb.pt"
  type    = "A"

  alias {
    name                   = data.aws_lb.alb.dns_name
    zone_id                = data.aws_lb.alb.zone_id
    evaluate_target_health = false
  }
}

################################################################################

# Route 53 provides health checks for the resources it is managing. 
# It routes traffic depending on wether the resources pass or not the health
# checks.

# Example of HTTP status health check.

resource "aws_route53_health_check" "example" {
  fqdn              = data.aws_lb.app.dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  # How many consecutive failures are required until the endpoint is
  # considered unhealthy by Route 53.
  failure_threshold = "5"
  # The health check will be sent every 30 seconds.
  request_interval  = "30"

  tags = {
    Name = "tf-test-health-check"
  }
}

################################################################################

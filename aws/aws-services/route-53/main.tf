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
# This A record points to an existing Application Load Balancer (check data.tf).

resource "aws_route53_record" "alb_alias" {
  zone_id = aws_route53_zone.pub_zone.zone_id
  name    = "app-default"
  type    = "A"

  alias {
    name                   = data.aws_lb.alb_01.dns_name
    zone_id                = data.aws_lb.alb_01.zone_id
    evaluate_target_health = false
  }
}

################################################################################

# Route 53 provides health checks for the resources it is managing. 
# It routes traffic depending on wether the resources pass or not the health
# checks.

# Example of HTTP status health check.

resource "aws_route53_health_check" "example" {
  fqdn          = data.aws_lb.alb_01.dns_name
  port          = 80
  type          = "HTTP"
  resource_path = "/"
  # How many consecutive failures are required until the endpoint is
  # considered unhealthy by Route 53.
  failure_threshold = 5
  # The health check will be sent every 30 seconds.
  request_interval = 30

  tags = {
    Name = "tf-test-health-check"
  }
}

################################################################################

# Examples of different routing policies (simple is the default so it's
# not shown). 

# Weighted routing

resource "aws_route53_record" "weighted_record_01" {
  zone_id = aws_route53_zone.pub_zone.zone_id
  name    = "weighted-app"
  type    = "A"

  alias {
    name                   = data.aws_lb.alb_01.dns_name
    zone_id                = data.aws_lb.alb_01.zone_id
    evaluate_target_health = true
  }

  set_identifier = "weighted-01-record"

  weighted_routing_policy {
    # 70% percent of requests are routed to this record.
    weight = 70
  }
}

resource "aws_route53_record" "weighted_record_02" {
  zone_id = aws_route53_zone.pub_zone.zone_id
  name    = "weighted-app"
  type    = "A"

  alias {
    name                   = data.aws_lb.alb_02.dns_name
    zone_id                = data.aws_lb.alb_02.zone_id
    evaluate_target_health = true
  }

  set_identifier = "weighted-02-record"

  weighted_routing_policy {
    # 30% (remaining of 70%) are routed to this record.
    weight = 30
  }
}

# Latency based routing

resource "aws_route53_record" "latency_record_eu_west" {
  zone_id = aws_route53_zone.pub_zone.zone_id
  name    = "app.example.com"
  type    = "A"

  set_identifier = "latency-record-eu-west-3"

  alias {
    name                   = data.aws_lb.alb_01.dns_name
    zone_id                = data.aws_lb.alb_01.zone_id
    evaluate_target_health = true
  }

  latency_routing_policy {
    region = "eu-west-3" # Region that this record should serve.
  }
}

resource "aws_route53_record" "latency_record_us" {
  zone_id = aws_route53_zone.pub_zone.zone_id
  name    = "app.example.com"
  type    = "A"

  alias {
    name                   = data.aws_lb.alb_02.dns_name
    zone_id                = data.aws_lb.alb_02.zone_id
    evaluate_target_health = true
  }

  set_identifier = "latency_record-us-east-1"

  latency_routing_policy {
    region = "us-east-1"
  }
}

# Failover routing

resource "aws_route53_record" "primary_failover" {
  zone_id = aws_route53_zone.pub_zone.zone_id
  name    = "app.example.com"
  type    = "A"

  set_identifier = "primary"

  alias {
    name                   = data.aws_lb.alb_01.dns_name
    zone_id                = data.aws_lb.alb_01.zone_id
    evaluate_target_health = true
  }

  failover_routing_policy {
    type = "PRIMARY"
  }
}


resource "aws_route53_record" "secondary_failover" {
  zone_id = aws_route53_zone.pub_zone.zone_id
  name    = "app.example.com"
  type    = "A"

  set_identifier = "secondary"

  alias {
    name                   = data.aws_lb.alb_02.dns_name
    zone_id                = data.aws_lb.alb_02.zone_id
    evaluate_target_health = true
  }

  failover_routing_policy {
    type = "SECONDARY"
  }
}

# Geolocation routing

resource "aws_route53_record" "geolocation_eu" {
  zone_id = aws_route53_zone.pub_zone.zone_id
  name    = "app.example.com"
  type    = "A"

  alias {
    name                   = data.aws_lb.alb_02.dns_name
    zone_id                = data.aws_lb.alb_02.zone_id
    evaluate_target_health = true
  }

  set_identifier = "europe"
  geolocation_routing_policy {
    continent = "EU"
  }
}

resource "aws_route53_record" "geolocation_na" {
  zone_id = aws_route53_zone.pub_zone.zone_id
  name    = "app.example.com"
  type    = "A"

  alias {
    name                   = data.aws_lb.alb_01.dns_name
    zone_id                = data.aws_lb.alb_01.zone_id
    evaluate_target_health = true
  }

  set_identifier = "north-america"
  geolocation_routing_policy {
    continent = "NA"
  }
}

# Multivalue policy

resource "aws_route53_record" "multivalue_1" {
  zone_id = aws_route53_zone.pub_zone.zone_id
  name    = "app.example.com"
  type    = "A"
  ttl     = 60
  records = [data.aws_instance.instance_01.private_ip]

  set_identifier = "multivalue-01"

  multivalue_answer_routing_policy = true

}

resource "aws_route53_record" "multivalue_2" {
  zone_id = aws_route53_zone.pub_zone.zone_id
  name    = "app.example.com"
  type    = "A"
  ttl     = 60
  records = [data.aws_instance.instance_02.private_ip]

  set_identifier = "multivalue-02"

  multivalue_answer_routing_policy = true
}

################################################################################

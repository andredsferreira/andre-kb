##########################################################################################

# Web application firewall allows us to block traffic based the content of HTTP
# requests. We can then associate this firewall with either Regional requests
# (coming from an ALB, API Gateway, AppSync, etc), or Global requests coming from
# the Cloudfront service.

# Web ACL (applies WAF rules)

resource "aws_wafv2_web_acl" "waf01" {
  name        = "waf-01-waf"
  description = "WAF to block requests > 1KB"
  scope       = "REGIONAL" # Use CLOUDFRONT for global

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "waf01WAF"
    sampled_requests_enabled   = true
  }

  # Rule the requests larger than 1KB
  rule {
    name     = "block-large-requests"
    priority = 1

    action {
      block {}
    }

    statement {
      size_constraint_statement {
        comparison_operator = "GT"
        size                = 1024
        field_to_match {
          body {}
        }
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "blockLargeRequests"
      sampled_requests_enabled   = true
    }
  }
  
  # Instead of writting your own rules like above you can use AWS managed rule
  # groups. The AWS managed common rule set prevents common attacks like SQL
  # injection, XSS, remote file inclusion, etc.
  rule {
    name     = "aws-managed-common-rules"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
        # Optional: exclude or include certain rules
        # excluded_rule {
        #   name = "SizeRestrictions_BODY"
        # }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRules"
      sampled_requests_enabled   = true
    }
  }

}

##########################################################################################

# Associating the WAF with an ALB (creating the ALB first).

resource "aws_lb" "waf01-alb" {
  name               = "waf01-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = []
  subnets            = ["subnet-xxxxxx", "subnet-yyyyyy"]
}

resource "aws_wafv2_web_acl_association" "alb_assoc" {
  resource_arn = aws_lb.waf01.arn
  web_acl_arn  = aws_wafv2_web_acl.waf01.arn
}

##########################################################################################

# Associating the WAF with an API, with API Gateway (creating the API Gateway
# first).


resource "aws_apigatewayv2_api" "waf01-api" {
  name          = "waf01-api"
  protocol_type = "HTTP"
}

resource "aws_wafv2_web_acl_association" "api_assoc" {
  resource_arn = aws_apigatewayv2_api.waf01.arn
  web_acl_arn  = aws_wafv2_web_acl.waf01.arn
}

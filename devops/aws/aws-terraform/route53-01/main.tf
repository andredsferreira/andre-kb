resource "aws_vpc" "this" {
  cidr_block = "10.10.0.0/16"
  tags = {
    "ToDelete" = true
  }
}


resource "aws_route53_zone" "private_hosted_zone" {
  name = "wwww.example.com"
  vpc {
    vpc_id = aws_vpc.this.id
  }
}
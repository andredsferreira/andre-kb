provider "aws" {
  region = "eu-west-3"
}

module "asg" {
  source  = "brikis98/devops/book//modules/asg"
  version = "1.0.0"

  name          = "sample-app-asg"                          
  ami_name      = "sample-app-packer-*"                     
  user_data     = filebase64("${path.module}/user-data.sh") 
  app_http_port = 8080                                      

  instance_type    = "t2.micro"                             
  min_size         = 3                                      
  max_size         = 5                                      

  target_group_arns = [module.alb.target_group_arn]

  # This block regards zero downtime deployment.
  instance_refresh = {
    # During new deployments the ASG will always try to 
    # keep 100% of the min_size instances (in this case 3).
    min_healthy_percentage = 100
    # During new deployments it will double the min_size instances 
    # (200% of 3), 3 will have the new deployment, and 3 the old one.
    # Once the 3 new are healthy the 3 old are removed.
    max_healthy_percentage = 200  
    auto_rollback          = true 
  }
}

module "alb" {
  source  = "brikis98/devops/book//modules/alb"
  version = "1.0.0"

  name                  = "sample-app-alb" 
  alb_http_port         = 80               
  app_http_port         = 8080             
  app_health_check_path = "/"              
}

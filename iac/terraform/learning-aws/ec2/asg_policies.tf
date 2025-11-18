#####################################################################################

# Simple policies

# Change In Capacity

resource "aws_autoscaling_policy" "simple_scale_up" {
  name                   = "simple-scale-up"
  autoscaling_group_name = aws_autoscaling_group.asg_01.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
}

resource "aws_autoscaling_policy" "simple_scale_down" {
  name                   = "simple-scale-down"
  autoscaling_group_name = aws_autoscaling_group.asg_01.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
}

# Exact Capacity

resource "aws_autoscaling_policy" "simple_scale_up" {
  name                   = "simple-scale-up"
  autoscaling_group_name = aws_autoscaling_group.asg_01.name
  policy_type            = "StepScaling"
  adjustment_type        = "ExactCapacity"
  scaling_adjustment     = 3
}

resource "aws_autoscaling_policy" "simple_scale_down" {
  name                   = "simple-scale-down"
  autoscaling_group_name = aws_autoscaling_group.asg_01.name
  policy_type            = "StepScaling"
  adjustment_type        = "ExactCapacity"
  scaling_adjustment     = 1
}

# Percent change 

resource "aws_autoscaling_policy" "scale_up_percent" {
  name                   = "scale-up-percent"
  autoscaling_group_name = aws_autoscaling_group.asg_01.name
  policy_type            = "StepScaling"
  adjustment_type        = "PercentChangeInCapacity"
  scaling_adjustment     = 50 # +50% of current capacity
}

resource "aws_autoscaling_policy" "scale_down_percent" {
  name                   = "scale-down-percent"
  autoscaling_group_name = aws_autoscaling_group.asg_01.name
  policy_type            = "StepScaling"
  adjustment_type        = "PercentChangeInCapacity"
  scaling_adjustment     = -25 # -25% of current capacity
}

#####################################################################################

# Target tracking policy

resource "aws_autoscaling_policy" "cpu_target" {
  name                   = "cpu-target-policy"
  autoscaling_group_name = aws_autoscaling_group.asg_01.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}

#####################################################################################

# Step scaling policy

resource "aws_autoscaling_policy" "cpu_step" {
  name                   = "cpu-step-policy"
  autoscaling_group_name = aws_autoscaling_group.asg_01.name
  policy_type            = "StepScaling"

  adjustment_type = "ChangeInCapacity"

  step_adjustment {
    metric_interval_lower_bound = 0
    scaling_adjustment          = 1
  }

  step_adjustment {
    metric_interval_upper_bound = 0
    scaling_adjustment          = -1
  }
}


provider "aws" {
  region = "eu-west-1"
}

data "template_file" "eng103a_project_template_file" {
  template = <<EOF
  #!/bin/bash

  sudo su

  kubeadm join 10.0.10.84:6443 --token tna5wy.kwuwvje2htmqnuun --discovery-token-ca-cert-hash sha256:a34aa9fb813a86379df56c57161edcd1fd516b207f87b36076e337921f07c6a0
  EOF
}

resource "aws_launch_configuration" "eng103a_project_launch_configuration" {
  name_prefix     = "eng103a-lc-"
  image_id        = "ami-01dd530743d8d9302"
  instance_type   = "t2.micro"
  security_groups = ["sg-0d6ce5401866a0b04"]
  key_name        = "eng103a_project"
  user_data       = base64encode(data.template_file.eng103a_project_template_file.rendered)


  root_block_device {
    volume_size           = "20"
    volume_type           = "gp2"
    encrypted             = false
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

}



# resource "aws_launch_template" "eng103a_project_launch_configuration" {
#   name_prefix            = "eng103a-lc-"
#   image_id               = "ami-01dd530743d8d9302"
#   instance_type          = "t2.micro"
#   vpc_security_group_ids = ["sg-0d6ce5401866a0b04"]
#   key_name               = "eng103a_project"
#   user_data              = base64encode(data.template_file.eng103a_project_template_file.rendered)

#   block_device_mappings {
#     device_name = "/dev/sda"

#     ebs {
#       volume_size = "20"
#       volume_type = "gp2"
#     }
#   }


#   lifecycle {
#     create_before_destroy = true
#   }
# }

resource "aws_autoscaling_group" "eng103a_project_asg" {
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.eng103a_project_launch_configuration.name
  vpc_zone_identifier  = ["subnet-065a0ff785a6dc741"]
  name                 = "eng103a_project_asg"
}

resource "aws_lb" "eng103a_project_lb" {
  name               = "eng103a-project-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-0d6ce5401866a0b04"]
  subnets            = ["subnet-065a0ff785a6dc741", "subnet-0adf364d7af02a159", "subnet-073c40b770af80fab"]

  tags = {
    Name = "eng103a_project_lb"
  }
}

resource "aws_lb_listener" "eng103a_project_lb_listener" {
  load_balancer_arn = aws_lb.eng103a_project_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eng103a_project_target_group.arn
  }
}

resource "aws_lb_target_group" "eng103a_project_target_group" {
  name     = "eng103a-project-asg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-092baf0cb22ee569f"
}

resource "aws_autoscaling_attachment" "eng103a_project_autoscaling_attachment" {
  autoscaling_group_name = aws_autoscaling_group.eng103a_project_asg.id
  alb_target_group_arn   = aws_lb_target_group.eng103a_project_target_group.arn
}

resource "aws_autoscaling_policy" "eng103a_project_scale_up" {
  name                   = "eng103a_project_scale_up"
  autoscaling_group_name = aws_autoscaling_group.eng103a_project_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_autoscaling_policy" "eng103a_project_scale_down" {
  name                   = "eng103a_project_scale_down"
  autoscaling_group_name = aws_autoscaling_group.eng103a_project_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "eng103a_project_scale_up_alarm" {
  alarm_description   = "Monitors CPU utilization for Application"
  alarm_actions       = [aws_autoscaling_policy.eng103a_project_scale_up.arn]
  alarm_name          = "eng103a_project_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "50"
  evaluation_periods  = "1"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.eng103a_project_asg.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "eng103a_project_scale_down_alarm" {
  alarm_description   = "Monitors CPU utilization for Application"
  alarm_actions       = [aws_autoscaling_policy.eng103a_project_scale_down.arn]
  alarm_name          = "eng103a_project_scale_down"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "30"
  evaluation_periods  = "1"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.eng103a_project_asg.name}"
  }
}

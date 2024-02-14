# 시작 템플릿 
resource "aws_launch_template" "example" {
    name = "aws17-example-tamplate"
    image_id = "ami-08fad555456323fb3"
    instance_type = "t2.micro"
    key_name = "aws17-key"
    vpc_security_group_ids = [aws_security_group.web.id, aws_security_group.ssh.id]

    user_data = "${base64encode(data.template_file.web_output.rendered)}"

    lifecycle {
      create_before_destroy = true
    }
}
# 오토스케일링 스룹 
resource "aws_autoscaling_group" "example" {
  availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]
  # vpc_zone_identifier = ["subnet-0f02b373f7f78e4a2","subnet-09f682d70ced2e4a1"]
  # vpc_zone_identifier = [var.subnet-2a,var.subnet-2c]
  name = "aws17-asg-example"
  desired_capacity  = 1
  min_size          = 1
  max_size          = 2

  launch_template {
    id = aws_launch_template.example.id 
    version = "$Latest"
  }
  tag {
    key = "Name"
    value = "aws17-asg-example"
    propagate_at_launch = true


  }
}


resource "aws_security_group" "web" {
    name = "aws17-example-web"
    #vpc_id = var.vpc-id

    ingress {
      from_port = var.web_port
      to_port = var.web_port
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
 }
}
resource "aws_security_group" "ssh" {
    name = "aws17-example-ssh"
    #vpc_id = var.vpc-id

    ingress {
      from_port = var.ssh_port
      to_port = var.ssh_port
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
 }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "template_file" "web_output" {
  template = file("${path.module}/web.sh")
  vars = {
    web_port = "${var.web_port}"
  }
}
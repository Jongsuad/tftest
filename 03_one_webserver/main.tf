provider "aws" {
    region = "ap-northeast-2"
  
}

resource "aws_instance" "exaple" {
    ami              = "ami-09eb4311cbaecf89d"
    instance_type    = "t2.micro"
    vpc_security_group_ids = [aws_security_group.web.id, aws_security_group.ssh.id]
    key_name = "aws17-key"

    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p ${var.web_port} &
                EOF


    tags = {
        Name = "aws17-webserver"
    }
}

resource "aws_security_group" "web" {
    name = "aws17-example-instance-web"
  
    ingress {
      from_port = var.web_port
      to_port = var.web_port
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
 }
}

resource "aws_security_group" "ssh" {
    name = "aws17-example-instance-ssh"
  
    ingress {
      from_port = var.ssh_port
      to_port = var.ssh_port
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
 }
}
output "public_ip" {
    value = aws_instance.exaple.public_ip
    description = "The public IP of the Instance"
}

variable "web_port" {
    description = "The port will use for HTTP requests"
    type = number
    default = 8080
  
}

variable "ssh_port" {
    description = "The port will use for SSH requests"
    type = number
    default = 22
  
}
resource "aws_instance" "bastion" {
  ami           = "ami-09eb4311cbaecf89d"
  instance_type = "t2.micro"
  key_name      = "aws17-key"
  // 퍼블릭 ip 활성화 
  associate_public_ip_address = true
  security_groups = [data.terraform_remote_state.security_group.outputs.ssh_id]

  subnet_id = data.terraform_remote_state.vpc.outputs.public-subnet-2a-id
   #"subnet-0188b2d9029b538fb"
  tags = {
    Name = "aws17-bastion"
  }
}


resource "aws_instance" "jenkins" {
  ami                         = "ami-09eb4311cbaecf89d"
  instance_type               = "t3.large"
  key_name                    = "aws17-key"
  private_ip                  = "10.17.64.100" 
  security_groups             = [data.terraform_remote_state.security_group.outputs.ssh_id,
                                 data.terraform_remote_state.security_group.outputs.http_id ]
  subnet_id = data.terraform_remote_state.vpc.outputs.private-subnet-2a-id

  user_data = templatefile("templates/userdata.sh", {})  

  tags = {
    Name = "aws17-jenkins"
  }
}
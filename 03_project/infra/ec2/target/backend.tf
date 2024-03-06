terraform {
  backend "s3" {
    bucket         = "aws17-terraform-state"
    region         = "ap-northeast-2"
    key            = "infra/ec2/target/terraform.tfstate"
    dynamodb_table = "aws17-terraform-locks"
    encrypt        = true
  }
}
provider "aws" {
    region = "ap-northeast-2"
}

data "aws_vpc" "default" {
    filter{
        name = "tag:Name"
        values = ["eks-vpc"]
    }
}

data "aws_subnets" "example" {
    filter {
        name = "vpc-id"  
        values = [ data.aws_vpc.default.id ]
    }
}

data "aws_subnet" "example" {
    for_each = toset(data.aws_subnets.example.ids)
    id = each.value
}
output "subnet_output" {
    value = [for i in data.aws_subnet.example : i.cidr_block]
  

}

output "vpc-id" {
    value = data.aws_vpc.default.id
}


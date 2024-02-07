variable "vpc_cidr" {
    default = "10.17.0.0/16"
  
}
variable "public_subnet" {
    type = list
    default = ["10.17.0.0/20","10.17.16.0/20"]
}
variable "private_subnet" {
    type = list
    default = ["10.17.64.0/20","10.17.80.0/20"]
}
variable "azs" {
    type = list
    default = ["ap-northeast-2a","ap-northeast-2c"]
}
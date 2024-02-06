variable "user_names" {
    description = "Create IAM users with these names"
    type        = list(string)
    default     = ["aws17-neo", "aws17-trinity", "aws17-morpheus"]
  
}
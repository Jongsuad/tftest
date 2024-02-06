variable "user_names" {
    description = "Create IAM users with these names"
    type        = list(string)
    default     = ["aws17-n", "aws17-t", "aws17-mo"]
  
}
variable "vpc_id" {}
variable "public_subnet_ids" {
  type = list(string)
}
variable "name_prefix" {}
variable "ami_id" {
  description = "AMI to use for EC2 instance"
}

variable "target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "image_url" {
  description = "URL of the image to display on the web page"
  type        = string
}
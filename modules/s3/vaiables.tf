variable "name_prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "destination_bucket_arn" {
  type    = string
  default = null
}
variable "vpc_id" {}
variable "name_prefix" {}
variable "public_subnet_ids" {
  type = list(string)
}
//riable "security_group_ids" {
 //ype = list(string)
//}
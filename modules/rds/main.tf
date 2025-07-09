#  terraform {
#   required_providers {
    # aws = {
    #   source  = "hashicorp/aws"
    #   version = "~> 5.0"
    # }
#   }
# }

# resource "aws_db_subnet_group" "rds_subnet_group" {
#   name       = "${var.name_prefix}-rds-subnet-group"
#   subnet_ids = var.private_subnet_ids

#   tags = {
    # Name = "${var.name_prefix}-rds-subnet-group"
#   }
# }

# resource "aws_db_instance" "rds_instance" {
#   identifier           = "${var.name_prefix}-rds"
#   engine               = var.engine
#   engine_version       = var.engine_version
#   instance_class       = var.instance_class
#   allocated_storage    = var.storage_size
#   db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
#   skip_final_snapshot  = true
#   publicly_accessible  = false
#   multi_az             = false
#   backup_retention_period = 7
#   replicate_source_db = var.replicate_source_db != "" ? var.replicate_source_db : null

 
#   username = var.replicate_source_db == "" ? var.username : null
#   password = var.replicate_source_db == "" ? var.password : null


#   tags = {
    # Name = "${var.name_prefix}-rds"
#   }
# }

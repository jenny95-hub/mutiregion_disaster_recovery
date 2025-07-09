provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "tokyo"
  region = "ap-northeast-1"
}

module "vpc_mumbai" {
  source      = "./modules/vpc"
  name_prefix = "mumbai"
  region      = "ap-south-1"
  octet       = 1
  providers = { aws = aws.mumbai }
}

module "vpc_tokyo" {
  source      = "./modules/vpc"
  name_prefix = "tokyo"
  region      = "ap-northeast-1"
  octet       = 2
  providers = { aws = aws.tokyo }
}

module "ec2_mumbai" {
  source           = "./modules/ec2"
  name_prefix      = "mumbai"
  vpc_id           = module.vpc_mumbai.vpc_id
  public_subnet_ids = module.vpc_mumbai.public_subnet_ids
  ami_id           = "ami-03f4878755434977f"
  providers        = { aws = aws.mumbai }
  target_group_arn  = module.alb_mumbai.target_group_arn
  image_url = module.s3_static_assets_mumbai.image_url
}

module "alb_mumbai" {
  source            = "./modules/alb"
  name_prefix       = "mumbai"
  vpc_id            = module.vpc_mumbai.vpc_id
  public_subnet_ids = module.vpc_mumbai.public_subnet_ids
  providers         = { aws = aws.mumbai }
}

module "s3_tokyo" {
  source                = "./modules/s3"
  name_prefix           = "tokyo"
  region                = "ap-northeast-1"
  destination_bucket_arn = null
  providers             = { aws = aws.tokyo }
}

data "aws_s3_bucket" "tokyo_bucket" {
  bucket   = module.s3_tokyo.bucket_name
  provider = aws.tokyo
}

module "s3_mumbai" {
  source                = "./modules/s3"
  name_prefix           = "mumbai-terraform-state0089"
  region                = "ap-south-1"
  destination_bucket_arn = data.aws_s3_bucket.tokyo_bucket.arn
  providers             = { aws = aws.mumbai }
}

module "s3_static_assets_mumbai" {
  source      = "./modules/s3_static_assets"
  name_prefix = "mumbai"
  region      = "ap-south-1"
  providers   = { aws = aws.mumbai }
}

output "mumbai_image_url" {
  value = module.s3_static_assets_mumbai.image_url
}

module "s3_static_assets_tokyo"{
  source      = "./modules/s3_static_assets"
  name_prefix = "tokyo"
  region      = "ap-northeast-1"
  providers   = { aws = aws.tokyo}
}

output "tokyo_image_url" {
  value = module.s3_static_assets_tokyo.image_url
}

# module "rds_mumbai" {
#   source              = "./modules/rds"
#   name_prefix         = "mumbai"
#   private_subnet_ids  = module.vpc_mumbai.private_subnet_ids
#   username            = "admin"
#   password            = "MyRdsPassword123"
#   providers   = { aws = aws.mumbai }
# }

# module "rds_tokyo" {
#   source               = "./modules/rds"
#   name_prefix          = "tokyo"
#   private_subnet_ids  = module.vpc_tokyo.private_subnet_ids
#   replicate_source_db  = module.rds_mumbai.rds_instance_arn
#   username             = "" # Must be blank to avoid conflict
#   password             = "" # Must be blank to avoid conflict
#   providers             = { aws = aws.tokyo }
# }
# output "tokyo_private_subnets" {
#   value = module.vpc_tokyo.private_subnet_ids
# }

module "ec2_tokyo" {
  source           = "./modules/ec2"
  name_prefix      = "tokyo"
  vpc_id           = module.vpc_tokyo.vpc_id
  public_subnet_ids = module.vpc_tokyo.public_subnet_ids
  ami_id           = "ami-07b3f199a3bed006a"
  providers        = { aws = aws.tokyo}
  target_group_arn  = module.alb_tokyo.target_group_arn
  image_url = module.s3_static_assets_tokyo.image_url
}


module "alb_tokyo"{
  source            = "./modules/alb"
  name_prefix       = "tokyo"
  vpc_id            = module.vpc_tokyo.vpc_id
  public_subnet_ids = module.vpc_tokyo.public_subnet_ids
  providers         = { aws = aws.tokyo}
}
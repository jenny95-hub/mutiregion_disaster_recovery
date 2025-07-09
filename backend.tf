terraform{
backend "s3" {
  bucket = "mumbai-terraform-state0089-terraform-state-499af9"
key    = "dr-infra/terraform.tfstate"
region = "ap-south-1"
encrypt = true
}
}

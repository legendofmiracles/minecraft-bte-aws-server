# aws profile
variable "aws-profile" {
  type = string
}

# region
variable "aws-region" {
  type = string
}

# key-name 
variable "ec2-key-pair-name" {
  type = string
}

# bucket name for tf state
variable "tf-bucket" {
  type = string
}

# define the region specific ami images
variable "ami-images" {
  type = map(string)

  default = {
    "eu-central-1" = "ami-0233214e13e500f77"
  }
}

# define the region specific availability zone
variable "aws-zones" {
  type = map(string)

  default = {
    "eu-central-1" = "eu-central-1a"
  }
}


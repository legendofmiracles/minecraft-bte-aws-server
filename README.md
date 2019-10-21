# Terraform-deplay a minecraft server

Deploy Minecraft server using terraform to AWS. 

Uses lambda functions to create and destroy a Minecraft server instance with terraform. S3 is used for server backups and for storing terraform resources. Lambda functions can send notifications to a Discord channel.

## Prerquisites
* An AWS account with credentials for programmatic access
* Download and install terraform

## Manual Configuration
* Create S3 bucket for terraform state
* Create S3 bucket for minecraft backup
* Create Elastic IP
* Create EC2 key

Enter corresponding values in `config/account.tfvars`.
Copy [latest Minecraft server download URL](https://www.minecraft.net/en-us/download/server/) into `files/mc-server.sh`.

## Initial Install
* `cd iac`
* `terraform init`
* `terraform apply -var-file=../config/account.tfvars`
* Sit back and enjoy the show

## The man behind the curtain
Beyond the allocation of AWs resources, the terraform script triggers modification of the ec2 instance. It installs the Minecraft server and adds crontab entries for syncing the minecraft directory to S3 and detecting idle state. Once idle state has been detected, it triggers the destruction of the ec2 instance via the afore mentioned lambda function.


auto_shutoff.py - Runs on the minecraft server 

mine-build.py - This is used in a lambda function. It pulls terraform files and startup bash script from s3 and starts an ec2 instance.

mine-destroy.py - Used in a lambda function to run terraform destroy and update the terraform state file in the s3 bucket

minecraft.sh - start up script use for ec2 instance

server.tf - terraform configuration file.

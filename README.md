# Terraform-deplay a minecraft server

Deploy Minecraft server using terraform to AWS. 

Uses lambda functions to auto-destroy a Minecraft server instance after inactivity. S3 is used for Minecraft world backups and for storing terraform state. Lambda function sends notifications to a Discord channel.

## Prerquisites
* An AWS account with credentials for programmatic access
* Download and install terraform
* Python, and pip installed

## Manual Configuration
### Local
* Install virtualenv: `sudo pip install virtualenv`

. venv/bin/activate
pip install -r requirements.txt

### AWS
* Create S3 bucket for terraform state
* Create S3 bucket for minecraft backup
* Create Elastic IP
* Create EC2 key

Enter corresponding values in `config/account.tfvars`.
Copy [latest Minecraft server download URL](https://www.minecraft.net/en-us/download/server/) into `src/mc-server.sh`.

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

## Debugging
* Logging into ec2 instance: `ssh -i ~/.ssh/minecraft.pem ec2-user@<eip>`
* Listing available screen sessions: `screen -ls`
* Re-attaching to minecraft screen session: `screen -r minecraft`

## Additional links
* https://www.codingforentrepreneurs.com/blog/install-django-on-mac-or-linux - installing python on MacOS
* https://jeremievallee.com/2017/03/26/aws-lambda-terraform.html - deploying AWs Lambda with terraform

## Updating Minecraft
* Add new Minecraft version download URL in `src/mc-setup.sh`
* Remove `eula.txt` file in root of minecraft backup S3 bucket
* Re-apply terraform with `terraform apply -var-file=../config/account.tfvars`

# McTerraform - A terraform'ed Minecraft BTE (build the earth) server (with auto-destroy on inactivity) 
This is a fork from [hlgr360/McTerraform](https://github.com/hlgr360/McTerraform), which in turn is again a fork from [aqemery/Terraform-deploy-minecraft](https://github.com/aqemery/Terraform-deploy-minecraft)
Deploy Minecraft BTE server using terraform to AWS. 

Uses lambda functions to auto-destroy a Minecraft server instance after 15 minutes of inactivity. S3 is used for Minecraft world backups and for storing terraform state. 

Future functionality:
* add Discord bot for both starting and stopping the Minecraft instance

## Prerequisites
* An AWS account with user credentials for programmatic access - see <https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html#id_users_create_console>
* Download and install terraform from <https://www.terraform.io/downloads.html>
* For running the scripted setup of the Terraform resoources, install the AWS CLI at <https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html>
### AWS
* Create IAM credentials for programmatic access and add locally [as named AWS credential](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
  * Update `config/account.tfvars`, `iac/mc-static/config.tf`, and `iac/mc-server/config.tf` with your credentials and your region and an unique name for your S3 bucket for Terraform state

### Setup
Very Very Important!!! :  Update `config/account.tfvars`, `iac/mc-static/config.tf`, and `iac/mc-server/config.tf` with your credentials and your region and an unique name for your S3 bucket for Terraform state.

##### Scripted Setup (the better way)
* make sure you have a `.aws` folder in your home directory, and a file called `credentials` in there with your credentials stored like that:
```
[default]
aws_access_key_id = <your key>
aws_secret_access_key = <your passwd>
[<your uname>]
aws_access_key_id = <same acress key>
aws_secret_access_key = <same passwd>
```
Replace everything in `<>`
* Run `./init_tf_req.sh`in the root of the locally cloned repo

### Deployment Options
* Copy [latest Minecraft server download URL](https://www.minecraft.net/en-us/download/server/) into `src/mc-server.sh`.

### Deployment Initialisation
* Init terraform: `terraform init` in `iac/mc-static`and `iac/mc-server`

## Deployment
### Static Resources (once)
* Change to static infrastructure setup: `cd iac/mc-static`
* Execute: `terraform apply -var-file=../../config/account.tfvars`
* Creates: S3 bucket for Minecraft World backup, Public IP, SNS topic plus attached Lambda for auto-destroy

### Server Resources
* Change to server infrastructure setup: `cd iac/mc-server`
* Execute: `terraform apply -var-file=../../config/account.tfvars`
* Creates: Minecraft Server with attached Public IP

## How it all works
Beyond the allocation of AWs resources, the terraform script triggers modification of the ec2 instance. It installs the Minecraft server, downloads the S3 backed-up minecraft world to the local instance, and add's a crontab script for detecting idle state. Once idle state has been detected, it triggers a backup of the current minecraft world to S3, and triggering the destruction of the ec2 instance by sending an empty message on the SNS destroy topic.

Attached to the SNS Topic is a lambda function, which downloads and installs terraform locally within the lambda context and executes a 'terraform destroy' on the server resources.

## Misc
### Debugging
* Logging into ec2 instance using the EC2 key: `ssh -i ~/.ssh/minecraft.pem ec2-user@<eip>`
* then tail the log of the mc server using the command: `tail -f minecraft/nohup.out`
* Or the log of the last run should also appear in the s3 bucket after a autosave. 

### Updating Minecraft
* Add new Minecraft version download URL in `src/mc-setup.sh`
* Remove `eula.txt` file in root of minecraft backup S3 bucket
* Re-apply terraform with `terraform apply -var-file=../config/account.tfvars`

### Additional links
* https://www.codingforentrepreneurs.com/blog/install-django-on-mac-or-linux - installing python on MacOS
* https://jeremievallee.com/2017/03/26/aws-lambda-terraform.html - deploying AWs Lambda with terraform


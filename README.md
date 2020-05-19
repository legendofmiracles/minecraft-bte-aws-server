# McTerraform - A terraform'ed Minecraft BTE (build the earth) server (with auto-destroy on inactivity) 
This is a fork from [hlgr360/McTerraform](https://github.com/hlgr360/McTerraform), which in turn is again a fork from [aqemery/Terraform-deploy-minecraft](https://github.com/aqemery/Terraform-deploy-minecraft)
Deploy Minecraft BTE server using terraform to AWS. 

Uses lambda functions to auto-destroy a Minecraft server instance after 15 minutes of inactivity. S3 is used for Minecraft world backups and for storing terraform state. 


### Cost
* This costs you money every month, because of the elastic ip
* And always when the instance is running, it costs you money aswell

Future functionality:
* add Discord bot for both starting and stopping the Minecraft instance

# How to setup
* Go through Prequesities and Setup

## Prerequisites
* An AWS account with user credentials for programmatic access - see <https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html#id_users_create_console>
* Download and install terraform from <https://www.terraform.io/downloads.html>
* For running the scripted setup of the Terraform resoources, install the AWS CLI at <https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html>
### AWS
* Create IAM credentials for programmatic access and add locally [as named AWS credential](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
  * Update `config/account.tfvars`, `iac/mc-static/config.tf`, and `iac/mc-server/config.tf` with your credentials and your region and an unique name for your S3 bucket for Terraform state

##### Scripted Setup
* If you want to debug it, you will have to go into the aws console and make a ssh key named minecraft which you then have to download  
* make sure you have a `.aws` folder in your home directory, and a file called `credentials` in there with your credentials stored like that:
```~/.aws/credentials
[default]
aws_access_key_id = <your key>
aws_secret_access_key = <your passwd>
[<your uname>]
aws_access_key_id = <same acress key>
aws_secret_access_key = <same passwd>
```
Replace everything in `< >`

* Replace every `alx365` with your username in the `config/account.tfvars` as well as in `mc-static/config.tf` and in `mc-static/config.tf` also in `mc-destroy.py` 

* Run `./init_tf_req.sh`in the root of the locally cloned rep.
**Doesn't work on windows. You should be able to copy the commands from there and then run them manually. I am not sure, because i am not on windows**

### Deployment Initialisation
* Init terraform: `terraform init` in `iac/mc-static`and `iac/mc-server`

## Deployment
### Static Resources (only do this once!)
* Change to static infrastructure setup: `cd iac/mc-static`
* Execute: `terraform apply -var-file=../../config/account.tfvars`
* Creates: S3 bucket for Minecraft World backup, Public IP, SNS topic plus attached Lambda for auto-destroy

### Server Resources (Do this every time you want to start the server)
* Change to server infrastructure setup: `cd iac/mc-server`
* Execute: `terraform apply -auto-approve --var-file ../../config/account.tfvars`
* Creates: Minecraft Server with attached Public IP
If you wanted to shut it down, without a backup replace the `apply` with a `destroy`.

## How it all works
Beyond the allocation of AWs resources, the terraform script triggers modification of the ec2 instance. It installs the Minecraft server, downloads the S3 backed-up minecraft world to the local instance, and add's a crontab script for detecting idle state. Once idle state has been detected, it triggers a backup of the current minecraft world to S3, and triggering the destruction of the ec2 instance by sending an empty message on the SNS destroy topic.

Attached to the SNS Topic is a lambda function, which downloads and installs terraform locally within the lambda context and executes a 'terraform destroy' on the server resources.

## Misc
### Debugging
* Logging into ec2 instance using the EC2 key: `ssh -i ~/.ssh/minecraft.pem ec2-user@<eip>`
* then tail the log of the mc server using the command: `tail -f minecraft/nohup.out`
* Or the log of the last run should also appear in the s3 bucket after a autosave. 


### Additional links
* https://www.codingforentrepreneurs.com/blog/install-django-on-mac-or-linux - installing python on MacOS
* https://jeremievallee.com/2017/03/26/aws-lambda-terraform.html - deploying AWs Lambda with terraform

### Contributing
* feel free to contribute. 
* But you can just clone the repo and tailor it to your needs. But the cloned repo **has** to be using the Apache 2 license

Have fun!

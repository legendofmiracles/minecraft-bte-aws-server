# McTerraform - A terraform'ed Minecraft server (with auto-destroy on inactivity) 

Deploy Minecraft server using terraform to AWS. 

Uses lambda functions to auto-destroy a Minecraft server instance after inactivity. S3 is used for Minecraft world backups and for storing terraform state. 

Future functionality:
* add Discord bot for both starting and stopping the Minecraft instance

## Prerquisites
* An AWS account with credentials for programmatic access
* Download and install terraform
* For local development: python, and pip installed

## Configuration
### Local Development
* Install virtualenv: `sudo pip install virtualenv`
* Change into source directory `cd src` 
* Activate venv: `. venv/bin/activate`
* Install dependencies: `pip install -r requirements.txt`

### AWS
* Create IAM credentials for programmatic access and add locally as named AWS credential
* Create S3 bucket and DynamoDB table for terraform state
* Create EC2 key

### Deployment Configuration
* Modify `config/account.tfvars`.
* Copy [latest Minecraft server download URL](https://www.minecraft.net/en-us/download/server/) into `src/mc-server.sh`.

### Deployment Initialisation
* Init terraform: `terraform init` in `iac/mc-static`and `iac/mc-server`

## Deployment
### Static Resources (once)
* Change to static infrastructure setup: `cd iac/mc-static`
* Execute: `terraform apply -var-file=../../config/account.tfvars`
* Creates: S3 bucket for mc world backup, Public IP, SNS topic plus attached Lambda for auto-destroy

### Server Resources
* Change to server infrastructure setup: `cd iac/mc-server`
* Execute: `terraform apply -var-file=../../config/account.tfvars`
* Creates: Minecraft Server with attached Public IP

## How it all works
Beyond the allocation of AWs resources, the terraform script triggers modification of the ec2 instance. It installs the Minecraft server, downloads the S3 backed-up minecraft world to the local instance, and add's a crontab script for detecting idle state. Once idle state has been detected, it triggers a backup of the current minecraft world to S3, and triggering the destruction of the ec2 instance by sending an empty message on the SNS destroy topic.

Attached to the SNS Topic is a lambda function, which downloads and installs terraform locally within the lambda context and executes a 'terraform destroy' on the server resources.

## Misc
### Debugging
* Logging into ec2 instance: `ssh -i ~/.ssh/minecraft.pem ec2-user@<eip>`
* Listing available screen sessions: `screen -ls`
* Re-attaching to minecraft screen session: `screen -r minecraft`

### Updating Minecraft
* Add new Minecraft version download URL in `src/mc-setup.sh`
* Remove `eula.txt` file in root of minecraft backup S3 bucket
* Re-apply terraform with `terraform apply -var-file=../config/account.tfvars`

### Additional links
* https://www.codingforentrepreneurs.com/blog/install-django-on-mac-or-linux - installing python on MacOS
* https://jeremievallee.com/2017/03/26/aws-lambda-terraform.html - deploying AWs Lambda with terraform


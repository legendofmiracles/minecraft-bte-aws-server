#!/bin/bash
#set -ex

# parse iac/mc-static/config.tf
profile=`cat iac/mc-static/config.tf | sed -e 's/[{}[:space:]]/''/g' -e 's/"//g' | awk -F"=" '$1=="profile" {print $2}' | sed -e 's#//[a-zA-Z]*##g' | sed -e 's#var.[-a-zA-Z]*##g'`
bucket=`cat iac/mc-static/config.tf | sed -e 's/[{}[:space:]]/''/g' -e 's/"//g' | awk -F"=" '$1=="bucket" {print $2}' | sed -e 's#//[a-zA-Z]*##g'`
region=`cat iac/mc-static/config.tf | sed -e 's/[{}[:space:]]/''/g' -e 's/"//g' | awk -F"=" '$1=="region" {print $2}' | sed -e 's#//[a-zA-Z]*##g' | sed -e 's#var.[-a-zA-Z]*##g'`

# create Terraform S3 bucket
aws s3api create-bucket --bucket $bucket --acl private --create-bucket-configuration LocationConstraint=$region --region $region --profile $profile

# create Terraform DynamoDB table
aws dynamodb create-table --table-name $bucket-lock --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 --region $region --profile $profile
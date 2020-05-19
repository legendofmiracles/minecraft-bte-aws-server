# -*- coding: utf-8 -*-

import os
import subprocess
import urllib
import requests
import boto3
import json


# Version of Terraform that we're using
TERRAFORM_VERSION = '0.12.24'

# Download URL for Terraform
TERRAFORM_LINUX_DOWNLOAD_URL = (
    'https://releases.hashicorp.com/terraform/%s/terraform_%s_linux_amd64.zip'
    % (TERRAFORM_VERSION, TERRAFORM_VERSION))
TERRAFORM_MACOS_DOWNLOAD_URL = (
    'https://releases.hashicorp.com/terraform/%s/terraform_%s_darwin_amd64.zip'
    % (TERRAFORM_VERSION, TERRAFORM_VERSION))

# Path of process execution
EXEC_DIR = '/tmp'

# Paths where Terraform should be installed
TERRAFORM_DIR = os.path.join(EXEC_DIR, 'terraform_%s' % TERRAFORM_VERSION)
TERRAFORM_PATH = os.path.join(TERRAFORM_DIR, 'terraform')

# TF Variables
TERRAFORM_STATE_S3_BUCKET = 'alx365-tf-state'
TERRAFORM_STATE_KEY = 'mc-server.tfstate'

# MC backup bucket (holding the TF config and account template)
MC_BACKUP_S3_BUCKET = 'alx365-mc-backup'


def send_discord_message(message):
    url = "" #Your discord webhook url here
    data = json.dumps({'content': message})
    header = {"Content-Type": "application/json", "User-Agent": "drop table webhooks"}
    response = requests.post(url, data, headers=header)

def check_call(args):
    """Wrapper for subprocess that checks if a process runs correctly,
    and if not, prints stdout and stderr.
    """
    proc = subprocess.Popen(args,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        cwd=EXEC_DIR)
    stdout, stderr = proc.communicate()
    if proc.returncode != 0:
        print(stdout)
        print(stderr)
        # send_discord_message("Error Destroying Server")
        raise subprocess.CalledProcessError(
            returncode=proc.returncode,
            cmd=args)


def install_terraform(install_url):
    """Install Terraform on the Lambda instance."""
    # Most of a Lambda's disk is read-only, but some transient storage is
    # provided in /tmp, so we install Terraform here.  This storage may
    # persist between invocations, so we skip downloading a new version if
    # it already exists.
    # http://docs.aws.amazon.com/lambda/latest/dg/lambda-introduction.html
    if os.path.exists(TERRAFORM_PATH):
        return

    urllib.request.urlretrieve(install_url, '/tmp/terraform.zip')

    # Flags:
    #   '-o' = overwrite existing files without prompting
    #   '-d' = output directory
    check_call('unzip -o /tmp/terraform.zip -d {0}'.format(TERRAFORM_DIR))
    check_call('{0} --version'.format(TERRAFORM_PATH))


def destroy_terraform_plan(s3_bucket, key):
    """Download a Terraform plan from S3 and run a 'terraform destroy'.

    :param s3_bucket: Name of the S3 bucket where the plan is stored.
    :param key: Path to the Terraform planfile in the S3 bucket.

    """
    s3 = boto3.resource('s3')

    # Copy TF config template
    configfile = s3.Object(MC_BACKUP_S3_BUCKET, 'config.tf')
    configfile.download_file('/tmp/config.tf')

    # init TF
    check_call('{0} init -input=false'.format(TERRAFORM_PATH))

    # Copy TF variable template
    accountfile = s3.Object(MC_BACKUP_S3_BUCKET, 'account.tfvars')
    accountfile.download_file('/tmp/account.tfvars')
    varfile = s3.Object(MC_BACKUP_S3_BUCKET, 'variables.tf')
    varfile.download_file('/tmp/variables.tf')

    # Although the /tmp directory may persist between invocations, we always
    # download a new copy of the planfile, as it may have changed externally.
    planfile = s3.Object(s3_bucket, key)
    planfile.download_file('/tmp/terraform.tfstate')

    # invoke TF destroy
    check_call('{0} destroy -force -state=/tmp/terraform.tfstate -var-file=/tmp/account.tfvars'.format(TERRAFORM_PATH))

    # uplaod updated planfile
    s3.meta.client.upload_file('/tmp/terraform.tfstate', s3_bucket, key)


def handler(event, context):
    send_discord_message("Server is now turning off, due to inactivity")
    install_terraform(TERRAFORM_LINUX_DOWNLOAD_URL)
    destroy_terraform_plan(s3_bucket=TERRAFORM_STATE_S3_BUCKET, key=TERRAFORM_STATE_KEY)

if __name__ == '__main__':
    # local testing on MacOS
    install_terraform(TERRAFORM_MACOS_DOWNLOAD_URL)
    destroy_terraform_plan(s3_bucket=TERRAFORM_STATE_S3_BUCKET, key=TERRAFORM_STATE_KEY)

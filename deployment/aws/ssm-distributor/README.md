# Zscaler Microsegmentation

## Deployment Resources for AWS SSM Distributor

### Introduction
“Distributor, a capability of AWS Systems Manager, helps you package and publish software to AWS Systems Manager managed nodes.” [source](https://docs.aws.amazon.com/systems-manager/latest/userguide/distributor.html)

Distributor is a great way to deploy the Zscaler Microsegmentation agent to AWS EC2 instances. This document covers the process for configuring Distributor to do so.

### Prerequisites
* The AWS SSM agent must be installed on the endpoints. [Refer to this document](https://docs.aws.amazon.com/systems-manager/latest/userguide/ssm-agent.html) for more information.
* `unzip` must available on each endpoint
* `wget` or `curl` must be available on each endpoint
* An S3 bucket is required to host the deployment package. It is advisable to enable Versioning on the bucket. [Refer to this document](https://docs.aws.amazon.com/AmazonS3/latest/userguide/GetStartedWithS3.html#creating-bucket) for more information. 
* IAM permissions must be configured to allow SSM to manage EC2 instances. The Default Host Management Configuration option is sufficient. [Refer to this document](https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-instance-permissions.html) for more information.

### Configuration

#### Create the Installation Package

1. Copy the Agent Provisioning Key from the Zscaler UI. Paste this value into the provision_key file. It is advisable to do this using a command line text editor to make certain not to introduce file formatting characters.
2. Run the build-deployment-packages script appropriate for your local OS (.sh, .ps1)
3. Note the SHA256 hash output from each build script. Paste these values into the manifest.json file where indicated with “UPDATE_THIS_VALUE”.

#### Upload the Installation Package

1. Verify that all prerequisites are met
2. Upload the following files to the S3 bucket:
    * manifest.json
    * zscaler-microsegmentation-agent-windows.zip
    * zscaler-microsegmentation-agent-linux.zip

#### Configure AWS SSM Distributor

1. Select Create Package in the AWS SSM Distributor UI
2. Select Advanced
3. Provide a Name and Version
4. Provide the S3 Bucket Name and S3 Key Prefix
    * The Key Prefix should be the name of the S3 folder where the installation package files are stored
5. Leave the Manifest setting as Extract From Package. Select View Manifest File. Verify there are no Warnings or Errors listed in the Manifest file viewer.
6. Select Create Package

#### Deploy the Installation Package

AWS SSM provides two options for deploying a Distributor package: Install One Time, and Install on a Schedule.

##### Install One Time

1. Select Install One Time in the AWS SSM Distributor Package Details UI
2. On the next screen, Name and other details should already be populated
3. Configure the Target Selection section
4. Optionally, specify a location to send logs in the Output Options section
5. Select Run
6. On the next screen, monitor the status and result of the Run Command

### Updates 

#### Updating the Installation Package

To update the provision_key file or to make similar modifications to the contents of the installation package: 
1. Make the required changes
2. Delete the existing zscaler-microsegmentation-agent-*.zip files
3. Run the build-deployment-packages script
4. Update the manifest.json file with the new SHA256 values
5. Upload the new zscaler-microsegmentation-agent-*.zip files and manifest.json file to the S3 bucket, overwriting the previous files
6. In the AWS SSM Distributor Package Details UI select the sub-menu option Versions
7. Select Add Version and complete the wizard
8. Select the radio button that matches the new version and then select Set Default Version. Subsequent deployments of the installation package will use the latest version unless specified otherwise on the Run Command screen.

### Troubleshooting

#### Verify the Installation Package was Downloaded to the VM

##### Windows

`C:\ProgramData\Amazon\SSM\Packages\<appname>\<app version>`

##### Linux

`/var/lib/amazon/ssm/packages/<appname>/<app version>`

#### Review the Installation Logs

1. When configuring the SSM Distributor install command options, specify an S3 bucket or CloudWatch Logs log group as log targets in the Output Options section
    * Note, IAM roles and policies may affect SSM's ability to write logs to S3 and CloudWatch Logs
2. Review the logs written to S3 or CloudWatch Logs

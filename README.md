## Packer and Chef scripts to create a Azure DevOps build server (Windows) golden image (AMI)

Order of execution:
1. `berks vendor` to pull in dependancies
2. `packer build`:
- Initializes disks
- Runs Windows cookbook to add service account, create necessary folders, installs features, sets timezone
- Runs Software cookbook to install required software components
- Retarts instance
- Syspreps the instance
- Creates AMI

Finally, VSTS recipe should then be run during launch. I chose to use Chef solo in the CloudFormation launch config (not included in this repo).

I used a VSTS build definition to run the above, grab the AMI ID from the packer build output, then update the AMI ID variable in the deployment tool that's used to launch new instances.
 



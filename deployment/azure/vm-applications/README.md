# Zscaler Microsegmentation

## Deployment Resources for Azure VM Applications

### Introduction

“VM Applications are a resource type in Azure Compute Gallery (formerly known as Shared Image Gallery) that simplifies management, sharing and global distribution of applications for your virtual machines.” [source](https://learn.microsoft.com/en-us/azure/virtual-machines/vm-applications-how-to)

VM Applications is a great way to deploy the Zscaler Microsegmentation agent to Azure VM instances. This document covers the process for configuring Distributor to do so.

### Prerequisites

* The Azure VM Agent is required to be installed on each endpoint
* `wget` and `unzip` must installed on each endpoint
* An Azure Compute Gallery is required to use Azure VM Applications. [Refer to this document](https://learn.microsoft.com/en-us/azure/virtual-machines/vm-applications-how-to) for more information.
    * Note, an Azure Compute Gallery will be required for each applicable region.
* An Azure Storage Account is required to host the deployment package. [Refer to this document](https://learn.microsoft.com/en-us/azure/virtual-machines/vm-applications-how-to) for more information.
    * Note, an Azure Storage Account will be required for each applicable region.
    * Note, if the Storage Account is configured to use page blob (instead of block) then you must byte align the deployment package. [Refer to this document](https://learn.microsoft.com/en-us/azure/virtual-machines/vm-applications-how-to) for more information.
    * Note, Azure Compute Gallery and Azure VM Applications are not compatible with Storage Account Private Endpoints. 
    * Note, this document will use an SAS URI in order to provide time-bound private URL access to the deployment package stored in the Storage Account Container. This means that it is not required to provide RBAC or similar access to the container or files, however, it is still necessary to verify that Azure Compute Gallery is able to access the Storage Account endpoint.

### Configuration

#### Create the Installation Package

1. Copy the Agent Provisioning Key from the Zscaler UI. Paste this value into the provision_key file. It is advisable to do this using a command line text editor to make certain not to introduce file formatting characters.
2. Run the build-deployment-packages script appropriate for your local OS (.sh, .ps1)

#### Upload the Installation Package

1. Verify that all prerequisites are met
2. Upload the following files to the Azure Storage Account Container:
    * zscaler-microsegmentation-agent-windows.zip
    * zscaler-microsegmentation-agent-linux-rpm.zip
    * zscaler-microsegmentation-agent-linux-deb.zip
3. Select the first uploaded file. Click Generate SAS and then Generate SAS Token and URL. Copy the Blob SAS URL string and save it for a subsequent step. Perform this action for the other uploaded files.

#### Create a VM Application Definition - Windows

1. Navigate to the previously created Azure Compute Gallery. Select Add > VM Application Definition.
2. Provide a Name, Region, and OS Type. Select Review and then Create.
    * Note, a VM Application Definition will be required for each applicable OS type.

#### Create a VM Application Version - Windows

1. On the VM Application Definition summary screen, select Add to create a new VM Application Version.
2. Provide the following information:
    * Version number: Specify a version number.
    * Source application package: Paste the Blob SAS URL string from the Upload the Installation Package step above.
    * Install script:
    ```
    rename zscaler-microsegmentation-agent-windows zscaler-microsegmentation-agent-windows.zip & powershell.exe -Command "Expand-Archive -path zscaler-microsegmentation-agent-windows.zip -destinationpath C:\ProgramData\Zscaler\ZMS\installation -force; cd C:\ProgramData\Zscaler\ZMS\installation; .\install.ps1; Remove-Item provision_key"
    ```
    * Uninstall script:
    ```
    powershell.exe -Command "C:\ProgramData\Zscaler\ZMS\installation\uninstall.ps1; Remove-Item -recurse -force C:\ProgramData\Zscaler\ZMS\installation"
    ```
    * Package file name: zscaler-microsegmentation-agent-windows.zip
3. Select Review and then Create

#### Create a VM Application Definition - Linux \*RPM\*

1. Navigate to the previously created Azure Compute Gallery. Select Add > VM Application Definition.
2. Provide a Name, Region, and OS Type. Select Review and then Create.
    * Note, a VM Application Definition will be required for each applicable OS type.

#### Create a VM Application Version - Linux \*RPM\*

1. On the VM Application Definition summary screen, select Add to create a new VM Application Version.
2. Provide the following information:
    * Version number: Specify a version number.
    * Source application package: Paste the Blob SAS URL string from the Upload the Installation Package step above.
    * Install script:
    ```
    mv zscaler-microsegmentation-agent-linux-rpm zscaler-microsegmentation-agent-linux-rpm.zip; mkdir -p /opt/zscaler/zms/installation && unzip -o zscaler-microsegmentation-agent-linux-rpm.zip -d /opt/zscaler/zms/installation && chmod +x /opt/zscaler/zms/installation/*.sh && /opt/zscaler/zms/installation/install.sh &> /opt/zscaler/zms/installation/install.log
    ```
    * Uninstall script:
    ```
    /opt/zscaler/zms/installation/uninstall.sh && rm -rf /opt/zscaler/zms/installation &> /opt/zscaler/zms/installation/uninstall.log
    ```
    * Package file name: zscaler-microsegmentation-agent-linux-rpm.zip
3. Select Review and then Create

#### Create a VM Application Definition - Linux \*DEB\*

1. Navigate to the previously created Azure Compute Gallery. Select Add > VM Application Definition.
2. Provide a Name, Region, and OS Type. Select Review and then Create.
    * Note, a VM Application Definition will be required for each applicable OS type.

#### Create a VM Application Version - Linux \*DEB\*

1. On the VM Application Definition summary screen, select Add to create a new VM Application Version.
2. Provide the following information:
    * Version number: Specify a version number.
    * Source application package: Paste the Blob SAS URL string from the Upload the Installation Package step above.
    * Install script:
    ```
    mv zscaler-microsegmentation-agent-linux-deb zscaler-microsegmentation-agent-linux-deb.zip; mkdir -p /opt/zscaler/zms/installation && unzip -o zscaler-microsegmentation-agent-linux-deb.zip -d /opt/zscaler/zms/installation && chmod +x /opt/zscaler/zms/installation/*.sh && /opt/zscaler/zms/installation/install.sh &> /opt/zscaler/zms/installation/install.log
    ```
    * Uninstall script:
    ```
    /opt/zscaler/zms/installation/uninstall.sh && rm -rf /opt/zscaler/zms/installation &> /opt/zscaler/zms/installation/uninstall.log
    ```
    * Package file name: zscaler-microsegmentation-agent-linux-deb.zip
3. Select Review and then Create

#### Deploy the Installation Package

##### Deploy to One VM (UI)

1. Navigate to Virtual Machines in the Azure Portal. Click on a VM and then expand the Settings menu. Select Extensions + Applications. Then select the VM Applications sub-menu.
2. Select Add Application
3. Select the row that shows the Zscaler Microsegmentation application that was previously created. Optionally, choose the Version.
4. Select Save. The application will be automatically installed within a few minutes.

##### Deploy to Multiple VMs (Azure Cloud Shell / PowerShell)

1. Start a new Azure Cloud Shell instance of type PowerShell. Modify and run the following commands to deploy the application to all VMs in the provided VM Resource Group. This process will automatically select the latest published version of the VM Application.
```
$vm_resource_group = “”
$compute_gallery_name = “”
$compute_gallery_app_name = “”
$compute_gallery_resource_group = “”

$vm_ids = az vm list --resource-group $vm_resource_group --query "[*].id" | ConvertFrom-Json

$latest_app_version = az sig gallery-application version list --resource-group $compute_gallery_resource_group --gallery-name $compute_gallery_name --application-name $compute_gallery_app_name --query "max_by([].{id:id, date:publishingProfile.publishedDate}, &date)" | ConvertFrom-Json

az vm application set --ids $vm_ids --app-version-ids $latest_app_version.id
```
2. To verify deployment:
```
$vm_ids = az vm list --resource-group $vm_resource_group --query "[*].id" | ConvertFrom-Json

$vm_ids | Foreach {
    Write-Output "ID: $_"
    az vm get-instance-view --ids $_ --query "instanceView.extensions[?name == 'VMAppExtension']"
}
```

### Updates 

#### Updating the Installation Package

To update the provision_key file or to make similar modifications to the contents of the installation package: 
1. Make the required changes
2. Delete the existing zscaler-microsegmentation-agent-*.zip files
3. Run the build-deployment-packages script
4. Upload the new zscaler-microsegmentation-agent-*.zip files to the Azure Storage Account Container, overwriting the previous files.
5. Complete the Create a VM Application Version process outlined above, making certain to increment the Version identifier when doing so.

### Troubleshooting

#### Verify the Installation Package was Downloaded to the VM

##### Windows

`C:\Packages\Plugins\Microsoft.CPlat.Core.VMApplicationManagerWindows\<version>\Downloads\<appname>\<app version>/`

##### Linux

`/var/lib/waagent/Microsoft.CPlat.Core.VMApplicationManagerLinux/<appname>/<app version>/`

#### Review the VM Applications Logs

##### Windows

`C:\Packages\Plugins\Microsoft.CPlat.Core.VMApplicationManagerWindows\<version>\Downloads\<app-name>\<app-version>\stderr`

`C:\Packages\Plugins\Microsoft.CPlat.Core.VMApplicationManagerWindows\<version>\Downloads\<app-name>\<app-version>\stdout`

##### Linux

`/var/lib/waagent/Microsoft.CPlat.Core.VMApplicationManagerLinux/<app-name>/<app-version>/stderr`

`/var/lib/waagent/Microsoft.CPlat.Core.VMApplicationManagerLinux/<app-name>/<app-version>/stdout`

#### Review the Installation Logs

##### Windows

`C:\ProgramData\Zscaler\ZMS\installation\install.log`

##### Linux

`/opt/zscaler/zms/installation/install.log`

#### Azure VMAppExtension is Stuck Installing/Uninstalling or is Unavailable

Run the following commands via Azure Cloud Shell:
```
$rg = 'vm-resource-group-name'
$vm = 'vm-name'
Get-AzVM -ResourceGroupName $rg -VM $vm | Update-AzVM
```
This process may take a few minutes to complete.

<h1 align="center">A digitial-life viewing application</h1>

<h3 align="center">
  <a href="https://memetrics.net/">Visit MeMetrics</a>
</h3>

<h3 align="center">
  <a href="https://github.com/thirschel/memetrics-ui/blob/master/ARCHITECTURE.md">Architecture Diagram</a> |
  <a href="https://github.com/thirschel/memetrics-ui">UI</a> |
  <a href="https://github.com/thirschel/memetrics-api">API</a> | 
  <a href="https://github.com/thirschel/memetrics-functions">Functions</a> |
  <a href="https://github.com/thirschel/memetrics-imessage-updater">iMessage Updater</a>
</h3>

### What is this?

This repository contains terraform scripts used to set up the backbone infrastructure of resources that do not belong to a specific domain. This includes things that cross domains such as Key Vaults, Service Buses, etc.

### Requirements / Assumptions
* Terraform v0.12 at least
* Terraform is written for Azure
* Azure Devops is *not* required but the steps to run will be written for that platform

### Setup

Before these scripts will can be run, some manual steps will need to completed. Terraform can't be used to create the storage account it will store it's state files in nor can it create the service principal used to connect to Azure. 

>  Create a [container registry](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-intro)

__If you already have one created and have the `LoginServer`, `Username`, and `Password` you and skip to the next step__
  1. Perform an `az login`
  2. Run `scripts/create_container_registry.ps1` which will take in 2 parameters `resource_group_name` and `container_name`. resource_group_name being the name of the resource group to create the container registry in and container_name being the name of the Container Registry
  3. eg. `./scripts/create_container_registry.ps1 -resource_group_name 'my-resource-group' -container_name 'myRegistry`
  4. This should produce an output that looks like
  ```
  loginServer  : <string>
  username     : <string>
  password     : <string>
  ```
  5. These variables will not go into the Key Vault because they not scoped to an environment. There is one only registry for the subscription.

>  Create a [service principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals)

__If you already have one created and have the `ObjectId`, `ClientId`, and `ClientSecret` you and skip to the next step__
  1. Perform an `az login`
  2. Run `scripts/create_service_principal.ps1` which will take in 2 parameters `name` and `subscriptionId`. Name being the name of the service principal and subscriptionId being the Azure subscription id you want to create it under
  3. eg. `./scripts/create_service_principal.ps1 -name 'my-service-principal' -subscriptionId '00000000-0000-0000-0000-000000000000`
  4. This should produce an output that looks like
  ```
  appId       : <guid>
  displayName : <name>
  name        : http://<name>
  password    : <guid>
  tenant      : <guid>
  objectId    : <guid>
  ```

> Create a storage account and container to hold the `.tfstate` files

__If you already have one created you and skip to the next step__
1. Perform an `az login`
2. Run `scripts/create_terraform_storage.ps1` which will take in 2 parameters `resource_group_name` and `storage_account_name`. resource_group_name being the name of the resource group to create the storage account in and storage_account_name being the name of the storage account
3. eg. `./scripts/create_terraform_storage.ps1 -resource_group_name 'my-resource-group' -storage_account_name 'my-storage-account`
4. This should produce an output that looks like
```
accountName  : <string>
accessKey    : <string>
```

> Add Service Connection in Azure Devops

1. In Azure Devops, navigate to the `Project Settings` for the project where your pipelines are held
2. Navigate to the `Service Connections` tab
3. Press `New service connection` and select `Azure Resource Manager` > `Service Principal (manual)`
5. Fill out the form as such and press `Verify and save`:

| Input | Value | 
| ------------- |-------------:|
| Environment | `Azure Cloud` |
| Scope Level   | `Subscription`   | 
| Susbcription Id   | The subscription id you created the service principal under   | 
| Subscription Name   | The subscription name you created the service principal under   | 
| Service principal id   | The appId from the service principal    | 
| Service principal key   | The password from the service principal   |
| Tenant ID   | The tenant from the service principal   | 
| Service connection name   | `Visual Studio Enterprise`   | 
| Grant access permission to all pipelines   | Checked   | 

> Add the container registry variables to a Variable Library in Azure Devops

1. In Azure Devops, navigate to the `Pipelines` view and select the `Library` tab
2. Press `+ Variable group`
3. Name the variable group `Infrastructure`
4. Ensure `Allow access to all pipelines` is checked
5. Add the following variables and save the group:

| Name | Value | Is Sercet?|
| ------------- |-------------| -----:|
| DockerRegistryServerName | The loginServer from the container registry | No  |
| DockerRegistryUsername   | The username from the container registry   | No  |
| DockerRegistryPassword   | The password from the container registry   | Yes |
| TerraformStorageAccountName   | The accountName from the storage account    | Yes |
| TerraformStorageAccountKey   | the accessKey from the storage account    | Yes |
| TerraformContainerName   | `terraform-backend-files`    | No |

> Add pipeline secret variables to the Azure Devops pipline
1. In Azure Devops, navigate to the Pipelines view and select the Pipeline for this repository
2. Select `Edit`
3. Select `Variables`
4. A variable can be added by pressing the `+` button and then giving the variable a `Name` and `Value`. You will also want to check `Keep this value secret` which will treat the value as a secret and obfuscate the value when shown in the pipeline console.
5. The following variables are needed

| Name | Value | Keep this value secret |
| ------------- |-------------| -----:|
| AnsibleSecret | The password used to encrypt the tfvar files | Yes  |
| DevopsTenantId   | The tenant from the service principal   | Yes  |
| DevopsClientId   | The appId from the service principal  | Yes |
| DevopsClientSecret   | The password from the service principal    | Yes |
| DevopsSubscriptionId   | The Azure subscription id the resources are being created under    | Yes |

### Creating a new environment

To create a new environment, you will need to create a new `.tfvars` file with the name matching the name of the environment and a new [deployment job will](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/deployment-jobs?view=azure-devops) needs to be added to `azure-pipelines.yml`.
The `.tfvars` file should contain all the variables declared in `variables.tf` and then encrypted using [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)

**WSL will be needed to use ansible if on Windows**

eg `ansible-vault encrypt dev.tfvars`
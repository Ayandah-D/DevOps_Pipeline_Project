Chapter 1 

Initial Setup and definition of terms 

In this section i will create all of the Azure cloud services and resources that initially need prior to deploying additional Azure resources using Terraform. 

 the activities that will be done are: 
    - Setup Azure DevOps
    - Create remote storage account for Terraform state files
    - Create an Azure AD group for AKS admins

# Azure DevOps setup

    Azure DevOps Organisation Setup

The first setup to setting up Azure DevOps is to create an organisation. We will be using a dummy organization named MzingaTech and the steps on creating the organization are listed below.

1. Sign into Azure DevOps
2. Select **New Organisation**
3. Enter your preferred Azure DevOps organisation name & hosting location 
4. Once you have created your organisation, you can sign into your organisation anything using
`https://dev.azure.com/{yourorganization}

Once an organisation has been setup, next is to create an Azure DevOps project

    Azure DevOps Project Creation

Creating a project allows you to use repositories, pipelines etc. 

1. Sign into Azure DevOps
2. Select organisation that you have created above
3. Select **New Project**
4. Enter new project name & description

![](images/azure-devops-project-creation.png)

    
    Azure Service Principal Creation

A Service Principal (SPN) is considered a best practice for DevOps within your CI/CD pipeline. It is used as an identity to authenticate you within your Azure Subscription to allow you to deploy the relevant Terraform code.

1. To begin creation, within your newly created Azure DevOps Project – select **Project Settings**
2. Select **Service Connections**
3. Select **Create Service Connection** -> **Azure Resource Manager** -> **Service Principal (Automatic)**
4. Enter subscription/resource group to where service connection will be created. Create with relevant service connection name

![](images/azure-devops-service-connection.png)

5. Once created you will see similar to below (You can select **Manage Service Principal** to review further)

![](images/azure-devops-service-connection-2.png)

6. Within** Manage Service Principal** options, branding -> name to give a relevant name for service principal (it creates originally with a random string at end)

![](images/azure-devops-service-connection-3.png)

7. All Service Principal role assignment to subscription, I will be giving the Service Principal **contributor** access to the subscription

![](images/azure-devops-service-connection-4.png)

After this initial setup,we are set and ready to deploy to Azure using Azure Devops 



## Azure Terraform Setup

    The purpose of this section is to create the location that will store the remote Terraform State file

    When deploying Terraform there is a requirement that it must store a state file; this file is used by Terraform to map Azure Resources to a configuration that i want to deploy, keeps track of meta data and can also assist with improving performance for larger Azure Resource deployments.

    Create Blob Storage location for Terraform State file
            
        1. Edit the variables
        2. Run the script {`./scripts/create-terraform-storage.sh`}
        {

            #!/bin/sh

            RESOURCE_GROUP_NAME="devops-journey-rg"
            STORAGE_ACCOUNT_NAME="devopsjourneyazuredevops"

            # Create Resource Group
            az group create -l uksouth -n $RESOURCE_GROUP_NAME

            # Create Storage Account
            az storage account create -n $STORAGE_ACCOUNT_NAME -g $RESOURCE_GROUP_NAME -l uksouth --sku Standard_LRS

            # Create Storage Account blob
            az storage container create  --name tfstate --account-name $STORAGE_ACCOUNT_NAME

        }



        3. The script will create
        - Azure Resource Group
        - Azure Storage Account
        - Azure Blob storage location within Azure Storage Account



### Create Azure AD Group for AKS Admins

The purpose of this lab to create an Azure AD Group for AKS Admins. These "admins" will be the group of users that will be able to access the AKS cluster using kubectl

  Create Azure AD AKS Admin Group
1. Run the script `./scripts/create-azure-ad-group.sh`

    {

        #!/bin/sh

        AZURE_AD_GROUP_NAME="devopsjourney-aks-group"
        CURRENT_USER_OBJECTID=$(az ad signed-in-user show --query objectId -o tsv)

        # Create Azure AD Group
        az ad group create --display-name $AZURE_AD_GROUP_NAME --mail-nickname $AZURE_AD_GROUP_NAME

        # Add Current az login user to Azure AD Group
        az ad group member add --group $AZURE_AD_GROUP_NAME --member-id $CURRENT_USER_OBJECTID

        AZURE_GROUP_ID=$(az ad group show --group "devopsjourney-aks-group" --query objectId -o tsv)

        echo "AZURE AD GROUP ID IS: $AZURE_GROUP_ID"

    }

2. The script will create
- Azure AD Group named `"devopsthehardway-aks-group"`
- Add current user logged into Az CLI to AD Group `"devopsthehardway-aks-group"`
- Will output Azure AD Group ID, note this down as it will be required for AKS Terraform
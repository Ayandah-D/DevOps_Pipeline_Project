#!/bin/sh

#The first two lines define variables for the resource group name and storage account name. 
#The RESOURCE_GROUP_NAME variable is set to "devops-journey-rg" and the STORAGE_ACCOUNT_NAME variable is set to "devopsjourneyazuredevops".

RESOURCE_GROUP_NAME="Capstone2"
STORAGE_ACCOUNT_NAME="CapstoneProject2"

# Create Resource Group
az group create -l uksouth -n $Capstone2

# Create Storage Account
az storage account create -n $CapstoneProject2 -g $Capstone2 -l uksouth --sku Standard_LRS

# Create Storage Account blob
az storage container create  --name tfstate --account-name $CapstoneProject2
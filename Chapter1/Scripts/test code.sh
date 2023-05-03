#!/bin/bash
RG_NAME=TF-State-RG
SA_NAME=tfstatekasunsa
CONTAINER_NAME=tfstate

# Create resource group
az group create --name $RG_NAME --location eastus

# Create storage account
az storage account create --resource-group $RG_NAME --name $SA_NAME --sku Standard_LRS --encryption-services blob

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $RG_NAME --account-name $SA_NAME --query [0].value -o tsv)

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $SA_NAME --account-key $ACCOUNT_KEY
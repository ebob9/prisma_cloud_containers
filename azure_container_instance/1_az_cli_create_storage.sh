#!/bin/bash
#
# This is an example script to use Azure CLI to launch a container group for use with prisma_access_panorama.
# It uses container_group.yml to spin up the container.
#
# Please edit the region below in 'az group create' and the CGX_AUTH_TOKEN in the YAML file at a minimum.
#

# Load user defined params from ./user_modifiable_variables.include
source ./user_modifiable_variables.include

# Change these parameters as needed
CGX_PAP_STORAGE_ACCOUNT_NAME="${CGX_PAP_STORAGE_ACCOUNT_NAME_PREFIX}$RANDOM"

echo "Using following Variabes:"
cat << EOM
    CGX_PAP_RESOURCE_GROUP=$CGX_PAP_RESOURCE_GROUP
    CGX_PAP_REGION=$CGX_PAP_REGION
    CGX_PAP_SHARE_NAME=$CGX_PAP_SHARE_NAME
    CGX_PAP_STORAGE_ACCOUNT_NAME_PREFIX=$CGX_PAP_STORAGE_ACCOUNT_NAME_PREFIX
    CGX_PAP_STORAGE_ACCOUNT_NAME=$CGX_PAP_STORAGE_ACCOUNT_NAME
EOM

# login
az login

# create resource group
az group create --name "$CGX_PAP_RESOURCE_GROUP" --location "$CGX_PAP_REGION"

# Create the storage account with the parameters
az storage account create \
    --resource-group "$CGX_PAP_RESOURCE_GROUP" \
    --name "$CGX_PAP_STORAGE_ACCOUNT_NAME" \
    --location "$CGX_PAP_REGION" \
    --sku Standard_LRS

# Create the file share
az storage share create --name "$CGX_PAP_SHARE_NAME" --account-name "$CGX_PAP_STORAGE_ACCOUNT_NAME"

# Get storage key
STORAGE_KEY=$(az storage account keys list --resource-group "$CGX_PAP_RESOURCE_GROUP" \
    --account-name "$CGX_PAP_STORAGE_ACCOUNT_NAME" \
    --query "[0].value" \
    --output tsv)

echo "Storage Account Name: $CGX_PAP_STORAGE_ACCOUNT_NAME"
echo "Storage Account Key : $STORAGE_KEY"
echo ''
cat << EOM
  volumes:
    - name: applogvolume
      azureFile:
        sharename: $CGX_PAP_SHARE_NAME
        storageAccountName: $CGX_PAP_STORAGE_ACCOUNT_NAME
        storageAccountKey: $STORAGE_KEY
EOM
echo ''
echo "Add these values to 'container_group.yml' file before running 2_az_cli_deploy_group.sh"

#!/bin/bash
#
# This is an example script to use Azure CLI to launch a container group for use with prisma_access_panorama.
# It uses container_group.yml to spin up the container.
#
# Please edit the region below in 'az group create' and the CGX_AUTH_TOKEN in the YAML file at a minimum.
#

# Load user defined params from ./user_modifiable_variables.include
source ./user_modifiable_variables.include

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

# deploy containers
az container create --resource-group "$CGX_PAP_RESOURCE_GROUP" --file container_group.yaml

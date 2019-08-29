Azure Container Instance (ACI) Container Script/YAML 
----------
These scripts help  Running Prisma Access for Networks (managed by Panorama) Cloudblade in ACI.

Prior to running these commands, you will need:
 * An active Azure account with a usable subscription
 * Functioning, configured Panorama with Prisma Access initial configuration
    * Username dedicated for CloudGenix Controller integration, and password.
    * Prisma Access API key generated and available
 * CloudGenix Portal Account
    * Prisma Access for Networks (Managed by Panorama) CloudBlade installed and configured.
    * AUTH_TOKEN generated and available (tenant_super, or SDWANAPP for CloudBlade custom role).

To use:
 1. (optional) Verify storage/container names in user_modifiable_variables.include are acceptable
 2. Run ./1_az_cli_create_storage.sh - Creates Storage share, and gives you storage keys/etc needed for other files.
 3. Edit container_group.yaml
   * Add the values from ./1_az_cli_create_storage.sh to the end.
   * Enter your VPN_PSK, PANORAMA_PASSWORD, PRISMA_ACCESS_API_KEY, and CGX_AUTH_TOKEN values.
 4. Run ./2_az_cli_deploy_group.sh to deploy the container. 

To view the applog, you can use the following command (assuming default names):
`az container exec --resource-group cloudgenixPrismaAccessPanorama --name prisma_access_panorama_azure --container prisma-access-panorama --exec-command "./tail_applog.sh"`


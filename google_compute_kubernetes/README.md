GCE Container Script/YAML 
----------
These scripts help for Running Prisma Access for Networks (managed by Panorama) Cloudblade in GCE.

Prior to running ./1_gce_cli_launch.sh, the following is needed:

 * A GCE account with a project, and Kubernetes Engine API and Google Compute Engine APIs enabled for project/account.
 * GCE SDK installed and configured with
   * Default Credentials
   * Default project
   * default region
 * kubectl utility installed (can be installed from GCE SDK)
 * Functioning, configured Panorama with Prisma Access initial configuration
    * Username dedicated for CloudGenix Controller integration, and password.
    * Prisma Access API key generated and available
 * CloudGenix Portal Account
    * Prisma Access for Networks (Managed by Panorama) CloudBlade installed and configured.
    * AUTH_TOKEN generated and available (tenant_super, or SDWANAPP for CloudBlade custom role).

To install the GCE SDK, see:
https://cloud.google.com/sdk/install

To install kubectl, try "gcloud components install kubectl", or see:
https://cloud.google.com/kubernetes-engine/docs/quickstart

To enable Google Cloud APIs, see:
https://cloud.google.com/apis/docs/getting-started

To Use:
 1. Run ./1_gce_cli_launch.sh bash shell script.

After setup, interesting commands:
kubectl get pods  # list pods
kubectl exec -it POD_NAME -- ./tail_applog.sh  # View Applog


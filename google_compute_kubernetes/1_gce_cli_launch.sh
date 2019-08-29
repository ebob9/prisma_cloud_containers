#!/bin/bash
#
# This is an example script to use GCE CLI to launch a container group for use with prisma_access_panorama.
# It uses kubernetes and prisma_access_panorama.yml to spin up the container.
#
# please ensure that Google Cloud SDK (gcloud) and kubectl are installed and configured.

#
# This section will GET current required kubernetes secrets (if they exist), and prompt you to edit them or accept.
#
KUBEVERSION=$(which kubectl)
if [ -z "${KUBEVERSION}" ]
  then
    echo "ERROR: No Kubernetes found (no 'kubectl' in path.) Exiting."
    exit 1
fi

GCEVERSION=$(gcloud version 2>/dev/null)
if [ -z "${GCEVERSION}" ]
  then
    echo "ERROR: No Google Compute SDK found (no 'gcloud' in path.) Exiting."
    exit 1
fi

# start to build system.
# create cluster, if doesnt exist. If exists, silently fail this line.
echo ""
echo "Attempting to create prisma-access-panorama GCE container cluster (if it does not exist).."
gcloud container clusters create prisma-access-panorama --machine-type=g1-small --num-nodes=1 2>/dev/null

# check if cluster was created (success of previous command), if so, download credentials.
clustercreatestatus=$?
if [ $clustercreatestatus -eq 0 ]; then
    echo "Cluster created, downloading kubectl credentials."
    gcloud container clusters get-credentials prisma-access-panorama
fi

echo ""
echo "GCE Container Clusters:"
gcloud container clusters list
echo ""
echo "Kubernetes is using $(kubectl config current-context):"
kubectl cluster-info
echo""
echo "If any of the above looks incorrect, please CTRL-C and verify. You may need to create clusters (gcloud container clusters create) and download credentials (gcloud container clusters get-credentials)."
echo ""
read -r -p "Press enter to continue"

echo "Loading pre-existing Prisma Access Panorama Kubernetes Secrets (if they exist.) Please verify/edit."

# first VPN_PSK
while [ -z "${VPN_PSK}" ]
  do
    VPN_PSK_PREV=$(kubectl get secret prisma-access-panorama.vpn-psk -o go-template='{{ .data.VPN_PSK }}' 2>/dev/null | base64 --decode)
    # read input, use read secret if nothing
    read -r -p "VPN Pre-shared Key Seed [$VPN_PSK_PREV]: " VPN_PSK
    [ -z "${VPN_PSK}" ] && VPN_PSK=$VPN_PSK_PREV
  done
# VPN_PSK should be set now, overwrite any previous secret
kubectl delete secret prisma-access-panorama.vpn-psk >/dev/null 2>&1
kubectl create secret generic prisma-access-panorama.vpn-psk --from-literal=VPN_PSK="${VPN_PSK}" >/dev/null 2>&1

# next PANORAMA_PASSWORD
while [ -z "${PANORAMA_PASSWORD}" ]
  do
    PANORAMA_PASSWORD_PREV=$(kubectl get secret prisma-access-panorama.panorama-password -o go-template='{{ .data.PANORAMA_PASSWORD }}' 2>/dev/null | base64 --decode)
    # read input, use read secret if nothing
    read -r -p "Panorama password for CloudBlade Account [$PANORAMA_PASSWORD_PREV]: " PANORAMA_PASSWORD
    [ -z "${PANORAMA_PASSWORD}" ] && PANORAMA_PASSWORD=$PANORAMA_PASSWORD_PREV
  done
# PANORAMA_PASSWORD should be set now, overwrite any previous secret
kubectl delete secret prisma-access-panorama.panorama-password >/dev/null 2>&1
kubectl create secret generic prisma-access-panorama.panorama-password --from-literal=PANORAMA_PASSWORD="${PANORAMA_PASSWORD}" >/dev/null 2>&1

# next PRISMA_ACCESS_API_KEY
while [ -z "${PRISMA_ACCESS_API_KEY}" ]
  do
    PRISMA_ACCESS_API_KEY_PREV=$(kubectl get secret prisma-access-panorama.prisma-access-api-key -o go-template='{{ .data.PRISMA_ACCESS_API_KEY }}' 2>/dev/null | base64 --decode)
    # read input, use read secret if nothing
    read -r -p "Prisma Access API Key (obtained from Panorama) [$PRISMA_ACCESS_API_KEY_PREV]: " PRISMA_ACCESS_API_KEY
    [ -z "${PRISMA_ACCESS_API_KEY}" ] && PRISMA_ACCESS_API_KEY=$PRISMA_ACCESS_API_KEY_PREV
  done
# PRISMA_ACCESS_API_KEY should be set now, overwrite any previous secret
kubectl delete secret prisma-access-panorama.prisma-access-api-key >/dev/null 2>&1
kubectl create secret generic prisma-access-panorama.prisma-access-api-key --from-literal=PRISMA_ACCESS_API_KEY="${PRISMA_ACCESS_API_KEY}" >/dev/null 2>&1

# next CGX_AUTH_TOKEN
while [ -z "${CGX_AUTH_TOKEN}" ]
  do
    CGX_AUTH_TOKEN_PREV=$(kubectl get secret prisma-access-panorama.cgx-auth-token -o go-template='{{ .data.CGX_AUTH_TOKEN }}' 2>/dev/null | base64 --decode)
    # read input, use read secret if nothing
    read -r -p "CloudGenix AUTH TOKEN (tenant_super, from 'system administration'.) [$CGX_AUTH_TOKEN_PREV]: " CGX_AUTH_TOKEN
    [ -z "${CGX_AUTH_TOKEN}" ] && CGX_AUTH_TOKEN=$CGX_AUTH_TOKEN_PREV
  done
# CGX_AUTH_TOKEN should be set now, overwrite any previous secret
kubectl delete secret prisma-access-panorama.cgx-auth-token >/dev/null 2>&1
kubectl create secret generic prisma-access-panorama.cgx-auth-token --from-literal=CGX_AUTH_TOKEN="${CGX_AUTH_TOKEN}" >/dev/null 2>&1

# apply the config
echo "Launching prisma-access-panorama-1-0-1."
kubectl apply -f ./prisma_access_panorama.yaml

# wait for container to be ready.
READY=$(kubectl get pods -l app=prisma-access-panorama-1-0-1 -o go-template='{{range .items}}{{range .status.containerStatuses}}{{.ready}}{{end}}{{end}}')
while [ "$READY" != "true" ]
  do
    echo "Container ready state: $READY"
    sleep 5
    READY=$(kubectl get pods -l app=prisma-access-panorama-1-0-1 -o go-template='{{range .items}}{{range .status.containerStatuses}}{{.ready}}{{end}}{{end}}')
  done


# view the pods
kubectl get pods

POD_TAIL_GUESS=$(kubectl get pods -l app=prisma-access-panorama-1-0-1 -o go-template='{{range .items}}{{ .metadata.name}}{{end}}')
echo ""
read -r -p "Enter pod to view applog from [$POD_TAIL_GUESS]: " POD_TAIL_LOG
[ -z "${POD_TAIL_LOG}" ] && POD_TAIL_LOG=$POD_TAIL_GUESS

echo ""
echo "Following Prisma Access CloudBlade applog file - press CTRL-C to exit."
kubectl exec -it ${POD_TAIL_LOG} -- ./tail_applog.sh

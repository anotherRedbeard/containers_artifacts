#create resource group
az group create --name <resource-group-name>  --location <fav-location>

#create aks cluster with 2 nodes
az aks create -g teamResources -n openHackAKSCluster --enable-managed-identity --node-count 2 --enable-addons monitoring --enable-msi-auth-for-monitoring  --generate-ssh-keys

#install kubectl locally if necessary
az aks install-cli

#configure kubectl to connect to your cluster
az aks get-credentials --resource-group teamResources --name openHackAKSCluster

#confirm connection, this command should return 2 nodes (if that's what you setup above)
kubectl get nodes

#grant access to ACR from AKS cluster
az aks update -n openHackAKSCluster -g teamResources --attach-acr registryqzu2798

#create yaml deployment file from quick start

#apply yaml for deployment
kubectl apply -f azure-k8s.yaml 

#port forward to test locally
kubectl port-forward service/tripviewer 8080:80

#show all pods
kubectl get pods

#show all services
kubectl get services

#show logs
kubectl logs <deployment-name>

#exec to allow you to run commands from within a container
kubectl exec --stdin --tty blazor-deployment-6cbc4b67f4-q48z4 -- sh

#get more detail on item
kubectl describe <service|pod> <service/pod name>

#secret(s) in AKS
export SQL_PASSWORD=<password>
export SECRET_NAME=sql
export SQL_DBNAME=mydrivingDB
export SQL_USER=sqlDrivingAdmin
export SQL_SERVER=sqlserverqzu2798.database.windows.net

kubectl create secret generic $SECRET_NAME --from-literal SQL_SERVER=$SQL_SERVER --from-literal SQL_DBNAME=$SQL_DBNAME --from-literal SQL_USER=$SQL_USER --from-literal SQL_PASSWORD=$SQL_PASSWORD

#Creating namespaces, I created the namespace-deploy.yaml file to create the namespaces then run the following to create the pods in the right namespace
kubectl apply -f ./src/poi/aks-deploy.yaml 
kubectl apply -f ./src/trips/aks-deploy.yaml
kubectl apply -f ./src/tripviewer/aks-deploy.yaml
kubectl apply -f ./src/user-java/aks-deploy.yaml
kubectl apply -f ./src/userprofile/aks-deploy.yaml

#remove the deployments
kubectl delete -f ./src/poi/aks-deploy.yaml
kubectl delete -f ./src/trips/aks-deploy.yaml
kubectl delete -f ./src/tripviewer/aks-deploy.yaml
kubectl delete -f ./src/user-java/aks-deploy.yaml
kubectl delete -f ./src/userprofile/aks-deploy.yaml

#command to describe pods/service/deployments
kubectl describe pod/service/deployment <name>

#commands to add a specific user to a role with a namespace
AKS_ID=$(az aks show -g teamResources -n aks_openhack --query id -o tsv)
az role assignment create --role "Azure Kubernetes Service RBAC Reader" --assignee <USERID> --scope $AKS_ID/namespaces/<NAMESPACE>

#command to create AKS cluster integrated into VNET
az aks create --resource-group teamResources \
  --name aks_openhack \
  --network-plugin azure \
  --vnet-subnet-id /subscriptions/25a39fd6-769f-4660-a60a-e457067347fb/resourceGroups/teamResources/providers/Microsoft.Network/virtualNetworks/vnet/subnets/aks \
  --docker-bridge-address 172.17.0.1/16 \
  --dns-service-ip 10.3.0.10 \
  --service-cidr 10.3.0.0/24 \
  --generate-ssh-keys \
  --enable-aad \
  --enable-azure-rbac
  --enabled-managed-identity

  #add Key Vault driver to existing cluster
  az aks create -n myAKSCluster -g myResourceGroup --enable-addons azure-keyvault-secrets-provider --enable-managed-identity
  
  #Get managed identity of cluster
  export SECRETS_PROVIDER_IDENTITY=$(az aks show \
  -g $RESOURCE_GROUP \
  -n $CLUSTER_NAME \
  --query "addonProfiles.azureKeyvaultSecretsProvider.identity.clientId" -o tsv)

  #Grant Access to AKS cluster on key vault
  az keyvault set-policy -n kvopenhack --secret-permissions get --spn b3fa3919-9aaa-41e8-bff4-4bd689000e3a

#create ingress controller
NAMESPACE=ingress-basic

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace \
  --namespace $NAMESPACE \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz
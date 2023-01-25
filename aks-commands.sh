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
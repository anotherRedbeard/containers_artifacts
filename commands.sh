#login to sepecifc tenant
az login -t <tenant-id>

#list docker network
docker network ls

#inspect existing network
docker network inspect bridge

#stop docker container
docker stop <container_id>

#remove docker container
docker rm <container_id>

#set SA_PASSWORD
SA_PASSWORD=<your_secure_password>

#command to build sql server container
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=$SA_PASSWORD" -p 1433:1433 --name sql1 --hostname sql1 -d mcr.microsoft.com/mssql/server:2017-latest

#command to build seperate images
docker build -t <image_name> .

#run data-load container, since we are using bridge network you will want to use the SQL_SERVER as the local IP of the machine.
docker run --network bridge -e SQLFQDN=$SQL_SERVER -e SQLUSER=SA -e SQLPASS=$SA_PASSWORD -e SQLDB=mydrivingDB registryqzu2798.azurecr.io/dataload:1.0

#command to connect to registry
az acr login --name <registry_name>

#tag the images with the registry
docker tag <source_image>:<tag> <registry_name>:<tag>

#push image to registry_name
docker push <registry_url>/<image_name>:<version>


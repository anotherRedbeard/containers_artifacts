#command to build seperate images
docker build -t <image_name> .

#command to build sql server container
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=$SA_PASSWORD" -p 1433:1433 --name sql1 --hostname sql1 -d mcr.microsoft.com/mssql/server:2017-latest

#command to connect to registry
az acr login --name <registry_name>

#push image to registry_name
docker push <registry_url>/<image_name>:<version>
# Ubuntu VM with NVIDIA driver for the GPU in Azure Cloud

This project can be used to spinup a single ubuntu VM with NVIDIA driver for the GPU in Azure Cloud and installing docker software to support containarized applications of Go Language

## Prerequisites

### i. Azure account[ subscription_id,tenant_id ] with app registration[ client_id, client_secret ]
```
az account list --query "[].{name:name, subscriptionId:id, tenantId:tenantId}"
export SUBSCRIPTION_ID= <query from above>
az account set --subscription="${SUBSCRIPTION_ID}"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID"
```
### ii. Terraform v0.12.18
### iii. ansible 2.9.1

## Deployment
1. Clone the Github project
2. Navigate to the terraform folder and execute the below
```
i. terraform init
ii. terraform plan \
  -var "subscription_id=<enter your id>" \
  -var "client_id=<enter your id>" \
  -var "client_secret=<enter your id>" \
  -var "tenant_id=<enter your id>" --auto-aprove

iii. terraform apply \
  -var "subscription_id=<enter your id>" \
  -var "client_id=<enter your id>" \
  -var "client_secret=<enter your id>" \
  -var "tenant_id=<enter your id>" --auto-aprove 
```
3. Retreive the public IP address created for the ubuntu machine
4. Navigate to the ansible folder and execute the below

```
ansible-playbook -i '<public-ip,> install_softwares.yml -u <user created by terraform for ubuntu VM>
```
5. Navigate to docker folder and execute the below to create docker image

```
docker build . -t golang
```

6. Once the build is succeded, run the docker image, so that docker container will consider the source code from the docker volume, compiles the golang application with name runme and executes the runme compiled file
 
```  
docker run -v $HOME/azure-ubuntu/docker/volumes/:/code <imageid> go
``` 
## Next steps to improve the solution
```  
•	Deploy the solution from Jenkins using declarative groovy instead of running from the console
•	Modularize the terraform code to support spinning of any number of VM's
•	Versioning of terraform state files
•	Coding standards on terraform, ansible and docker
```
## Authors

* **Sai Kumar Chukkapalli** - *Initial work* - [Sai Kumar Chukkapalli](https://github.com/saikumarch7548)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


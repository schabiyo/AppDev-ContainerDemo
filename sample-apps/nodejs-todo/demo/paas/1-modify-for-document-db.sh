#!/bin/bash
RESET="\e[0m"
INPUT="\e[7m"
BOLD="\e[4m"
YELLOW="\033[38;5;11m"
RED="\033[0;31m"

#make sure the demo is setup correctly
../../1-setup-demo.sh

echo "Modify /source/AppDev-ContainerDemo/sample-apps/nodejs-todo/src/config/database.js for remote documentDB"
#Change connection string in code - we can also move this to an ENV variable instead
DOCUMENTDBKEY=`~/bin/az documentdb list-connection-strings -g ossdemo-appdev-paas -n VALUEOF-UNIQUE-SERVER-PREFIX-documentdb --query connectionStrings[].connectionString -o tsv`
echo ".working with documentdbkey:${DOCUMENTDBKEY}"
sed -i -e "s|mongodb://nosqlsvc:27017/todo|$DOCUMENTDBKEY|g" /source/AppDev-ContainerDemo/sample-apps/nodejs-todo/src/config/database.js

#BUILD Container & publish to registry
read -p "$(echo -e -n "${INPUT}Create and publish containers into Azure Private Registry? [Y/n]:"${RESET})" continuescript
if [[ ${continuescript,,} != "n" ]]; then
    /source/AppDev-ContainerDemo/sample-apps/nodejs-todo/demo/ansible/build-docdb-containers.sh
fi

#Delete existing K8S Service & Redeploy
cd /source/AppDev-ContainerDemo/sample-apps/nodejs-todo/demo/paas
echo "deleting existing nodejs deployment "
./x-reset-demo.sh
echo "-------------------------"
echo "Deploy the app deployment"
kubectl create -f deploy-nodejs.yml
echo "-------------------------"

echo "Initial deployment & expose the service"
kubectl expose deployments nodejs-todo-with-documentdb-deployment --port=80 --target-port=8080 --type=LoadBalancer --name=nodejs-todo-with-documentdb

echo "Deployment complete for pods: nodejs-todo-with-documentdb"

echo ".kubectl get services"
kubectl get services

echo ".kubectl get pods"
kubectl get pods

echo "To scale: kubectl scale --replicas=3 deployment/nodejs-todo-deployment"
echo "To debug: kubectl log <pod name>"
echo "To bash : kubectl exec -p <pod name> -i -t -- bash -il"
echo "Service : kubectl get services"
echo "Pods    : kubectl get pods"
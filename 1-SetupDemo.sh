echo "Welcome to the OSS Demo for Simple app dev Containers.  This demo will configure:"
echo "    - Resource group - ossdemo-appdev-iaas"
echo "    - Resource group - ossdemo-appdev-acs"
echo "    - Resource group - ossdemo-appdev-paas"
echo ""
echo "It will also modify scripts for the demo and download the GIT repository and create:"
echo "     - Servers in ossdemo-appdev-iaas"
echo "     - Kubernetes cluster in ossdemo-appdev-acs"
echo "     - Azure app service in ossdemo-appdev-paas"
echo ""
echo "Installation & Configuration will require SU rights but pleae run this script as GBBOSSDemo."
echo ""
echo "Upon download please edit /source/AppDev-ContainerDemo/vm-assets/DemoEnvironmentTemplateValues file with your unique values."
echo ""
echo "Logging in to Azure"
#Checking to see if we are logged into Azure
echo "    Checking if we are logged in to Azure."
#We need to redirect the output streams to stdout
azstatus=`az group list 2>&1` 
if [[ $azstatus =~ "Please run 'az login' to setup account." ]]; then
   echo "   We need to login to azure.."
   az login
else
   echo "    Logged in."
fi
read -p "    Change default subscription? [y/n]:" changesubscription
if [[ $changesubscription =~ "y" ]];then
    read -p "      New Subscription Name:" newsubscription
    az account set --subscription "$newsubscription"
else
    echo "    Using default existing subscription."
fi

echo "GIT HUB REPO"
read -p "Download the GIT HUB repo for https://github.com/dansand71/AppDev-ContainerDemo? [y/n]" continuescript
if [[ $continuescript != "n" ]];then
    #Download the GIT Repo for keys etc.
    echo "--------------------------------------------"
    echo "Downloading the Github repo for the connectivity keys and bits."
    cd /source
    sudo rm -rf /source/AppDev-ContainerDemo
    sudo git clone https://github.com/dansand71/AppDev-ContainerDemo
    sudo chmod +x /source/AppDev-ContainerDemo/1-SetupDemos.sh
    echo ""
    echo "--------------------------------------------"
fi
if [ -f /source/appdev-demo-EnvironmentTemplateValues ]
  then
    echo "    Existing settings file found.  Not copying the version from /source/AppDev-ContainerDemo/vm-assets"
  else
    echo "    Copying the template file for your edits - /source/appdev-demo-EnvironmentTemplateValues"
    cp /source/AppDev-ContainerDemo/vm-assets/DemoEnvironmentTemplateValues /source/appdev-demo-EnvironmentTemplateValues
fi
source /source/appdev-demo-EnvironmentTemplateValues
echo ""
echo " Current Template Values:"
echo "DEMO_UNIQUE_SERVER_PREFIX="$DEMO_UNIQUE_SERVER_PREFIX
echo "DEMO_STORAGE_ACCOUNT="$DEMO_STORAGE_ACCOUNT
echo "DEMO_REGISTRY_SERVER-NAME="$DEMO_REGISTRY_SERVER_NAME
echo "DEMO_REGISTRY_USER_NAME="$DEMO_REGISTRY_USER_NAME
echo "DEMO_REGISTRY_PASSWORD="$DEMO_REGISTRY_PASSWORD
echo "DEMO_OMS_WORKSPACE="$DEMO_OMS_WORKSPACE
echo "DEMO_OMS_PRIMARYKEY="$DEMO_OMS_PRIMARYKEY
echo "DEMO_APPLICATION_INSIGHTS_KEY="$DEMO_APPLICATION_INSIGHTS_KEY
echo ""
read -p "The remainder of this script requires the template values be filled in the /source/appdev-demo-EnvironmentTemplateValues file.  Continue? [y/n]" continuescript
if [[ $continuescript != "y" ]];then
    exit
fi

echo ""
echo "Set values for creation of resource groups for container demo"
echo ""
read -p "Create resource group, and network rules? [y/n]:"  continuescript
if [[ $continuescript != "n" ]];then

    #BUILD RESOURCE GROUPS
    echo ""
    echo "BUILDING RESOURCE GROUPS"
    echo "--------------------------------------------"
    echo 'create utility resource group'
    az group create --name ossdemo-appdev-iaas --location eastus
    az group create --name ossdemo-appdev-acs --location eastus
    az group create --name ossdemo-appdev-paas --location eastus

    #BUILD NETWORKS SECURTIY GROUPS and RULES
    echo ""
    echo "BUILDING NETWORKS SECURTIY GROUPS and RULES"
    echo "--------------------------------------------"
    echo 'Network Security Group for Resource Groups'
    az network nsg create --resource-group ossdemo-appdev-iaas --name NSG-ossdemo-appdev-iaas --location eastus
    az network nsg create --resource-group ossdemo-appdev-acs --name NSG-ossdemo-appdev-acs --location eastus
    az network nsg create --resource-group ossdemo-appdev-paas --name NSG-ossdemo-appdev-paas --location eastus

    echo 'Allow SSH inbound to iaas, acs and paas resource groups'
    az network nsg rule create --resource-group ossdemo-appdev-iaas \
        --nsg-name NSG-ossdemo-appdev-iaas --name ssh-rule \
        --access Allow --protocol Tcp --direction Inbound --priority 110 \
        --source-address-prefix Internet \
        --source-port-range "*" --destination-address-prefix "*" \
        --destination-port-range 22

    az network nsg rule create --resource-group ossdemo-appdev-acs \
     --nsg-name NSG-ossdemo-appdev-acs --name ssh-rule \
     --access Allow --protocol Tcp --direction Inbound --priority 110 \
     --source-address-prefix Internet \
     --source-port-range "*" --destination-address-prefix "*" \
     --destination-port-range 22

    az network nsg rule create --resource-group ossdemo-appdev-paas \
     --nsg-name NSG-ossdemo-appdev-paas --name ssh-rule \
     --access Allow --protocol Tcp --direction Inbound --priority 110 \
     --source-address-prefix Internet \
     --source-port-range "*" --destination-address-prefix "*" \
     --destination-port-range 22
fi

#Leverage the existing public key for new VM creation script
echo "--------------------------------------------"
echo "Reading ~/.ssh/id_rsa.pub and writing values to /source/AppDev-ContainerDemo/*"
sshpubkey=$(< ~/.ssh/id_rsa.pub)
sudo sed -i -e "s@REPLACE-SSH-KEY@${sshpubkey}@g" /source/AppDev-ContainerDemo/.
echo "--------------------------------------------"

echo "Configure demo scripts"
sudo echo "export ANSIBLE_HOST_KEY_CHECKING=false" >> ~/.bashrc
export ANSIBLE_HOST_KEY_CHECKING=false
sudo sed -i -e "s@VALUEOF-UNIQUE-SERVER-PREFIX@$DEMO_UNIQUE_SERVER_PREFIX@g" /source/AppDev-ContainerDemo/.
echo ""
echo"---------------------------------------------"

#Copy the desktop icons
sudo cp /source/OSSonAzure/vm-assets/*.desktop /home/GBBOSSDemo/Desktop/
sudo chmod +x /home/GBBOSSDemo/Desktop/code.desktop
sudo chmod +x /home/GBBOSSDemo/Desktop/firefox.desktop
sudo chmod +x /home/GBBOSSDemo/Desktop/gnome-terminal.desktop


#Set Scripts as executable
sudo chmod +x /source/AppDev-ContainerDemo/kubernetes/configK8S.sh
sudo chmod +x /source/AppDev-ContainerDemo/kubernetes/refreshK8S.sh
sudo chmod +x /source/AppDev-ContainerDemo/kubernetes/deploy.sh

sudo chmod +x /source/AppDev-ContainerDemo/azscripts/newVM.sh
sudo chmod +x /source/AppDev-ContainerDemo/azscripts/createAzureRegistry.sh
sudo chmod +x /source/AppDev-ContainerDemo/azscripts/createK8S-cluster.sh

##Please ensure your logged in to azure via the CLI & your subscription is set correctly

#Create new worker VM's for the docker demo
#/source/AppDev-ContainerDemo/azscripts/newVM.sh

#Create Azure Registry
#/source/AppDev-ContainerDemo/azscripts/createAzureRegistry.sh

#Create K8S Cluster
#/source/AppDev-ContainerDemo/azscripts/createK8S-cluster.sh
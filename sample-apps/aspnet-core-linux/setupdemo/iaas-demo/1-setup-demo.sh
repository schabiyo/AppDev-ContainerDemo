echo "Creating Docker Runtime hosts for Demo #1"

echo ""
echo "----------------------------------"
echo "Create VM #1 & add it to the availability set and vnet"
az vm create -g 'ossdemo-appdev-iaas' -n svr1-VALUEOF-UNIQUE-SERVER-PREFIX \
        --public-ip-address-dns-name 'svr1-VALUEOF-UNIQUE-SERVER-PREFIX' \
        --os-disk-name 'svr1-disk' --image "OpenLogic:CentOS:7.2:latest" --storage-sku 'Premium_LRS' \
        --size Standard_DS1_v2  --admin-username gbbossdemo \
        --availability-set 'ossdemo-appdev-iaas-availabilityset' \
        --nics svr1-nic \
        --no-wait \
        --ssh-key-value 'REPLACE-SSH-KEY' 
echo ""
echo "----------------------------------"
echo "Create VM #2 & add it to the availability set and vnet"
az vm create -g 'ossdemo-appdev-iaas' -n svr2-VALUEOF-UNIQUE-SERVER-PREFIX \
        --public-ip-address-dns-name 'svr2-VALUEOF-UNIQUE-SERVER-PREFIX' \
        --os-disk-name 'svr2-disk' --image "OpenLogic:CentOS:7.2:latest" --storage-sku 'Premium_LRS' \
        --size Standard_DS1_v2 --admin-username gbbossdemo  \
        --availability-set 'ossdemo-appdev-iaas-availabilityset' \
        --nics svr2-nic \
        --no-wait \
        --ssh-key-value 'REPLACE-SSH-KEY'


#echo "Create VM #RHEL"
#az vm create -g 'ossdemo-appdev-iaas' -n svr3-VALUEOF-UNIQUE-SERVER-PREFIX \
#        --public-ip-address-dns-name 'svr3-VALUEOF-UNIQUE-SERVER-PREFIX' \
#        --os-disk-name 'svr3-disk' --image "RedHat:RHEL:7.2:latest" --os-type linux --storage-sku 'Premium_LRS' \
#        --size Standard_DS1_v2 --admin-username gbbossdemo  \
#        --nsg 'NSG-ossdemo-appdev-iaas' --availability-set 'ossdemo-appdev-iaas-availabilityset' \
#        --no-wait \
#        --ssh-key-value 'REPLACE-SSH-KEY'
        

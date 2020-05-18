param ($resource_group_name, $storage_account_name)

# Create storage account
$storage_account = $(az storage account create --resource-group $resource_group_name --name $storage_account_name --sku Standard_LRS --encryption-services blob)
# Get storage account key
$ACCOUNT_KEY = $(az storage account keys list --resource-group $resource_group_name --account-name $storage_account_name --query [0].value -o tsv)
# Create blob container
az storage container create --name terraform-backend-files --account-name $storage_account_name --account-key $ACCOUNT_KEY

echo "accountName   : $($storage_account_name)"
echo "accessKey     : $($ACCOUNT_KEY)"
param ($resource_group_name, $container_name)

# Create container registry
$containerRegistry = (az acr create --resource-group $resource_group_name --name $container_name --sku Basic --admin-enabled true) | ConvertFrom-Json
# Get container registry password

$password=$(az acr credential show -n $container_name --query passwords[0].value -o tsv)
echo "loginServer  : $($containerRegistry.loginServer)"
echo "username     : $($containerRegistry.name)"
echo "password     : $($password)"
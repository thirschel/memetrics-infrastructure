param ($name = "terraform-$(Get-Date -Format "yyyy-MM-dd")", $subscriptionId)

# Create service principal
$servicePrincipal = (az ad sp create-for-rbac --name=$name --role="Contributor" --scopes="/subscriptions/$($subscriptionId)") | ConvertFrom-Json
# Get service principal object id
$objectId = (az ad sp list --filter "appId eq '$($servicePrincipal.appId)'" --query [0].objectId -o tsv)

echo $servicePrincipal
echo "objectId    : $($objectId)"
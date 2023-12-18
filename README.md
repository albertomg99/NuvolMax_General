## Azure Landing Básico

Texto 

* Esto es una prueba
* Esto es otra prueba

`
az group list --output table
`

#Comandos útiles:

Para conectar Visial Studio con nuestras Suscripción de Azure
`Connect-AzAccount`

Lo usamos para tomar información acerda de la suscripción donde queremos lanzar la implementación
`Get-AzSubscription` 

lo usuamos para definir la suscripción por defecto
`Set-AzContext -SubscriptionId {Your subscription ID}` 

Crear un fichero ARM
`az bicep built --file nombrearchivo -f`


Borrar por comandos un grupo de recursos creado (con todo lo de dentro):
`az group delete --name "nombre-gr" --no-wait` 
Antes poner (para ver los grupos de recursos que hay): 
az group list --output table

# Borrar todos los recursos con la etiqueta indicada. Esto hay que ponerlo en el Cloud Shell de Azure
`az group list --tag cor-aut-delete=true --query [].name -o tsv | xargs -otl az group delete --no-wait  --yes --name`

Si tenemos problemas de permisos en el despliegue hay que realizar los siguientes pasos:
Grant Access to User and/or Service principal at root scope "/" to deploy Enterprise-Scale reference implementation Please ensure you are logged in as a user with UAA role enabled in AAD tenant and logged in user is not a guest user.
get object Id of the current user (that is used above)
$user = Get-AzADUser -UserPrincipalName (Get-AzContext).Account

assign Owner role at Tenant root scope ("/") as a User Access Administrator to current user
New-AzRoleAssignment -Scope '/' -RoleDefinitionName 'Owner' -ObjectId $user.Id

2[OPTIONAL]. Elevate Access to manage Azure resources in the directory Sign in to the Azure portal or the Azure Active Directory admin center as a Global Administrator. If you are using Azure AD Privileged Identity Management, activate your Global Administrator role assignment. Open Azure Active Directory. Under Manage, select Properties. Under Access management for Azure resources, set the toggle to Yes.

#Para seguir los anteriores pasos nos hemos guiado del siguiente enlace https://github.com/Azure/Enterprise-Scale/blob/main/docs/EnterpriseScale-Setup-azure.md#2-grant-access-to-user-at-root-scope--to-deploy-enterprise-scale-reference-implementation 


Para hacer el deploy: 

New-AzSubscriptionDeployment `
  -Location northeurope `
  -TemplateFile ./main.bsc.bicep `
  -TemplateParameterFile ./main.parameters.json



### Azure Configuration for GitHub  

The newly created GitHub repo uses GitHub Actions to deploy Azure resources and application code automatically. Your subscription is accessed using an Azure Service Principal. This is an identity created for use by applications, hosted services, and automated tools to access Azure resources. The following steps show how to [set up GitHub Actions to deploy Azure applications](https://github.com/Azure/actions-workflow-samples/blob/master/assets/create-secrets-for-GitHub-workflows.md)

1. Create an [Azure Service Principal](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli) with **contributor** permissions on the subscription. The subscription-level permission is needed because the deployment includes creation of the resource group itself.
 * Run the following [az cli](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) command, either locally on your command line or on the Cloud Shell. 
   Replace {subscription-id} with the id of the subscription in GUID format. {service-principal-name} can be any alfanumeric string, e.g. GithubPrincipal
    ```bash  
       az ad sp create-for-rbac --name {service-principal-name} --role contributor --scopes /subscriptions/{subscription-id} --sdk-auth      
      ```
 * The command should output a JSON object similar to this:
 ```
      {
        "clientId": "<GUID>",
        "clientSecret": "<GUID>",
        "subscriptionId": "<GUID>",
        "tenantId": "<GUID>",
        "activeDirectoryEndpointUrl": "<URL>",
        "resourceManagerEndpointUrl": "<URL>",
        "activeDirectoryGraphResourceId": "<URL>",
        "sqlManagementEndpointUrl": "<URL>",
        "galleryEndpointUrl": "<URL>",
        "managementEndpointUrl": "<URL>"
      }
   ```
2. Store the output JSON as the value of a GitHub secret named 'AZURE_CREDENTIALS'
   + Under your repository name, click Settings. 
   + In the "Security" section of the sidebar, select Secrets. 
   + At the top of the page, click New repository secret
   + Provide the secret name as AZURE_CREDENTIALS
   + Add the output JSON as secret value
   + Then repeat this pocess and create a Secret for each of the following Iteam with their corresponding values:  

    + PULL SECRET (+ Go to your [Red Hat OpenShift cluster manager portal](https://console.redhat.com/openshift/install/azure/aro-provisioned) and select Download pull secret)

    + AAD_CLIENT_ID 

    + AAD_CLIENT_SECRET

    + AAD_SP_OB_ID

    + ARO_Cluster_ID

    + AZURE CREDENTIALS

    + AZURE_SUBSCRIPTION
  
### Rewuired Parameter Definitions 

3. The following  parameters are required.

| Property | Description | Default Value |
|----------|-------------|---------------|
| `pullSecret` | The pull secret that you obtained from the Red Hat OpenShift Cluster Manager web site.| |
| `aadClientId` | The Service Prinicipal  Client ID  (a GUID) of  the service principal for the Azure AD client application. | AAD_CLIENT_ID |
| `aadObjectId` | The Service Prinicipal Object ID (a GUID) of the service principal for the Azure AD client application. | AAD_SP_OB_ID |
| `aadClientSecret` | The client secret of the service principal for the Azure AD client application, as a secure string. | AAD_CLIENT_SECRET |
| `rpObjectId` | The object ID of the ARO Cluster. | ARO_Cluster_ID |
| `Azure_Credentials` | The JSON that is provided when you create a Service Principal. | |
| `Azure_Subscription` | The Subscription ID of the resource provider Service Principal. | |

### Azure Protal Permmision Configuration

4. Verify your Azure Permissions ( You must have Contributor and User Access Administrator roles)
      
  * Azure Red Hat OpenShift requires roleAssignment/write permission, so make sure  your Azure user account has Microsoft.Authorization/roleAssignments/write permissions, such as User Access Administrator or Owner and Contributor. More info can be found in the documentation for [Azure built-in roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles).

  + Go to your Subcription, look to the left hand side menu and select Access Control (IAM).

  + Select Role Assignments.

  + Type in the name of your Service Principle, check the access levels.

  + Sinc you just created it, the Service Principal will have Contributor Access.

  + In the Top Menu...Click "+Add", and select Ass Role Assignment from the drop down menu...

  + In the Role Serach Box.... type "User Access Administrator"

  + In the Details column, click "View"

  + At the bottom of the page, click "Select Role"

  + Then click.."Next"

  + On th Menbers Page...click "+Select Members"

  + On the Select Members menu..type the name of the "Service Pricicpal" in the select box

  + At the bottom of the menu, click Select

  + Copy the Service Prnicipal Object ID and save it for later use...the valu will be added to the GIHUB Actions Secrets as the "ARO_SP_OB_ID"

  + Click Review and Assign....

  + GitHub Workflow setup

  + On the Reopository top menu, click "Settings".

  + On the left hand side Menu, scroll down and click "Secrets" and select "Actions" from the drop down menu.

  + On the right hand side, select "New Reposistory Secret" and create a GITHUB 


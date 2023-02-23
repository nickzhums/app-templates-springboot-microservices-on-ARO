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

    + AAD_CLIENT_ID - Located in the Service Principal

    + AAD_CLIENT_SECRET - Located in the Serivce Principal

    + AAD_SP_OB_ID - Located in the Service Principal

    + ARO_CLUSTER_ID - More information on how to attain the Cluster ID is listed in Section 4. 

    + AZURE CREDENTIALS - Is the Serivce Principal

    + AZURE_SUBSCRIPTION - Located in the Service Principal

    + Then make sure that you update the "CLUSTER_RG" String....it needs your Subcription ID!!!!

    + Also, make sure that you copy your ".kube/config" file into the "file.crt" located in the infa/aro-bicep/modules folder. 
  
### Required Parameter Definitions 

3. The following  parameters are required.

| Property | Description | Default Value |
|----------|-------------|---------------|
| `pullSecret` | The pull secret that you obtained from the Red Hat OpenShift Cluster Manager web site.| |
| `aadClientId` | The Service Prinicipal  Client ID  (a GUID) of  the service principal for the Azure AD client application. | AAD_CLIENT_ID |
| `aadObjectId` | The Service Prinicipal Object ID (a GUID) of the service principal for the Azure AD client application. | AAD_SP_OB_ID |
| `aadClientSecret` | The client secret of the service principal for the Azure AD client application, as a secure string. | AAD_CLIENT_SECRET |
| `rpObjectId` | The object ID of the ARO Cluster. | ARO_CLUSTER_ID |
| `Azure_Credentials` | The JSON that is provided when you create a Service Principal. | |
| `Azure_Subscription` | The Subscription ID of the resource provider Service Principal. | |

### ARO Cluster ID Location
4.  The best way to attain the ARO Cluster ID is g to the Azure portal and deploy an ARO Cluster via the portal.  

  + Goto the Azure Home Page and view all of the services.

  + Select Azure Redhat Openshift (ARO) ***Note** - If you dont see Azure RedHat Openshift listed, you can type the name into the serach bar at the top of the page and it will locate it for you. 

  + Click "+Create" - located in the upper left hand corner.

  + The Azure Portal will walk you through 5 Screens. (Basics, Authenication, Networking, Tags, Review + Create)

  + Follow the required guideance for each screen. 

  + Once you have filled in all of the rreuired information, you will get to the "Review + Create"....Click "Create" -- located on the lower left hand side.  

  + As the Cluster starts to deploy, goto the left hand side and locate the Template and Download a copy.

  + The Azure Portal will open the ARO Template....just scroll down till yuou see the rpObjectId. 

  + The rpObjectId is the ARO_CLUSTER_ID!!!

  + Copy it, and save it as a GitHUb Action Secret. 

### Azure Portal Permmision Configuration

5. Verify your Azure Permissions ( You must have Contributor and User Access Administrator roles)
      
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


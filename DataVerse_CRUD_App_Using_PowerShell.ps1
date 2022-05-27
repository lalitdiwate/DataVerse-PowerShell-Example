We can use the PowerShell script below to perform CRUD operations on the DataVerse table by leveraging Azure AD.
#Parameter
        $TenantId = 'xxxxxxxxxxx' #Directory (tenant) ID
        $AppId = 'xxxxxxxxxxx' #Application (client) ID
        $ClientSecret = 'xxxxxxxxxxx '  #ClientSecretValue
        $PowerPlatformOrg = 'xxxxxxxxxxx'   #OrgID YourEnvironmentId
        $PowerPlatformEnvironmentUrl = "https://$($PowerPlatformOrg).crm8.dynamics.com"
        $oAuthTokenEndpoint = "https://login.microsoftonline.com/$($TenantId)/oauth2/v2.0/token"
<#
Note
	$TenantId
		The Directory (tenant) ID of the App registration
$AppId
		The Application (client) ID of the App registration
	$ClientSecret
		The client secret generated within the App registration
	$ PowerPlatformOrg
		Dynamics 365 Organization ID
$ PowerPlatformEnvironmentUrl
		The URL of the Dataverse environment you want to connect to perform CRUD Operation
$ oAuthTokenEndpoint
The “v2 OAuth” endpoint is for the App registration. You’ll want to open the app registration and click the “endpoints” button in the overview area to find it. Then, copy the “OAuth 2.0” token endpoint (v2) URL.
#>



<############################Start_Access_Token_Request##############################>
##########################################################
                # To Generate Access Token 
                ##########################################################
                # OAuth Body Access Token Request
                $authBody = @{
                    client_id = $AppId;
                    client_secret = $ClientSecret;    
                    # The v2 endpoint for OAuth uses scope instead of resource
                    scope = "$($PowerPlatformEnvironmentUrl)/.default"    
                    grant_type = 'client_credentials'
                }
            
# Parameters for OAuth Access Token Request
                $authParams = @{
                    URI = $oAuthTokenEndpoint
                    Method = 'POST'
                    ContentType = 'application/x-www-form-urlencoded'
                    Body = $authBody
                }
             # Get Access Token
                $authResponseObject = Invoke-RestMethod @authParams -ErrorAction Stop
                $authResponseObject
<############################End_Access_Token_Request###############################>





<################################Start_Extract_Data_From_DataVerse_Table###############>
##########################################################
                # To read data from the DataVerse table.
                ##########################################################


$getDataRequestUri = 'accounts?$top=5&$select=name,accountid';
# Set up web API call parameters, including a header for the access token
    $getApiCallParams = @{
        URI = "$($PowerPlatformEnvironmentUrl)/api/data/v9.1/$($getDataRequestUri)"
        Headers = @{
            "Authorization" = "$($authResponseObject.token_type) $($authResponseObject.access_token)"
            "Accept" = "application/json"
            "OData-MaxVersion" = "4.0"
            "OData-Version" = "4.0"
        }
        Method = 'GET'
    }

# Call API to Get Response
    $getApiResponseObject = Invoke-RestMethod @getApiCallParams -ErrorAction Stop
# Output
    $getApiResponseObject.value
 

<#########################End_Extract_Data_From_DataVerse_Table######################>

<#########################Start_Create_New_Record####################################>
##########################################################
                # To add a new record to the DataVerse table.
              ##########################################################
$postRequestUri = "accounts"+'?$select=name,accountid'
    $postBody = @{
        'name' = 'Lalit'
    } | ConvertTo-Json
# Set up web API call parameters, including a header for the access token
    $postApiCallParams = @{
        URI = "$($PowerPlatformEnvironmentUrl)/api/data/v9.1/$($postRequestUri)"
        Headers = @{
            "Authorization" = "$($authResponseObject.token_type) $($authResponseObject.access_token)"
            "Accept" = "application/json"
            "OData-MaxVersion" = "4.0"
            "OData-Version" = "4.0"
            "Content-Type" = "application/json; charset=utf-8"
            "Prefer" = "return=representation"  # in order to return data
        }
        Method = 'POST'
        Body = $postBody
    }
#Call Api to Create New Record
$postApiResponseObject = Invoke-RestMethod @postApiCallParams -ErrorAction Stop
#Output
$postApiResponseObject.value

<#################################End_Create_New_Record#############################>

<###############################Start_Update_Record##################################>
##########################################################
                # To create an update request to the DataVerse table.
              ##########################################################
$accountid = 'be494594-90cf-ec11-a7b5-6045bda5684f'
$patchRequestUri = "accounts($($accountid))"+'?$select=name,accountid'
$updateBody  = @{
    'name' = 'Lalit D'
} | ConvertTo-Json
# Set up web API call parameters, including a header for the access token
$patchApiCallParams = @{
    URI = "$($PowerPlatformEnvironmentUrl)/api/data/v9.1/$($patchRequestUri)"
    Headers = @{
        "Authorization" = "$($authResponseObject.token_type) $($authResponseObject.access_token)"
        "Accept" = "application/json"
        "OData-MaxVersion" = "4.0"
        "OData-Version" = "4.0"
        "Content-Type" = "application/json; charset=utf-8"
        "Prefer" = "return=representation"  # in order to return data
        "If-Match" = "*" 
    }
    Method = 'PATCH'
    Body = $updateBody
}



# Call API to Update a record.
$patchApiResponseObject = Invoke-RestMethod @patchApiCallParams -ErrorAction Stop
# Output
$patchApiResponseObject.Value
<################################Start_Update_Record#############################>
<##############################Start_Delete_Record##############################>

##########################################################
                # To remove a record from the DataVerse table.
              ##########################################################

$accountid = 'be494594-90cf-ec11-a7b5-6045bda5684f'
$deleteRequestUri = "accounts($($accountid))"+'?$select=name,accountid'
# Set up web API call parameters, including a header for the access token
$deleteApiCallParams = @{
    URI = "$($PowerPlatformEnvironmentUrl)/api/data/v9.1/$($deleteRequestUri)"
    Headers = @{
        "Authorization" = "$($authResponseObject.token_type) $($authResponseObject.access_token)"
        "OData-MaxVersion" = "4.0"
        "OData-Version" = "4.0"
        "Content-Type" = "application/json; charset=utf-8"
    }
    Method = 'DELETE'
}

# Call API to delete a record. 
$deleteApiResponseObject = Invoke-RestMethod @deleteApiCallParams -ErrorAction Stop
# Output
 $deleteApiResponseObject


<##############################End_Delete_Record#############################>

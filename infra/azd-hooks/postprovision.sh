#!/bin/bash

# Convert WORKSPACE to lowercase and trim any whitespace
WORKSPACE=$(echo "${WORKSPACE}" | tr '[:upper:]' '[:lower:]' | xargs)

# Check if WORKSPACE is set to "azure"
if [ "$WORKSPACE" = "azure" ]; then
    echo "Retrieving cluster credentials"
    az aks get-credentials --resource-group ${rg_name} --name ${aks_name}
    
    echo "Deploy Helm chart"
    helm upgrade aks-store-demo ./charts/aks-store-demo \
    --install \
    --set aiService.create=true \
    --set aiService.modelDeploymentName=${ai_model_name} \
    --set aiService.openAiEndpoint=${ai_endpoint} \
    --set aiService.managedIdentityClientId=${ai_managed_identity_client_id} \
    --set orderService.useAzureServiceBus=true \
    --set orderService.queueHost=${sb_namespace_host} \
    --set orderService.queuePort=5671 \
    --set orderService.queueUsername=${sb_sender_username} \
    --set orderService.queuePassword=${sb_sender_key} \
    --set orderService.queueTransport=tls \
    --set makelineService.useAzureCosmosDB=true \
    --set makelineService.orderQueueUri=${sb_namespace_uri} \
    --set makelineService.orderQueueUsername=${sb_listener_username} \
    --set makelineService.orderQueuePassword=${sb_listener_key} \
    --set makelineService.orderDBUri=${db_uri} \
    --set makelineService.orderDBUsername=${db_account_name} \
    --set makelineService.orderDBPassword=${db_key}
    
    # Add a delay to ensure that the service is up and running
    echo "Waiting for the service to be available..."
    sleep 30
    
    echo "Retrieving the external IP address of the store-admin service"
    STORE_ADMIN_IP=$(kubectl get svc store-admin -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
    echo "Store-admin service IP: http://$STORE_ADMIN_IP"
fi

azd env get-values > .env

# Check if AZD_PIPELINE_CONFIG_PROMPT is not set or is true
if [ -z "${AZD_PIPELINE_CONFIG_PROMPT}" ] || [ "${AZD_PIPELINE_CONFIG_PROMPT}" = "true" ]; then
    
    echo "======================================================"
    echo "                     Github Action Setup                 "
    echo "======================================================"
    
    # Ask the user a question and get their response
    read -p "Do you want to configure a GitHub action to automatically deploy this repo to Azure when you push code changes? (Y/n) " response

    # Default response is "N"
    response=${response:-Y}

    # Check the response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "Configuring GitHub Action..."
        azd pipeline config
        # Set AZD_GH_ACTION_PROMPT to false
        azd env set AZD_PIPELINE_CONFIG_PROMPT false
    fi
fi

# Retrieve the internalId of the Cognitive Services account
INTERNAL_ID=$(az cognitiveservices account show \
    --name ${ai_name} \
    -g ${rg_name} \
--query "properties.internalId" -o tsv)

# Construct the URL
COGNITIVE_SERVICE_URL="https://oai.azure.com/portal/${INTERNAL_ID}?tenantid=${azure_tenant_id}"


# Display OpenAI Endpoint and other details
echo "======================================================"
echo " AI Configuration                 "
echo "======================================================"
echo "    OpenAI Endpoint: ${ai_endpoint}                    "
echo "    SKU Name: S0                             "
echo "    AI Model Name: ${ai_model_name}                    "
echo "    Model Version: 0613                    "
echo "    Model Capacity: 120                "
echo "    Azure Portal Link:                                 "
echo "    https://ms.portal.azure.com/#@microsoft.onmicrosoft.com/resource/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${rg_name}/providers/Microsoft.CognitiveServices/accounts/${ai_name}/overview"
echo "    Azure OpenAI Studio: ${COGNITIVE_SERVICE_URL}    "
echo ""
echo "======================================================"
echo " AI Test                 "
echo "======================================================"
echo " You can run the following to test the AI Service: "
echo "      ./tests/test-ai.sh"
echo ""
echo "======================================================"
echo " AI Key                 "
echo "======================================================"
echo " The Azure OpenAI Key is stored in the .env file in the root of this repo.  "
echo ""
echo " You can also find the key by running this following command: "
echo ""
echo "    azd env get-values"
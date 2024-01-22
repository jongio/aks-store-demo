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

#!/bin/bash

# Convert AI_ONLY to lowercase and trim any whitespace
AI_ONLY=$(echo "${AI_ONLY}" | tr '[:upper:]' '[:lower:]' | xargs)

# Check if AI_ONLY is set to "true"
if [ "$AI_ONLY" = "false" ]; then
    echo "Ensuring Azure CLI extensions and dependencies are installed"
    az provider register --namespace Microsoft.ContainerService
    az feature register --namespace Microsoft.ContainerService --name AKS-KedaPreview
    az feature register --namespace Microsoft.ContainerService --name AKS-PrometheusAddonPreview
    az feature register --namespace Microsoft.ContainerService --name EnableWorkloadIdentityPreview
    az feature register --namespace Microsoft.ContainerService --name NetworkObservabilityPreview
    az extension add --upgrade --name aks-preview
    az extension add --upgrade --name amg
fi

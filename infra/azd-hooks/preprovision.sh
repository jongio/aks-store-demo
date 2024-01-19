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
else
    # Define the file path
    TF_DIR="infra/tfstate"

    # Set TF_VAR_location to the value of AZURE_LOCATION
    export TF_VAR_location=$AZURE_LOCATION

    # Set TF_VAR_environment_name to the value of AZURE_ENV_NAME
    export TF_VAR_environment_name=$AZURE_ENV_NAME

    # Initialize and apply Terraform configuration
    terraform -chdir="$TF_DIR" init
    terraform -chdir="$TF_DIR" apply -auto-approve

        # Add a delay to ensure that the service is up and running
    echo "Waiting for the service to be available..."
    sleep 30

    # Capture the outputs
    RS_STORAGE_ACCOUNT=$(terraform -chdir="$TF_DIR" output -raw RS_STORAGE_ACCOUNT )
    RS_CONTAINER_NAME=$(terraform -chdir="$TF_DIR" output -raw RS_CONTAINER_NAME )
    RS_RESOURCE_GROUP=$(terraform -chdir="$TF_DIR" output -raw RS_RESOURCE_GROUP )

    # Set the environment variables
    azd env set RS_STORAGE_ACCOUNT "$RS_STORAGE_ACCOUNT"
    azd env set RS_CONTAINER_NAME "$RS_CONTAINER_NAME"
    azd env set RS_RESOURCE_GROUP "$RS_RESOURCE_GROUP"
fi


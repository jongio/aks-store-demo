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
    
    # Define the file path
    FILE_PATH="infra/provider.tf"
    TF_DIR="infra/tfstate"
    
    # Check if backend "azurerm" already exists in the file
    if ! grep -q 'backend "azurerm"' "$FILE_PATH"; then
        # Define the pattern to search for and the text to add
        SEARCH_PATTERN="^terraform {"
        TEXT_TO_ADD="\n  backend \"azurerm\" {}\n"
        
        # Use awk to add the text within the terraform block
        awk -v pattern="$SEARCH_PATTERN" -v text="$TEXT_TO_ADD" '
    $0 ~ pattern {print; print text; next}
        1' "$FILE_PATH" > temp && mv temp "$FILE_PATH"
        
        echo "Added backend \"azurerm\" to the terraform configuration in $FILE_PATH"
    else
        echo "backend \"azurerm\" already exists in $FILE_PATH"
    fi
    
    # Navigate to the Terraform directory
    cd "$TF_DIR" || exit
    
    # Initialize and apply Terraform configuration
    terraform init
    terraform apply -auto-approve
    
    # Capture the outputs
    RS_STORAGE_ACCOUNT=$(terraform output -raw RS_STORAGE_ACCOUNT)
    RS_CONTAINER_NAME=$(terraform output -raw RS_CONTAINER_NAME)
    RS_RESOURCE_GROUP=$(terraform output -raw RS_RESOURCE_GROUP)
    
    # Set the environment variables
    azd env set RS_STORAGE_ACCOUNT "$RS_STORAGE_ACCOUNT"
    azd env set RS_CONTAINER_NAME "$RS_CONTAINER_NAME"
    azd env set RS_RESOURCE_GROUP "$RS_RESOURCE_GROUP"
    
    echo "Environment variables set successfully."
    
    
fi

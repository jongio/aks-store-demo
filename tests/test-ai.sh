 #!/bin/sh

while IFS='=' read -r key value; do
    value=$(echo "$value" | sed 's/^"//' | sed 's/"$//')
    export "$key=$value"
done <<EOF
$(azd env get-values)
EOF


# Define the chat messages
CHAT_MESSAGES='{"messages":[{"role": "system", "content": "You are a helpful assistant."},{"role": "user", "content": "Does Azure OpenAI support customer managed keys?"},{"role": "assistant", "content": "Yes, customer managed keys are supported by Azure OpenAI."},{"role": "user", "content": "Do other Azure AI services support this too?"}]}'

# Define the chat endpoint
CHAT_ENDPOINT="${ai_endpoint}openai/deployments/${ai_model_name}/chat/completions?api-version=2023-05-15"
echo "AI Endpoint: ${ai_endpoint}"
echo "REST Endpoint: ${CHAT_ENDPOINT}"

# Output the user messages
echo "==========User Messages=========="
echo "${CHAT_MESSAGES}" | jq -r '.messages[] | select(.role == "user") | .content'

# Make the curl request and output the assistant's reply
echo "==========AI Response=========="
curl -s ${CHAT_ENDPOINT} \
  -H "Content-Type: application/json" \
  -H "api-key: ${ai_key}" \
  -d "${CHAT_MESSAGES}" | jq -r '"Model: \(.model)\nMessage ID: \(.id)\nAssistant Reply: \(.choices[0].message.content)"'

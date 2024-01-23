 #!/bin/sh

echo "Loading azd .env file from current environment..."

while IFS='=' read -r key value; do
    value=$(echo "$value" | sed 's/^"//' | sed 's/"$//')
    export "$key=$value"
done <<EOF
$(azd env get-values)
EOF

echo ${ai_endpoint}
curl "${ai_endpoint}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${ai_key}" \
  -d '{
    "prompt": "Translate the following English text to French: Hello, how are you?",
    "temperature": 0.7,
    "max_tokens": 60
}'

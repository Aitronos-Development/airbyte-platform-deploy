#!/bin/bash
# Bootstrap Airbyte instance with connector definitions and configurations

set -e

ENVIRONMENT="${1:-stage}"
AIRBYTE_URL="${2}"
CATALOG_FILE="${3:-../../airbyte-connectors/catalog.yaml}"

if [ -z "$AIRBYTE_URL" ]; then
  echo "Usage: $0 <environment> <airbyte-url> [catalog-file]"
  echo "Example: $0 stage https://airbyte-stage.yourdomain.com"
  exit 1
fi

echo "Bootstrapping Airbyte ${ENVIRONMENT} environment"
echo "Airbyte URL: ${AIRBYTE_URL}"
echo "Catalog: ${CATALOG_FILE}"

# Check if Airbyte is accessible
echo "Checking Airbyte availability..."
if ! curl -s -f "${AIRBYTE_URL}/api/v1/health" > /dev/null; then
  echo "Error: Airbyte is not accessible at ${AIRBYTE_URL}"
  echo "Please check the URL and ensure Airbyte is running"
  exit 1
fi

echo "✓ Airbyte is accessible"

# Get workspace ID (assumes default workspace)
echo "Getting workspace ID..."
WORKSPACE_ID=$(curl -s -X POST "${AIRBYTE_URL}/api/v1/workspaces/list" \
  -H "Content-Type: application/json" \
  -d '{}' | jq -r '.workspaces[0].workspaceId')

if [ -z "$WORKSPACE_ID" ] || [ "$WORKSPACE_ID" = "null" ]; then
  echo "Error: Could not get workspace ID"
  exit 1
fi

echo "✓ Workspace ID: ${WORKSPACE_ID}"

# Function to upsert source definition
upsert_source_definition() {
  local name=$1
  local image=$2
  local tag=$3
  local description=$4
  
  echo "Registering source: ${name}"
  
  # Check if source definition exists
  EXISTING_ID=$(curl -s -X POST "${AIRBYTE_URL}/api/v1/source_definitions/list" \
    -H "Content-Type: application/json" \
    -d '{}' | jq -r ".sourceDefinitions[] | select(.name == \"${name}\") | .sourceDefinitionId")
  
  if [ -n "$EXISTING_ID" ] && [ "$EXISTING_ID" != "null" ]; then
    echo "  Source definition already exists, updating..."
    curl -s -X POST "${AIRBYTE_URL}/api/v1/source_definitions/update" \
      -H "Content-Type: application/json" \
      -d "{
        \"sourceDefinitionId\": \"${EXISTING_ID}\",
        \"dockerRepository\": \"${image}\",
        \"dockerImageTag\": \"${tag}\"
      }" > /dev/null
    echo "  ✓ Updated ${name}"
  else
    echo "  Creating new source definition..."
    curl -s -X POST "${AIRBYTE_URL}/api/v1/source_definitions/create_custom" \
      -H "Content-Type: application/json" \
      -d "{
        \"workspaceId\": \"${WORKSPACE_ID}\",
        \"sourceDefinition\": {
          \"name\": \"${name}\",
          \"dockerRepository\": \"${image}\",
          \"dockerImageTag\": \"${tag}\",
          \"documentationUrl\": \"https://github.com/yourorg/airbyte-connectors\",
          \"icon\": \"\"
        }
      }" > /dev/null
    echo "  ✓ Created ${name}"
  fi
}

# Function to upsert destination definition
upsert_destination_definition() {
  local name=$1
  local image=$2
  local tag=$3
  local description=$4
  
  echo "Registering destination: ${name}"
  
  EXISTING_ID=$(curl -s -X POST "${AIRBYTE_URL}/api/v1/destination_definitions/list" \
    -H "Content-Type: application/json" \
    -d '{}' | jq -r ".destinationDefinitions[] | select(.name == \"${name}\") | .destinationDefinitionId")
  
  if [ -n "$EXISTING_ID" ] && [ "$EXISTING_ID" != "null" ]; then
    echo "  Destination definition already exists, updating..."
    curl -s -X POST "${AIRBYTE_URL}/api/v1/destination_definitions/update" \
      -H "Content-Type: application/json" \
      -d "{
        \"destinationDefinitionId\": \"${EXISTING_ID}\",
        \"dockerRepository\": \"${image}\",
        \"dockerImageTag\": \"${tag}\"
      }" > /dev/null
    echo "  ✓ Updated ${name}"
  else
    echo "  Creating new destination definition..."
    curl -s -X POST "${AIRBYTE_URL}/api/v1/destination_definitions/create_custom" \
      -H "Content-Type: application/json" \
      -d "{
        \"workspaceId\": \"${WORKSPACE_ID}\",
        \"destinationDefinition\": {
          \"name\": \"${name}\",
          \"dockerRepository\": \"${image}\",
          \"dockerImageTag\": \"${tag}\",
          \"documentationUrl\": \"https://github.com/yourorg/airbyte-connectors\",
          \"icon\": \"\"
        }
      }" > /dev/null
    echo "  ✓ Created ${name}"
  fi
}

# Parse catalog file and register connectors
echo ""
echo "Processing connector catalog..."

if [ ! -f "$CATALOG_FILE" ]; then
  echo "Warning: Catalog file not found: ${CATALOG_FILE}"
  echo "No custom connectors to register"
else
  # Simple YAML parsing (requires yq for complex cases)
  # For now, just create a message
  echo "Catalog file found. Parse and register connectors as needed."
  echo "You can manually add connectors or use Python/yq to parse the catalog.yaml"
fi

echo ""
echo "========================================="
echo "Bootstrap complete!"
echo "========================================="
echo "Environment: ${ENVIRONMENT}"
echo "Airbyte URL: ${AIRBYTE_URL}"
echo "Workspace ID: ${WORKSPACE_ID}"
echo ""
echo "Next steps:"
echo "1. Log in to Airbyte UI: ${AIRBYTE_URL}"
echo "2. Create sources and destinations"
echo "3. Configure connections"
echo "4. Test syncs"
echo ""


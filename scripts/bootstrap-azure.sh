#!/usr/bin/env bash
set -euo pipefail

repository=""
resource_group="rg-github-portfolio"
location="francecentral"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --github-repository)
      repository="$2"
      shift 2
      ;;
    --resource-group)
      resource_group="$2"
      shift 2
      ;;
    --location)
      location="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "${repository}" ]]; then
  echo "Missing --github-repository owner/repository" >&2
  exit 1
fi

subscription_id="$(az account show --query id --output tsv)"
tenant_id="$(az account show --query tenantId --output tsv)"
safe_name="$(echo "${repository}" | tr '/_' '--' | tr '[:upper:]' '[:lower:]')"
application_name="github-${safe_name}-azure-demo"

az group create \
  --name "${resource_group}" \
  --location "${location}" \
  --output none

application_id="$(az ad app list \
  --display-name "${application_name}" \
  --query '[0].appId' \
  --output tsv)"

if [[ -z "${application_id}" ]]; then
  application_id="$(az ad app create \
    --display-name "${application_name}" \
    --query appId \
    --output tsv)"
fi

if ! az ad sp show --id "${application_id}" --output none 2>/dev/null; then
  az ad sp create --id "${application_id}" --output none
fi

resource_group_id="$(az group show \
  --name "${resource_group}" \
  --query id \
  --output tsv)"

principal_id="$(az ad sp show --id "${application_id}" --query id --output tsv)"

if [[ "$(az role assignment list \
  --assignee-object-id "${principal_id}" \
  --scope "${resource_group_id}" \
  --role Contributor \
  --query 'length(@)' \
  --output tsv)" == "0" ]]; then
  az role assignment create \
    --assignee-object-id "${principal_id}" \
    --assignee-principal-type ServicePrincipal \
    --role Contributor \
    --scope "${resource_group_id}" \
    --output none
fi

credential_file="$(mktemp)"
trap 'rm -f "${credential_file}"' EXIT

cat > "${credential_file}" <<EOF
{
  "name": "github-main",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:${repository}:ref:refs/heads/main",
  "description": "GitHub Actions main branch",
  "audiences": ["api://AzureADTokenExchange"]
}
EOF

if [[ "$(az ad app federated-credential list \
  --id "${application_id}" \
  --query "[?name=='github-main'] | length(@)" \
  --output tsv)" == "0" ]]; then
  az ad app federated-credential create \
    --id "${application_id}" \
    --parameters "${credential_file}" \
    --output none
fi

cat <<EOF

GitHub Actions variables:

AZURE_CLIENT_ID=${application_id}
AZURE_TENANT_ID=${tenant_id}
AZURE_SUBSCRIPTION_ID=${subscription_id}
AZURE_RESOURCE_GROUP=${resource_group}
AZURE_LOCATION=${location}
EOF

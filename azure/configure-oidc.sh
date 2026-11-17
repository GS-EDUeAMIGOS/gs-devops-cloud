#!/usr/bin/env bash
set -euo pipefail
# Executar uma vez, após revisar o escopo. Exige permissão de criar identidade e atribuir papel.
: "${AZURE_SUBSCRIPTION_ID:?Informe a assinatura escolhida}"
rg=${RESOURCE_GROUP:-rg-viacidada-gs}
vm=${VM_NAME:-vm-viacidada-gs}
identity=identity-viacidada-github
az account set --subscription "$AZURE_SUBSCRIPTION_ID"
location=$(az group show -n "$rg" --query location -o tsv)
az identity create -g "$rg" -n "$identity" -l "$location" -o none
principal=$(az identity show -g "$rg" -n "$identity" --query principalId -o tsv)
vm_id=$(az vm show -g "$rg" -n "$vm" --query id -o tsv)
az role assignment create --assignee-object-id "$principal" --assignee-principal-type ServicePrincipal \
  --role 'Virtual Machine Contributor' --scope "$vm_id" -o none
for repository in gs-devops-cloud gs-java-api; do
  if ! az identity federated-credential show -g "$rg" --identity-name "$identity" -n "$repository-main" -o none 2>/dev/null; then
    az identity federated-credential create -g "$rg" --identity-name "$identity" -n "$repository-main" \
      --issuer https://token.actions.githubusercontent.com \
      --subject "repo:GS-EDUeAMIGOS/$repository:ref:refs/heads/main" \
      --audiences api://AzureADTokenExchange -o none
  fi
done
echo 'Identidade configurada para as duas branches main; papel limitado a esta VM.'
echo 'Copie os IDs da identidade/assinatura para as variáveis Actions, sem senha de service principal.'
az identity show -g "$rg" -n "$identity" --query '{AZURE_CLIENT_ID:clientId,AZURE_TENANT_ID:tenantId}' -o json

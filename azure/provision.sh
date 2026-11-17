#!/usr/bin/env bash
set -euo pipefail
: "${AZURE_SUBSCRIPTION_ID:?Informe a assinatura escolhida}"
rg=${RESOURCE_GROUP:-rg-viacidada-gs}
vm=${VM_NAME:-vm-viacidada-gs}
location=${AZURE_LOCATION:-eastus}
size=${VM_SIZE:-Standard_D2s_v4}
az account set --subscription "$AZURE_SUBSCRIPTION_ID"
[[ $(az group exists -n "$rg") == false ]] || { echo 'Grupo já existe: confira antes de criar novamente.'; exit 1; }
az group create -n "$rg" -l "$location" --tags project=ViaCidada managed-by=viacidada-devops -o none
az vm create -g "$rg" -n "$vm" --location "$location" --image Ubuntu2204 \
  --size "$size" --admin-username azureuser --authentication-type ssh --generate-ssh-keys \
  --public-ip-sku Standard --nsg "$vm-nsg" --nsg-rule NONE \
  --storage-sku Standard_LRS --os-disk-size-gb 64 \
  --tags project=ViaCidada managed-by=viacidada-devops -o none
az vm get-instance-view -g "$rg" -n "$vm" --query 'instanceView.statuses[].displayStatus' -o tsv
echo 'VM criada sem portas públicas de entrada. Use Run Command.'

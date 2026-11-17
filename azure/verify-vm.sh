#!/usr/bin/env bash
set -euo pipefail
rg=${RESOURCE_GROUP:-rg-viacidada-gs}
vm=${VM_NAME:-vm-viacidada-gs}
az vm get-instance-view -g "$rg" -n "$vm" --query 'instanceView.statuses[].displayStatus' -o tsv
output=$(az vm run-command invoke -g "$rg" -n "$vm" --command-id RunShellScript \
  --scripts 'bash -c "cd /opt/viacidada/current && bash scripts/verify.sh && bash scripts/select-db.sh"' \
  --query 'value[].message' -o tsv)
printf '%s\n' "$output"
[[ "$output" == *VIACIDADA_VERIFY_OK* ]] || exit 1

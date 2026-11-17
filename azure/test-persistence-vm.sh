#!/usr/bin/env bash
set -euo pipefail
output=$(az vm run-command invoke -g "${RESOURCE_GROUP:-rg-viacidada-gs}" -n "${VM_NAME:-vm-viacidada-gs}" \
  --command-id RunShellScript \
  --scripts 'bash -c "cd /opt/viacidada/current && bash scripts/test-persistence.sh"' \
  --query 'value[].message' -o tsv)
printf '%s\n' "$output"
[[ "$output" == *VIACIDADA_PERSISTENCE_OK* ]] || exit 1

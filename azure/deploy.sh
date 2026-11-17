#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${AZURE_SUBSCRIPTION_ID:?Informe a assinatura escolhida}"
devops_sha=${DEVOPS_SHA:-$(git rev-parse HEAD)}
java_sha=${JAVA_SHA:-$(cat .java-ref)}
[[ $devops_sha =~ ^[0-9a-f]{40}$ && $java_sha =~ ^[0-9a-f]{40}$ ]] || exit 1
az account set --subscription "$AZURE_SUBSCRIPTION_ID"
script=$(printf "bash -s -- '%s' '%s' <<'VIACIDADA_REMOTE'\n" "$devops_sha" "$java_sha"; cat azure/remote-deploy.sh; printf '\nVIACIDADA_REMOTE\n')
output=$(az vm run-command invoke -g "${RESOURCE_GROUP:-rg-viacidada-gs}" -n "${VM_NAME:-vm-viacidada-gs}" \
  --command-id RunShellScript --scripts "$script" --query 'value[].message' -o tsv)
printf '%s\n' "$output"
[[ "$output" == *"VIACIDADA_DEPLOY_OK java=$java_sha devops=$devops_sha"* ]] || { echo 'Implantação sem confirmação de sucesso.' >&2; exit 1; }

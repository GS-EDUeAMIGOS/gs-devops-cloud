#!/usr/bin/env bash
# Configura somente a chave SPTrans no ambiente privado da VM.
set -euo pipefail
set +x
: "${AZURE_SUBSCRIPTION_ID:?Informe a assinatura escolhida}"
az account set --subscription "$AZURE_SUBSCRIPTION_ID"
IFS= read -r -s -p 'SPTRANS_TOKEN (entrada oculta): ' vc_sptrans_token
printf '\n'
[[ $vc_sptrans_token =~ ^[a-fA-F0-9]{64}$ ]] || { unset vc_sptrans_token; echo 'Formato de token inesperado.'; exit 1; }
remote=$(cat <<'REMOTE'
set -euo pipefail
umask 077
exec 9>/opt/viacidada/deploy.lock
flock -w 900 9
python3 - "$1" <<'PY'
import os
import sys
from pathlib import Path
path = Path('/opt/viacidada/runtime.env')
lines = [line for line in path.read_text().splitlines() if not line.startswith('SPTRANS_TOKEN=')]
lines.append('SPTRANS_TOKEN=' + sys.argv[1])
path.write_text('\n'.join(lines) + '\n')
os.chmod(path, 0o600)
PY
cd /opt/viacidada/current
docker compose up -d --no-build --wait --wait-timeout 900 api
curl --fail --silent --show-error --max-time 90 --get --data-urlencode 'termo=8000' \
  http://127.0.0.1:8080/api/linhas -o /tmp/viacidada-sptrans-check.json
python3 - <<'PY'
import json
from pathlib import Path
rows = json.loads(Path('/tmp/viacidada-sptrans-check.json').read_text())
assert isinstance(rows, list) and rows, 'Consulta SPTrans não retornou linhas.'
print('VIACIDADA_SPTRANS_OK linhas=' + str(len(rows)))
PY
REMOTE
)
script=$(printf "bash -s -- '%s' <<'VIACIDADA_SPTRANS'\n" "$vc_sptrans_token"; printf '%s\n' "$remote"; printf 'VIACIDADA_SPTRANS\n')
unset vc_sptrans_token
output=$(az vm run-command invoke -g "${RESOURCE_GROUP:-rg-viacidada-gs}" -n "${VM_NAME:-vm-viacidada-gs}" \
  --command-id RunShellScript --scripts "$script" --query 'value[].message' -o tsv)
unset script
printf '%s\n' "$output"
[[ $output == *VIACIDADA_SPTRANS_OK* ]] || { echo 'SPTrans sem confirmação de sucesso.'; exit 1; }

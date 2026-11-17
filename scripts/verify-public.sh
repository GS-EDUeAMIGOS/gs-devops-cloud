#!/usr/bin/env bash
set -euo pipefail
base=${1:?Informe a URL HTTPS pública}
base=${base%/}
[[ $base =~ ^https://[a-zA-Z0-9.-]+$ ]] || { echo 'Use uma URL HTTPS sem caminho, token ou credenciais.'; exit 1; }
for path in /actuator/health /swagger-ui/index.html /v3/api-docs /api/ocorrencias; do
  code=$(curl --silent --show-error --fail --retry 30 --retry-all-errors --retry-delay 5 \
    --connect-timeout 10 --max-time 20 --output /dev/null --write-out '%{http_code}' "$base$path")
  [[ $code == 200 ]] || { echo "HTTP $code $path"; exit 1; }
  printf 'HTTPS 200 %s\n' "$path"
done
echo VIACIDADA_PUBLIC_OK

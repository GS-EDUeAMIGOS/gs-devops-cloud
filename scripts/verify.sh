#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
port=${API_PORT:-$(docker compose port api 8080 | head -n 1 | sed 's/.*://')}
curl --fail --silent --show-error --retry 40 --retry-all-errors --retry-delay 3 \
  "http://127.0.0.1:$port/actuator/health"
printf '\n'
for endpoint in swagger-ui/index.html v3/api-docs api/ocorrencias; do
  code=$(curl --silent --show-error -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/$endpoint")
  [[ "$code" == 200 ]] || { echo "HTTP $code /$endpoint"; exit 1; }
  echo "HTTP $code /$endpoint"
done
docker compose ps
docker compose exec -T api id
docker compose exec -T api pwd
docker compose exec -T api ls -l /opt/viacidada
docker compose exec -T db id
echo VIACIDADA_VERIFY_OK

#!/usr/bin/env bash
# Teste HTTP interno do encaminhamento; certificado público é validado na Azure.
set -euo pipefail
trap 'docker rm -f viacidada-proxy-test >/dev/null 2>&1 || true' EXIT
docker compose --profile public run --no-deps --rm proxy caddy validate --config /etc/caddy/Caddyfile
docker compose --profile public run --no-deps -d --name viacidada-proxy-test \
  -p 127.0.0.1:18080:80 -e API_DOMAIN=http://localhost proxy
curl --fail --silent --show-error --retry 15 --retry-all-errors --retry-delay 2 \
  -H 'Host: localhost' http://127.0.0.1:18080/actuator/health
echo
echo VIACIDADA_PROXY_TEST_OK

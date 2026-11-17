#!/usr/bin/env bash
set -euo pipefail
[[ $EUID == 0 ]] || { echo 'Execute pelo Run Command (root).'; exit 1; }
devops_sha=${1:?SHA DevOps ausente}
java_sha=${2:?SHA Java ausente}
[[ $devops_sha =~ ^[0-9a-f]{40}$ && $java_sha =~ ^[0-9a-f]{40}$ ]] || exit 1
install -d -m 700 /opt/viacidada /opt/viacidada/releases
exec 9>/opt/viacidada/deploy.lock
flock -w 900 9
if ! command -v git >/dev/null; then apt-get update; apt-get install -y git ca-certificates; fi
release="/opt/viacidada/releases/${devops_sha}-${java_sha}"
if [[ ! -d "$release/.git" ]]; then
  mkdir -p "$release"
  git -C "$release" init -q
  git -C "$release" remote add origin https://github.com/GS-EDUeAMIGOS/gs-devops-cloud.git
  git -C "$release" fetch --depth 1 origin "$devops_sha"
  git -C "$release" checkout -q --detach FETCH_HEAD
fi
cd "$release"
if ! command -v docker >/dev/null; then bash azure/install-docker.sh; fi
if [[ ! -f /opt/viacidada/runtime.env ]]; then
  python3 scripts/init-env.py
  mv .env /opt/viacidada/runtime.env
fi
[[ -L .env ]] || ln -s /opt/viacidada/runtime.env .env
bash scripts/prepare-source.sh "$java_sha"
export API_IMAGE="viacidada-api:$java_sha-${devops_sha:0:12}"
docker compose config --quiet
docker compose build api
previous=$(readlink -f /opt/viacidada/current 2>/dev/null || true)
if docker compose up -d --no-build --wait --wait-timeout 900 && bash scripts/verify.sh; then
  printf '%s\n' "$API_IMAGE" > .image
  sed -i '/^API_IMAGE=/d' /opt/viacidada/runtime.env
  printf 'API_IMAGE=%s\n' "$API_IMAGE" >> /opt/viacidada/runtime.env
  ln -sfn "$release" /opt/viacidada/current
  echo "VIACIDADA_DEPLOY_OK java=$java_sha devops=$devops_sha"
else
  echo 'Falha de saúde. Tentando restaurar a versão anterior da API.' >&2
  if [[ -n "$previous" && -f "$previous/.image" ]]; then
    export API_IMAGE="$(cat "$previous/.image")"
    (cd "$previous" && docker compose up -d --no-build --wait --wait-timeout 900 api) || echo 'Rollback falhou: intervenção necessária.' >&2
  fi
  exit 1
fi

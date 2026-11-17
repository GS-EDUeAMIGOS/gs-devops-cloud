#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 scripts/smoke-crud.py create
bash scripts/select-db.sh
# Remove e recria ambos os containers; mantém o volume nomeado.
docker compose down
docker compose up -d --no-build --wait --wait-timeout 900
bash scripts/verify.sh
python3 scripts/smoke-crud.py check
python3 scripts/smoke-crud.py cleanup
echo VIACIDADA_PERSISTENCE_OK

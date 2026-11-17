#!/usr/bin/env bash
set -euo pipefail
# Para economizar entre demonstrações: preserva disco e volume; disco/IP continuam cobrados.
az vm deallocate -g "${RESOURCE_GROUP:-rg-viacidada-gs}" -n "${VM_NAME:-vm-viacidada-gs}"

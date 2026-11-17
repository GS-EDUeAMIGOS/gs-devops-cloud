#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
ref=${1:-$(cat .java-ref)}
[[ "$ref" =~ ^[0-9a-f]{40}$ ]] || { echo 'Informe um SHA Java completo, revisado.' >&2; exit 1; }
mkdir -p .build
if [[ -e .build/java ]]; then
  actual=$(git -C .build/java rev-parse HEAD)
  [[ "$actual" == "$ref" ]] || { echo 'Fonte existente é de outro commit; use uma nova pasta de checkout.' >&2; exit 1; }
  [[ -z "$(git -C .build/java status --porcelain)" ]] || { echo 'Fonte contém alterações; preservada.' >&2; exit 1; }
else
  git init -q .build/java
  git -C .build/java remote add origin https://github.com/GS-EDUeAMIGOS/gs-java-api.git
  git -C .build/java fetch --depth 1 origin "$ref"
  git -C .build/java checkout -q --detach FETCH_HEAD
fi
[[ $(git -C .build/java rev-parse HEAD) == "$ref" ]]
printf '%s\n' "$ref" > .build/java.sha
printf 'Fonte Java pronta: %s\n' "$ref"

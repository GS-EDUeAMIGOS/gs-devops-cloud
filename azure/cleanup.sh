#!/usr/bin/env bash
set -euo pipefail
rg=${RESOURCE_GROUP:-rg-viacidada-gs}
[[ $(az group show -n "$rg" --query 'tags."managed-by"' -o tsv) == viacidada-devops ]] || { echo 'Tag não confere; operação interrompida.'; exit 1; }
az resource list -g "$rg" --query '[].{nome:name,tipo:type}' -o table
read -r -p "Exclusão definitiva de VM e dados. Digite $rg para confirmar: " answer
[[ "$answer" == "$rg" ]] || { echo 'Cancelado.'; exit 1; }
az group delete -n "$rg" --yes
[[ $(az group exists -n "$rg") == false ]]
echo VIACIDADA_CLEANUP_OK

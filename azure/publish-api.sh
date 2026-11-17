#!/usr/bin/env bash
# Publica apenas HTTP/HTTPS para o app; Oracle, SSH e porta 8080 ficam privados.
set -euo pipefail
: "${AZURE_SUBSCRIPTION_ID:?Informe a assinatura escolhida}"
rg=${RESOURCE_GROUP:-rg-viacidada-gs}
vm=${VM_NAME:-vm-viacidada-gs}
az account set --subscription "$AZURE_SUBSCRIPTION_ID"
[[ $(az group show -n "$rg" --query tags.project -o tsv) == ViaCidada ]] || { echo 'Grupo sem identificação ViaCidada.'; exit 1; }
nic=$(az vm show -g "$rg" -n "$vm" --query 'networkProfile.networkInterfaces[0].id' -o tsv)
ip=$(az network nic show --ids "$nic" --query 'ipConfigurations[0].publicIPAddress.id' -o tsv)
nsg=$(az network nic show --ids "$nic" --query 'networkSecurityGroup.id' -o tsv)
[[ -n "$ip" && -n "$nsg" ]] || { echo 'VM sem IP público ou NSG esperado.'; exit 1; }
suffix=$(printf '%s' "$AZURE_SUBSCRIPTION_ID/$rg/$vm" | sha256sum | cut -c1-12)
label=${API_DNS_LABEL:-viacidada-$suffix}
[[ $label =~ ^[a-z][a-z0-9-]{1,61}[a-z0-9]$ ]] || { echo 'Rótulo DNS inválido.'; exit 1; }
az network public-ip update --ids "$ip" --dns-name "$label" -o none
domain=$(az network public-ip show --ids "$ip" --query dnsSettings.fqdn -o tsv)
[[ $domain =~ ^[a-z0-9][a-z0-9.-]+\.cloudapp\.azure\.com$ ]] || { echo 'FQDN Azure inválido.'; exit 1; }
for item in '1000 80 viacidada-http' '1010 443 viacidada-https'; do
  read -r priority port rule <<< "$item"
  az network nsg rule create -g "$rg" --nsg-name "${nsg##*/}" -n "$rule" \
    --priority "$priority" --direction Inbound --access Allow --protocol Tcp \
    --source-address-prefixes Internet --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges "$port" -o none
done
remote=$(cat <<'REMOTE'
set -euo pipefail
exec 9>/opt/viacidada/deploy.lock
flock -w 900 9
cd /opt/viacidada/current
test -f proxy/Caddyfile
python3 - "$DOMAIN" <<'PY'
import os
import sys
from pathlib import Path
path = Path('/opt/viacidada/runtime.env')
lines = [line for line in path.read_text().splitlines()
         if not line.startswith(('COMPOSE_PROFILES=', 'API_DOMAIN='))]
lines.extend(['COMPOSE_PROFILES=public', 'API_DOMAIN=' + sys.argv[1]])
path.write_text('\n'.join(lines) + '\n')
os.chmod(path, 0o600)
PY
docker compose --profile public up -d --no-build --wait --wait-timeout 900
echo VIACIDADA_PROXY_OK
REMOTE
)
output=$(az vm run-command invoke -g "$rg" -n "$vm" --command-id RunShellScript \
  --scripts "DOMAIN='$domain'" "$remote" --query 'value[].message' -o tsv)
printf '%s\n' "$output"
[[ $output == *VIACIDADA_PROXY_OK* ]] || { echo 'Proxy não confirmou inicialização.'; exit 1; }
bash "$(dirname "$0")/../scripts/verify-public.sh" "https://$domain"
printf '\nURL base: https://%s\nSwagger: https://%s/swagger-ui/index.html\n' "$domain" "$domain"

# Automação Java -> Azure

## Fluxo

Push em `gs-java-api/main` -> testes Java -> build da imagem -> Oracle e API no
runner -> CRUD, SELECT e persistência -> login OIDC -> Run Command na VM -> build
com os mesmos SHAs -> saúde -> ativação da versão. PRs não implantam na Azure.

A integração está implementada nos arquivos, mas só é considerada ativa quando
houver execução aprovada e deploy real confirmado.

## Gancho no repositório Java

Arquivo `.github/workflows/devops-azure.yml` em `gs-java-api`:

```yaml
name: ViaCidada - validar e implantar Java
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:
permissions:
  contents: read
  id-token: write
jobs:
  devops:
    uses: GS-EDUeAMIGOS/gs-devops-cloud/.github/workflows/ci-cd.yml@main
    with:
      java_sha: ${{ github.sha }}
```

O workflow reutilizável foi integrado na main DevOps pelo PR #1. O gancho Java
foi integrado pelo [PR #7](https://github.com/GS-EDUeAMIGOS/gs-java-api/pull/7), após
[CI entre os repositórios aprovado](https://github.com/GS-EDUeAMIGOS/gs-java-api/actions/runs/44169181037).
A chamada reutilizável não precisa de PAT nem de secrets do banco. A etapa de
deploy Azure continua desativada até preparar a VM, a identidade e as variáveis.

## Configuração inicial na Azure

Após criar a VM, revise e execute `bash azure/configure-oidc.sh` no Cloud Shell.
Ele cria uma identidade gerenciada com federação para as branches `main` dos dois
repositórios e atribui `Virtual Machine Contributor` somente à VM desta entrega.
Essa permissão permite executar comandos como root nessa VM; administradores dos
repositórios devem controlar quem pode publicar nessas branches.

O script exige permissão de criar identidade e atribuir papel na assinatura.
Se a conta de estudante não permitir, não habilite o deploy; use os comandos de
implantação manual pelo Cloud Shell até resolver a autorização com o administrador.
Não crie senha permanente de service principal como tentativa automática.

Nos **dois repositórios**, configure em Settings -> Secrets and variables -> Actions
as seguintes **Variables**:

| Variável | Valor |
| --- | --- |
| AZURE_CLIENT_ID | Client ID da identidade |
| AZURE_TENANT_ID | Tenant ID da identidade |
| AZURE_SUBSCRIPTION_ID | Assinatura usada |
| AZURE_RESOURCE_GROUP | Opcional; padrão rg-viacidada-gs |
| AZURE_VM_NAME | Opcional; padrão vm-viacidada-gs |
| AZURE_DEPLOY_ENABLED | true somente depois da preparação |

Se a VM estiver desalocada, inicie-a antes do deploy. O workflow não cria a VM,
não altera NSG, não exclui recursos e não modifica o Oracle da FIAP.

## Versões e falhas

A API é etiquetada com seu SHA. O deploy mantém releases separados e tenta voltar
à imagem anterior se o novo Compose não ficar saudável. O banco mantém o mesmo
volume; rollback da aplicação não desfaz mudanças de schema. Como esta versão usa
`validate`, deploy não realiza migração automática.

As imagens base usam tags de versão. Para auditoria mais estrita, fixe os digests
depois da primeira execução validada e repita a validação ao atualizar dependências.

# Validação - 17/11/2026

## Execução aprovada no GitHub Actions

- Run: https://github.com/GS-EDUeAMIGOS/gs-devops-cloud/actions/runs/44167072340
- Head da branch testada: `6a04348fd01564c565ba04406faffaa1cae284a0`.
- Fonte Java: `e627711b3e971ead00e0234e407b9528e7e32096`.
- Job `validar`: **success**. Deploy Azure: **skipped**, ainda desativado.
- [Trechos do log](../evidence/ci-2026-11-17.txt), com timestamps UTC e sem credenciais.

| Verificação realmente executada | Resultado |
| --- | --- |
| Maven verify | 9 testes; zero falhas, erros ou ignorados; BUILD SUCCESS |
| Dockerfile Java 21 | Imagem compilada e iniciada; processo UID/GID 10001; /opt/viacidada |
| Oracle XE 21 | Inicialização com SQL original; cinco tabelas; schema validado pelo Hibernate |
| HTTP | Swagger, OpenAPI, saúde e ocorrências funcionando |
| CRUD com JWT | Cadastro e criação 201; leitura e alteração 200; entrada inválida 400 |
| Consulta direta ao Oracle | SELECT com JOIN do mesmo usuário e ocorrência |
| Persistência | Ambos os containers removidos e recriados; login, ID e título preservados |
| Exclusão via API | DELETE 204 seguido de GET 404 |
| Caddy | Configuração válida e encaminhamento interno para a saúde da API aprovado |

Os dois primeiros runs identificaram incompatibilidades reais: a senha aleatória
excedia o limite do Oracle XE e o SQLPlus precisava aceitar linhas em branco.
O gerador passou a usar senhas de 26 caracteres; o wrapper ativa SQLBLANKLINES,
monta o SQL fora dos scripts automáticos e só marca o banco como saudável após
terminar a inicialização. O arquivo SQL do grupo permaneceu idêntico ao original.

## Integração publicada

- [PR DevOps #1](https://github.com/GS-EDUeAMIGOS/gs-devops-cloud/pull/1) integrado na main.
- [CI da main DevOps](https://github.com/GS-EDUeAMIGOS/gs-devops-cloud/actions/runs/44169000660): success.
- [PR Java #7](https://github.com/GS-EDUeAMIGOS/gs-java-api/pull/7) adiciona somente o workflow de 15 linhas e foi integrado na main.
- [Chamada Java → DevOps](https://github.com/GS-EDUeAMIGOS/gs-java-api/actions/runs/44169181037): job `devops / validar` aprovado, com os mesmos testes de integração. Job Azure ignorado por estar desativado.

## Conferências adicionais

- Leitura do enunciado DevOps e análise dos repositórios Java, Banco, Mobile e DevOps.
- SQL original: `1464861a8670921e5cd5ab5ddf881ca9d5bf4101`; hash conferido.
- Sintaxe Bash, YAML e Python; links locais e arquitetura SVG/PNG conferidos.
- Geração de .env em diretório temporário: permissão 600 e recusa de sobrescrita.
- Credenciais recebidas no chat não foram incluídas nos arquivos publicados.

O Maven local não conseguiu resolver dependências por limitação de rede, mas o
mesmo comando de validação foi executado com sucesso no runner GitHub.
Docker não existe no ambiente de preparação; a execução acima aconteceu no CI.

## Azure executada em 18/11/2026

- Conta FIAP confirmada pelo usuário; assinatura Azure for Students.
- Região East US permitida pela política da assinatura; quota de CPU conferida.
- `azure/provision.sh`: exit 0, Provisioning succeeded, VM running.
- VM `vm-viacidada-gs`, grupo `rg-viacidada-gs`, Ubuntu 22.04, D2s v4, 2 vCPU e 8 GiB.
- Deploy inicial: Java `bf49a23706fb79e49499718a338b07352113e9e0`; DevOps `b6e0234010029328d0bbd9d5dbd8296c01266b14`.
- `VIACIDADA_DEPLOY_OK` e `VIACIDADA_VERIFY_OK` confirmados na VM.
- CRUD, SELECT com JOIN e recriação dos dois containers aprovados; `VIACIDADA_PERSISTENCE_OK`.
- A primeira publicação HTTPS identificou que o Azure Run Command inicia com `sh`.
  O script passou a chamar Bash explicitamente; a nova execução aprovou HTTPS.
- `VIACIDADA_PROXY_OK` e `VIACIDADA_PUBLIC_OK`; saúde, Swagger, OpenAPI e ocorrências com HTTPS 200.
- [Swagger público](https://viacidada-3a46802b7054.eastus.cloudapp.azure.com/swagger-ui/index.html).
- Identidade OIDC criada; federação nas duas branches main; papel somente na VM.
- Token SPTrans configurado por entrada oculta no ambiente privado da VM. Consulta real retornou quatro linhas: `VIACIDADA_SPTRANS_OK linhas=4`.
- O Oracle FIAP não foi usado. Credenciais reais permanecem no ambiente privado.

## Próximas verificações


O primeiro deploy real por GitHub Actions ainda precisa ter seu resultado registrado. O teste do aplicativo no aparelho físico, o vídeo
não listado e o PDF final continuam pendentes. O sucesso do CI e do backend não
substitui a gravação ou a apresentação presencial.

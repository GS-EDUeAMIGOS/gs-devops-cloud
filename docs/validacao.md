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

## Pendente na nuvem

O sucesso do CI não comprova deploy Azure, emissão de certificado ou uso pelo
celular. A conta pessoal encontrada na Azure não exibe assinatura; é preciso
confirmar a conta de estudante antes de acessar os créditos.

Ainda faltam: criar a VM por CLI, implantar, repetir CRUD/SELECT/persistência,
ativar DNS/HTTPS e testar pelo celular. Depois, configurar OIDC e variáveis e
confirmar que um commit Java atualiza o mesmo SHA na VM. O token SPTrans deve
ficar no ambiente privado; os serviços externos exigem teste próprio.

Não há evidência de nuvem, vídeo ou PDF final ainda. O Oracle FIAP não foi usado.

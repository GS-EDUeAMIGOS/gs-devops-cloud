# Gravação e defesa - ViaCidadã

A seção DevOps da GS não fixa duração de vídeo. Use cerca de 5 a 7 minutos como
organização de conteúdo, se o portal/professor não der outro limite. Isso é uma
sugestão de roteiro, não uma regra do enunciado. Não aplique o limite de 3 minutos
da sprint anterior a esta GS.

| Na tela | O que explicar e demonstrar |
| --- | --- |
| README e arquitetura | Mobilidade acessível; API Java e Oracle na VM, rede e volume |
| Azure Cloud Shell Bash | Saída de provision.sh e VM running; foi criada via CLI |
| Dockerfile e Compose | Maven gera JAR; Java roda como UID 10001; healthcheck espera o schema Oracle |
| Run Command na VM | compose ps, logs, exec id, pwd e ls; API e Oracle em background |
| Acesso pelo celular | DNS, Caddy e HTTPS público; Swagger externo e mesma ocorrência vista no app e Oracle |
| Teste CRUD | Cadastro JWT, criar/consultar/atualizar ocorrência, entrada inválida |
| SELECT direto no Oracle | Duas tabelas relacionadas e JOIN; dados realmente persistidos |
| Recriar containers | down SEM -v, up, login e consulta do mesmo registro; depois DELETE e 404 |
| GitHub Actions | Run aprovado; se OIDC ativado, mostrar SHA do commit e deploy real |

O comando `bash azure/test-persistence-vm.sh` faz a demonstração remota da sequência
CRUD + SELECT + recriação. Salve as saídas legíveis e corte apenas esperas, não
os resultados que comprovam funcionamento. Não mostre `.env`, token JWT ou senhas.

Para a banca:

- Imagem é o pacote da aplicação; container é o processo executando esse pacote.
- Compose cria a rede e inicia os serviços; `db` é o nome DNS interno do Oracle.
- Volume guarda os arquivos do banco fora do ciclo de vida dos containers.
- O JAR é a aplicação Java compilada; o JRE é quem a executa.
- A API usa usuário de aplicação no Oracle, e não SYS; o processo Java usa UID 10001.
- OIDC permite ao GitHub autenticar na Azure sem guardar uma senha permanente.
- Caddy recebe HTTPS em 443 e encaminha para a API na rede Docker; o banco não é público.
- O runner é descartável; a VM Azure é a máquina usada na entrega e na banca.

A apresentação presencial vale 30 pontos e todos podem receber perguntas.
Mantenha a VM e os dados para esse dia. O enunciado desta GS não exige excluir
o grupo ao final do vídeo, ao contrário da sprint anterior.

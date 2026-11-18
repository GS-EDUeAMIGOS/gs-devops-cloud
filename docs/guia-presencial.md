# ViaCidadã: guia para explicar e demonstrar

## A explicação em 30 segundos

"A ViaCidadã tem uma API Java que atende o aplicativo Flutter. Colocamos essa API
e o banco Oracle em containers Docker dentro de uma máquina virtual da Azure.
O Compose liga os serviços e cria a rede entre eles. Os dados do Oracle ficam
em um volume, por isso continuam existindo quando os containers são recriados."

Não precisa decorar nomes de serviços Azure. Entenda a função de cada peça:

| Peça | O que ela faz no nosso projeto |
| --- | --- |
| VM Azure | É o computador Linux na nuvem onde tudo fica executando. |
| Imagem Docker | É o pacote preparado para iniciar um serviço com suas dependências. |
| Container | É uma instância desse pacote em execução. Temos Java, Oracle e o proxy HTTPS. |
| Dockerfile | Explica como compilar o Java e preparar a imagem da API. |
| JAR | É a aplicação Java compilada e empacotada; o comando `java -jar app.jar` a inicia. |
| Compose | É o arquivo que descreve quais serviços iniciar e como se conectam. |
| Rede Docker | Permite que o Java encontre o Oracle pelo nome `db`. |
| Volume | Guarda os arquivos do banco separadamente dos containers. |
| Variáveis de ambiente | Fornecem configuração e credenciais sem colocar senhas no código público. |

## Como a requisição chega ao banco

O celular chama a URL HTTPS. O Caddy recebe essa conexão e a encaminha para a
API Java na porta 8080. O Java processa a requisição e consulta ou grava no Oracle,
usando `db:1521/XEPDB1` dentro da rede Docker. A resposta volta pelo mesmo caminho.
O celular não recebe a senha do Oracle nem se conecta diretamente a ele.

HTTPS é a porta de entrada com certificado. Caddy é o serviço que cuida dela.
Esse terceiro container permite usar o app no celular sem abrir o banco na internet.

## Quais arquivos abrir na apresentação

1. `docs/arquitetura.png`: localizar VM, API, banco, rede, volume e entrada HTTPS.
2. `Dockerfile`: Maven compila; a imagem final recebe o JAR e executa como usuário 10001.
3. `docker-compose.yml`: apontar os serviços `api`, `db` e `proxy`, as redes e o volume.
4. `azure/provision.sh`: mostrar `az group create` e `az vm create`, usados para criar a VM por CLI.
5. `docs/validacao.md`: separar os resultados do CI das evidências executadas na VM.

Criar a VM é uma etapa inicial, feita uma vez. Na demonstração, mostre o script
de criação e o recurso existente; os dois comandos abaixo verificam o ambiente
sem tentar criar outra VM.

## Dois comandos para demonstrar na Azure

No Cloud Shell, usando Bash e a conta da assinatura:

Se abrir uma sessão nova e a pasta não existir, primeiro baixe o repositório:

```bash
git clone https://github.com/GS-EDUeAMIGOS/gs-devops-cloud.git ~/ViaCidada-GS
```

O Cloud Shell desta conta é temporário: seus arquivos podem desaparecer ao encerrar
a sessão. Isso não apaga a VM, os containers ou o volume Oracle. Se a pasta já
existir, siga diretamente para os comandos de demonstração:

```bash
cd ~/ViaCidada-GS
bash azure/verify-vm.sh
```

Esse comando consulta a VM e executa verificações dentro dela: containers, saúde
HTTP, usuário, diretório e SELECT. `VM running` é a máquina ligada; `healthy`
significa que o serviço respondeu à verificação. `uid=10001` demonstra que o Java
não roda como root. O diretório `/opt/viacidada` é o WORKDIR da imagem.

Para demonstrar CRUD e persistência:

```bash
bash azure/test-persistence-vm.sh
```

O script cria um usuário e uma ocorrência fictícios pela API, consulta o Oracle,
altera o registro, remove e recria os containers e consulta o mesmo registro.
Depois exclui a ocorrência de teste. Isso provoca uma interrupção breve da API;
combine o momento com quem estiver gravando ou testando o aplicativo.

| Resultado | O que falar |
| --- | --- |
| POST 201 | A API criou o registro no Oracle. |
| GET 200 e PUT 200 | Conseguimos consultar e alterar o registro. |
| SELECT com JOIN | Usuário e ocorrência estão relacionados no banco de verdade. |
| Mesmo ID após recriar | Os dados sobreviveram porque o volume foi preservado. |
| DELETE 204 e GET 404 | O registro foi removido pela API. |

O endereço `127.0.0.1` mostrado nesses testes pertence à VM: os comandos executam
lá pelo Run Command. No celular, usamos a URL HTTPS pública.

## Perguntas prováveis da banca

**Por que Docker?** Para executar a aplicação com o mesmo ambiente definido no projeto.

**Por que dois containers?** API e banco são processos diferentes, com dependências próprias.

**Por que Compose?** Para subir e conectar os serviços a partir de um único arquivo.

**Por que volume?** O container pode ser recriado sem perder os arquivos do banco.

**Por que o Java espera o banco?** Ele só inicia depois que o Oracle e o schema ficam prontos.

**Por que usuário não-root?** A API funciona com menos privilégios dentro do container.

**Por que não usar o Oracle da FIAP?** Esta entrega exige banco em container e volume persistente.
O ambiente é isolado; não alteramos o banco compartilhado da FIAP.

**E o GitHub Actions?** É a automação: testa uma versão do código e, quando habilitada,
implanta essa versão na VM. OIDC permite esse acesso sem guardar uma senha permanente
do Azure no GitHub. A identidade tem permissão somente sobre a VM desta entrega.

## Vídeo e apresentação são duas entregas

No enunciado enviado, página 42, a seção DevOps exige vídeo YouTube não listado,
mínimo 720p, e PDF com links. A seção não informa duração máxima. A página 43 trata
da apresentação presencial de 23 a 27/11, valendo 30% da nota. Veja também
[o roteiro de gravação](apresentacao.md). Não aplique o limite da sprint NEXO a esta GS.

Não abra `.env`, não mostre tokens e não execute `docker compose down -v` na VM:
essa opção exclui o volume do banco. A apresentação exige a solução funcionando
na nuvem; mantenha os recursos e confira o dia específico da turma.

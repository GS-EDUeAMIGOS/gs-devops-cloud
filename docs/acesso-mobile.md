# API para o aplicativo no celular

## Endereço da nuvem

O endereço real será registrado aqui depois de criar a VM e aprovar o teste HTTPS.
Ainda não há URL pública validada. Não use os exemplos abaixo como endereço ativo.

Após o primeiro deploy, execute no Cloud Shell:

```bash
bash azure/publish-api.sh
```

O script configura um nome DNS no IP estático Azure, libera somente TCP 80/443 no
NSG e ativa o perfil `public` do Compose. O Caddy emite e renova o certificado,
redireciona HTTP para HTTPS e encaminha as requisições para `api:8080`.
Os arquivos do certificado ficam em volumes próprios. SSH, Oracle e 8080 não
ganham regras públicas. O banco fica na rede `backend`; o proxy só participa de
`ingress`, compartilhada com a API.

| Uso | Caminho no domínio HTTPS exibido pelo script |
| --- | --- |
| URL base do serviço | raiz do domínio |
| `baseUrl` do Flutter | `/api` |
| Swagger | `/swagger-ui/index.html` |
| Saúde | `/actuator/health` |
| Cadastro | `POST /api/auth/register` |
| Login | `POST /api/auth/login` |
| Ocorrências | `/api/ocorrencias` |

## Ajuste necessário no Flutter

Em `gs-mobile/lib/services/api_service.dart`, `baseUrl` ainda usa `localhost` no
desktop/web e `10.0.2.2` no Android. O segundo endereço funciona no emulador;
no aparelho físico ele não aponta para a VM. O app deve receber a URL HTTPS da
nuvem terminada em `/api`, sem duplicar esse prefixo nos endpoints.

Sugestão para o responsável por Mobile, no começo do getter existente:

```dart
const cloudUrl = String.fromEnvironment('API_BASE_URL');
if (cloudUrl.isNotEmpty) {
  return cloudUrl.replaceFirst(RegExp(r'/$'), '');
}
```

Depois, usando o domínio **real** exibido na publicação:

```bash
flutter run --dart-define=API_BASE_URL=https://DOMINIO_REAL/api
flutter build apk --dart-define=API_BASE_URL=https://DOMINIO_REAL/api
```

Não foi alterado o código Mobile nesta entrega DevOps. A sugestão preserva os
endereços locais quando o parâmetro não é passado e evita mudar o código a cada
ambiente. HTTPS atende o aparelho físico sem desabilitar a validação de certificado.
No aplicativo nativo, CORS não limita as requisições; para Flutter Web, inclua a
origem real do site em `CORS_ALLOWED_ORIGINS`, separando origens por vírgula.

## Conferir integração real antes de gravar

O manifesto principal Android analisado não declara `INTERNET`. Antes de gerar o
APK de entrega, o responsável Mobile deve incluir esta linha dentro de
`<manifest>`, antes de `<application>`, em
`android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

O template permite rede durante o desenvolvimento, mas a permissão também deve
estar no manifesto principal para a versão release. Referência:
[documentação Flutter](https://docs.flutter.dev/data-and-backend/networking).

1. Abrir a saúde e o Swagger pelo navegador do celular, usando dados móveis.
2. Cadastrar um usuário novo pela API. O Oracle isolado não possui os usuários de demonstração H2.
3. Entrar no app, criar uma ocorrência fictícia e anotar seu ID.
4. Consultar o mesmo ID no Swagger e confirmar pelo SELECT no Oracle da VM.
5. Fechar/reabrir o app e confirmar o mesmo registro.

O Mobile possui fallback com dados em memória quando a conexão falha. Uma tela
com registros de demonstração sozinha não comprova conexão à Azure. Conferir o
mesmo ID no Swagger e no Oracle demonstra que o app usou o backend publicado.

As consultas SPTrans dependem do token privado configurado na VM. Aprovação do
CRUD não prova que linhas, previsão, GPS e rotas externas estão funcionando.
Esses caminhos precisam ser testados com o responsável Java/Mobile antes dos vídeos.

## Validação técnica

`scripts/test-proxy.sh` valida o Caddyfile e o encaminhamento interno durante CI.
`scripts/verify-public.sh https://DOMINIO_REAL` valida o certificado e os quatro
endereços públicos depois da publicação, sem usar `curl -k`.
Um teste no aparelho físico continua necessário para validar o aplicativo.

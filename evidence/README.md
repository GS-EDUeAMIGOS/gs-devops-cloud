# Evidências

As verificações executadas estão em [validação](../docs/validacao.md).
O [registro Azure de 18/11/2026](azure-2026-11-18.txt) contém trechos reais de
CRUD, SELECT, persistência e publicação HTTPS. O teste do aplicativo no aparelho
físico ainda depende do responsável Mobile.

Para a gravação e a banca, demonstre:

1. Saída CLI da criação e VM running.
2. docker compose ps com API e Oracle saudáveis, em background.
3. Logs sem segredos; exec id, pwd e ls.
4. CRUD HTTP com usuário e ocorrência relacionados.
5. SELECT/JOIN executado no Oracle do container.
6. Recriação dos dois containers sem -v e consulta dos mesmos dados.
7. URL do Actions aprovado e, após configuração, atualização automática da VM.

O texto docs/validacao.md registra somente verificações efetivamente executadas.
Saídas com senhas/tokens ficam fora do Git. Não publique `.evidence-private`.

## CI executado

[Log selecionado de 17/11/2026](ci-2026-11-17.txt): Java, Oracle, CRUD, JOIN,
persistência e proxy aprovados no runner GitHub. Esse ambiente é separado da VM;
as verificações da nuvem estão no registro de 18/11 acima.

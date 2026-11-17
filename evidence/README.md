# Evidências

Ainda não há evidência real de implantação aprovada. Registre após executar:

1. Saída CLI da criação e VM running.
2. docker compose ps com API e Oracle saudáveis, em background.
3. Logs sem segredos; exec id, pwd e ls.
4. CRUD HTTP com usuário e ocorrência relacionados.
5. SELECT/JOIN executado no Oracle do container.
6. Recriação dos dois containers sem -v e consulta dos mesmos dados.
7. URL do Actions aprovado e, após configuração, atualização automática da VM.

O texto docs/validacao.md registra somente verificações efetivamente executadas.
Saídas com senhas/tokens ficam fora do Git. Não publique `.evidence-private`.

# Oracle isolado da entrega DevOps

O container usa `gvenzl/oracle-xe:21-slim-faststart`, serviço `XEPDB1`, usuário
`viacidada` e volume `viacidada-oracle-data`. A escolha de Oracle XE 21 mantém a
compatibilidade com o driver/dialeto Oracle e com os tipos NUMBER(1) do modelo
existente. Não utiliza o Oracle compartilhado da FIAP.

`schema/CREATE_TABELAS.sql` é uma cópia sem alteração do script do grupo:

- Origem: https://github.com/GS-EDUeAMIGOS/gs-database/blob/1464861a8670921e5cd5ab5ddf881ca9d5bf4101/CREATE_TABELAS.sql
- Commit: `1464861a8670921e5cd5ab5ddf881ca9d5bf4101`.
- SHA256: `a89b47a8c6b2899838bbab0a60cb523ac65f922de203da8fce0f0cb38857b2b6`.

A imagem cria o usuário APP_USER; `01-init.sh` conecta com esse usuário e executa
o SQL. Isso acontece somente em volume novo. Scripts não executam DROP nem
alteram entidades Java. A API valida o schema na inicialização.

O wrapper configura `SQLBLANKLINES ON` para aceitar as linhas em branco do SQL
original. O schema é montado em `/opt/viacidada-schema`, fora do diretório de
scripts automáticos. Um marcador no volume só é criado após o SQL terminar sem
erro; o healthcheck exige esse marcador antes de liberar a API.
As senhas geradas têm 26 caracteres, dentro do limite de 30 bytes do Oracle XE.

Se houver mudança futura de schema, combine a migração com o responsável por
Banco/Java. Reiniciar o container não aplica migrations e não reexecuta este SQL.
Nunca remova o volume para "atualizar" dados existentes.

Para inspeção: `bash scripts/select-db.sh`. As consultas listam as cinco tabelas
e fazem SELECT com JOIN entre usuário e ocorrência; não mostram senhas ou tokens.

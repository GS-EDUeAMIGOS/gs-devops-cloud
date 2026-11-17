#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Somente SELECT. Credenciais são lidas dentro do container, sem imprimir .env.
docker compose exec -T db bash -c 'sqlplus -s /nolog <<SQL
WHENEVER SQLERROR EXIT SQL.SQLCODE
CONNECT ${APP_USER}/"${APP_USER_PASSWORD}"@//localhost:1521/XEPDB1
SET LINESIZE 160 PAGESIZE 50
SELECT table_name FROM user_tables ORDER BY table_name;
SELECT o.id, o.titulo, u.nome FROM tb_vc_ocorrencia o JOIN tb_vc_usuario u ON u.id = o.usuario_id ORDER BY o.id;
EXIT SUCCESS
SQL'

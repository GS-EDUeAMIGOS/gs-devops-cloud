#!/usr/bin/env bash
set -euo pipefail
# A imagem cria APP_USER antes de executar este script, somente no volume novo.
# O SQL original do grupo fica fora da pasta de scripts autoexecutados.
sqlplus -s /nolog <<SQL
WHENEVER OSERROR EXIT FAILURE
WHENEVER SQLERROR EXIT SQL.SQLCODE
SET SQLBLANKLINES ON
SET DEFINE OFF
CONNECT ${APP_USER}/"${APP_USER_PASSWORD}"@//localhost:1521/XEPDB1
@/opt/viacidada-schema/CREATE_TABELAS.sql
EXIT SUCCESS
SQL
touch /opt/oracle/oradata/.viacidada-schema-ready

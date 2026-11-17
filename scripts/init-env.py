#!/usr/bin/env python3
"""Gera credenciais exclusivas para o Oracle local; não usa o Oracle FIAP."""
import os
import secrets
from pathlib import Path
path = Path(__file__).resolve().parents[1] / '.env'
content = ('ORACLE_PASSWORD=' + secrets.token_hex(24) + '\n'
           'ORACLE_APP_PASSWORD=' + secrets.token_hex(24) + '\n'
           'JWT_SECRET=' + secrets.token_hex(48) + '\n'
           'API_IMAGE=viacidada-api:local\nAPI_BIND=127.0.0.1\nAPI_PORT=8080\n'
           'DB_PORT=1521\nCORS_ALLOWED_ORIGINS=http://localhost:3000\nSPTRANS_TOKEN=\n')
try:
    fd = os.open(path, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
except FileExistsError:
    raise SystemExit('.env já existe: preservado. Não gere senhas novas para um volume existente.')
with os.fdopen(fd, 'w') as stream:
    stream.write(content)
print('.env criado com permissão 600. Nenhuma senha foi exibida.')

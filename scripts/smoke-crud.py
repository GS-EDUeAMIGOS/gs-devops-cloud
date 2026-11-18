#!/usr/bin/env python3
"""CRUD sintético e verificação após recriar containers. Não depende da SPTrans."""
import json
import os
import secrets
import sys
import urllib.error
import urllib.request
import uuid
from pathlib import Path
root = Path(__file__).resolve().parents[1]
port = os.environ.get('API_PORT', '8080')
if (root / '.env').exists():
    for line in (root / '.env').read_text().splitlines():
        if line.startswith('API_PORT=') and 'API_PORT' not in os.environ:
            port = line.split('=', 1)[1].strip()
port = str(int(port))
base = os.environ.get('API_BASE_URL', 'http://127.0.0.1:' + port).rstrip('/')
state_file = Path(__file__).resolve().parents[1] / '.evidence-private' / 'crud-state.json'
def call(method, path, expected, payload=None, token=None):
    headers = {'Accept': 'application/json'}
    data = None
    if payload is not None:
        data = json.dumps(payload).encode(); headers['Content-Type'] = 'application/json'
    if token:
        headers['Authorization'] = 'Bearer ' + token
    request = urllib.request.Request(base + path, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            code, body = response.status, response.read()
    except urllib.error.HTTPError as exc:
        code, body = exc.code, exc.read()
    if code != expected:
        raise RuntimeError(f'{method} {path}: esperado {expected}, recebido {code}')
    print(f'HTTP {code} {method} {path}')
    return json.loads(body) if body else None
mode = sys.argv[1] if len(sys.argv) == 2 else ''
if mode == 'create':
    if state_file.exists():
        raise SystemExit('Estado anterior preservado. Execute check/cleanup antes de outro teste.')
    run_id = uuid.uuid4().hex
    credentials = {'email': f'devops-{run_id}@example.com', 'senha': secrets.token_hex(16)}
    auth = call('POST', '/api/auth/register', 201,
                {**credentials, 'nome': 'Cidadão fictício DevOps', 'possuiMobilidadeReduzida': True})
    token, user_id = auth['token'], auth['usuarioId']
    payload = {'usuarioId': user_id, 'titulo': 'Rampa de teste DevOps ' + run_id[:8],
               'descricao': 'Registro fictício para comprovar integração API e Oracle em container.',
               'tipo': 'ACESSIBILIDADE', 'status': 'ABERTA', 'gravidade': 'ALTA',
               'afetaAcessibilidade': True}
    item = call('POST', '/api/ocorrencias', 201, payload, token)
    state = {'credentials': credentials, 'id': item['id'], 'user_id': user_id, 'payload': payload}
    state_file.parent.mkdir(mode=0o700, exist_ok=True)
    fd = os.open(state_file, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
    with os.fdopen(fd, 'w') as stream:
        json.dump(state, stream)
    call('GET', '/api/ocorrencias/' + str(item['id']), 200)
    payload['titulo'] = 'Rampa atualizada DevOps ' + run_id[:8]
    updated = call('PUT', '/api/ocorrencias/' + str(item['id']), 200, payload, token)
    assert updated['titulo'] == payload['titulo']
    state['payload'] = payload
    state_file.write_text(json.dumps(state))
    call('POST', '/api/ocorrencias', 400, {}, token)
    print('VIACIDADA_CRUD_CREATE_UPDATE_OK: usuário e ocorrência relacionados no Oracle.')
elif mode in ('check', 'cleanup'):
    state = json.loads(state_file.read_text())
    auth = call('POST', '/api/auth/login', 200, state['credentials'])
    assert auth['usuarioId'] == state['user_id']
    path = '/api/ocorrencias/' + str(state['id'])
    if mode == 'check':
        item = call('GET', path, 200)
        assert item['titulo'] == state['payload']['titulo'] and item['usuarioId'] == state['user_id']
        print('VIACIDADA_PERSISTENCE_CHECK_OK: mesmo usuário, ocorrência e título após recriação.')
    else:
        call('DELETE', path, 403, token=auth['token'])
        call('GET', path, 200)
        state_file.unlink()
        print('VIACIDADA_CRUD_RBAC_DELETE_FORBIDDEN_OK: cidadão impedido de remover ocorrência (403).')
else:
    raise SystemExit('Uso: python3 scripts/smoke-crud.py create|check|cleanup')

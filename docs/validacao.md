# Validação - 17/11/2026

## Conferências executadas no ambiente de preparação

- Leitura do enunciado DevOps e análise dos repositórios Java, Banco e DevOps.
- Fonte Java analisada: e627711b3e971ead00e0234e407b9528e7e32096.
- SQL original: 1464861a8670921e5cd5ab5ddf881ca9d5bf4101; cópia conferida por hash.
- Sintaxe Bash dos scripts, parse de YAML e sintaxe Python verificados.
- Geração de .env testada em diretório temporário: permissão 600 e recusa de sobrescrita confirmadas.
- Links locais conferidos e SVG da arquitetura renderizado e revisado.

## Não executado / bloqueios

O comando `bash mvnw -B -ntp test` foi tentado no checkout Java. O Maven não
conseguiu baixar o parent Spring Boot 3.4.5 por falha de resolução de rede para
repo.maven.apache.org. Isso não é um teste aprovado nem uma falha funcional
comprovada da API.

Docker não está disponível neste ambiente. Build da imagem, inicialização do
Oracle, validação Hibernate, CRUD e persistência ainda dependem da execução do
Actions ou da VM. A conexão Oracle FIAP não foi usada.

O conector GitHub retornou 403 ao tentar criar a branch. Arquivos preparados
localmente não são considerados publicados até confirmação no repositório.

## Critérios para registrar sucesso

1. Job de validação aprovado, incluindo Oracle e recriação dos containers.
2. VM running criada por CLI, com saída real registrada.
3. VIACIDADA_DEPLOY_OK e VIACIDADA_VERIFY_OK na VM.
4. SELECT com JOIN mostrando usuário/ocorrência e VIACIDADA_PERSISTENCE_OK.
5. Um novo commit Java provocar deploy do mesmo SHA na VM.

Atualize este registro com URLs de runs, SHAs e data depois de executar. Não
substitua os resultados reais por um checklist marcado automaticamente.

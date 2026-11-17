# Conferência - DevOps GS 2026/2

Fonte: PDF fornecido pelo grupo, seção DevOps Tools & Cloud Computing 1/7 a 7/7.
O prazo geral indicado é 19/11/2026 às 23h55. A entrega técnica vale 70 pontos;
a apresentação presencial, 30. A seção DevOps não informa limite de duração do
vídeo. O limite do pitch de Java é outra entrega, e não deve ser confundido com ela.

| Critério | Pontos | Implementação / evidência necessária |
| --- | --- | --- |
| Arquitetura macro da solução | 10 | docs/arquitetura.svg; explicar serviços reais |
| VM Azure e provisionamento CLI | 10 | azure/provision.sh; registrar saída da criação e VM running |
| Container API e Dockerfile | 15 | Dockerfile, WORKDIR, USER, ENV no Compose, EXPOSE, execução -d |
| Banco em container e persistência | 15 | Oracle, cinco tabelas, volume; comprovar recriação sem perda |
| Compose e integração | 5 | docker-compose.yml: API, DB, network, volume, portas e healthcheck |
| GitHub, How To e evidências | 15 | README, scripts, logs, exec, id, SELECT e vídeo acessível |
| Defesa presencial | 30 | VM funcionando, Compose, banco, persistência, arquitetura e domínio técnico |

Preparar arquivos não equivale a executar. Confira docs/validacao.md para saber o
que foi de fato testado. Os scripts cobrem os itens, mas evidências reais de nuvem
continuam obrigatórias.

Entregáveis: GitHub público com código-fonte, Dockerfile, Compose, script CLI,
arquitetura e README; vídeo YouTube não listado, mínimo 720p, explicando VM,
Compose, containers, CRUD, logs e SELECT; PDF com solução, integrantes/RMs/turma
e links do GitHub e vídeo. Caso o portal aceite apenas ZIP, compacte esse PDF.

Penalidades relevantes: sem código/Dockerfile/Compose, somente localhost ou links
inacessíveis pode zerar; sem SELECT/CRUD/duas tabelas, -20; How To/evidências
incompletos, até -15; vídeo ilegível/abaixo de 720p/sem explicação, -20. A nota da
arquitetura pode zerar se for genérica ou um fluxograma sem relação com a aplicação.

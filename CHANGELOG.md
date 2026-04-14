# CHANGELOG

## 0.2.0 (2026-04-14)
_Testado em OPNsense 26.1.6-amd64 / FreeBSD 14.3-RELEASE-p10_

### Novas Funcionalidades
- Suporte a `--no-autoupdate`: desativa atualizações automáticas do cloudflared (habilitado por padrão).
- Suporte a `--post-quantum`: habilita criptografia pós-quântica na conexão do túnel (opcional).
- Log persistente do daemon em `/var/log/cloudflared.log` via `daemon(8) -o`.
- Controle de serviço inline na interface (Start, Stop, Restart, badge de status Running/Stopped) — sem dependência do partial `base_service_control`.
- Campos `no_autoupdate` e `post_quantum` adicionados ao modelo, formulário e traduções.

### Melhorias
- RC script: `REQUIRE: LOGIN` substituído por `REQUIRE: NETWORKING SERVERS` — serviço inicia somente após a rede estar disponível.
- RC script: token lido via `$(cat token_file)` e passado com `--token` (compatibilidade ampla com o fork kjake).
- `install_binary.sh`: versão do binário agora buscada dinamicamente via GitHub API (`/releases/latest`) — sem versão hardcoded.
- `install_binary.sh`: versão do FreeBSD e arquitetura da CPU detectadas automaticamente via `uname`.
- `reconfigure.sh`: verifica existência do binário antes de reiniciar o serviço.
- `reconfigure.sh`: aplica `chmod 600` no arquivo de token após cada reload de templates.
- Arquivo de token renderizado com filtro `|trim` para evitar quebra de linha no final.
- Campo Tunnel Token exibido como `password` na interface (token mascarado).
- `installAction()` no ServiceController restrito a requisições POST.
- Ação `[start]` no `actions_cloudflared.conf` corrigida (chamava `restart` em vez de `start`).
- `cloudflared.conf` (config.yml vazio) removido dos templates gerenciados.
- Feedback visual do botão "Install/Update Binary" com diálogo de sucesso/erro e saída real do script.
- `forms/general.xml` movido para `controllers/OPNsense/Cloudflared/forms/` (localização correta exigida pelo OPNsense).
- Strings de tradução adicionadas: Start, Stop, Restart, Running, Stopped (pt_BR e en_US).

### Correções de Bugs
- Correção: `forms/general.xml` em `models/` causava exceção PHP (`form xml missing`) ao carregar a página.
- Correção: uso do partial `base_service_control` causava exceção Phalcon em instalações sem o arquivo — substituído por controle inline.

---

## 0.1.0 (2026-04-14)

- Lançamento inicial do os-cloudflared.
- Integração nativa do Cloudflare Tunnel (cloudflared).
- Suporte para configuração por Token (Managed Tunnels).
- Ajuste automático de kernel para QUIC (kern.ipc.maxsockbuf e net.inet.udp.recvspace).
- Instalador integrado de binário para o fork FreeBSD do cloudflared (kjake).
- Gerenciamento de serviço via backend OPNsense.
- Suporte multilíngue (inglês e português).
- Log profissional via syslog.
- Autor: Alan Martines <alancpmartines@hotmail.com>

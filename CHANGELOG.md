# CHANGELOG

## Em validação (ainda não enviado ao upstream)
_Base: upstream `833b944`. Cada item é um commit independente, a ser validado na VM e enviado como PR separado ao opnsense/plugins._

| Item | Commit | Validado na VM |
|---|---|---|
| Token aceita `+` e `/` (base64 padrão) | `net/cloudflared: allow + and / in tunnel token` | ✅ 2026-10-20 |
| Token obrigatório só com o serviço ativado | `net/cloudflared: only require tunnel token when enabled` | ✅ 2026-10-20 |
| Pós-quântico com HTTP/2 recusado na validação | `net/cloudflared: reject post-quantum with HTTP/2` | ✅ 2026-10-20 |
| Gancho `newwanip` não inicia o serviço desativado | `net/cloudflared: skip newwanip start when disabled` | ✅ 2026-10-20 |
| Versão de IP do edge: padrão IPv4 rotulado corretamente, opção Auto, valor no `config.yml` | `net/cloudflared: fix edge IP version default and add auto` | ✅ 2026-10-20 |
| Endereço de métricas configurável (padrão `localhost:2000`, vazio = porta livre) | `net/cloudflared: make metrics address configurable` | ✅ 2026-10-20 |
| Status de conexão do túnel na página (endpoint `/ready`) | `net/cloudflared: show tunnel connection status` | ☐ |
| Saída do daemon enviada ao syslog, com rotação do syslog-ng | `net/cloudflared: send daemon output to syslog` | ✅ 2026-10-20 |

Fora do plugin: reinício automático do processo depende de alterar o rc.d do port `net/cloudflared` (`daemon -r -P`).

---

## 1.1_1 (2026-10-20) — alinhamento com o upstream
_Espelho de [opnsense/plugins › net/cloudflared](https://github.com/opnsense/plugins/tree/master/net/cloudflared) no commit `833b944`._

A partir desta versão o repositório é um espelho de desenvolvimento do plugin oficial, usado para testar mudanças e propor PRs.

### Mudanças de arquitetura
- Binário e rc.d passam a vir do pacote `cloudflared` (`PLUGIN_DEPENDS`); removidos `install_binary.sh` e `src/usr/local/etc/rc.d/cloudflared`.
- Opções geradas em `config.yml` em vez de flags montadas em `cloudflared_mode`.
- Token entregue via `cloudflared_env="TUNNEL_TOKEN=..."`; removido o arquivo `/usr/local/etc/cloudflared/token` e o `--token` nos argumentos do processo.
- `ServiceController` usa o comportamento padrão de `ApiMutableServiceControllerBase`; removidos `reconfigure.sh` e as actions `reconfigure`, `install_binary` e `tunnel_status`.
- View reescrita com `base_form`, `SimpleActionButton`, `base_apply_button` e `updateServiceControlUI`.

### Novas funcionalidades
- Opções de protocolo (auto/QUIC/HTTP2), desativar QUIC PMTU discovery, versão de IP do edge e nível de log (modo avançado).
- Logs no syslog-ng com parser próprio e página **Log File** no menu.
- Reinício do serviço em `newwanip` e sincronização HA via `cloudflared_xmlrpc_sync()`.

### Correções
- Validação do token aceita `=`.
- Desativar o plugin e aplicar agora para o serviço.

### Removido
- Tunables de sysctl para QUIC (configure em **System → Settings → Tunables** se necessário).
- Badge de saúde do túnel.
- Opção `no_autoupdate` (sempre ativo).
- Traduções `en_US.po` / `pt_BR.po` do plugin.

---

## 0.4.0 (2026-04-15)
_Testado em OPNsense 26.1.6-amd64 / FreeBSD 14.3-RELEASE-p10_

### Novas Funcionalidades
- Registro em **System → Diagnostics → Services**: arquivo `src/etc/inc/plugins.inc.d/cloudflared.inc` com `cloudflared_services()` — aparece na lista quando habilitado, com botões Start/Stop/Restart nativos do OPNsense.
- Status do tunnel em tempo real: badge **Túnel: Saudável** (verde) / **Túnel: Conectando** (laranja) na barra de status.
- Endpoint `/api/cloudflared/service/tunnel_status` retorna JSON `{"tunnel":"healthy"|"connecting"|"stopped"}`.
- Script `tunnel_status.sh` consulta `http://localhost:2000/healthcheck` (endpoint local do cloudflared).

### Correções de Bugs
- Correção: `--metrics` é flag global do cloudflared — deve vir **antes** de `tunnel`, não após `run`. Posicionada corretamente no rc.d como `cloudflared --metrics localhost:2000 tunnel ... run`.
- Correção: `reconfigureAction()` na base class (`ApiMutableServiceControllerBase`) não executava o `reconfigure.sh` — sobrescrita no `ServiceController` para chamar `configdRun("cloudflared reconfigure")`, garantindo aplicação dos sysctl tunables e demais passos.
- Correção: sysctl tunables não aplicados ao kernel em execução — substituído `sysctl "$line"` por `sysctl -w "${key}=${val}"` com log de sucesso/falha.

### Melhorias
- `updateServiceStatus()` na view também chama `updateTunnelStatus()` quando o serviço está Running.
- Strings i18n adicionadas: `Tunnel`, `Healthy`, `Connecting` (en_US e pt_BR).

---

## 0.3.0 (2026-04-15)
_Testado em OPNsense 26.1.6-amd64 / FreeBSD 14.3-RELEASE-p10_

### Tunnel funcionando
- Tunnel conecta corretamente ao Cloudflare Zero Trust.

### Correções de Bugs
- Correção: `--quic-disable-pmtu-discovery` removido — flag não existe no cloudflared 2026.3.0 (fork kjake), causava falha de inicialização.
- Correção: `Menu.xml` e `ACL.xml` movidos para subdiretórios `Menu/` e `ACL/` — OPNsense escaneia `models/*/Menu/Menu.xml`, não a raiz do modelo.
- Correção: `+metadata.xml` substituído por `+TARGETS` — formato moderno do OPNsense para mapeamento de templates.
- Correção: Templates sem `helpers.exists()` causavam "Template generation failed" na primeira execução (config ainda não existente); todos os templates atualizados com guards.
- Correção: `order` no Menu.xml estava em `<VPN>` em vez do item filho `<Cloudflared>` — menu não aparecia.
- Correção: Cache do menu em `/tmp/opnsense_menu_cache.xml` não era limpo pelo `rm -rf mvc/app/cache/*` — necessário remover separadamente.
- Correção: Actions `start`/`stop`/`restart` chamavam `configctl service X` recursivamente — alteradas para chamar `/usr/local/etc/rc.d/cloudflared` diretamente.
- Correção: `install_binary.sh` usava `grep | sed` para parsear JSON minificado — substituído por `python3` para leitura confiável.
- Correção: `configctl cloudflared install_binary` retornava "Execute error" quando script saía com código não-zero — adicionado `;exit 0` na action.
- Correção: rc.d script não era instalado com bit de execução pelo `make install` — permissão corrigida para `555` na fonte.
- Correção: `saveFormToEndpoint` chamado com 4 e 5 parâmetros incorretos — função aceita apenas 3; spinner gerenciado manualmente.
- Correção: Token passado via `$(cat token)` com `--token` substituído pelo padrão do guia hannoeru.me; `cloudflared_mode` como variável única no `rc.conf.d`.
- Correção: Diretórios de destino dos templates (`/usr/local/etc/cloudflared/`, `/usr/local/etc/sysctl.conf.d/`) não existiam — arquivos `.keep` adicionados ao `src/` para criação automática pelo `make install`.

### Melhorias
- Menu movido para **Services → Cloudflare Tunnel** (padrão OPNsense para plugins de serviço).
- Ícone `fa-cloud` adicionado ao item de menu.
- `cloudflared_mode` no `rc.conf.d` agora contém a string completa de argumentos (`tunnel [--no-autoupdate] run [--post-quantum]`), seguindo o Method 1 do guia hannoeru.me.
- `reconfigure.sh` distingue dados dinâmicos (sempre atualizados via templates) de dados estáticos (diretórios criados apenas se não existirem).
- Campo Tunnel Token com botão de mostrar/ocultar (olho) via jQuery input-group.
- Botão Apply com spinner e checkmark após sucesso, padrão OPNsense.
- Botões de controle (Start/Stop/Restart) com ícones `fa-fw` consistentes.
- Padding corrigido nos botões Apply e Install/Update Binary.

---

## 0.2.0 (2026-04-14)
_Testado em OPNsense 26.1.6-amd64 / FreeBSD 14.3-RELEASE-p10_

### Novas Funcionalidades
- Suporte a `--no-autoupdate`: desativa atualizações automáticas do cloudflared (habilitado por padrão).
- Suporte a `--post-quantum`: habilita criptografia pós-quântica na conexão do túnel (opcional).
- Log persistente do daemon em `/var/log/cloudflared.log` via `daemon(8) -o`.
- Controle de serviço inline na interface (Start, Stop, Restart, badge de status Running/Stopped).
- Campos `no_autoupdate` e `post_quantum` adicionados ao modelo, formulário e traduções.

### Melhorias
- RC script: `REQUIRE: LOGIN` substituído por `REQUIRE: NETWORKING SERVERS`.
- `install_binary.sh`: versão do binário buscada dinamicamente via GitHub API.
- `install_binary.sh`: versão do FreeBSD e arquitetura da CPU detectadas via `uname`.
- `reconfigure.sh`: verifica existência do binário antes de reiniciar o serviço.
- `reconfigure.sh`: aplica `chmod 600` no arquivo de token após cada reload de templates.
- Campo Tunnel Token exibido como `password` na interface.
- `installAction()` restrito a requisições POST.

### Correções de Bugs
- `forms/general.xml` movido para `controllers/OPNsense/Cloudflared/forms/`.
- Partial `base_service_control` removido — substituído por controle inline.

---

## 0.1.0 (2026-04-14)

- Lançamento inicial do os-cloudflared.
- Integração nativa do Cloudflare Tunnel (cloudflared).
- Suporte para configuração por Token (Managed Tunnels).
- Ajuste automático de kernel para QUIC.
- Instalador integrado de binário para o fork FreeBSD do cloudflared (kjake).
- Gerenciamento de serviço via backend OPNsense.
- Suporte multilíngue (inglês e português).
- Autor: Alan Martines <alancpmartines@hotmail.com>

# CHANGELOG

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

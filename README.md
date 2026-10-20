# OPNsense Plugin: os-cloudflared (repositório de desenvolvimento)

Plugin que integra o **Cloudflare Tunnel (cloudflared)** ao OPNsense, permitindo expor serviços internos via Cloudflare Zero Trust sem abrir portas no firewall nem depender de IP público.

> **Este repositório é um espelho de desenvolvimento.** A versão oficial e mantida do plugin está em [opnsense/plugins › net/cloudflared](https://github.com/opnsense/plugins/tree/master/net/cloudflared) (mantenedor: Richard Aspden). Este repositório serve para testar mudanças e propor PRs ao oficial. Usuários finais devem instalar o plugin oficial pelo **System → Firmware → Plugins** (`os-cloudflared`).

Baseado no upstream no commit [`833b944`](https://github.com/opnsense/plugins/commit/833b94414ff01ddec22c4f9e3d84c5dd1e1cbdab) (versão 1.1_1), com correções ainda em validação listadas no [CHANGELOG](CHANGELOG.md).

## Funcionalidades

- Interface MVC nativa em **Services → Cloudflare Tunnel**
- Autenticação por token de túnel gerenciado (Cloudflare Zero Trust)
- Binário fornecido pelo pacote `cloudflared` do repositório do OPNsense (`PLUGIN_DEPENDS`), com o rc.d do próprio pacote
- Token entregue ao processo via variável de ambiente `TUNNEL_TOKEN` (não aparece nos argumentos do processo)
- Opções geradas em `/usr/local/etc/cloudflared/config.yml`: protocolo (auto/QUIC/HTTP2), criptografia pós-quântica, desativar QUIC PMTU discovery, versão de IP do edge (padrão IPv4, IPv6 ou Auto), endereço de métricas, nível de log
- Status de conexão do túnel na página (conexões ativas com o edge da Cloudflare)
- `no-autoupdate` sempre ativo — atualizações chegam pelo pacote
- Logs enviados ao syslog-ng (`/var/log/cloudflared/`, com rotação), visíveis em **Services → Cloudflare Tunnel → Log File**
- Integração com **System → Diagnostics → Services**
- Reinício do serviço em mudança de IP da WAN (`newwanip`)
- Sincronização de configuração em HA (XMLRPC)

## Desenvolvimento

### Pré-requisitos (uma única vez)

```sh
opnsense-code plugins
pkg install cloudflared
```

> `make install` não resolve dependências; o pacote `cloudflared` precisa ser instalado manualmente.

### Instalar a partir deste repositório

O diretório `/usr/plugins/net/cloudflared` já existe na árvore oficial, então clone em um diretório separado no mesmo nível (o `Makefile` inclui `../../Mk/plugins.mk`):

```sh
cd /usr/plugins/net/
git clone https://github.com/AlanMartines/os-cloudflared cloudflared-dev
cd cloudflared-dev
make install
service configd restart
```

Faça logout e login no OPNsense para o menu aparecer.

### Gerar pacote

```sh
cd /usr/plugins/net/cloudflared-dev
make package
```

### Propor mudanças ao oficial

1. Faça um fork de [opnsense/plugins](https://github.com/opnsense/plugins).
2. Copie as alterações deste repositório para `net/cloudflared/` no fork (somente `Makefile`, `pkg-descr` e `src/`).
3. Incremente `PLUGIN_REVISION` (correções) ou `PLUGIN_VERSION` (funcionalidades) no `Makefile`.
4. Rode `make style` e `make lint` na árvore de plugins.
5. Abra o PR com título no formato `net/cloudflared: descrição`.

## Como usar

1. Em [Cloudflare Zero Trust](https://one.dash.cloudflare.com/), vá em **Networks → Tunnels**, crie ou selecione um túnel e copie o token.
2. No OPNsense, acesse **Services → Cloudflare Tunnel**.
3. Marque **Enable**, cole o token em **Tunnel Token** e clique em **Apply**.
4. Opções avançadas (protocolo, pós-quântico, PMTU, versão de IP) ficam visíveis ao ativar o modo avançado do formulário.

Verificação:

```sh
service cloudflared status
cat /usr/local/etc/cloudflared/config.yml
configctl cloudflared tunnel_status
tail -f /var/log/cloudflared/latest.log
```

Na página do plugin, **Tunnel Status** deve mostrar **Connected**. No dashboard da Cloudflare, o túnel deve aparecer como **Healthy**.

## Migração a partir da versão 0.4.0 deste repositório

A versão 0.4.0 instalava um binário próprio (fork kjake) e um rc.d próprio **nos mesmos caminhos** usados pelo pacote `cloudflared`. Remova-os antes de instalar o pacote:

```sh
service cloudflared stop

# Arquivos da 0.4.0 que conflitam com o pacote cloudflared
rm -f /usr/local/bin/cloudflared
rm -f /usr/local/etc/rc.d/cloudflared

# Arquivos da 0.4.0 que não são mais usados
rm -f /usr/local/etc/cloudflared/token
rm -f /usr/local/etc/sysctl.conf.d/cloudflared.conf
rm -f /var/log/cloudflared.log
rm -f /usr/local/opnsense/mvc/app/languages/*/cloudflared*
rm -rf /usr/local/opnsense/scripts/OPNsense/Cloudflared

pkg install cloudflared
```

Depois instale o plugin (oficial ou deste repositório) e clique em **Apply** na página do plugin.

Configuração existente:

- `enabled`, `token` e `post_quantum` são mantidos (mesmo ponto de montagem `//OPNsense/Cloudflared`).
- `no_autoupdate`, `kern_ipc_maxsockbuf` e `net_inet_udp_recvspace` deixam de existir e são descartados no próximo salvamento.
- Os sysctl aplicados pela 0.4.0 valem só até o próximo reboot. Para mantê-los, adicione em **System → Settings → Tunables**:
  - `kern.ipc.maxsockbuf = 16777216`
  - `net.inet.udp.recvspace = 8388608`

## Licença

BSD 2-Clause — mesma licença do OPNsense.

## Créditos

- Plugin oficial: Richard Aspden e equipe OPNsense ([opnsense/plugins](https://github.com/opnsense/plugins/tree/master/net/cloudflared))
- Trabalho original: Alan Martines

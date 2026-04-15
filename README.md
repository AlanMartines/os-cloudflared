# OPNsense Plugin: os-cloudflared

Plugin para integração nativa do **Cloudflare Tunnel (cloudflared)** no OPNsense. Permite expor serviços internos para a internet de forma segura, sem abrir portas no firewall ou depender de IPs estáticos.

Implementa o **Method 1: Token-based Setup (Recommended)** conforme o guia [hannoeru.me](https://hannoeru.me/posts/install-cloudflared-opnsense), usando binários do fork [kjake/cloudflared](https://github.com/kjake/cloudflared) compilado para FreeBSD.

## Funcionalidades

- **Interface MVC nativa** — menu **Services → Cloudflare Tunnel** integrado ao OPNsense
- **Autenticação por Token** — túneis gerenciados via Cloudflare Zero Trust
- **Instalador de Binário** — baixa/atualiza automaticamente a versão mais recente, com detecção de versão FreeBSD e arquitetura
- **Sem Auto-Update** — `--no-autoupdate` habilitado por padrão; atualizações sempre manuais
- **Criptografia Pós-Quântica** — opção `--post-quantum` disponível
- **Otimização QUIC** — aplica `kern.ipc.maxsockbuf` e `net.inet.udp.recvspace` via sysctl
- **Token seguro** — arquivo com permissões `600`, nunca exposto em argumentos de processo
- **Log persistente** — `/var/log/cloudflared.log` via `daemon(8)`
- **Serviço RC** — `REQUIRE: NETWORKING SERVERS`, inicia após a rede estar disponível

## Ambiente de Testes

| Componente | Versão |
|------------|--------|
| OPNsense   | 26.1.6-amd64 |
| FreeBSD    | 14.3-RELEASE-p10 |
| cloudflared | 2026.3.0 (kjake fork) |

## Instalação

### Pré-requisito (uma única vez)

```sh
opnsense-code plugins
```

### Instalar para desenvolvimento

```sh
mkdir -p /usr/plugins/net/
cd /usr/plugins/net/
git clone https://github.com/AlanMartines/os-cloudflared cloudflared
cd cloudflared
make install
service configd restart
rm -rf /usr/local/opnsense/mvc/app/cache/*
rm -f /tmp/opnsense_menu_cache.xml
```

> Faça logout e login no OPNsense para o menu aparecer.

### Gerar pacote distribuível

```sh
cd /usr/plugins/net/cloudflared
make package
# Saída: /usr/ports/packages/All/os-cloudflared-*.txz
```

## Como Usar

### 1. Obtenha o Token

1. Acesse [Cloudflare Zero Trust](https://one.dash.cloudflare.com/)
2. Navegue em **Networks → Tunnels**
3. Crie ou selecione um túnel → **Configure** → copie o token

### 2. Configure o Plugin

1. No OPNsense, acesse **Services → Cloudflare Tunnel**
2. Clique em **Install/Update Binary** para baixar o `cloudflared`
3. Cole o token em **Tunnel Token** (use o olho para visualizar)
4. Marque **Enable**
5. Configure as opções conforme necessário:
   - **Disable Auto-Update** — recomendado
   - **Enable Post-Quantum Encryption** — opcional
6. Clique em **Apply**

O serviço inicia automaticamente. O status **Running** (verde) aparece na barra inferior da página.

### 3. Verificar

```sh
# Status do serviço
service cloudflared status

# Logs em tempo real
tail -f /var/log/cloudflared.log
```

No **Cloudflare Dashboard**: Networks → Tunnels → o túnel deve aparecer como **Healthy**.

## Arquivos Gerados

| Arquivo | Descrição |
|---------|-----------|
| `/etc/rc.conf.d/cloudflared` | Configuração RC (enable + mode) |
| `/usr/local/etc/cloudflared/token` | Token do túnel (600) |
| `/usr/local/etc/sysctl.conf.d/cloudflared.conf` | Tunables QUIC |
| `/var/log/cloudflared.log` | Log do daemon |
| `/var/run/cloudflared.pid` | PID do processo |
| `/usr/local/bin/cloudflared` | Binário instalado |

## Licença

BSD 2-Clause — mesma licença do OPNsense.

## Créditos

- Guia de instalação: [hannoeru.me](https://hannoeru.me/posts/install-cloudflared-opnsense)
- Binários FreeBSD: [kjake/cloudflared](https://github.com/kjake/cloudflared)

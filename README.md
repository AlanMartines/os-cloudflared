# OPNsense Plugin: os-cloudflared

Este plugin permite a integração nativa do **Cloudflare Tunnel (cloudflared)** no OPNsense, permitindo que você exponha serviços internos para a internet de forma segura, sem a necessidade de abrir portas no seu firewall ou lidar com IPs dinâmicos.

O plugin implementa o **Method 1: Token-based Setup (Recommended)** conforme documentado em [hannoeru.me](https://hannoeru.me/posts/install-cloudflared-opnsense), utilizando binários do fork [kjake/cloudflared](https://github.com/kjake/cloudflared) otimizado para FreeBSD.

## Funcionalidades

- **Configuração via Interface (MVC):** Gerenciamento completo através do menu padrão do OPNsense em **Serviços → Cloudflare Tunnel → Configurações**.
- **Autenticação por Token:** Suporte para túneis gerenciados via painel Cloudflare Zero Trust (token-based).
- **Instalador de Binário Integrado:** Botão na interface para baixar/atualizar automaticamente a versão mais recente do `cloudflared`, com detecção automática de versão do FreeBSD e arquitetura da CPU.
- **Sem Auto-Update (`--no-autoupdate`):** Desativa atualizações automáticas do cloudflared — habilitado por padrão, garantindo que atualizações sejam sempre controladas manualmente.
- **Criptografia Pós-Quântica (`--post-quantum`):** Opção para habilitar criptografia pós-quântica na conexão do túnel.
- **Otimização para QUIC:** Aplica automaticamente os ajustes de `sysctl` (`kern.ipc.maxsockbuf` e `net.inet.udp.recvspace`) recomendados pela Cloudflare, e desativa PMTU Discovery.
- **Log Persistente:** Saída do serviço gravada em `/var/log/cloudflared.log` via `daemon(8)`.
- **Segurança:** Arquivo de token protegido com permissões `600` a cada reconfiguração.
- **Integração com o Sistema:** Gerenciado como serviço padrão RC (`REQUIRE: NETWORKING SERVERS`), iniciando corretamente após a rede estar disponível.

## Instalação

### 1. Preparação do Ambiente (necessário uma única vez)

Para compilar e instalar plugins no OPNsense, você precisa da infraestrutura de build do repositório oficial. No shell do seu OPNsense, execute:

```bash
opnsense-code plugins
```

### 2. Instalação para Desenvolvimento (manual)

1. Acesse o shell do seu OPNsense (via SSH ou console).
2. Navegue até o diretório de plugins de rede:
    ```bash
    mkdir -p /usr/plugins/net/
    cd /usr/plugins/net/
    ```
3. Clone este repositório:
    ```bash
    git clone https://github.com/AlanMartines/os-cloudflared cloudflared
    ```
4. Instale o plugin:
    ```bash
    cd cloudflared
    make install
    ```
5. Recarregue o backend e limpe o cache:
    ```bash
    service configd restart
    rm -rf /usr/local/opnsense/mvc/app/cache/*
    ```

### 3. Instalação via Pacote (.txz)

Para distribuir o plugin para outros sistemas OPNsense, gere um pacote:

```bash
cd /usr/plugins/net/cloudflared
make package
```

O arquivo será gerado em `/usr/ports/packages/All/os-cloudflared-*.txz`.

## Como Usar

### 1. Obtenha seu Token

1. Acesse o painel [Cloudflare Zero Trust](https://one.dash.cloudflare.com/).
2. Navegue até **Access → Tunnels**.
3. Crie um novo túnel ou selecione um existente.
4. Clique em **Configure** e copie o **token** exibido.

### 2. Configure o Plugin

1. No OPNsense, acesse **Serviços → Cloudflare Tunnel → Configurações**.
2. Clique em **Install/Update Binary** para baixar o binário do `cloudflared`.
3. Cole o token no campo **Tunnel Token**.
4. Marque a opção **Enable**.
5. Configure as opções avançadas conforme necessário:
   - **Disable Auto-Update:** Recomendado — mantém o binário sob controle manual.
   - **Enable Post-Quantum Encryption:** Opcional — habilita criptografia pós-quântica.
   - **Disable PMTU Discovery:** Recomendado no FreeBSD/OPNsense.
6. Clique em **Apply**.

### 3. Verifique o Status

- Ao final da página de configurações há uma barra de status com o estado atual do serviço (**Running** / **Stopped**) e botões de **Start**, **Stop** e **Restart**.
- Para acompanhar os logs em tempo real:
    ```bash
    tail -f /var/log/cloudflared.log
    ```

## Ajustes de Performance (QUIC)

O plugin configura automaticamente os seguintes parâmetros de kernel para evitar erros de buffer no protocolo QUIC:

| Parâmetro | Valor padrão |
|-----------|-------------|
| `kern.ipc.maxsockbuf` | `16777216` |
| `net.inet.udp.recvspace` | `8388608` |

Os valores podem ser ajustados na interface em **Configurações Gerais**.

## Arquivos Gerados pelo Plugin

| Arquivo | Descrição |
|---------|-----------|
| `/etc/rc.conf.d/cloudflared` | Variáveis de configuração do serviço RC |
| `/usr/local/etc/cloudflared/token` | Token do túnel (permissões `600`) |
| `/usr/local/etc/sysctl.conf.d/cloudflared.conf` | Tunables de kernel para QUIC |
| `/var/log/cloudflared.log` | Log do daemon |
| `/var/run/cloudflared.pid` | PID do processo |
| `/usr/local/bin/cloudflared` | Binário instalado |

## Licença

Este projeto segue a mesma licença do OPNsense — BSD 2-Clause "Simplified".

## Créditos

- Baseado no guia de instalação de [hannoeru.me](https://hannoeru.me/posts/install-cloudflared-opnsense).
- Binários fornecidos pelo fork [kjake/cloudflared](https://github.com/kjake/cloudflared) para FreeBSD.

## Ambiente de Desenvolvimento e Testes

| Componente | Versão |
|------------|--------|
| OPNsense   | 26.1.6-amd64 |
| FreeBSD    | 14.3-RELEASE-p10 |

---

> **Status:** Este projeto está em **desenvolvimento ativo** (v0.2.0). Teste com cautela em ambientes de produção.

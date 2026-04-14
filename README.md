# OPNsense Plugin: os-cloudflared

Este plugin permite a integração nativa do **Cloudflare Tunnel (cloudflared)** no OPNsense, permitindo que você exponha serviços internos para a internet de forma segura, sem a necessidade de abrir portas no seu firewall ou lidar com IPs dinâmicos.

O plugin utiliza o fork comunitário do **kjake**, que fornece binários otimizados do `cloudflared` para **FreeBSD/OPNsense**.

## 🚀 Funcionalidades

- **Configuração via Interface (MVC):** Gerenciamento completo através do menu padrão do OPNsense.
- **Autenticação por Token:** Suporte simplificado para túneis gerenciados via painel Cloudflare Zero Trust.
- **Instalador de Binário Integrado:** Botão na interface para baixar/atualizar a versão mais recente do `cloudflared` compatível com FreeBSD.
- **Otimização para QUIC:** Aplica automaticamente os ajustes de `sysctl` (`kern.ipc.maxsockbuf` e `net.inet.udp.recvspace`) recomendados pela Cloudflare para melhor performance em sistemas BSD.
- **Integração com o Sistema:** Gerenciado como um serviço padrão (RC script), permitindo iniciar, parar e monitorar o status.

## 🛠️ Instalação

### 1. Preparação do Ambiente (Necessário uma única vez)
Para compilar e instalar plugins no OPNsense, você precisa da infraestrutura de build (`Mk`) do repositório oficial de plugins. No shell do seu OPNsense, execute:

```bash
opnsense-code plugins
```
*Isso criará o diretório `/usr/plugins` com todos os arquivos necessários para o `make` funcionar.*

### 2. Instalação para Desenvolvimento (Manual)
Este método é ideal para testar alterações rapidamente no código.

1.  Acesse o shell do seu OPNsense (via SSH ou console).
2.  Navegue até o diretório de plugins de rede:
    ```bash
    mkdir -p /usr/plugins/net/
    cd /usr/plugins/net/
    ```
3.  Clone este repositório:
    ```bash
    git clone https://github.com/AlanMartines/os-cloudflared cloudflared
    ```
4.  Instale o plugin no sistema:
    ```bash
    cd cloudflared
    make install
    ```
5.  Recarregue as configurações do backend:
    ```bash
    service configd restart
    ```

### 3. Instalação via Pacote (.txz)
Recomendado para distribuir o plugin para outros sistemas OPNsense.

#### Gerando o pacote:
No seu ambiente de desenvolvimento OPNsense, execute:
```bash
cd /usr/plugins/net/cloudflared
make package
```
O arquivo será gerado em `/usr/ports/packages/All/os-cloudflared-*.txz`.

#### Instalando o pacote:
Copie o arquivo `.txz` para o OPNsense de destino e instale com:
```bash
pkg add os-cloudflared-0.1.0.txz
```

## 📖 Como Usar

1.  **Acesse a Interface:** No menu lateral do OPNsense, vá para **Serviços -> Cloudflare Tunnel -> Configurações**.
2.  **Baixe o Binário:** Clique no botão **"Install/Update Binary"** para realizar o download automático da versão correta para o seu sistema.
3.  **Configure o Token:**
    - Vá ao painel [Cloudflare Zero Trust](https://one.dash.cloudflare.com/).
    - Crie um novo Tunnel (ou selecione um existente).
    - Copie apenas o **Token** fornecido na seção de instalação.
4.  **Habilite o Serviço:** 
    - Cole o token no campo **Tunnel Token**.
    - Marque a opção **Enable**.
    - Clique em **Apply**.
5.  **Verifique o Status:** O status do serviço deverá mudar para "Running" (ícone verde) no rodapé da página.

## ⚙️ Ajustes de Performance

O plugin configura os seguintes parâmetros de kernel para evitar erros de buffer no protocolo QUIC:
- `kern.ipc.maxsockbuf`: `16777216`
- `net.inet.udp.recvspace`: `8388608`

Estes valores são aplicados automaticamente ao clicar em "Apply".

## 📄 Licença

Este projeto segue a mesma licença do OPNsense (BSD 2-Clause "Simplified").

## 🙏 Créditos

- Baseado no guia de instalação de [hannoeru.me](https://hannoeru.me/posts/install-cloudflared-opnsense).
- Binários fornecidos pelo fork de [kjake/cloudflared](https://github.com/kjake/cloudflared).
- Estrutura MVC baseada no exemplo [HelloWorld](https://docs.opnsense.org/development/examples/helloworld.html) da documentação oficial do OPNsense.

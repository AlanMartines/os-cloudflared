# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-br/1.0.0/),
e este projeto segue o [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-04-14

### Adicionado
- **Lançamento Inicial:** Estrutura completa do plugin `os-cloudflared` para OPNsense.
- **Arquitetura MVC:** Implementação de Modelos, Visões (Volt) e Controladores para gerenciamento do túnel.
- **Instalador de Binário:** Script para download automático do binário `cloudflared` (Fork kjake para FreeBSD).
- **Gerenciamento de Token:** Campo dedicado para autenticação simplificada via Cloudflare Zero Trust.
- **Otimização QUIC:** Aplicação automática de ajustes de kernel (`sysctl`) para melhorar a performance de rede.
- **Integração configd:** Ações de backend para `start`, `stop`, `restart`, `status` e `reconfigure`.
- **Interface Web:** Painel de configurações integrado ao menu de Serviços do OPNsense com monitoramento de status.
- **Documentação:** Arquivos `README.md` e `CHANGELOG.md` com instruções de uso e instalação.
- **Scripts de Serviço:** Script RC para gerenciamento do daemon no FreeBSD.

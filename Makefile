PLUGIN_NAME=        cloudflared
PLUGIN_VERSION=     0.1.0
PLUGIN_REVISION=    1
PLUGIN_COMMENT=     Cloudflare Tunnel (cloudflared)
PLUGIN_MAINTAINER=  ai@opnsense.org

# Tenta encontrar a infraestrutura de plugins do OPNsense
.if exists(../../Mk/plugins.mk)
.include "../../Mk/plugins.mk"
.elif exists(/usr/plugins/Mk/plugins.mk)
.include "/usr/plugins/Mk/plugins.mk"
.else
.error "Não foi possível encontrar a infraestrutura de plugins do OPNsense (Mk/plugins.mk)"
.endif

cloudflared_enable="{{ OPNsense.Cloudflared.general.enabled|default('0') == '1' ? 'YES' : 'NO' }}"
cloudflared_token_file="/usr/local/etc/cloudflared/token"
cloudflared_quic_disable_pmtu_discovery="{{ OPNsense.Cloudflared.general.quic_disable_pmtu_discovery|default('1') == '1' ? 'YES' : 'NO' }}"

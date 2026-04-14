cloudflared_enable="{{ OPNsense.Cloudflared.general.enabled|default('0') == '1' ? 'YES' : 'NO' }}"
cloudflared_mode="tunnel run --token-file /usr/local/etc/cloudflared/token {{ OPNsense.Cloudflared.general.quic_disable_pmtu_discovery|default('0') == '1' ? '--quic-disable-pmtu-discovery' : '' }}"

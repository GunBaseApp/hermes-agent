FROM tailscale/tailscale:stable AS tailscale

FROM nousresearch/hermes-agent:v2026.8.3

COPY --from=tailscale /usr/local/bin/tailscale /usr/local/bin/tailscale
COPY --from=tailscale /usr/local/bin/tailscaled /usr/local/bin/tailscaled

# The Railway container cannot create a kernel TUN device, so tailscaled runs
# in userspace mode. Route SSH destinations on the tailnet through `tailscale
# nc`; no SSH listener or Railway TCP proxy is exposed.
RUN install -d /etc/ssh/ssh_config.d && printf '%s\n' \
    'Host 100.*' \
    '    ProxyCommand /usr/local/bin/tailscale --socket=/tmp/tailscaled.sock nc %h %p' \
    > /etc/ssh/ssh_config.d/99-tailscale.conf

COPY start.sh /opt/hermes/railway-start.sh
RUN chmod +x /opt/hermes/railway-start.sh

CMD ["/opt/hermes/railway-start.sh"]

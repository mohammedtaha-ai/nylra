# syntax=docker/dockerfile:1
# Debian 13 matches the host Shadows binary's GLIBC_2.39 requirement.
FROM node:24-trixie
RUN --mount=type=secret,id=proxy_ca \
    if [ -s /run/secrets/proxy_ca ]; then \
      cp /run/secrets/proxy_ca /usr/local/share/ca-certificates/session-proxy.crt; \
      update-ca-certificates; \
    fi && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      libgtk-3-0t64 libwebkit2gtk-4.1-0 libayatana-appindicator3-1 \
      xvfb x11-utils x11-apps xdotool python3 && \
    rm -rf /var/lib/apt/lists/* /usr/local/share/ca-certificates/session-proxy.crt && \
    update-ca-certificates

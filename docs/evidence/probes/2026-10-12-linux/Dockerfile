# syntax=docker/dockerfile:1
FROM rust:1.94-bookworm
RUN --mount=type=secret,id=proxy_ca \
    if [ -s /run/secrets/proxy_ca ]; then \
      cp /run/secrets/proxy_ca /usr/local/share/ca-certificates/session-proxy.crt; \
      update-ca-certificates; \
    fi && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      pkg-config libgtk-3-dev libwebkit2gtk-4.1-dev \
      libayatana-appindicator3-dev librsvg2-dev libssl-dev libxdo-dev patchelf \
      xvfb x11-utils x11-apps xdotool && \
    rm -rf /var/lib/apt/lists/* /usr/local/share/ca-certificates/session-proxy.crt && \
    update-ca-certificates

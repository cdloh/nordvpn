FROM s6on/ubuntu:20.04
LABEL maintainer="Julio Gutierrez julio.guti+nordvpn@pm.me"

ARG NORDVPN_VERSION=3.12.3
ARG DEBIAN_FRONTEND=noninteractive


RUN apt-get update -y && \
    apt-get install -y curl iptables iproute2 iputils-ping libc6 wireguard jq && \
    curl https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_1.0.0_all.deb --output /tmp/nordrepo.deb && \
    apt-get install -y /tmp/nordrepo.deb && \
    apt-get update -y && \
    apt-get install -y nordvpn${NORDVPN_VERSION:+=$NORDVPN_VERSION} && \
    apt-get remove -y nordvpn-release && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    rm -rf \
		/tmp/* \
		/var/cache/apt/archives/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

COPY /rootfs /
ENV S6_CMD_WAIT_FOR_SERVICES=1
ENV PATH=/usr/bin:/sbin:$PATH
CMD /usr/bin/nord_login && /usr/bin/nord_config && /usr/bin/nord_connect && /usr/bin/nord_watch

HEALTHCHECK --interval=2m --timeout=10s \
  CMD /usr/bin/healthcheck

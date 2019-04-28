FROM debian

LABEL maintainer="Raik Bieniek <raik.bieniek@gmail.com>"
LABEL com.github.actions.name="Create Github Release"
LABEL com.github.actions.description="Allows to create releases on Github and upload binaries."
LABEL com.github.actions.icon="tag"
LABEL com.github.actions.color="orange"

ARG VERSION_HUB=2.11.2
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
      git \
      ca-certificates \
      wget && \
    \
    mkdir /hub && \
    cd /hub && \
    wget https://github.com/github/hub/releases/download/v${VERSION_HUB}/hub-linux-amd64-${VERSION_HUB}.tgz && \
    tar -xf hub-linux-amd64-${VERSION_HUB}.tgz && \
    cd hub-linux-amd64-${VERSION_HUB} && \
    ./install && \
    rm -r /hub && \
    \
    apt-get remove -y wget && \
    rm -rf /var/lib/apt/lists/*

COPY "entrypoint.sh" /
ENTRYPOINT ["/entrypoint.sh"]

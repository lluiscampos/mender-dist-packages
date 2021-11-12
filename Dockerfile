ARG DEBIAN_VERSION=buster
FROM debian:$DEBIAN_VERSION
ARG DEBIAN_VERSION

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    git wget curl \
    debhelper devscripts

ARG ARCH=amd64
RUN dpkg --add-architecture ${ARCH} && \
    apt-get update

RUN apt-get install -y \
    pkg-config \
    liblzma-dev:${ARCH} \
    libssl-dev:${ARCH} \
    libglib2.0-dev:${ARCH};

RUN if [ "${ARCH}" = "arm64" ]; then \
        apt-get install -y gcc-aarch64-linux-gnu; \
    fi

RUN if [ "${ARCH}" = "armhf" ]; then \
        apt-get install -y gcc-arm-linux-gnueabihf; \
    fi

# Golang environment, for cross-compiling the Mender client
ARG GOLANG_VERSION=1.14.7
RUN wget -q https://dl.google.com/go/go$GOLANG_VERSION.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOPATH "/root/go"
ENV PATH "$PATH:/usr/local/go/bin"
# Support building mender-client 2.3.x, since it does not have go modules support
# For newer clients with a go.mod file, this is a no-op however.
ENV GO111MODULE auto

# Import GPG key, if set
ARG GPG_KEY_BUILD=""
RUN if [ -n "$GPG_KEY_BUILD" ]; then \
        echo "$GPG_KEY_BUILD" | gpg --import; \
    fi

# Prepare the deb-package script
COPY mender-deb-package /usr/local/bin/
ENTRYPOINT  ["/usr/local/bin/mender-deb-package"]

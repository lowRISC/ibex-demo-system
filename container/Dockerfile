# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Docker container containing various hardware and software development tools
# for OpenTitan.

# Global configuration options.
ARG VERILATOR_VERSION=4.210
ARG VERIBLE_VERSION=v0.0-2135-gb534c1fe
ARG RISCV_TOOLCHAIN_RELEASE_TAG=20220210-1

# Main container image.
FROM ubuntu:20.04 AS ibex
ARG VERILATOR_VERSION
ARG VERIBLE_VERSION
ARG RISCV_TOOLCHAIN_RELEASE_TAG

LABEL version="0.2"
LABEL description="Ibex Demo System Container."

# Use bash as default shell.
RUN ln -sf /bin/bash /bin/sh

# Add OBS repository to apt sources.
RUN OBS_URL="https://download.opensuse.org/repositories"; \
    OBS_PATH="/home:/phiwag:/edatools/xUbuntu_20.04"; \
    REPO_URL="${OBS_URL}${OBS_PATH}"; \
    \
    EDATOOLS_REPO_KEY="${REPO_URL}/Release.key"; \
    EDATOOLS_REPO="deb ${REPO_URL}/ /"; \
    \
    apt-get update && \
    apt-get install -y curl && \
    \
    curl -f -sL -o "$TMPDIR/obs.asc" "$EDATOOLS_REPO_KEY" || { \
        error "Failed to download repository key from ${REPO_URL}"; \
    } && \
    echo "$EDATOOLS_REPO" > "$TMPDIR/obs.list" && \
    mv "$TMPDIR/obs.asc"  /etc/apt/trusted.gpg.d/obs.asc && \
    mv "$TMPDIR/obs.list" /etc/apt/sources.list.d/edatools.list

# Necessary to avoid user interaction with tzdata during install
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

COPY container/apt-requirements.txt /tmp/apt-requirements.txt
RUN echo "verilator-${VERILATOR_VERSION}" >> /tmp/apt-requirements.txt \
    && sed -i -e '/^$/d' -e '/^#/D' -e 's/#.*//' /tmp/apt-requirements.txt \
    && apt-get update \
    && xargs apt-get install -y < /tmp/apt-requirements.txt \
    && apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# RISC-V device toolchain
COPY container/get-toolchain.py /tmp/get-toolchain.py
RUN /tmp/get-toolchain.py -r ${RISCV_TOOLCHAIN_RELEASE_TAG} \
    && rm -f /tmp/get-toolchain.py
ENV PATH "/tools/riscv/bin:${PATH}"

# Install Verible
RUN curl -f -Ls -o verible.tar.gz \
        https://github.com/chipsalliance/verible/releases/download/${VERIBLE_VERSION}/verible-${VERIBLE_VERSION}-Ubuntu-18.04-bionic-x86_64.tar.gz \
    && mkdir -p /tools/verible \
    && tar -C /tools/verible -xf verible.tar.gz --strip-components=1
ENV PATH "/tools/verible/bin:${PATH}"

# Install openFPGALoader
RUN curl -f -Ls -o openfpgaloader.tar.gz \
    https://github.com/trabucayre/openFPGALoader/releases/download/v0.10.0/ubtuntu20.04-openFPGALoader.tgz
RUN tar -C / -xf openfpgaloader.tar.gz --strip-components=1

# Build OpenOCD
RUN git clone https://github.com/openocd-org/openocd.git \
    && cd openocd \
    && git checkout v0.11.0 \
    && ./bootstrap \
    && ./configure \
    && make \
    && mkdir -p /tools/openocd \
    && cp -r src /tools/openocd \
    && cd ..
ENV PATH "/tools/openocd/src:$PATH"

# Set Locale to utf-8 everywhere
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

# Scripting for use within this container.
COPY container/start.sh /start.sh
COPY container/sudoconf /etc/sudoers.d/dev
COPY container/novnc.pem /novnc.pem

# Add the development user (UID/GID to be replaced).
RUN groupadd dev \
    && useradd --create-home -g dev dev \
    && usermod -p '*' dev \
    && passwd -u dev

# All subsequent steps are performed as user.
USER dev:dev

# Install Python Packages.
ENV PATH "/home/dev/.local/bin:${PATH}"
COPY --chown=dev:dev python-requirements.txt /tmp/python-requirements.txt
RUN python3 -m pip install --user -U pip setuptools==58.2.0 testresources \
    && python3 -m pip install --user -r /tmp/python-requirements.txt \
        --no-warn-script-location \
    && rm -f /tmp/python-requirements.txt

ENTRYPOINT [ ]
CMD [ "/start.sh" ]

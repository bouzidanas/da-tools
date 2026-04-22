FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

# Install base development tools, C/C++ toolchain, and browser automation deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    gdb \
    cmake \
    make \
    clang \
    clang-format \
    lldb \
    curl \
    wget \
    ca-certificates \
    sudo \
    locales \
    gnupg \
    unzip \
    xdg-utils \
    # Browser / GUI dependencies for headless Chrome, Playwright, Selenium
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libpango-1.0-0 \
    libcairo2 \
    libasound2t64 \
    libxshmfence1 \
    libx11-xcb1 \
    fonts-liberation \
    libappindicator3-1 \
    xvfb \
    # Networking tools
    dnsutils \
    iputils-ping \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# Install Google Chrome (stable)
RUN wget -q -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get update \
    && apt-get install -y --no-install-recommends /tmp/chrome.deb \
    && rm /tmp/chrome.deb \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8

# Create non-root user (handle case where GID/UID already exist)
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN if getent group $USER_GID >/dev/null; then \
        groupmod -n $USERNAME $(getent group $USER_GID | cut -d: -f1); \
    else \
        groupadd --gid $USER_GID $USERNAME; \
    fi \
    && if id -u $USER_UID >/dev/null 2>&1; then \
        usermod -l $USERNAME -d /home/$USERNAME -m $(id -nu $USER_UID); \
    else \
        useradd --uid $USER_UID --gid $USER_GID -m $USERNAME; \
    fi \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Bake setup script into image so it's available regardless of mount type
COPY setup.sh /usr/local/bin/container-setup.sh
RUN chmod +x /usr/local/bin/container-setup.sh

USER $USERNAME

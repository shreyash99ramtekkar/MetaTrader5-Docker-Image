FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntujammy

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Metatrader Docker:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="gmartin"

ENV TITLE=Metatrader5
ENV WINEPREFIX="/config/.wine"

# Remove stale nodesource repo baked into the base image (deb.nodesource.com no longer serves node_18.x/jammy)
RUN rm -f /etc/apt/sources.list.d/nodesource.list

# Update package lists and upgrade packages
RUN apt-get update && apt-get upgrade -y

# Install required packages
RUN apt-get install -y \
    python3-pip \
    wget \
    && pip3 install --upgrade pip

# Add WineHQ repository key and APT source
RUN wget -q https://dl.winehq.org/wine-builds/winehq.key \
    && apt-key add winehq.key \
    && add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ jammy main' \
    && rm winehq.key

# Add i386 architecture and update package lists
RUN dpkg --add-architecture i386 \
    && apt-get update

# Install WineHQ stable package and dependencies
# Pinned to 10.0.0.0~jammy-1: Wine 11.0 trips MetaTrader5's anti-debug check
# ("A debugger has been found running in your system") and aborts install.
RUN WINE_VERSION="10.0.0.0~jammy-1" \
    && apt-get install --install-recommends -y \
    winehq-stable=$WINE_VERSION \
    wine-stable=$WINE_VERSION \
    wine-stable-amd64=$WINE_VERSION \
    wine-stable-i386=$WINE_VERSION \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


COPY /Metatrader /Metatrader
RUN chmod +x /Metatrader/start.sh
COPY /root /

EXPOSE 3000 8001
VOLUME /config

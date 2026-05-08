FROM debian:trixie
RUN apt-get update && apt-get install -y --no-install-recommends \
      libsdl1.2-dev libsdl-image1.2-dev libsdl-mixer1.2-dev \
      libsdl-ttf2.0-dev libsdl-pango-dev libsdl-net1.2-dev \
      libxml2-dev librsvg2-dev libespeak-ng-dev \
      cmake build-essential pkg-config gettext \
      autoconf automake libtool autopoint \
      gcc-12 gcc-14 \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /src

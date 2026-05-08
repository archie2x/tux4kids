# EL8 (Rocky / Alma 8): NOT viable for SDL1.2 upstream builds.
#
# EPEL 8 ships SDL_image, SDL_ttf, SDL_net but dropped SDL_mixer 1.2 — only
# SDL2_mixer is packaged. Until upstream tuxtype/tuxmath move to SDL2 or
# SDL3, building on EL8 would require compiling SDL_mixer 1.2 from source.
#
# Kept here for future use (against an SDL2/SDL3-port branch).
FROM --platform=linux/amd64 rockylinux:8
RUN dnf install -y epel-release dnf-plugins-core && \
    dnf config-manager --set-enabled powertools && \
    dnf install -y --setopt=install_weak_deps=False \
      SDL-devel SDL_image-devel SDL_ttf-devel SDL_net-devel \
      libxml2-devel librsvg2-devel \
      cmake make gcc gcc-c++ pkg-config gettext gettext-devel \
      autoconf automake libtool \
      diffutils file findutils \
    && dnf clean all
WORKDIR /src

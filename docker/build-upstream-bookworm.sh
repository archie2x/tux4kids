#!/bin/sh
# Build t4kcommon + tuxtype + tuxmath against upstream-prep branches in
# a bookworm container. Sources mounted rw (autoreconf needs to write
# into them). Build trees + stage prefix go under _build/upstream-bookworm/.
#
# Image: docker build -t t4k-bookworm -f docker/upstream-bookworm.Dockerfile .

set -e
cd "$(dirname "$0")/.."

mkdir -p _build/upstream-bookworm

docker run --rm \
  -v "$(pwd)/t4kcommon:/src/t4kcommon" \
  -v "$(pwd)/tuxtype:/src/tuxtype" \
  -v "$(pwd)/tuxmath:/src/tuxmath" \
  -v "$(pwd)/_build/upstream-bookworm:/build" \
  -w /build t4k-bookworm sh -c '
set -e
mkdir -p t4kcommon-build stage tuxtype-build tuxmath-build

cd /src/t4kcommon
[ -x ./configure ] || autoreconf -fi

cd /build/t4kcommon-build
/src/t4kcommon/configure --prefix=/build/stage
make -j
make install

cd /src/tuxtype
[ -x ./configure ] || autoreconf -fi

cd /build/tuxtype-build
PKG_CONFIG_PATH=/build/stage/lib/pkgconfig \
  /src/tuxtype/configure --prefix=/build/stage
make -j
make install

cd /src/tuxmath
[ -x ./configure ] || autoreconf -fi

cd /build/tuxmath-build
PKG_CONFIG_PATH=/build/stage/lib/pkgconfig \
  /src/tuxmath/configure --prefix=/build/stage
make -j
make install
'

#!/bin/sh
# Standalone autotools build of t4kcommon + tuxtype + tuxmath against
# upstream-prep branches. Runs anywhere with the SDL1.2 + autotools
# stack installed (Debian bookworm / trixie, Ubuntu, etc.).
#
# Layout:
#   $SRC_DIR/{t4kcommon,tuxtype,tuxmath}/
#   $BLD_DIR/{stage,t4kcommon,tuxtype,tuxmath}/
#
# Override:
#   SRC_DIR=/src/tux4kids   (default: $PWD)
#   BLD_DIR=/build          (default: $SRC_DIR/_build/upstream-prep)

set -e
SRC_DIR=${SRC_DIR:-$(pwd)}
BLD_DIR=${BLD_DIR:-${SRC_DIR}/_build/upstream-prep}
export PKG_CONFIG_PATH=${BLD_DIR}/stage/lib/pkgconfig

mkdir -p "$BLD_DIR"/stage "$BLD_DIR"/t4kcommon "$BLD_DIR"/tuxtype "$BLD_DIR"/tuxmath

for sub in t4kcommon tuxtype tuxmath; do
    ( cd "$SRC_DIR/$sub" && autoreconf -fi )
    # tuxtype/tuxmath upstream master have ~50 implicit-decl /
    # incompat-pointer call sites that gcc 14 promotes from warnings to
    # errors. Relax those for now; they're a separate upstream-prep PR
    # that this build script doesn't gate on.
    case "$sub" in
        tuxtype|tuxmath)
            CFLAGS_RELAX="-Wno-error=implicit-function-declaration -Wno-error=incompatible-pointer-types -Wno-error=int-conversion"
            ;;
        *) CFLAGS_RELAX="" ;;
    esac
    (
        cd "$BLD_DIR/$sub"
        CFLAGS="${CFLAGS:--g -O2} $CFLAGS_RELAX" \
            "$SRC_DIR/$sub/configure" --prefix="$BLD_DIR/stage"
        make -j
        make install
    )
done

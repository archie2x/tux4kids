#!/bin/sh
# Build the upstream-prep tree across multiple environments. Pass/fail per
# environment, full logs under _build/farm/<env>/.
#
# Each environment is a docker image baked from docker/<env>.Dockerfile.
# The image runs autotools-build.sh against the mounted source.
#
# Override:
#   FARM_ENVS="bookworm trixie"   pick a subset
#   FARM_BUILD_IMAGE=1            force-rebuild the docker image even if cached

set -u
cd "$(dirname "$0")"

ENVS=${FARM_ENVS:-"bookworm trixie"}
FAIL=""

for env in $ENVS; do
    img=t4k-$env
    df=docker/$env.Dockerfile

    if [ ! -f "$df" ]; then
        echo "SKIP   $env  (no $df)"
        continue
    fi

    if [ -n "${FARM_BUILD_IMAGE:-}" ] || [ -z "$(docker images -q $img 2>/dev/null)" ]; then
        echo "BUILD  $env  (image)"
        docker build -t $img -f $df . > /dev/null 2>&1 || {
            echo "FAIL   $env  (image build) — see docker build $df"
            FAIL="$FAIL $env"
            continue
        }
    fi

    bld=_build/farm/$env
    rm -rf "$bld"
    mkdir -p "$bld"
    log=$bld.log

    echo "RUN    $env"
    if docker run --rm \
        -v "$(pwd):/src" \
        -v "$(pwd)/$bld:/build" \
        -e SRC_DIR=/src -e BLD_DIR=/build \
        -w /src $img \
        /src/autotools-build.sh > "$log" 2>&1
    then
        echo "PASS   $env  (log: $log)"
    else
        echo "FAIL   $env  (log: $log — last lines:)"
        tail -10 "$log" | sed 's/^/  /'
        FAIL="$FAIL $env"
    fi
done

echo
if [ -n "$FAIL" ]; then
    echo "Build farm result: FAIL on${FAIL}"
    exit 1
fi
echo "Build farm result: all PASS"

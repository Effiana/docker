FROM alpine

COPY ./unit/go1.24/entrypoint.sh /docker-entrypoint.sh
RUN --mount=type=cache,target=/usr/src/unit/rustup \
    --mount=type=cache,target=/usr/src/unit/cargo
RUN --mount=type=cache,target=/var/cache/apk \
    set -ex && \
    apk update && \
    apk add --no-cache \
        ca-certificates \
        git \
        build-base \
        openssl \
        openssl-dev \
        pcre2 \
        libgcc \
        pcre2-dev \
        curl \
        pkgconfig \
        clang-dev \
        cmake \
        wget && \
    \
    export RUST_VERSION=1.83.0 && \
    export RUSTUP_HOME=/usr/src/unit/rustup && \
    export CARGO_HOME=/usr/src/unit/cargo && \
    export PATH="$CARGO_HOME/bin:$PATH" && \
    \
    if ! command -v rustc > /dev/null 2>&1; then \
        curl -sSf https://sh.rustup.rs -o rustup-init && \
        chmod +x rustup-init && \
        ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION && \
        rm rustup-init; \
    fi && \
    \
    mkdir -p /usr/lib/unit/modules /usr/lib/unit/debug-modules /usr/src/unit && \
    cd /usr/src/unit && \
    \
    git clone --depth 1 -b 1.34.2-1 https://github.com/nginx/unit unit && \
    cd unit && \
    \
    cd pkg/contrib && \
    mkdir -p tarballs && \
    if [ ! -f tarballs/njs-0.8.8.tar.gz ]; then \
        wget -O tarballs/njs-0.8.8.tar.gz https://github.com/nginx/njs/archive/0.8.8.tar.gz; \
    fi && \
    sha512sum tarballs/njs-0.8.8.tar.gz > tarballs/njs-0.8.8.tar.gz.sha512 && \
    cd ../.. && \
    \
    NCPU=$(nproc) && \
    CC_OPT="-fPIC -O2 -D_FORTIFY_SOURCE=2" && \
    LD_OPT="-Wl,--as-needed -Wl,--strip-all" && \
    CONFIGURE_ARGS_MODULES="--prefix=/usr \
        --statedir=/var/lib/unit \
        --control=unix:/var/run/control.unit.sock \
        --runstatedir=/var/run \
        --pid=/var/run/unit.pid \
        --logdir=/var/log \
        --log=/var/log/unit.log \
        --tmpdir=/var/tmp \
        --user=unit \
        --group=unit \
        --openssl \
        --libdir=/usr/lib" && \
    CONFIGURE_ARGS="$CONFIGURE_ARGS_MODULES --njs --otel" && \
    \
    make -j $NCPU -C pkg/contrib .njs && \
    export PKG_CONFIG_PATH=$(pwd)/pkg/contrib/njs/build && \
    \
    ./configure $CONFIGURE_ARGS --cc-opt="$CC_OPT" --ld-opt="$LD_OPT" --modulesdir=/usr/lib/unit/modules && \
    make -j $NCPU unitd && \
    install -Dm755 build/sbin/unitd /usr/sbin/unitd && \
    \
    cd / && \
    rm -rf /usr/src/unit/unit && \
    rm -rf /usr/src/unit/rustup /usr/src/unit/cargo && \
    mkdir -p /var/lib/unit /docker-entrypoint.d && \
    addgroup -g 1000 unit && \
    adduser -D -H -u 1000 -G unit -s /sbin/nologin -h /nonexistent -g "unit user" unit && \
    ln -sf /dev/stderr /var/log/unit.log && \
    mkdir -p /app && \
    chown -R unit:unit /app && \
    chmod +x /docker-entrypoint.sh && \
    \
    apk del --purge -r \
        git \
        build-base \
        openssl-dev \
        pcre2-dev \
        pkgconfig \
        clang-dev \
        cmake \
        wget && \
    rm -rf /var/cache/apk/*
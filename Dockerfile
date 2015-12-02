FROM scratch

ARG ARCH
ARG VERSION
ARG DEBIAN_VERSION

MAINTAINER You-Sheng Yang <vicamo@gmail.com>
LABEL qemu-user-static.arch="$ARCH" \
      qemu-user-static.version="$VERSION" \
      debian.qemu-user-static.version="$DEBIAN_VERSION"

ADD qemu-$ARCH-static /usr/bin/qemu-$ARCH-static

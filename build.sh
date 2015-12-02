#!/bin/sh

set -e

cp /usr/bin/qemu-*-static .

first=$(ls -1 qemu-*-static | head -n 1)
ARCHES=$(ls -1 qemu-*-static | cut -d- -f2)
VERSION=$(${first} -version | awk '{print $3}')
DEBIAN_VERSION=$(dpkg-query -W -f '${Version}' qemu-user-static)

echo <<EOF
ARCHITECTURES: $ARCHES
VERSION: $VERSION
DEBIAN_VERSION: $DEBIAN_VERSION
EOF

for ARCH in ${ARCHES}; do
  cat Dockerfile.template | \
    sed "s,@ARCH@,${ARCH},g; s,@VERSION@,${VERSION},g; s,@DEBIAN_VERSION@,${DEBIAN_VERSION},g;" > Dockerfile
  echo "#### Building $ARCH ####"
  cat Dockerfile

  docker build -t vicamo/qemu-user-static:$ARCH . \
  && docker tag vicamo/qemu-user-static:$ARCH vicamo/qemu-user-static:$ARCH-$VERSION
done

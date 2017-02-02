#!/bin/bash

set -xe

DOCKER_USER=${DOCKER_USER:-vicamo}
DOCKER_REPO=${DOCKER_REPO:-qemu-user-static}

cp /usr/bin/qemu-*-static .

first=$(ls -1 qemu-*-static | head -n 1)
arches=$(ls -1 qemu-*-static | cut -d- -f2)
version=$(${first} -version | grep ' version ' | sed -e 's,^.* version \([0-9\.]\+\).*$,\1,')
debian_version=$(dpkg-query -W -f '${Version}' qemu-user-static)

echo <<EOF
ARCHITECTURES: ${arches}
VERSION: ${version}
DEBIAN_VERSION: ${debian_version}
EOF

new_version_available=
for arch in ${arches}; do
  if ! docker pull ${DOCKER_USER}/${DOCKER_REPO}:${arch}-${version}; then
    new_version_available=yes
    break
  fi
done

[ -n "${new_version_available}" ] || (echo "No updates available."; exit 0)

for arch in ${arches}; do
  cat Dockerfile.template | \
    sed "s,@ARCH@,${arch},g; s,@VERSION@,${version},g; s,@DEBIAN_VERSION@,${debian_version},g;" > Dockerfile
  echo "#### Building ${arch} ####"
  cat Dockerfile

  docker build -t ${DOCKER_USER}/${DOCKER_REPO}:${arch} . \
    && docker tag ${DOCKER_USER}/${DOCKER_REPO}:${arch} ${DOCKER_USER}/${DOCKER_REPO}:${arch}-${version}
done

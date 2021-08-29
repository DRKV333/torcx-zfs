#!/bin/bash

if [ -z "$ZOL_VERSION" ]; then
    echo "Please set ZOL_VERSION"
    exit 1
fi

echo "Dowloading and decompressing development container image..."

url="https://${GROUP:-stable}.release.flatcar-linux.net/${FLATCAR_RELEASE_BOARD}/${FLATCAR_RELEASE_VERSION}/flatcar_developer_container.bin.bz2"
curl -L "${url}" |
    tee >(bzip2 -d > flatcar_developer_container.bin) |
    gpg2 --verify <(curl -Ls "${url}.sig") -

echo "Extracting image..."

mkdir -p dev_root
export LIBGUESTFS_TRACE=1
virt-copy-out -a flatcar_developer_container.bin / dev_root

mount -t proc /proc dev_root/proc
mount -o bind /dev dev_root/dev
cp /etc/resolv.conf dev_root/etc
cp -r build dev_root/build

echo "Entering chroot..."

chroot dev_root /bin/bash -c "ZOL_VERSION=$ZOL_VERSION; cd /build; ./build.sh"

echo "Copying output..."

cp dev_root/build/zfs:$ZOL_VERSION.torcx.tgz /out

exec "$@"
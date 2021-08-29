# Torcx ZFS Module

## Building

The entire build process happens inside a docker container, so that's the only dependency you'll need. Build the image, and then run it. This will download and extract the Flatcar development image, build zfs and package up into a torcx module.

```
docker build -t torcx-zfs .

docker run --rm -it -e "FLATCAR_RELEASE_BOARD=amd64-usr" -e "FLATCAR_RELEASE_VERSION=current" -e "ZOL_VERSION=2.1.0" -v /some/place/to/put/the/output:/out --privileged torcx-zfs
```

The image uses chroot and bind mounts to setup the development environment, and thus needs a few more capabilities than the default. Running with `--privileged` is the easiest option, but if you don't want to do that, you can use `--cap-add` as well. `SYS_CHROOT` and `SYS_ADMIN` are necessary, `SYS_NET_ADMIN` is needed to get rid of some warnings from Portage.

The following environment variables can be used to specify which version of Flatcar and zfs should be used:
- `GROUP` (defaults to "stable")
- `FLATCAR_RELEASE_BOARD`
- `FLATCAR_RELEASE_VERSION`
- `ZOL_VERSION`

## Installation

Take the resulting `zfs:0.8.0.torcx.tgz` file and either manually put it into
`/var/lib/torcx/store/$VERSION/` or have some orchestration system do that for you. 

Create a torcx manifest or extend your existing manifest (example below) and drop it in `/etc/torcx/profiles/some_manifest.json`.
```json
{
  "kind": "profile-manifest-v0",
  "value": {
    "images": [
      {
        "name": "zfs",
        "reference": "0.8.0"
      }
    ]
  }
}
```

Enable your manifest if you haven't already:
```sh
echo 'some_manifest' > /etc/torcx/next-profile
```

If you want to be able to use the ZFS CLI utils you need to add the Torcx PATH to your system path. Create an executable file in `/etc/profile.d/torcx-path.sh` with the following content:
```sh
# torcx drop-in: add torcx-bindir to PATH
export PATH="/var/run/torcx/bin:${PATH}"
```
You only need to do that once for all Torcx modules. This will hopefully no longer be necessary once Torcx is better integrated into CoreOS.

At that point you can reboot and enjoy ZFS on your CoreOS system :)

## FAQ
**Do I need to rebuild the module for every CoreOS release?**
Yes. Technically you can skip it if the Kernel release hasn't changed (not often), but I wouldn't.

**What can I do to make ZFS imports faster?**
By default this ZFSOnLinux doesn't use the ZFS import cache. You can enable it by executing `zpool set cachefile=/etc/zfs/zpool.cache <poolname>`, but please read up on the effects of doing that

# Dockerfiles for building libnginx-mod-brotli for Debian / Ubuntu

[![packagecloud deb packages](https://img.shields.io/badge/deb-packagecloud.io-844fec.svg)](https://packagecloud.io/DaryL/libnginx-mod-brotli-stable) [![Build and Deploy](https://github.com/darylounet/libnginx-mod-brotli/actions/workflows/github-actions.yml/badge.svg)](https://github.com/darylounet/libnginx-mod-brotli/actions/workflows/github-actions.yml)

If you're just interested in installing built packages, go there :
https://packagecloud.io/DaryL/libnginx-mod-brotli-stable

/!\ Warning : these packages only works with official NGiNX Ubuntu / Debian repository : https://nginx.org/en/linux_packages.html#distributions

Instructions : https://packagecloud.io/DaryL/libnginx-mod-brotli-stable/install#manual-deb

If you're interested in installing [mainline](https://packagecloud.io/DaryL/libnginx-mod-brotli-mainline) NGiNX packages, go there :
https://packagecloud.io/DaryL/libnginx-mod-brotli-mainline

If you want to build packages by yourself, this is for you :

DCH Dockerfile usage (always use bullseye as it is replaced before build) :

```bash
docker build -t deb-dch -f Dockerfile-deb-dch .
docker run -it -v $PWD:/local -e HOME=/local deb-dch bash -c 'cd /local && \
dch -M -v 1.0.7+nginx-1.18.0-1~bullseye --distribution "bullseye" "Updated upstream."'
```

## Build locally usage

Docker or Podman:

```bash
# you can replace bullseye with other debian code name
docker run --rm -v `pwd`:/build debian:bullseye /build/build.sh

# or
podman run --rm -v `pwd`:/build debian:bullseye /build/build.sh
```

Or for Ubuntu :

```bash
# you can replace jammy with other ubuntu code name
docker run --rm -v `pwd`:/build ubuntu:jammy /build/build.sh

# or
podman run --rm -v `pwd`:/build ubuntu:jammy /build/build.sh
```

Optional environment variables (can be inject via command option `-e ENV=VAL`):

- `NGINX_VERSION`. E.g: `1.18.0`, default is the latest nginx version.
- `NGINX_DEB_RELEASE`. E.g: `1`, default is `1` or follow offician nginx deb version.

Then build deb files can be found in `debs/` directory.

Latest Brotli version : https://github.com/google/brotli/releases

Latest ngx_brotli version : https://github.com/google/ngx_brotli

Get latest nginx version : https://nginx.org/en/download.html
Or :

```bash
curl -s https://nginx.org/packages/debian/pool/nginx/n/nginx/ |grep '"nginx_' | sed -n "s/^.*\">nginx_\(.*\)\~.*$/\1/p" |sort -Vr |head -1| cut -d'-' -f1
```

## Cross platform build

Make sure you have installed `qemu-user` package in your machine before, and execute:

```sh
# Note, you may need to execute this command every time after you reboot your machine
sudo docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

# or
sudo podman run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

Then:

```sh
docker run --rm -v `pwd`:/build --platform=linux/arm64 ubuntu:jammy /build/build.sh

# or
podman run --rm -v `pwd`:/build --platform=linux/arm64 ubuntu:jammy /build/build.sh
```

`--platform` can be any of the official debian / ubuntu supported platforms.

You can find it under `OS/ARCH` field in https://hub.docker.com/_/ubuntu/tags. Please note official nginx deb should also supported this platform.

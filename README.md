
Dockerfiles for building libnginx-mod-brotli for Debian / Ubuntu

[![packagecloud deb packages](https://img.shields.io/badge/deb-packagecloud.io-844fec.svg)](https://packagecloud.io/DaryL/libnginx-mod-brotli-stable) [![Build Status](https://travis-ci.org/darylounet/libnginx-mod-brotli.svg?branch=stable)](https://travis-ci.org/darylounet/libnginx-mod-brotli)

If you're just interested in installing built packages, go there :
https://packagecloud.io/DaryL/libnginx-mod-brotli-stable

Instructions : https://packagecloud.io/DaryL/libnginx-mod-brotli-stable/install#manual-deb

If you're interested in installing [mainline](https://packagecloud.io/DaryL/libnginx-mod-brotli-mainline) NGiNX packages, go there :
https://packagecloud.io/DaryL/libnginx-mod-brotli-mainline

If you want to build packages by yourself, this is for you :

DCH Dockerfile usage (always use stretch as it is replaced before build) :

```bash
docker build -t deb-dch -f Dockerfile-deb-dch .
docker run -it -v $PWD:/local -e HOME=/local deb-dch bash -c 'cd /local && \
dch -M -v 1.0.7+nginx-1.18.0-1~stretch --distribution "stretch" "Updated upstream."'
```

Build Dockerfile usage :

```bash
docker build -t build-nginx-brotli -f Dockerfile-deb \
--build-arg DISTRIB=debian --build-arg RELEASE=stretch \
--build-arg NGINX_VERSION=1.18.0 .
```

Or for Ubuntu :
```bash
docker build -t build-nginx-brotli -f Dockerfile-deb \
--build-arg DISTRIB=ubuntu --build-arg RELEASE=bionic \
--build-arg NGINX_VERSION=1.18.0 .
```

Then :
```bash
docker run build-nginx-brotli
docker cp $(docker ps -l -q):/src ~/Downloads/
```

And once you don't need it anymore :
```bash
docker rm $(docker ps -l -q)
```

Latest Brotli version : https://github.com/google/brotli/releases

Latest ngx_brotli version : https://github.com/google/ngx_brotli

Get latest nginx version : https://nginx.org/en/download.html
Or :
```bash
curl -s https://nginx.org/packages/debian/pool/nginx/n/nginx/ |grep '"nginx_' | sed -n "s/^.*\">nginx_\(.*\)\~.*$/\1/p" |sort -Vr |head -1| cut -d'-' -f1
```

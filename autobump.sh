#!/bin/bash

BROTLI_VERSION="1.0.9"
NGINX_DEB_VERSION=`curl -s https://nginx.org/packages/debian/pool/nginx/n/nginx/ |grep '"nginx_' | sed -n "s/^.*\">nginx_\(.*\)\~.*$/\1/p" |sort -Vr |head -1`

docker build --pull -t deb-dch -f Dockerfile-deb-dch .
docker run -it -v $PWD:/local -e HOME=/local deb-dch bash -c "cd /local && \
    dch -M -v ${BROTLI_VERSION}+nginx-${NGINX_DEB_VERSION}~bullseye --distribution 'bullseye' 'Updated upstream.'"

git add debian/changelog
git commit -m "Updated upstream."
git tag "brotli-${BROTLI_VERSION}/nginx-${NGINX_DEB_VERSION}"
git push origin --tags
#git push origin "pagespeed-${BROTLI_VERSION}/nginx-${NGINX_DEB_VERSION}"

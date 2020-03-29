#!/bin/bash

BROTLI_VERSION="1.0.7"
NGINX_VERSION=`curl -s https://nginx.org/packages/ubuntu/dists/bionic/nginx/binary-amd64/Packages.gz |zcat |php -r 'preg_match_all("#Package: nginx\nVersion: (.*?)-\d~.*?\nArch#", file_get_contents("php://stdin"), $m);echo implode($m[1], "\n")."\n";' |sort -r |head -1`

docker build --pull -t deb-dch -f Dockerfile-deb-dch .
docker run -it -v $PWD:/local -e HOME=/local deb-dch bash -c "cd /local && \
    dch -M -v ${BROTLI_VERSION}+nginx-${NGINX_VERSION}-1~stretch --distribution 'stretch' 'Updated upstream.'"

git add debian/changelog
git commit -m "Updated upstream."
git tag "brotli-${BROTLI_VERSION}/nginx-${NGINX_VERSION}"
git push origin --tags
#git push origin "pagespeed-${BROTLI_VERSION}/nginx-${NGINX_VERSION}"

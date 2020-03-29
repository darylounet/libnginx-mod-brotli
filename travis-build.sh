#!/bin/bash

NGINX_VERSION=`curl -s https://nginx.org/packages/mainline/ubuntu/dists/bionic/nginx/binary-amd64/Packages.gz |zcat |php -r 'preg_match_all("#Package: nginx\nVersion: (.*?)-\d~.*?\nArch#", file_get_contents("php://stdin"), $m);echo implode($m[1], "\n")."\n";' |sort -r |head -1`

docker build -t build-nginx-brotli -f Dockerfile-deb \
	--build-arg DISTRIB=${OS} --build-arg RELEASE=${DIST} \
    --build-arg NGINX_VERSION=${NGINX_VERSION} .

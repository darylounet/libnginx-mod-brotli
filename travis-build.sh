#!/bin/bash

NGINX_DEB_VERSION=`curl -s https://nginx.org/packages/debian/pool/nginx/n/nginx/ |grep '"nginx_' | sed -n "s/^.*\">nginx_\(.*\)\~.*$/\1/p" |sort -Vr |head -1`
NGINX_VERSION=`echo ${NGINX_DEB_VERSION} | cut -d'-' -f1`
NGINX_DEB_RELEASE=`echo ${NGINX_DEB_VERSION} | cut -d'-' -f2`

docker build -t build-nginx-brotli -f Dockerfile-deb \
    --build-arg DISTRIB=${OS} --build-arg RELEASE=${DIST} \
    --build-arg NGINX_VERSION=${NGINX_VERSION} --build-arg NGINX_DEB_RELEASE=${NGINX_DEB_RELEASE} .

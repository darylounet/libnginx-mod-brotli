#!/bin/bash -e

# Script run in docker for building libnginx-mod-brotli for Debian / Ubuntu
#
# Usage :
#
#   docker run --rm -v `pwd`:/build debian:bullseye /build/build.sh
#
# Or Ubuntu :
#
#   docker run --rm -v `pwd`:/build ubuntu:jammy /build/build.sh
#
# Then deb files can be found under debs/
#
# Latest ngx_brotli version : https://github.com/google/ngx_brotli
#
# Latest nginx version : https://nginx.org/en/download.html
# Or :
# curl -s https://nginx.org/packages/debian/pool/nginx/n/nginx/ |grep '"nginx_' | sed -n "s/^.*\">nginx_\(.*\)\~.*$/\1/p" |sort -Vr |head -1| cut -d'-' -f1

export DEBIAN_FRONTEND="noninteractive"
export DEB_BUILD_OPTIONS="parallel=$nproc"
export TZ=Europe/Paris

source /etc/os-release
# ID may debian or ubuntu
OS="${ID}"
# VERSION_CODENAME may bullseye or jammy or else
DIST="${VERSION_CODENAME}"

SELF_DIR="$(dirname "$(realpath "${0}")")"

apt-get update
apt-get --no-install-recommends --no-install-suggests -y install \
    git wget ca-certificates curl openssl gnupg2 apt-transport-https \
    unzip make libpcre3-dev zlib1g-dev build-essential devscripts \
    debhelper quilt lsb-release libssl-dev lintian uuid-dev

if [ -z "${NGINX_VERSION}" ]; then
    NGINX_DEB_VERSION="$(curl -s https://nginx.org/packages/debian/pool/nginx/n/nginx/ | grep '"nginx_' | sed -n "s/^.*\">nginx_\(.*\)\~.*$/\1/p" | sort -Vr | head -1)"
    NGINX_VERSION="$(echo ${NGINX_DEB_VERSION} | cut -d'-' -f1)"
    NGINX_DEB_RELEASE="$(echo ${NGINX_DEB_VERSION} | cut -d'-' -f2)"
else
    NGINX_VERSION="1.18.0"
fi
NGINX_DEB_RELEASE="${NGINX_DEB_RELEASE:-1}"
BROTLI_VERSION="${BROTLI_VERSION:-1.0.9}"

cd /root

git clone --depth 1 --recurse-submodules --shallow-submodules https://github.com/google/ngx_brotli.git
wget -qO - "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" | tar zxvf -

cp -rfv "${SELF_DIR}/debian" "nginx-${NGINX_VERSION}/debian"

sed -i "s/bullseye; urgency/${DIST}; urgency/g" "nginx-${NGINX_VERSION}/debian/changelog"
sed -i "s/~bullseye)/~${DIST})/g" "nginx-${NGINX_VERSION}/debian/changelog"
sed -i "s/{NGINX_VERSION}/${NGINX_VERSION}-${NGINX_DEB_RELEASE}~${DIST}/g" "nginx-${NGINX_VERSION}/debian/control"

cd "nginx-${NGINX_VERSION}" && dpkg-buildpackage

mkdir /src && mv -fv /root/libnginx-mod-brotli* /src/ && cp -fv "/root/nginx-${NGINX_VERSION}/debian/changelog" /src/
dpkg -c /src/libnginx-mod-brotli_*.deb

curl -sL https://nginx.org/keys/nginx_signing.key | apt-key add -
echo "deb https://nginx.org/packages/${OS}/ ${DIST} nginx" >/etc/apt/sources.list.d/nginx.list

apt-get update && apt-get -V --no-install-recommends --no-install-suggests -y install nginx="${NGINX_VERSION}-${NGINX_DEB_RELEASE}~${DIST}"

dpkg -i /src/libnginx-mod-brotli_*.deb &&
    sed -i '1iload_module modules/ngx_http_brotli_filter_module.so;' /etc/nginx/nginx.conf &&
    sed -i '1 abrotli on;' /etc/nginx/conf.d/default.conf &&
    nginx -t && /etc/init.d/nginx start && echo "Testing NGiNX headers for Brotli presence : " &&
    curl -s -I -H 'Accept-Encoding: br,gzip,deflate' http://localhost/ | grep 'Content-Encoding: br'

dpkg -r libnginx-mod-brotli
dpkg -P libnginx-mod-brotli

mkdir -p "${SELF_DIR}/debs/"
mv -fv /src/libnginx-mod-brotli_*.deb "${SELF_DIR}/debs/"

#!/bin/bash

NGINX_PACKAGES_URL=https://nginx.org/packages/mainline

BROTLI_VERSION="1.2.1"
NGINX_DEB_VERSION=`curl -s https://nginx.org/packages/mainline/debian/pool/nginx/n/nginx/ |grep '"nginx_' | sed -n "s/^.*\">nginx_\(.*\)\~.*$/\1/p" |sort -Vr |head -1`

# Check that the distributions built by the workflow are the ones nginx.org
# publishes for this nginx version, before anything is committed or tagged.
WORKFLOW=.github/workflows/github-actions.yml
NGINX_OSES="debian ubuntu"

# os/dist pairs of the workflow build matrix (each one appears once per runner)
WORKFLOW_DISTS=`awk '
    /^[[:space:]]*- / { os = dist = "" }
    { sub(/^[[:space:]]*- /, "") }
    /^[[:space:]]*os:/ { os = $2 }
    /^[[:space:]]*dist:/ { dist = $2 }
    os != "" && dist != "" { print os "/" dist; os = dist = "" }
' ${WORKFLOW} |LC_ALL=C sort -u`
if [ -z "${WORKFLOW_DISTS}" ]; then
    echo "Error: no os/dist pair found in ${WORKFLOW}." >&2
    exit 1
fi

# os/dist pairs having a binary package of this exact nginx version on nginx.org
NGINX_DISTS=`for os in ${NGINX_OSES}; do
    curl -sf ${NGINX_PACKAGES_URL}/${os}/pool/nginx/n/nginx/ |grep '"nginx_' \
        |sed -n "s/^.*\">nginx_\(.*\)\~\(.*\)_[a-z0-9]*\.deb<.*$/\1 \2/p" \
        |awk -v os=${os} -v version=${NGINX_DEB_VERSION} '$1 == version { print os "/" $2 }'
done |LC_ALL=C sort -u`
for os in ${NGINX_OSES}; do
    if ! grep -q "^${os}/" <<< "${NGINX_DISTS}"; then
        echo "Error: no ${os} package of nginx '${NGINX_DEB_VERSION}' found on nginx.org (download failure, or version not published yet)." >&2
        exit 1
    fi
done

REMOVED_DISTS=`LC_ALL=C comm -23 <(echo "${WORKFLOW_DISTS}") <(echo "${NGINX_DISTS}")`
ADDED_DISTS=`LC_ALL=C comm -13 <(echo "${WORKFLOW_DISTS}") <(echo "${NGINX_DISTS}")`
if [ -n "${REMOVED_DISTS}" ] || [ -n "${ADDED_DISTS}" ]; then
    echo "Error: distributions in ${WORKFLOW} do not match nginx.org packages for nginx ${NGINX_DEB_VERSION}." >&2
    if [ -n "${REMOVED_DISTS}" ]; then
        echo "Removed by nginx.org (to remove from the build matrix) :" >&2
        echo "${REMOVED_DISTS}" |sed 's/^/  - /' >&2
    fi
    if [ -n "${ADDED_DISTS}" ]; then
        echo "Added by nginx.org (to add to the build matrix) :" >&2
        echo "${ADDED_DISTS}" |sed 's/^/  - /' >&2
    fi
    echo "Update ${WORKFLOW}, then run this script again (if this version is still being published, retry later)." >&2
    exit 1
fi

docker build --pull -t deb-dch -f Dockerfile-deb-dch .
docker run -it -v $PWD:/local -e HOME=/local deb-dch bash -c "cd /local && \
    dch -M -v ${BROTLI_VERSION}+nginx-${NGINX_DEB_VERSION}~bullseye --distribution 'bullseye' 'Updated upstream.'"

git add debian/changelog
git commit -m "Updated upstream."
git tag "brotli-${BROTLI_VERSION}/nginx-${NGINX_DEB_VERSION}"
git push origin --tags
#git push origin "brotli-${BROTLI_VERSION}/nginx-${NGINX_DEB_VERSION}"

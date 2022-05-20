#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    build-upload-kpxe.sh USER HOST TFTP_DIR HTTP_DIR
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 4 ]; then
    usage
    exit 1
fi

USER=$1
HOST=$2
TFTP_DIR=$3
HTTP_DIR=$4

if [ ! -d ./ipxe ];then
  git clone git://git.ipxe.org/ipxe.git
fi

cat >boot.ipxe <<EOF
#!ipxe

dhcp
isset \${next-server} || set next-server ${HOST}
chain http://\${next-server}/menu.ipxe
EOF

pushd ./ipxe/src
make bin/undionly.kpxe EMBED=../../boot.ipxe
popd

scp ./ipxe/src/bin/undionly.kpxe $USER@$HOST:$TFTP_DIR
scp menu.ipxe $USER@$HOST:$HTTP_DIR


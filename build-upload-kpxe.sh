#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    build-upload-kpxe.sh SSH_CONFIG TFTP_DIR HTTP_DIR
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 3 ]; then
    usage
    exit 1
fi

SSH_CONFIG=$1
TFTP_DIR=$2
HTTP_DIR=$3

if [ ! -d ./ipxe ];then
  git clone git://git.ipxe.org/ipxe.git
fi

pushd ./ipxe/src
make bin/undionly.kpxe EMBED=../../boot.ipxe
popd

scp ./ipxe/src/bin/undionly.kpxe $SSH_CONFIG:$TFTP_DIR
scp menu.ipxe $SSH_CONFIG:$HTTP_DIR


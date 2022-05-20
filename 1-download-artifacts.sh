#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    download-artifacts.sh VERSION
HELP
}

exit_err() {
    echo >&2 "${1}"
    exit 1
}

if [ $# -lt 1 ]; then
    usage
    exit 1
fi

VERSION=$1
base_url=https://releases.rancher.com/harvester
artifact_suffixs=(
"amd64.iso"
"initrd-amd64"
"vmlinuz-amd64"
"rootfs-amd64.squashfs"
)
mkdir -p artifacts
pushd artifacts
mkdir -p $VERSION
for ((i = 1; i <= ${#artifact_suffixs[@]}; i++)); do
  artifact_suffix=${artifact_suffixs[$i-1]}
  artifact_local_name=${VERSION}/harvester-${artifact_suffix}
  artifact_remote_url=${base_url}/${VERSION}/harvester-${VERSION}-${artifact_suffix}
  if [[ ! -f "${artifact_local_name}" ]];then
  	wget -O ${artifact_local_name} ${artifact_remote_url}
  fi
done
popd

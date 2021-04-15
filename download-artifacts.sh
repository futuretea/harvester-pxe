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
base_url=https://releases.rancher.com/harvester/$VERSION
artifact_names=(
"harvester-amd64.iso"
"harvester-initrd-amd64"
"harvester-vmlinuz-amd64"
)
mkdir -p artifacts
pushd artifacts
mkdir $VERSION
for ((i = 1; i <= ${#artifact_names[@]}; i++)); do
  artifact_name=${artifact_names[$i-1]}
  wget -O $VERSION/${artifact_name} ${base_url}/${artifact_name}
done
popd

#!/usr/bin/env bash
[[ -n $DEBUG ]] && set -x
set -eou pipefail

usage() {
    cat <<HELP
USAGE:
    create-menu-ipxe.sh BASE_URL FIRST_NODE_MAC HARVESTER_VERSION
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

BASE_URL=$1
FIRST_NODE_MAC=$2
HARVESTER_VERSION=$3

cat >menu.ipxe <<EOF
#!ipxe

set menu-timeout 5000
iseq \${net0/mac} $FIRST_NODE_MAC && set menu-default create || set menu-default join
set base-url $BASE_URL
set harvester-version $HARVESTER_VERSION

:start
  menu Harvester Boot Menu --\${mac}--\${ip}
  
  item --gap --             -------------------------------- Harvester ---------------------------
  item create				Create a new cluster
  item join				Join an existing cluster
  item --gap --             -------------------------------- Advanced -----------------------------
  item --key l local            [L] Boot from local drive
  item --key s shell 		[S] Drop to iPXE Shell
  item --key r reboot		[R] Reboot the Computer

  choose --timeout \${menu-timeout} --default \${menu-default} selected
  goto harvester

:harvester
  kernel \${base-url}/artifacts/\${harvester-version}/harvester-vmlinuz-amd64 k3os.mode=install k3os.debug console=tty1 harvester.install.automatic=true harvester.install.iso_url=\${base-url}/artifacts/\${harvester-version}/harvester-amd64.iso harvester.install.config_url=\${base-url}/configs/\${selected}.yaml 
  initrd \${base-url}/artifacts/\${harvester-version}/harvester-initrd-amd64
  boot

:local
  sanboot --no-describe --drive 0x80

:shell
  echo Type 'exit' to go back to the menu.
  shell
  goto start

:reboot
  reboot

:exit
  exit
EOF

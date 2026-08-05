#!/usr/bin/env bash

USERNAME=$(whoami)

sudo usermod -aG docker "$USERNAME"

echo "Group result: $(grep docker /etc/group)"

if id -nG "$USERNAME" | tr ' ' '\n' | grep -qx docker; then
    echo "The 'docker' group is already active in this session."
    exit 0
fi

cat <<EOF

The 'docker' group is NOT active in the current session yet.
Supplementary groups are resolved at login time, so the running shell,
desktop session and any already-running terminals keep the old group set.

  * Temporary : run 'newgrp docker' to start a subshell with the new group.
  * Permanent : log out and log back in (or reboot).

Verify with: 'id -nG' or 'docker run --rm hello-world'
EOF

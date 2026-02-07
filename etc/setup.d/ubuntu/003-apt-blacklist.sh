#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo "Please run as root" 1>&2
    exit 1
fi

# Blacklist packages for specific Ubuntu versions using APT pinning
. /etc/os-release

if [[ "$ID" == "ubuntu" && "$VERSION_ID" == "24.04" ]]; then
    # Prevent fuse/libfuse2 installation (causes Gnome Desktop issues on 24.04)
    cat > /etc/apt/preferences.d/blacklist-fuse <<'EOF'
Package: fuse libfuse2
Pin: release *
Pin-Priority: -1
EOF
    echo "Blacklisted fuse/libfuse2 via APT preferences on Ubuntu 24.04" 1>&2
fi

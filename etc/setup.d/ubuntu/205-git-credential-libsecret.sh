#!/usr/bin/env bash

if [[ -z $OPM_HOME ]]; then
    echo "Not defined OPM_HOME variable." 1>&2
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo "Not found git executable" 1>&2
    exit 1
fi

if ! command -v gcc &> /dev/null; then
    echo "Not found gcc executable" 1>&2
    exit 1
fi

if ! command -v pkg-config &> /dev/null; then
    echo "Not found pkg-config executable" 1>&2
    exit 1
fi

SRC=/usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret.c
DEST=$(opm-home)/var/bin/git-credential-libsecret

if [[ -x "$DEST" ]]; then
    echo "File '$DEST' already exists"
    exit 0
fi

if [[ ! -f "$SRC" ]]; then
    echo "Not found '$SRC' file" 1>&2
    exit 1
fi

if ! pkg-config --cflags libsecret-1 &> /dev/null; then
    echo "Not found 'libsecret-1' library" 1>&2
    exit 1
fi

if ! pkg-config --cflags glib-2.0 &> /dev/null; then
    echo "Not found 'glib-2.0' library" 1>&2
    exit 1
fi

read -ra CFLAGS < <(pkg-config --cflags libsecret-1 glib-2.0)
read -ra LIBS < <(pkg-config --libs libsecret-1 glib-2.0)
gcc -o "$DEST" -O2 -Wall "$SRC" "${CFLAGS[@]}" "${LIBS[@]}"

if [[ ! -x "$DEST" ]]; then
    echo "Not found '$DEST' executable" 1>&2
    exit 1
fi

git config --global credential.helper "$DEST"

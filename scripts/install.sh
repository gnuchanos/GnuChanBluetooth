#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PREFIX=${PREFIX:-"${HOME:?HOME must be set}/.local"}
DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
BIN_DIR=$PREFIX/bin
LIB_DIR=$PREFIX/lib/gnuchan-bluetooth
PACKAGE_DIR=$LIB_DIR/gnuchan_bluetooth
APP_DIR=$DATA_HOME/applications

case "$PREFIX" in
    ""|"/")
        printf '%s\n' "Refusing unsafe PREFIX: $PREFIX" >&2
        exit 1
        ;;
esac

mkdir -p "$BIN_DIR" "$PACKAGE_DIR" "$APP_DIR"
cp -R "$SCRIPT_DIR/gnuchan_bluetooth/." "$PACKAGE_DIR/"
cp "$SCRIPT_DIR/bin/gnuchan-bluetooth" "$BIN_DIR/gnuchan-bluetooth"
chmod 755 "$BIN_DIR/gnuchan-bluetooth"

# Desktop entry Exec uses a quoted absolute path; escape desktop-entry syntax.
python3 - "$SCRIPT_DIR/share/applications/gnuchan-bluetooth.desktop" \
    "$APP_DIR/gnuchan-bluetooth.desktop" "$BIN_DIR/gnuchan-bluetooth" <<'PY'
from pathlib import Path
import sys

source, destination, executable = map(Path, sys.argv[1:])
entry = source.read_text(encoding="utf-8")
escaped = str(executable).replace("\\", "\\\\").replace('"', '\\"')
escaped = escaped.replace("`", "\\`").replace("$", "\\$").replace("%", "%%")
entry = entry.replace("Exec=gnuchan-bluetooth", f'Exec="{escaped}"')
entry = entry.replace("TryExec=gnuchan-bluetooth", f'TryExec="{escaped}"')
destination.write_text(entry, encoding="utf-8")
PY

printf 'Installed GnuChanBluetooth to %s\n' "$PREFIX"

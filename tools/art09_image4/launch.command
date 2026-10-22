#!/bin/zsh
set -eu
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
GODOT="${KAZE_GODOT:-/Applications/Godot.app/Contents/MacOS/Godot}"
mkdir -p "$ROOT/build/art09_image4"
exec "$GODOT" --path "$ROOT" --log-file "$ROOT/build/art09_image4/demo.log" --rendering-method gl_compatibility res://tools/art09_image4/demo.tscn -- --test

#!/bin/zsh
set -eu
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
GODOT="${KAZE_GODOT:-/Applications/Godot.app/Contents/MacOS/Godot}"
mkdir -p "$ROOT/build"
# Existing PR78/TR08 candidate footage only; Image4 ninja animation is pending.
exec "$GODOT" --log-file "$ROOT/build/alpha07-animation-demo.log" --path "$ROOT" res://tools/cin_tools_01/demo.tscn -- --test

#!/bin/zsh
ART05_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ART05_GODOT="${ART05_GODOT:-/Applications/Godot.app/Contents/MacOS/Godot}"
exec "$ART05_GODOT" --path "$ART05_ROOT" --resolution 1280x720 res://tools/art05/testbed.tscn -- --test

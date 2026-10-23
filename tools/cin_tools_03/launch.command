#!/bin/zsh
set -eu
cd "${0:A:h}/../.."
exec /Applications/Godot.app/Contents/MacOS/Godot --path "$PWD" res://tools/cin_tools_03/studio.tscn -- --test

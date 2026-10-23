#!/bin/zsh
# Finder double-click or Terminal; this always opens the existing Studio scene.
set -eu
cd "${0:A:h}/../.."
studio_godot="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"
if [[ ! -x "$studio_godot" && -x "$HOME/Applications/Godot.app/Contents/MacOS/Godot" ]]; then
  studio_godot="$HOME/Applications/Godot.app/Contents/MacOS/Godot"
fi
if [[ ! -x "$studio_godot" ]]; then
  print -u2 'Godot was not found. Install Godot 4.6.1 in /Applications/Godot.app, or set GODOT_BIN to its executable.'
  exit 1
fi
studio_version="$("$studio_godot" --version)"
if [[ "$studio_version" != 4.6.1.* ]]; then
  print -u2 "Studio is tested on Godot 4.6.1; found $studio_version at $studio_godot. Set GODOT_BIN to Godot 4.6.1."
  exit 1
fi
studio_log="${TMPDIR:-/private/tmp}/cin-tools-03-studio-${UID}.log"
# Do not pass --test: Godot 4.6.1 macOS scans even user args for it
# and selects a headless event loop that draws but cannot receive native input.
studio_args=()
# Optional disposable QA directory; ordinary creator launches use user://cin_tools_03.
if [[ -n "${CIN_STUDIO_SAVE_DIR:-}" ]]; then
  studio_args+=("--studio-save-dir=$CIN_STUDIO_SAVE_DIR")
fi
print "Opening Cinematic Studio with $studio_version"
print "Log: $studio_log"
exec "$studio_godot" --path "$PWD" --log-file "$studio_log" "$@" res://tools/cin_tools_03/studio.tscn -- "${studio_args[@]}"

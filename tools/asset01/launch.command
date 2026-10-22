#!/bin/zsh
set -eu
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
STAGE="${1:-$ROOT/../asset01-staging}"
GODOT="${KAZE_GODOT:-/Applications/Godot.app/Contents/MacOS/Godot}"
if [[ ! -f "$STAGE/gallery.json" ]]; then
  print "Missing local intake. Read docs/asset01/README.md; supply the six original ZIPs and run stage/scan/finalize."
  exit 1
fi
mkdir -p "$ROOT/build/asset01"
exec "$GODOT" --path "$ROOT/tools/asset01/gallery" --rendering-method gl_compatibility --log-file "$ROOT/build/asset01/gallery.log" -- --stage="$STAGE"

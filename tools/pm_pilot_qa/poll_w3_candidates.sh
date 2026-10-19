#!/bin/bash
# Poll origin for Wave 3 candidate pushes. Prints "NEW <branch> <sha>" for the first change and exits 0.
# State file remembers the SHA already evaluated (or ignored) per branch so a second call waits for the NEXT push.
#   poll_w3_candidates.sh [state_file] [max_minutes] [interval_seconds]
STATE=${1:-/tmp/w3_poll_state.txt}; MAX=${2:-50}; EVERY=${3:-180}
BRANCHES="feature/tr08-fullscreen-embodied-cinematics art/art08-embodied-cinematic-animation feature/ld05-intentional-world-boundaries"
touch "$STATE"
end=$(( $(date +%s) + MAX*60 ))
while [ $(date +%s) -lt $end ]; do
  for b in $BRANCHES; do
    sha=$(gh api "repos/cappy2yappy/momentum-fractured/branches/$b" --jq .commit.sha 2>/dev/null)
    [ -z "$sha" ] && continue
    if ! grep -q "^$b $sha" "$STATE"; then
      grep -v "^$b " "$STATE" > "$STATE.tmp"; echo "$b $sha" >> "$STATE.tmp"; mv "$STATE.tmp" "$STATE"
      echo "NEW $b $sha"; exit 0
    fi
  done
  sleep "$EVERY"
done
echo "TIMEOUT no new candidate push in $MAX minutes"; exit 2

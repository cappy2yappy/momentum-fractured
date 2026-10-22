# Concurrent ASSET01 work — recoverable content snapshot

The asset owner was still working at the timestamp in snapshot.json. These files preserve its current dirty text only, based on the recorded HEAD. This is not its final published result or validation claim. No raw packs, extracted images or generated captures are included.

First fetch origin and check whether codex/asset01-controlled-pilots and a new draft PR have appeared. Prefer the owner's final published branch. If it has not, start a separate scratch branch at equivalent_published_base from snapshot.json (the local HEAD may have an unpublished equivalent commit hash), then copy files/ onto the checkout preserving paths. Review the per-file hashes, run the owner's checks and complete its draft handoff before integration. This audit did not overwrite or commit in the active owner's checkout.

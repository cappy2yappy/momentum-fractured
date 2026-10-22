# ASSET-01 adoption handoff

Owner: Lead Codex, isolated `codex/asset01-intake` worktree. Base PR78 `af184380fb690f2c19bac69960b7aacce50f9ff2`. This is an intake review, not a gameplay integration.

Done: six exact local archive pins; safe staging and reproduced file hashes; image/sequence/source inventory; publisher license evidence; six selectable native Godot galleries with atlas-region browsing and approved Kaze scale reference; 49 actual native captures kept local; 2,533 passing checks; baseline preservation proof and bounded-cache measurements.

Source: `tools/asset01/`; evidence, inventories and decisions: `docs/asset01/`. Originals and editable sources remain outside Git in the local `asset01-staging` directory. No third-party image, source-project binary or archive belongs in this PR. The runtime gallery reads that staging directory through an explicit argument and has no game autoload, physics, collision or save ownership.

Next owners: Art Mane selects IDs and approves style, scale, alpha boundaries, pivots and missing action cues. Level Masta verifies approved visual placements against unchanged colliders, approach/recovery space and room performance. Claude retains source/license provenance, obtains complete terms for the DarkCave pair, approves adoption sequence and commissions separate integration drafts. Creator markup/canon approval remains authoritative.

Risks: full-resolution RGBA payload is approximately 1.5 GiB; original timing/pivots are unknown; painted art may mismatch Kaze; combat and hazard states are incomplete; editor project fidelity and other platforms are untested. Mossy bundle asset redistribution is prohibited; do not publish the staged originals or local capture images. DarkCave permission evidence does not settle all conditions.

Verified locally: actual Godot 4.6.1 official; Apple M4 OpenGL captures; all 1,103 images decoded; six ZIPs and 1,106 extracted-file hashes reproduced; 49 native views, no missing source or GDScript errors. Gallery-only p95 timing is not a shipping-world benchmark. No merge or live-room acceptance is claimed.

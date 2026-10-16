# TR-05 — Transition implementation and polish: PM return

2026-10-16 · Transition Masta · **automatic passage/direction candidate ready; cinematic study ready for comparison, finished animation pending**.

[Draft PR39](https://github.com/cappy2yappy/momentum-fractured/pull/39) · branch `feature/alpha-0.6.1-tr05-pr37` · base PR37 `b950373efb5c4621d7da7e0be1506db048e3043a` · runtime `f168339a6fa6b02f16958ce250636dbe47d4a783`. The PR head includes final evidence/continuity commits after runtime. No merge or force push. Earlier PR33-only TR05 source61607f4 is preserved separately and superseded as the integration candidate.

## Delivered

- 39 ordinary left/right endpoints activate automatically, including Canal-left. Outward movement at the matching elevation is required; E cues are removed from these passages. Walk/sprint/stop/reverse are covered.
- R13↔R14 correctly uses side passages. Reciprocal headings face inward;64px inset arrivals and nearest existing support-top adjustment prevent wall/shelf overlap, including R9.
- Meaningful depth entrances, shrine/console actions, gated returns, stairs and exceptional wind-fold retain E and existing prerequisites.
- Cinematic staircase moves a visible approved Kaze proxy along an ascending/descending flight with brief close-up framing; smooth envelope restores normal lens/focus/offset. F6 or CLI reduced motion uses a still camera/pose and plain fade.
- Sampled directional crossing, inward rearm and arrival cooldown prevent stationary/held-E transition loops.0.65s discrete loader retained; no seamless-streaming claim.
- PR37 Bellroof geometry, blocked-save staging, character identity, physics, combat, progression, map graph and save format/default identity preserved. No new collision or route.

## Evidence and playtest

[Review/captures](../tr05/README.md) · [QA matrix](../tr05/QA_MATRIX.md) · [raw results](../tr05/evidence/source-results.json) · [coordination/ART05 missing frames](../tr05/COORDINATION.md).

25 source suites /1,607 passing assertions; baseline and PR37 preservation pass. Native Windows54 checks cover walking, double-tap sprint, stop/reverse, held E, both stair directions and reduced motion. Exported-resource proof and seven real Windows launcher boots are recorded in final evidence. Native captures are scripted Godot gameplay fixtures, not human campaign review. No physical-gamepad/native-macOS or sustained60FPS certification.

Primary demonstrations: `Play-Canal-Automatic.cmd` (A), `Play-Door-East.cmd` (D then stop/reverse A), `Play-Stair-Cinematic.cmd` (E). Reverse/reduced/fresh launchers are included. Every demo resets its own isolated supplied fixture; Fresh persists separately. Opening the EXE directly uses the normal historical save identity.

Hosted download and exact final package hashes are appended after validation; this avoids claiming a local archive is durably delivered. Hosted rebuilds are not byte-identical to the native-session EXE.

## Limits and next owner

Stair poses are approved ART04 held keys translated through space, explicitly labelled MOVING STAIR STUDY / FULL GAIT PENDING. Actual character movement is visible, but full limb/gait animation is not complete. Existing run is reused; distinct walk/outward/arrival frames remain ART05 requirements. Do not hold stable automatic passages for those missing cycles. Camera and transition feel require creator review.

Level coordination posted on PR37; Art requirements on PR30. Build Shogun receives the pinned PR37-based source for Mac EOD packaging/native validation; Windows proof does not establish Mac acceptance. Other PR37 purpose/route acceptance conditions remain unchanged. Creator should test all three demos, stop/reverse at R13 and Canal exits, try F6 and pause during stairs, and report feel/readability. Do not merge.

## Final verified delivery

[Download Windows demonstrations](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38933528377/artifacts/12058994075) - [Successful hosted build](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38933528377). GitHub sign-in may be required; expires2026-11-15. Extract the artifact, then extract its inner `Kaze-TR05-Windows-Demos.zip` and launch the named `.cmd` files.

Hosted artifact source f168339,51,784,078 bytes, reported digest042fa63dbea7a0e6011d081e5fe017be53ede3a9356de47d6819ab160171cc78. Source-transition/baseline/export/package/CRC checks and upload succeeded on the hosted Linux builder; hosted Windows rendering is not claimed.

Final native-session exported resources pass54/54 checks, and all7 actual EXE launchers pass from a spaced directory. This proof uses the actual compiled Windows resource pack, not a source-only fixture. Native ZIP has 51918291 bytes, SHA256 `1adda063d7e5cefb479f9c5a29fa08956e3bc55e1acb42581a6cfbd66628b0f4`; EXE SHA256 `44c28d78d5f2dd6705bbb3331956e9b1f038cb1dc7436f83ccb22bcc6112e854`. See [manifest](../tr05/evidence/windows-manifest.json). The hosted rebuild is separately identified and not byte-identical to the native-session ZIP.

All source, JPEG captures, raw QA and continuity are committed on PR39; runtime and presentation bytes remain f168339. Final PR HEAD is the documentation/evidence publication commit, available in the PR. Creator review and Mac-native packaging remain next; no merge.

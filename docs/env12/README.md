# ENV-12 — world cohesion review

Status: isolated native studies and art-production specifications. Creator art and geometry decisions are pending. No production integration is enabled.

Branch: `art/env12-world-cohesion`. Exact base: ART-11 PR99 `250afde28517fcc05984038ac9e1487114729b78`. Writes are confined to `docs/env12/`, `tools/env12/`, and `tests/env12/`. The existing ART-11 checkout, host, source stage and review captures are read-only references.

Start with [room matrix](ROOM_MATRIX.md), [material and motion language](VISUAL_LANGUAGE.md), [four study cards](STUDIES.md), [artist specifications](ART_PRODUCTION.md), [rights](RIGHTS_AND_PROVENANCE.md), and [executed QA](QA.md). [Authority and pending decisions](AUTHORITY.md) separates observed source behavior from proposed design.

## Native review

Prerequisites: Godot **4.6.1**, Python 3, the creator's already staged six packs, and the exact ART-11 derivative cache. No downloader, external art service, or image generation is used. Source and cache hash mismatches fail closed. ART-11's read-only stage verifier is reused.

```powershell
python tools/env12/launch.py prepare --godot <Godot-4.6.1-console.exe> --stage <art11-staging> --cache <art11-cache>
python tools/env12/launch.py capture --all --godot <Godot-4.6.1-console.exe> --stage <art11-staging> --cache <art11-cache>
python tools/env12/launch.py review --room 14 --godot <Godot-4.6.1-console.exe> --stage <art11-staging> --cache <art11-cache>
python tests/env12/verify.py
```

`prepare` copies only hash-pinned runtime files into `tools/env12/.private/host/`, then imports that copy. Each run gets a separate disposable APPDATA/LOCALAPPDATA profile below `.private/profiles/`; the original creator profile is never read. The gallery freezes gameplay simulation for controlled art comparisons. It is not a playable prototype or traversal acceptance test.

Controls: **F4** art on/off, **F7** collision/reservation guides, **F8** reduced motion, **F9** cosmetic B preview, **1–4** individual art layers, **F5** overview/1x framing, **Esc** exit. Native controls/controllers/abilities are not reimplemented. Category C devices are absent.

Open [the local review index](../../tools/env12/review.html) after capture. All screenshot pixels and native logs remain under ignored `tools/env12/.private/`. Git contains only code, text specifications, hashes and numeric evidence. No raw packs, derivative images or screenshots are published.

## Review boundary

21 rooms / 29 links, inherited source copy, progression flags, controller/ability source, gate logic, saves, automatic Canal/stair systems and R18 PR47 artwork remain byte-identical to the pinned base. R13/R17 are not modified; LD-08's open-top direction and Level redlines supersede planning. G1/G2 is undecided. No connector or refuge-return geometry is added. The base is a review source, not a claim that every inherited proposal is approved. **Known base gap:** PR99 still contains legacy objective/Foundry Refuge wording and lacks the later approved opening. ENV12 retains the exact approved text in its handoff, hides the old host HUD/messages, and leaves source untouched. Runtime approved-copy acceptance on a reconciled integration base remains pending; see AUTHORITY.md.

The R16 study reads the existing ART-11 renderer and assets. A separate capture shows the unmodified ART-11 reference; the ENV comparison applies stricter temporary masks in memory. No ART-11 resource, placement file, branch or source image is edited.

Stop point: creator selects/rejects material treatment and layer density; Level supplies accepted geometry/redlines; Story resolves placement/canon choices; Art Mane receives the missing-illustration packet. Gameplay, traversal, export and production integration remain separate owner tasks.

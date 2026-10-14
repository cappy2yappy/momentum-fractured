# Kaze Art Asset Registry

**Status:** creator has authorized storing reference images in this public repository; both ART-01-0061 reference images **PUBLISHED ON DOCUMENTATION BRANCH** at commit `7312c62068e8b964ce78848b85024b876af6efc3`. This does not establish stock-site redistribution rights.
**Library owner:** Project Management (PM-01)
**Repository:** https://github.com/cappy2yappy/momentum-fractured
**Purpose:** One verifiable home for creator-provided reference images, approved concepts, and production-ready art without reattaching images to each chat.

## Reference inventory

| ID | Intended Git path | Context / usage | Current state | Rights / provenance |
| --- | --- | --- | --- | --- |
| REF-CITY-001 | `docs/art/references/alpha061/city_silent_district_reference_01.png` | Creator-provided nighttime city image; City / Silent District visual direction | **PUBLISHED — VERIFIED GITHUB PATH** | Shared by creator in PM chat (2026-10-14); creator authorizes public repository storage; stock-site name/license and redistribution rights not independently verified |
| REF-VILLAGE-001 | `docs/art/references/alpha061/hidden_village_reference_01.png` | Creator-provided warm Japanese hidden village image; playable prologue visual direction | **PUBLISHED — VERIFIED GITHUB PATH** | Shared by creator in PM chat (2026-10-14); creator not necessarily copyright holder; source/license unknown |
| REF-RUINS-001 | `docs/art/references/alpha061/ruins_reference_01.png` | Optional later ruins concept reference | **NOT PROVIDED** | No original supplied |

Both PNG paths were retrieved from GitHub commit `7312c62` and their Git blob IDs confirmed. SHA-256 source values appear below. The GitHub connector did not return the full binary bytes, so independent byte-for-byte post-upload SHA-256 verification remains optional follow-up. REF-RUINS-001 is not supplied.

## Publishing and verification protocol

1. When a creator supplies visual references, retrieve the **actual original image bytes** from the authorized chat attachment or a creator-approved source; never substitute a visually similar image.
2. Keep original filenames and formats when possible. If changing extension, only after verifying true image encoding. Preserve an original copy byte-for-byte, without resizing, recoloring or embedding in a PDF.
3. Creator confirmed on 2026-10-14 that these images may be placed in the public Kaze repository. Record this authorization, but independently verify the originating stock-site license/redistribution conditions before publishing third-party originals when source information is available; if public redistribution is prohibited, use a private reference store or link instead.
4. Use filenames consistent with this registry (adjust extensions to actual file format). Upload each image on an isolated branch. Confirm the binary can be fetched as an image and its SHA-256 and dimensions match the source.
5. Update this table with **PUBLISHED — VERIFIED**, the exact commit permalink, format/dimensions, SHA-256, provenance (creator reference vs licensed source), permission status, attribution and intended use (inspiration only vs permitted to redistribute/use in-game).
6. Put finalized in-game assets under `assets/environment/`, not `docs/art/references/`, with separate provenance and QA. Art references are **not approved production assets**.
7. Assignment issuers must verify reference URLs exist **before** marking a reference-dependent task READY. If reference unavailable, issue a bounded preliminary audit task and flag visual sign-off as BLOCKED.

## Agent handoff / synchronization

In every art work order, include a **Reference Manifest** with reference ID, committed filename, GitHub URL and commit SHA; the agent must confirm each fetch. If the manifest marks an asset MISSING, continue only with evidence-backed technical audits and non-final preliminary ideas, never claim reference-based art approval.

For ART-01-0061, the Art Mane already retrieved its assignment and inspected the game. City and village source images are now available through the permanent GitHub links below. The Art Mane can fetch both and continue concept development without repeating its technical audit. Stock-site name/license have not been independently verified; use as concept references, not direct production textures.

## Rights and storage policy

A creator posting an image for visual inspiration does not establish that the image is owned by the creator or licensed for redistribution in a public code repository. Default unknown-rights images to a **private repository** or linked restricted location pending confirmation. Record license/credit when known. Do not build final game textures by directly incorporating third-party reference pixels without appropriate rights.

## Original image intake verified (2026-10-14)

- REF-CITY-001: original PM chat attachment `image(7).png`; PNG RGBA; 736 × 1314 pixels; SHA-256 `ae534f4cfba433dfeec2fa1c5310cd1498e190ad8fabd631a0ac4a64a4cbadab`.
- REF-VILLAGE-001: original PM chat attachment `image(8).png`; PNG RGBA; 736 × 1104 pixels; SHA-256 `f51e4ae44990f9db3cb89b8b502b3cd34f3c2a56fda6710794cf29c5516428cf`.
- The creator successfully uploaded the two PNGs using Git from macOS at `7312c62068e8b964ce78848b85024b876af6efc3`. GitHub verified both paths and file blob objects exist; complete byte-for-byte post-upload checksum comparison was not performed here.

## Published reference links (2026-10-14)

- REF-CITY-001: [city_silent_district_reference_01.png](https://github.com/cappy2yappy/momentum-fractured/blob/7312c62068e8b964ce78848b85024b876af6efc3/docs/art/references/alpha061/city_silent_district_reference_01.png) | Git blob `a52a726df1c0c02f8eca04ea577697fc3af3f05b` | concept reference only.
- REF-VILLAGE-001: [hidden_village_reference_01.png](https://github.com/cappy2yappy/momentum-fractured/blob/7312c62068e8b964ce78848b85024b876af6efc3/docs/art/references/alpha061/hidden_village_reference_01.png) | Git blob `a142a004fc318c9d248888704b3470dd8e2b7517` | concept reference only.

**Source commit:** https://github.com/cappy2yappy/momentum-fractured/commit/7312c62068e8b964ce78848b85024b876af6efc3

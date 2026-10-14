# Kaze Art Asset Registry

**Status:** registry established; original ART-01-0061 reference images **NOT YET PUBLISHED**. Never represent a planned filename as an uploaded image.
**Library owner:** Project Management (PM-01)
**Repository:** https://github.com/cappy2yappy/momentum-fractured
**Purpose:** One verifiable home for creator-provided reference images, approved concepts, and production-ready art without reattaching images to each chat.

## Reference inventory

| ID | Intended Git path | Context / usage | Current state | Rights / provenance |
| --- | --- | --- | --- | --- |
| REF-CITY-001 | `docs/art/references/alpha061/city_silent_district_reference_01.png` | Creator-provided nighttime city image; City / Silent District visual direction | **MISSING ORIGINAL BINARY** — do not fetch/recreate substitutes | Shared by creator in PM chat (2026-10-14); creator not necessarily copyright holder; source/license unknown |
| REF-VILLAGE-001 | `docs/art/references/alpha061/hidden_village_reference_01.png` | Creator-provided warm Japanese hidden village image; playable prologue visual direction | **MISSING ORIGINAL BINARY** — do not fetch/recreate substitutes | Shared by creator in PM chat (2026-10-14); creator not necessarily copyright holder; source/license unknown |
| REF-RUINS-001 | `docs/art/references/alpha061/ruins_reference_01.png` | Optional later ruins concept reference | **NOT PROVIDED** | No original supplied |

This registry intentionally does **not** include image URLs or checksums until original files have been uploaded and independently verified from GitHub. **Do not make an Art Agent assume these planned paths exist.**

## Publishing and verification protocol

1. When a creator supplies visual references, retrieve the **actual original image bytes** from the authorized chat attachment or a creator-approved source; never substitute a visually similar image.
2. Keep original filenames and formats when possible. If changing extension, only after verifying true image encoding. Preserve an original copy byte-for-byte, without resizing, recoloring or embedding in a PDF.
3. Because the repository is public, ask the creator to confirm that publishing each possibly copyrighted third-party reference is permitted. If not, use a private asset repository or creator-controlled private storage, and publish only a safe pointer/description here.
4. Use filenames consistent with this registry (adjust extensions to actual file format). Upload each image on an isolated branch. Confirm the binary can be fetched as an image and its SHA-256 and dimensions match the source.
5. Update this table with **PUBLISHED — VERIFIED**, the exact commit permalink, format/dimensions, SHA-256, provenance (creator reference vs licensed source), permission status, attribution and intended use (inspiration only vs permitted to redistribute/use in-game).
6. Put finalized in-game assets under `assets/environment/`, not `docs/art/references/`, with separate provenance and QA. Art references are **not approved production assets**.
7. Assignment issuers must verify reference URLs exist **before** marking a reference-dependent task READY. If reference unavailable, issue a bounded preliminary audit task and flag visual sign-off as BLOCKED.

## Agent handoff / synchronization

In every art work order, include a **Reference Manifest** with reference ID, committed filename, GitHub URL and commit SHA; the agent must confirm each fetch. If the manifest marks an asset MISSING, continue only with evidence-backed technical audits and non-final preliminary ideas, never claim reference-based art approval.

For ART-01-0061, the Art Mane already retrieved its assignment and inspected the game. The exact original city and village image transfers remain blocked until source bytes and publication permission are available. The agent should not claim it saw them, and need not restart its completed technical audit.

## Rights and storage policy

A creator posting an image for visual inspiration does not establish that the image is owned by the creator or licensed for redistribution in a public code repository. Default unknown-rights images to a **private repository** or linked restricted location pending confirmation. Record license/credit when known. Do not build final game textures by directly incorporating third-party reference pixels without appropriate rights.

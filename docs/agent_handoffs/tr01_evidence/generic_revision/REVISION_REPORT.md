# TR-01-0061 creator follow-up — generic entrance size

Creator request: “Entrance need to be a little bigger for the generic. The stairwell is a nice look.”

Generic housing increased from 64×84 to 80×108, inset 48×65 to 60×89, base 96×14 to 112×14 and E marker 12px to 16px. R17/R19 route plaques move up 18px to avoid overlap. Feet anchors, interaction range/input, connectivity, gates, collision, movement and saves remain unchanged. The pilot stairwell, masonry and effect functions compare byte-identical against the previous submission.

Runtime revision: `75fd73b1bbe50745d08628c4b61a36c0c64a2976` on `feature/alpha-0.6.1-room-transition-prototype`, [draft PR #12](https://github.com/cappy2yappy/momentum-fractured/pull/12). No merge performed.

QA: preservation verifier passed; room_transition_prototype 109 PASS and integration_candidate 12 PASS, zero failures or script errors. Existing full QA evidence remains the initial-run record; the full combined runner was not repeated for this presentation-only change. New native before/after captures cover R0/R8/R17/R19 at 1280×720, zoom 1.0. Raw logs and exact commands are retained in this directory. Comparison images stack before above after.

Refreshed macOS universal candidate:

`/Users/tonysantiago/.codex/.chatgpt-projects/g-p-6aa9b0443c20819186909618bb6be970/work/tr01-alpha061/build/tr01/Kaze-TR01-Alpha061-GenericSized-macOS-Universal.zip`

Runtime source: `75fd73b1bbe50745d08628c4b61a36c0c64a2976`. ZIP SHA-256: `abd0b9b5c481115feb49aa7198c85dcdf102ad4642944419fccf6e49cb3b76ca`. ZIP CRC passes; native and headless boots exit 0 on Apple M4 using an isolated rooftop profile. Intel untested; Windows not exported. Unsigned and not notarized. No remote binary publication. The previous candidate ZIP remains available separately.

Unzip and use Play Rooftop.command / Play Canal.command or Play Fresh.command for isolated saves; Python 3 is required. To inspect generic entrances, use E to return from R14 to R13 or from R15 to R2, or start fresh and inspect Haven's east exit. Compare entrance scale beside Kaze at normal camera zoom. Reduced-motion launchers remain available.

READY FOR PM REVIEW — this implements the authorized modest generic-size adjustment and preserves the liked stairwell design.

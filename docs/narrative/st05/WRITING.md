# Interactable-object writing samples

Only the C entries below are exact approved strings. E entries are quotations from the inspected runtime, not new approval. Every N line is a review candidate. Object titles/prompts are also proposals. No text here grants permission to add UI or narration. Use the shared delivery rules in BEATS.md.

## Exact approved copy — preserve verbatim (C)
- Opening: **The refuge was attacked. I have to find the others.**
- First objective: **Search for survivors. Defeat the Market sentinel for Windstep.**
- Checkpoint name: **Foundry Rest Station**. Existing drawn form: **FOUNDRY REST STATION • E**. Actual room name remains **Storm Foundry**.

## Optional object cards (N)
| Beat / proposed title | Object description | Kaze reaction / state variant | Revisit behavior |
|---|---|---|---|
| B02 / Mended wrap | A narrow wrap, repaired along one edge. No name. | We mended wraps like this. I can't tell whose it was. | Reread on request; no automatic repeated speech |
| B03 / Hidden letter | A damp letter. The departure time has no date beside it. | Before dawn. But which dawn? | Available after existing collection; no second heal |
| B04 / Broken parapet | Bracing remains at the edge of the broken crossing. | The crossing is broken. I can still get across. | No change to bridge or collision |
| B05 / Routing panel | The Archive route is open. | These routes are opening again. I can search farther. | Only when `completed` is true |
| B06 / Still figure — clan variant | A still figure beneath worn cloth. A familiar kind of mending at its edge. | That mending… like ours. I can't tell who this was. | Optional separate prompt: **Lay the cloth straight**; afterward: **Rest here.** |
| B06 / Still figure — affiliation withheld | A still figure beneath worn cloth. Nothing here gives a name. | I don't know your name. I'm sorry. | Same optional memorial; no affiliation inferred |
| B07 / Carrying frame | An empty carrying frame rests beside an unfastened bundle. | Was this left before they set out—or after? | No new inventory item |
| B08 / Tended lamp | The lamp has been cared for. There is no name beside it. | Someone still tends these lamps. I hope I find them. | No “still warm,” fresh footprints or timed deduction |
| B09 / Pump overlook | The machinery feeds the canal and conservatory. | Guard present: **A guard at the pumps. What are they protecting?** Guard cleared: **This pump route was guarded. Why?** | Query actual encounter state on each examine |
| B10 / Rest station | A place to pause inside the foundry. | A place to rest. Then I keep looking. | Only after current save/heal announcement; no extra healing |
| B11 / Return panel | The Undercroft return is open. | The return is open. I still have to find the others. | Only after `skyworks_restored` |
| B12 / Mooring return | The return to the quay is open. | Not all rooms visited: **Back to the quay. There are still places I haven't searched.** All visited: **Back to the quay. I still haven't found the others.** | Only after real switch/region eligibility; check actual visited set |

The new B03 description proposes undated physical presentation; it does not silently amend the original letter's stored text. If this treatment is rejected, keep the existing announcement alone. B02/B06 recognition proposes only shared material culture, not a remembered individual, lesson, family keepsake or canonical crest. The two B06 variants are alternatives; never display both.

## Existing record text to preserve (E)
- R2: “Hidden letter: the next convoy leaves before dawn. Health restored.”
- R14: “Bellkeepers marked this roof as the convoy's quiet route.”
- R15: “Inspection ledger: the lower pumps ran dry before the evacuation.”
- R16: “Roots hold the old shrine together. Someone still tends its lamps.”
- R17: “Counterweights once carried workers above the storm line.”
- R18: “The pumps feed both the canal and the conservatory.”
- R19: “Service crews isolated the coils before the Keeper arrived.”
- R20: “The relay garden links the roof watch to the maintenance crews.”

No new authored message names a survivor, dates a convoy, blames Kaze, identifies a traitor, promises a reunion or reveals who ordered the guards. The post-attack context and uncertainty carry the emotion; avoid explaining later plot through item text.

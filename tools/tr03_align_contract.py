"""Align review-board narrative to the independently recovered Lane B checkpoint."""
from pathlib import Path
import json
p=Path(__file__).resolve().parents[1]/'docs/art/tr03'
c=json.loads((p/'transition_art_contract.json').read_text())
(p/'ANIMATION_CONTRACT.json').write_text(json.dumps(c,indent=2)+'\n')
f=p/'ANIMATION_BRIEF.md'
t=f.read_text(encoding='utf-8')
t=t.replace('Eight new frames: side plant → head turn → shoulders → hips → rear 3/4 → two depth steps → occluded hold','Four turn keys + three entering keys, three leaving keys + two return-to-profile keys; see SPRITE_PACK_SPEC.md')
t=t.replace('Eight frames each, independently authored','Six frames each, independently authored').replace('Eight new upright heel-to-toe walk frames','Six new upright heel-to-toe walk frames')
a=t.index('New strips:'); b=t.index('Right is the reference',a)
t=t[:a]+'''Use [SPRITE_PACK_SPEC.md](SPRITE_PACK_SPEC.md) and [transition_art_contract.json](transition_art_contract.json) from recovered checkpoint 0d96f939641c0815b16813c2382b607a5eb34f28 as the single proposed production contract. New cells320×724, ground pivot(160,600), target upright occupied height320px, initial scale0.303125. Centered Sprite2D offset(0,−238). Keep at least12px alpha margin; never scale/recenter each frame. New variable clip counts require a render-only adapter; the current controller assumes eight hframes. No production strip/source is delivered here. Aseprite sources, tag names, frames and export dimensions follow that specification. Existing strips keep their exact original pivots/scales.

'''+t[b:]
a=t.index('All times are proposed');b=t.index('For depth/stairs',a)
t=t[:a]+'''All beats fit the existing39 ticks /0.65s; no added preparation delay. They follow loader cues rather than extending nominal clip durations end to end. Level owns authoritative swap timing, eligibility, cooldown and restoration. Labels in STORYBOARDS.svg show action order, not additional waiting time.

| Mode | Source ticks0–18 | Cover/swap ticks18–21 | Arrival ticks21–38 / resume39 |
| --- | --- | --- | --- |
| depth_door | Planted profile→quarter-back→rear; two depth contacts toward inner marker | Near jamb occludes; follow existing room-swap event | Leave-depth front-quarter steps then return_profile; show actual destination heading |
| stair_up | Knee leads, upper foot contacts, trailing toe pushes; local step fragment only | Landing cheek/return wall hides discrete swap | Upper landing settling contact; restore authoritative position |
| stair_down | Toe reaches lower tread then knee absorbs; independent art | Landing cheek hides swap | Lower landing settling contact; no reverse ascending playback |
| horizontal_walk | Six-frame10FPS upright walk, actual approach displacement | Existing safe carry policy | Preserve phase; never call a slowed run a walk |
| horizontal_run | Reuse eight-frame12.5FPS ninja run and current phase | Existing safe carry policy | Continue reciprocal direction without forced braking or acceleration |
| wind_fold | Existing exceptional treatment | Existing special swap | Preserve original/plain/reduced choices |

Placeholder gate: run is available; depth/stair staging may use visibly labeled planted poses and fade, but must not be reported as finished turning/stair animation. Missing walk art retains the existing comparison rather than relabeling run. No lateral sprite shrinking as a substitute for turning.

'''+t[b:]
t=t.replace('Stair staging may be longer than its final load, so PM should review added interaction latency before production.','Local stair fragments fit the loader envelope; a complete staircase performance is a separate scope decision.')
t=t.replace('complete32 minimum new frames (8 turn +8 up +8 down +8 walk); up to64 if separately drawn left variants are required','complete30 minimum new master frames (6 walk +4 turn +3 enter +3 leave +2 profile return +6 up +6 down); extra authored direction variants may increase this')
t=t.replace('dedicated presentation Sprite2D','dedicated presentation Sprite2D')
f.write_text(t,encoding='utf-8')
f=p/'STORYBOARDS.svg';t=f.read_text().replace('DEPTH DOOR / 500ms preparation','DEPTH DOOR / source cues within 0.65s').replace('Plant /0ms','Plant / source').replace('Head + shoulders /125ms','Head + shoulders / source').replace('Rear 3/4 /250ms','Rear 3/4 / source').replace('Depth step /375ms','Depth step / cover').replace('Occlude /500ms','Occlude / swap').replace('Load remains 0.65s after staging','Full presentation stays inside existing 0.65s'); f.write_text(t)
f=p/'README.md';t=f.read_text().replace('Rebuild boards with `python tools/tr03_art_specs.py`.','Rebuild boards with `python tools/tr03_art_specs.py` followed by `python tools/tr03_align_contract.py`. The recovered `SPRITE_PACK_SPEC.md` and `transition_art_contract.json` own proposed frame/pivot/timing values; this kit adds technical previews.');f.write_text(t)
print('Aligned visual kit to recovered 30-frame / pivot600 / 39-tick contract.')

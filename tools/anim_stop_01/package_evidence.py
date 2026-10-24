"""Package real captured frame timing and an HTML contact sheet, without repainting images."""
from pathlib import Path
import json, subprocess, shutil, hashlib, html
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'docs/anim_stop_01/private-evidence'
d=json.loads((OUT/'timing.json').read_text())
samples=d['samples']
lines=['ffconcat version 1.0']
for i,s in enumerate(samples):
    lines.append("file '"+s['file']+"'")
    end=samples[i+1]['wall'] if i+1<len(samples) else d['wall_seconds']
    lines.append('duration '+str(max(.001,end-s['wall'])))
lines.append("file '"+samples[-1]['file']+"'")
(OUT/'native.ffconcat').write_text('\n'.join(lines)+'\n')
ffmpeg=shutil.which('ffmpeg')
assert ffmpeg, 'ffmpeg missing'
subprocess.run([ffmpeg,'-v','error','-y','-f','concat','-safe','0','-i','native.ffconcat','-vsync','vfr','-c:v','libx264','-pix_fmt','yuv420p','-crf','18','native-speed.mp4'],cwd=OUT,check=True)
times=[1.417,1.583,1.8,2.05,2.55,4.2]
cards=[]
for t in times:
    s=min(samples,key=lambda s:abs(s['timeline']-t))
    cards.append(f'<figure><img src="{s["file"]}"><figcaption>{s["timeline"]:.3f}s</figcaption></figure>')
doc='''<!doctype html><html lang="en"><meta charset="utf-8"><title>ANIM-STOP-01 review</title><style>body{background:#171923;color:#eee;font:17px system-ui;max-width:1400px;margin:32px auto}img,video{max-width:100%}.grid{display:grid;grid-template-columns:1fr 1fr;gap:12px}figure{margin:0}figcaption{padding:8px}a{color:#9be7d8}</style><h1>Stopping study — creator review</h1><p>Native Godot render. No generated or repainted artwork. Left: original Studio seed. Middle: portable motion keys with original rig scale. Right: separately calibrated 0.68 rig study; requires actor setup and is not a drop-in Studio clip.</p><video controls src="native-speed.mp4"></video><p>Real wall-clock intervals, 1.0×. Review cameras follow horizontal root travel. Gold dots mark actual opaque heel pixels; green dots mark actual forefoot pixels. They do not certify anatomy.</p><h2>Six-pose contact sheet</h2><div class="grid">'''+''.join(cards)+'''</div><h2>Aligned handoff overlays</h2><p>Cyan: intact sprint sprite at 1.417s. Magenta: rig at 1.583s. Same root. These different poses cannot establish anatomical equivalence.</p><div class="grid"><figure><img src="overlay_seed.png"><figcaption>Original scale mismatch</figcaption></figure><figure><img src="overlay_calibrated.png"><figcaption>Calibrated proposal: still lacks a matching handoff drawing</figcaption></figure></div><p><a href="../README.md">Audit, acceptance boundaries and missing-art specification</a></p></html>'''
(OUT/'review.html').write_text(doc,encoding='utf-8')
durations=[samples[i+1]['wall']-s['wall'] for i,s in enumerate(samples[:-1])]
report={k:v for k,v in d.items() if k!='samples'}
report.update({'samples':len(samples),'max_timeline_vs_wall_error_seconds':max(abs(s['timeline']-min(s['wall'],4.2)) for s in samples),'frame_intervals_seconds':{'min':min(durations),'max':max(durations)},'video_sha256':hashlib.sha256((OUT/'native-speed.mp4').read_bytes()).hexdigest(),'performance_limit':'Capture overhead and 30Hz sampling are not a 60fps gameplay benchmark.'})
(ROOT/'docs/anim_stop_01/capture_summary.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))

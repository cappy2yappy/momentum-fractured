#!/usr/bin/env python3
"""Enrich an ImageIO-scanned local manifest; emits metadata only, never assets."""
import argparse,collections,json,re,hashlib,struct
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('manifest',type=Path);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
d=json.loads(a.manifest.read_text());a.out.mkdir(parents=True,exist_ok=True)
summary=[]
for pack in d['packs']:
 entries={e['path']:e for e in pack['entries']}; groups=[]
 for seq in pack['sequences']:
  frames=[entries[n] for n in seq['frames']]
  if seq['kind']=='static_atlas_collection':
   for e in frames: groups.append(dict(id=pack['slug']+'/'+e['path'],name=e['path'],frames=[e['path']],frame_count=1,kind='static_atlas',dimensions=[[e['width'],e['height'],1]],rgba_memory_bytes=e['decoded_rgba_bytes'],timing='static; no animation metadata'))
  else:groups.append(seq)
 for seq in groups:
  frames=[entries[n] for n in seq['frames']];seq['byte_unique_frames']=len(set(e['sha256'] for e in frames));seq['rgba_memory_bytes']=sum(e['decoded_rgba_bytes'] for e in frames)
  indices=[int(m.group(1)) for n in seq['frames'] if (m:=re.search(r'(\d+)\.png$',n,re.I))]
  seq['index_range']=[min(indices),max(indices)] if indices else None
  seq['missing_indices']=sorted(set(range(min(indices),max(indices)+1))-set(indices)) if indices else []
  seq['transparent_images']=sum(e.get('true_transparency',False) for e in frames);seq['partial_alpha_images']=sum(e.get('partial_alpha_pixels',0)>0 for e in frames)
  seq['first_last_byte_identical']=frames[0]['sha256']==frames[-1]['sha256'] if len(frames)>1 else None
  seq['visible_height_range']=[min(e['visible_bbox'][3] for e in frames),max(e['visible_bbox'][3] for e in frames)]
  seq['visible_width_range']=[min(e['visible_bbox'][2] for e in frames),max(e['visible_bbox'][2] for e in frames)]
  if len(frames)==1:
   seq['regions']=frames[0].get('authored_grid_regions',frames[0].get('candidate_component_regions',[]));seq['region_kind']='512px authored tile grid' if 'authored_grid_regions' in frames[0] else 'candidate alpha components, not verified sprite identities'
  else: seq['regions']=[]
 pack['sequences']=groups
 pack['png_count']=sum(e['extension']=='.png' for e in entries.values());pack['image_count']=sum(e['extension'] in ['.png','.jpg'] for e in entries.values());pack['decoded_rgba_bytes']=sum(e.get('decoded_rgba_bytes',0) for e in entries.values());pack['editable_sources']=[e['path'] for e in entries.values() if e['extension'] in ['.aep','.psd']]
 # compact per-file JSONL shards keep each reviewable and reproducible.
 for start in range(0,len(pack['entries']),64):
  (a.out/f"{pack['slug']}-{start//64:02d}.jsonl").write_text(''.join(json.dumps(e,separators=(',',':'))+'\n' for e in pack['entries'][start:start+64]))
 overview={k:v for k,v in pack.items() if k!='entries'};summary.append(overview)
 manifest=dict(contract=1,scan_engine='ImageIO alpha counts + PNG headers; no source files executed',packs=d['packs']);a.manifest.write_text(json.dumps(manifest,indent=2)+'\n')
(a.out/'packs.json').write_text(json.dumps(dict(contract=1,packs=summary),indent=2)+'\n')
print(json.dumps({'packs':len(summary),'images':sum(x['image_count'] for x in summary),'png_frames_and_atlases':sum(x['png_count'] for x in summary),'sequences_and_static_atlases':sum(len(x['sequences']) for x in summary),'decoded_MiB':sum(x['decoded_rgba_bytes'] for x in summary)/1048576}))

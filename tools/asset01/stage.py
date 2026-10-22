#!/usr/bin/env python3
"""Stage exact ASSET-01 input archives locally; no downloads, scripts, or game imports."""
import argparse,hashlib,json,shutil,stat,struct,zipfile,collections
from pathlib import Path,PurePosixPath
EXPECTED={
'BlueWizard Animations.zip':'6ede017d0f66ce51d083892f74d130c741744df107a3ae906460a0a775c6f094',
'CaveAssetsMaaot.zip':'8014e9efe9749fe2c4782db4a1d1dfd8afd69d0e846a35514dff06abf58bdb47',
'Mossy Assets.zip':'eae4339b38a4a202b03e0524ab88084702de6cd59f5e8e2bda735a043a155de2',
'Plant Animations.zip':'9eae629a9ad8690fd59cc93f6adb1337e2e62e03d53aa87ba84d061e13dcca21',
'PlantsAnimated.zip':'24176b7ee3c1dc3fa4274e7ce1db2f8b4b074f0687c2597d2148dc4810787447',
'Slimes.zip':'5fd1c2db9accc4c0085e70752cad96f0e752f7715b25baed8a8433ac24305ab3'}
def put_exact(path,data):
 path.parent.mkdir(parents=True,exist_ok=True)
 if path.exists() and path.read_bytes()!=data: raise ValueError('Refusing to replace changed staged file: '+str(path))
 if not path.exists(): path.write_bytes(data)
def run():
 p=argparse.ArgumentParser();p.add_argument('--source',type=Path,required=True);p.add_argument('--stage',type=Path,required=True);a=p.parse_args();packs=[]
 a.stage.mkdir(parents=True,exist_ok=True)
 for name,expected in EXPECTED.items():
  archive=a.source/name;raw=archive.read_bytes();sha=hashlib.sha256(raw).hexdigest()
  if sha!=expected:raise ValueError('Archive identity changed; review before intake: '+name)
  put_exact(a.stage/'originals'/name,raw)
  pack={'name':name,'slug':name[:-4].lower().replace(' ','-'),'sha256':sha,'archive_bytes':len(raw),'entries':[],'embedded_license_files':[],'sequences':[]}
  with zipfile.ZipFile(archive) as z:
   if sum(i.file_size for i in z.infolist())>300_000_000: raise ValueError('Expanded pack exceeds audited limit')
   seen=set()
   for i in z.infolist():
    path=PurePosixPath(i.filename)
    if path.is_absolute() or '..' in path.parts or '\\' in i.filename or stat.S_IFMT(i.external_attr>>16)==stat.S_IFLNK or i.flag_bits&1:raise ValueError('Unsafe archive entry')
    if i.is_dir():continue
    if path.as_posix() in seen:raise ValueError('Duplicate archive entry')
    seen.add(path.as_posix());data=z.read(i);out=a.stage/'extracted'/pack['slug']/path
    put_exact(out,data)
    row={'path':i.filename,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'extension':out.suffix.lower()}
    if out.suffix.lower()=='.png':
     w,h,depth,color,*_=struct.unpack('>IIBBBBB',data[16:29]);row.update(width=w,height=h,bit_depth=depth,png_color_type=color,alpha_channel=color in [4,6],decoded_rgba_bytes=w*h*4)
    if out.suffix.lower() in ['.txt','.md','.pdf','.html','.license'] or 'license' in out.name.lower() or 'readme' in out.name.lower():pack['embedded_license_files'].append(i.filename)
    pack['entries'].append(row)
  groups=collections.defaultdict(list)
  for row in pack['entries']:
   if row['extension']=='.png':groups[str(PurePosixPath(row['path']).parent)].append(row)
  for group,frames in groups.items():
   dims=collections.Counter((r['width'],r['height']) for r in frames)
   pack['sequences'].append({'id':pack['slug']+'/'+group,'name':group,'frames':[r['path'] for r in sorted(frames,key=lambda r:r['path'])],'frame_count':len(frames),'dimensions':[[*d,n] for d,n in dims.items()],'rgba_memory_bytes':sum(r['decoded_rgba_bytes'] for r in frames),'timing':'unspecified; gallery review FPS only','kind':'static_atlas_collection' if pack['slug'] in ['mossy-assets','caveassetsmaaot'] else 'frame_sequence'})
  packs.append(pack)
 (a.stage/'inventory-initial.json').write_text(json.dumps({'contract':1,'packs':packs},indent=2)+'\n')
 print('Six exact archives staged. Next run scan_images and finalize_inventory; originals remain local.')
if __name__=='__main__':run()

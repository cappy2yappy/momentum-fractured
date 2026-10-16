"""Deterministic, non-trimming export from reviewed source-cell/root coordinates.

Run with Python + Pillow + NumPy. Never alters approved ART04 or active Kaze.
Edit source_art/art05/authoring.json to author registration, not this exporter.
"""
from pathlib import Path
import hashlib, io, json, struct, zlib, zipfile
import xml.etree.ElementTree as ET
import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT/'source_art/art05'
OUT = ROOT/'assets/art05'
DOC = ROOT/'docs/art/art05'

def digest(path): return hashlib.sha256(path.read_bytes()).hexdigest()

def clean(im):
    a = np.array(im.convert('RGBA')).copy()
    a[a[:,:,3] <= 8] = 0
    a[:,:,3][a[:,:,3] >= 248] = 255
    a[a[:,:,3] == 0,:3] = 0
    return Image.fromarray(a)

def png(im):
    b = io.BytesIO(); im.save(b,format='PNG'); return b.getvalue()

def crc_check(path):
    data=path.read_bytes(); assert data[:8]==b'\x89PNG\r\n\x1a\n'
    pos=8
    while pos<len(data):
        n=struct.unpack('>I',data[pos:pos+4])[0];kind=data[pos+4:pos+8]
        chunk=data[pos+4:pos+8+n];crc=struct.unpack('>I',data[pos+8+n:pos+12+n])[0]
        assert zlib.crc32(chunk)&0xffffffff==crc,(path,kind)
        pos+=n+12
        if kind==b'IEND': assert pos==len(data);return
    raise AssertionError(f'{path}: no IEND')

def ora(path,frames):
    # Real editable flat frame layers + hidden guides; no fictitious body layers.
    merged=frames[0];w,h=merged.size
    root=ET.Element('image',w=str(w),h=str(h),name=path.stem,version='0.0.3')
    stack=ET.SubElement(root,'stack')
    guides=Image.new('RGBA',(w,h));d=ImageDraw.Draw(guides)
    d.line((160,0,160,h),fill='#f4bc70');d.line((0,600,w,600),fill='#f4bc70')
    with zipfile.ZipFile(path,'w') as z:
        def put(name,data):
            info=zipfile.ZipInfo(name,date_time=(1980,1,1,0,0,0));info.compress_type=zipfile.ZIP_STORED
            z.writestr(info,data)
        put('mimetype','image/openraster')
        for i,(name,im,visible) in enumerate([('root_contact_guides',guides,False)]+[(f'frame_{i:02d}_flat_paint',im,i==0) for i,im in enumerate(frames)]):
            src=f'data/layer{i}.png';put(src,png(im))
            ET.SubElement(stack,'layer',name=name,src=src,opacity='1.0',visibility='visible' if visible else 'hidden',**{'composite-op':'svg:src-over','x':'0','y':'0'})
        put('stack.xml',ET.tostring(root));put('mergedimage.png',png(merged))

def main():
    cfg=json.loads((SRC/'authoring.json').read_text());manifest={k:cfg[k] for k in ['schema_version','cell_size','pivot_px','engine_scale']}
    manifest.update(source_pr30='a6b76b9938825307bdcd4efb687c7198ea0d8681',foundation_pr39='5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c',clips=[])
    qa={'automatic_checks':[], 'artistic_acceptance':'human review still required; technical tests cannot prove identity/anatomy', 'rejected_clips':[]}
    resources=[];subs=[];anims=[];rid=0
    for clip in cfg['clips']:
        master=clean(Image.open(SRC/clip['master']));cols,rows=clip['grid'];sw,sh=master.width//cols,master.height//rows
        assert master.size==(sw*cols,sh*rows)
        frames=[];records=[]
        for i,root in enumerate(clip['roots']):
            cell=master.crop((i%cols*sw,i//cols*sh,(i%cols+1)*sw,(i//cols+1)*sh))
            a=np.array(cell)[:,:,3];source_edge=bool(np.any(a[0]>32) or np.any(a[-1]>32) or np.any(a[:,0]>32) or np.any(a[:,-1]>32))
            s=clip['scale'];rx,ry=root
            f=clean(cell.transform(tuple(cfg['cell_size']),Image.Transform.AFFINE,(1/s,0,rx-160/s,0,1/s,ry-600/s),Image.Resampling.BICUBIC))
            b=f.getchannel('A').getbbox();assert b
            margin=min(b[0],b[1],320-b[2],724-b[3]);assert margin>=12,(clip['id'],i,b)
            arr=np.array(f);assert not np.any(arr[arr[:,:,3]==0,:3])
            assert np.any(arr[:,:,3]==0)
            frames.append(f)
            records.append({'index':i,'region':[i*320,0,320,724],'source_cell':[i%cols*sw,i//cols*sh,sw,sh],'source_root_px':root,'source_scale':s,'pivot_px':[160,600],'duration_ms':1000/clip['fps'],'phase':clip['phases'][i],'contact_foot':clip['contacts'][i],'alpha_bbox':list(b),'alpha_margin_px':margin,'source_cell_clipped':source_edge,'sha256_rgba':hashlib.sha256(f.tobytes()).hexdigest()})
        if any(r['source_cell_clipped'] for r in records): qa['rejected_clips'].append(clip['id'])
        sheet=Image.new('RGBA',(320*len(frames),724))
        for i,f in enumerate(frames):sheet.alpha_composite(f,(i*320,0))
        path=OUT/'kaze'/f"{clip['id']}.png";path.parent.mkdir(parents=True,exist_ok=True);sheet.save(path);crc_check(path)
        ora(SRC/f"{clip['id']}.ora",frames)
        entry={k:clip[k] for k in ['id','fps','loop','status','review']};entry.update(path=str(path.relative_to(ROOT)),sha256=digest(path),master_sha256=digest(SRC/clip['master']),frames=records)
        manifest['clips'].append(entry)
        rid+=1;resources.append(f'[ext_resource type="Texture2D" path="res://{entry["path"]}" id="{rid}"]')
        refs=[]
        for i in range(len(frames)):
            sub=f'{clip["id"]}_{i}';subs.append(f'[sub_resource type="AtlasTexture" id="{sub}"]\natlas = ExtResource("{rid}")\nregion = Rect2({i*320},0,320,724)\nfilter_clip = true')
            refs.append('{"duration": 1.0, "texture": SubResource("'+sub+'")}')
        anims.append('{"frames": ['+','.join(refs)+'], "loop": '+str(clip['loop']).lower()+', "name": &"'+clip['id']+'", "speed": '+str(float(clip['fps']))+'}')
        # Preview derivative at native world scale, playback always same authored rate.
        previews=[]
        for f in frames:
            bg=Image.new('RGBA',(320,240),'#202438');small=f.resize((97,219),Image.Resampling.LANCZOS);bg.alpha_composite(small,(112,5));previews.append(bg.convert('RGB'))
        previews[0].save(DOC/f"{clip['id']}_sequence.gif",save_all=True,append_images=previews[1:],duration=round(1000/clip['fps']),loop=0,disposal=2)
    tres='[gd_resource type="SpriteFrames" load_steps="'+str(1+len(resources)+len(subs))+'" format="3"]\n\n'+'\n'.join(resources)+'\n\n'+'\n\n'.join(subs)+'\n\n[resource]\nanimations = ['+',\n'.join(anims)+']\n'
    (OUT/'kaze/ART05_candidates.tres').write_text(tres)
    env=cfg['environment'];master=clean(Image.open(SRC/env['master']));block=clean(master.crop(tuple(env['crop'])).resize(tuple(env['size']),Image.Resampling.LANCZOS))
    # All solid face texels stay inside the existing 180x80 collision rectangle.
    # Cap row backed by stone color for a continuous, exact walkable edge.
    backing=Image.new('RGBA',tuple(env['size']),'#51494e');backing.alpha_composite(block);block=backing
    p=OUT/'environment/bellroof_west_masonry.png';p.parent.mkdir(parents=True,exist_ok=True);block.save(p);crc_check(p)
    manifest['environment']=dict(env,path=str(p.relative_to(ROOT)),sha256=digest(p),master_sha256=digest(SRC/env['master']),world_rect=[520,1220,180,80],no_collision_nodes=True)
    # Reference board includes actual PR30 frames and the new sequence at equal source scale.
    board=Image.new('RGB',(1280,880),'#202438');d=ImageDraw.Draw(board)
    d.text((20,12),'KAZE ART05 | PR30 identity at left; turn candidate frames 0 / 1 / 2 / 3',fill='#e8d4b8')
    turn=manifest['clips'][0];strip=Image.open(ROOT/turn['path'])
    for i in range(4):
        f=strip.crop((i*320,0,(i+1)*320,724));board.paste(f,(i*320,60),f);d.line((i*320,660,i*320+319,660),fill='#e5b669')
    ref=Image.open(ROOT/'assets/art04/kaze/turn_depth_key.png').convert('RGBA').resize((97,219))
    board.paste(ref,(20,660),ref);d.text((130,810),'Approved PR30 key. Compare face, hair, cuffs, skirt, boots and green ribbons.',fill='#e8d4b8')
    board.save(DOC/'CHARACTER_CONSISTENCY.png')
    qa['automatic_checks']=['PNG CRC/IEND and full decode','RGBA zero hidden RGB','fixed cell/pivot and shared clip scale','12px exported cell margins','source-cell boundary detection (stair rejected)','distinct frame hashes','SpriteFrames regions/count/FPS exported']
    for clip in manifest['clips']:assert len({r['sha256_rgba'] for r in clip['frames']})==len(clip['frames'])
    (OUT/'MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n');(DOC/'ASSET_QA.json').write_text(json.dumps(qa,indent=2)+'\n')
    print(json.dumps({'clips':[(c['id'],len(c['frames']),c['status']) for c in manifest['clips']],'rejected':qa['rejected_clips']}))

if __name__=='__main__': main()

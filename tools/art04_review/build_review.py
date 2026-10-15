"""Assemble native captures without resizing their 1280x720 gameplay views."""
from pathlib import Path
import hashlib,json,zipfile,io,struct,zlib
import numpy as np
from PIL import Image,ImageDraw,ImageFont

ROOT=Path(__file__).resolve().parents[2]
DOC=ROOT/'docs/art/art04'
FONT=ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial.ttf',22)

def label(d,xy,text):d.text(xy,text,font=FONT,fill='#ecdfc7')

def main():
    comp=Image.new('RGB',(2560,1520),'#171c2c');d=ImageDraw.Draw(comp)
    for row,room in enumerate([14,15]):
        for col,kind in enumerate(['tr03','art04']):
            y=row*760
            label(d,(col*1280+20,y+9),f'R{room} / '+('TR-03 procedural pilot' if col==0 else 'ART-04 derived production dressing')+' / 1280 × 720, zoom 1.0')
            im=Image.open(DOC/f'captures/R{room}_{kind}.png');assert im.size==(1280,720)
            comp.paste(im,(col*1280,y+40))
    comp.save(DOC/'GAME_SCALE_COMPARISON.png')
    keys=['turn_depth_key','enter_depth_key','stair_up_key','stair_down_key']
    gallery=Image.new('RGB',(2560,1520),'#171c2c');d=ImageDraw.Draw(gallery)
    for i,key in enumerate(keys):
        x=(i%2)*1280;y=(i//2)*760
        label(d,(x+20,y+9),key+' / native Godot fixture, 1280 × 720, zoom 1.0')
        gallery.paste(Image.open(DOC/f'captures/{key}.png'),(x,y+40))
    gallery.save(DOC/'POSES_IN_ENGINE.png')
    board=Image.new('RGB',(1360,780),'#30374b');d=ImageDraw.Draw(board)
    label(d,(24,16),'ART-04 / transparent production layers (textures at 1:1 game size)')
    items=[('door_combined',(24,80)),('r14_door_back',(250,80)),('r14_door_front',(476,80)),('r14_door_interior',(702,80)),('stair_flight_right',(928,80)),('r14_roof_support',(24,380)),('r15_masonry_support',(552,380))]
    for name,(x,y) in items:
        label(d,(x,y-30),name)
        im=Image.open(ROOT/f'assets/art04/environment/{name}.png').convert('RGBA');board.paste(im,(x,y),im)
    board.save(DOC/'ENVIRONMENT_LAYERS.png')
    assets=json.loads((ROOT/'assets/art04/MANIFEST.json').read_text())['images']
    for row in assets:
        p=ROOT/row['path'];b=p.read_bytes();assert hashlib.sha256(b).hexdigest()==row['sha256']
        off=8;iend=False
        while off+12<=len(b):
            n=int.from_bytes(b[off:off+4],'big');tag=b[off+4:off+8];data=b[off+8:off+8+n];crc=b[off+8+n:off+12+n]
            assert len(crc)==4 and zlib.crc32(tag+data)==int.from_bytes(crc,'big'),str(p)
            if tag==b'IEND':iend=True
            off+=12+n
        assert iend
        with Image.open(p) as im:im.load()
    sources=[]
    for p in sorted((ROOT/'source_art/art04').glob('*.ora')):
        with zipfile.ZipFile(p) as z:
            assert z.testzip() is None and z.read('mimetype')==b'image/openraster'
            Image.open(io.BytesIO(z.read('mergedimage.png'))).load()
        sources.append(dict(path=str(p.relative_to(ROOT)),sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
    captures=[]
    for p in sorted((DOC/'captures').glob('*.png')):
        im=Image.open(p);im.load();assert im.size==(1280,720)
        captures.append(dict(path=str(p.relative_to(ROOT)),sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
    # Comparative warm skin samples; excludes purple/green and zero-alpha pixels.
    samples={}
    for name,path in [('approved_idle',ROOT/'assets/kaze/cleaned/kaze_idle_strip.png')]+[(k,ROOT/f'assets/art04/kaze/{k}.png') for k in keys]:
        a=np.array(Image.open(path).convert('RGBA')).astype(float)
        mask=(a[:,:,3]>200)&(a[:,:,0]>80)&(a[:,:,0]>a[:,:,1]*1.25)&(a[:,:,1]>a[:,:,2]*1.2)
        samples[name]={'median_warm_pixels_rgb':np.median(a[:,:,:3][mask],axis=0).astype(int).tolist(),'method':'warm-pixel color proxy, not an identity approval or exact skin segmentation'}
    result=dict(status='technical import and native static-review passed; creator acceptance and runtime integration pending',engine='Godot 4.6.1.stable.official.14d19694e',platform='native macOS Apple M4, OpenGL compatibility',pngs_validated=len(assets),rgba_hidden_rgb_and_margins='passed in art04_export.py',root_equation='(160 - 320/2, 600 - 724/2 - 238) = (0,0)',source_archives=sources,captures=captures,skin_color_proxy=samples,colliders={'R14_before_after':[23,23],'R15_before_after':[15,15]},visual_results=['Four distinct keys, brown skin/purple costume/green ribbons retained; visible head-to-boot silhouettes at approximately 94–97px occupied height.','Door rear/foreground layers and transparent opening rendered; inward foot recedes into background.','Ascent leading boot sits on higher tread; descent leading boot reaches lower tread with flexed knees; 0.8 vertical stair staging scale aligns contacts.','Existing procedural roof silhouettes/large arches still overdraw parts of new dressing; integration must resolve these scoped placeholders. No claim of a final room reskin.'],limitations=['Static native fixture captures, not a playable ART04 integration or creator playtest.','No full cycles, walk, exit/front-quarter keys or reviewed opposite-facing variants supplied.','R17 descent destination/runtime masking not validated.','Full runtime cleanup/cancel/death/input/progression/save tests not rerun; gameplay unchanged.','No Windows export/native check, sustained 60FPS, or finished transition timing acceptance.','Initial sandbox GUI capture aborted before rendering; authorized native capture succeeded. Headless import had profile-permission/certificate/shutdown diagnostics; native final capture log has no script or resource errors.'])
    (DOC/'QA_RESULTS.json').write_text(json.dumps(result,indent=2)+'\n')
    source_files=[]
    for p in sorted((ROOT/'source_art/art04').iterdir()):
        if p.is_file() and p.name not in ['SOURCE_MANIFEST.json','.gdignore']:
            source_files.append(dict(path=str(p.relative_to(ROOT)),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
    (ROOT/'source_art/art04/SOURCE_MANIFEST.json').write_text(json.dumps(dict(files=source_files),indent=2)+'\n')
    print('Passed PNG CRC/decode/hash for',len(assets),'textures;',len(sources),'ORA archives;',len(captures),'native captures.')

if __name__=='__main__':main()

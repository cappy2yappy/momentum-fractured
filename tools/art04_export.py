"""Export authored raster assets, registered key poses, editable ORA sources and QA."""
from pathlib import Path
import hashlib, io, json, zipfile, xml.etree.ElementTree as ET
import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'source_art/art04'
ASSET=ROOT/'assets/art04'
DOC=ROOT/'docs/art/art04'
FONT=ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial.ttf',20)
POSES={
 'turn_depth_key':dict(source='turn',scale=.2348,root=[650,1470],contact=[880,1373],facing='right-quarter-rear'),
 'enter_depth_key':dict(source='entry',scale=.2348,root=[600,1459],contact=[535,1454],facing='rear'),
 'stair_up_key':dict(source='up',scale=.248,root=[600,1281],contact=[1000,1120],facing='right'),
 'stair_down_key':dict(source='down',scale=.24,root=[520,1408],contact=[285,1402],facing='left'),
}

def clean(im):
    a=np.array(im.convert('RGBA')).copy()
    # Remove only low-alpha export noise; preserve visible artwork and edge coverage.
    a[:,:,3][a[:,:,3]<=8]=0
    a[:,:,3][a[:,:,3]>=248]=255
    a[a[:,:,3]==0,:3]=0
    return Image.fromarray(a)

def pngbytes(im):
    s=io.BytesIO();im.save(s,format='PNG');return s.getvalue()

def ora(path,size,layers):
    root=ET.Element('image',{'w':str(size[0]),'h':str(size[1]),'name':path.stem,'version':'0.0.3'})
    stack=ET.SubElement(root,'stack')
    merged=Image.new('RGBA',size)
    for name,im,visible in reversed(layers):
        if visible: merged.alpha_composite(im)
    with zipfile.ZipFile(path,'w') as z:
        z.writestr('mimetype','image/openraster',compress_type=zipfile.ZIP_STORED)
        for i,(name,im,visible) in enumerate(layers):
            src=f'data/layer{i}.png';z.writestr(src,pngbytes(im))
            ET.SubElement(stack,'layer',{'name':name,'src':src,'opacity':'1.0','visibility':'visible' if visible else 'hidden','composite-op':'svg:src-over','x':'0','y':'0'})
        z.writestr('stack.xml',ET.tostring(root,encoding='utf-8'))
        z.writestr('mergedimage.png',pngbytes(merged))

def write(im,rel):
    path=ASSET/rel;path.parent.mkdir(parents=True,exist_ok=True)
    clean(im).save(path)
    return path

def main():
    for p in [DOC,SRC,ASSET/'environment',ASSET/'kaze',ASSET/'prefabs']: p.mkdir(parents=True,exist_ok=True)
    metadata=[];pose_images=[]
    for key,cfg in POSES.items():
        im=clean(Image.open(SRC/(cfg['source']+'_master.png')))
        scale=cfg['scale'];rx,ry=cfg['root']
        # Fixed manually selected authoring transform, not runtime auto-centering.
        out=im.transform((320,724),Image.Transform.AFFINE,(1/scale,0,rx-160/scale,0,1/scale,ry-600/scale),Image.Resampling.BICUBIC)
        path=write(out,'kaze/'+key+'.png');out=Image.open(path).convert('RGBA');pose_images.append(out)
        contact=[round(160+(cfg['contact'][0]-rx)*scale,3),round(600+(cfg['contact'][1]-ry)*scale,3)]
        metadata.append(dict(id=key,path=str(path.relative_to(ROOT)),size=[320,724],pivot=[160,600],scale=.303125,offset=[0,-238],frame_count=1,loop=False,direction=cfg['facing'],contact_px=contact,authoring_transform=cfg,status='single key; technical import candidate, creator acceptance pending'))
        guides=Image.new('RGBA',(320,724));d=ImageDraw.Draw(guides);d.line((0,600,320,600),fill='#e4b75b',width=1);d.line((160,0,160,724),fill='#e4b75b',width=1);d.ellipse((contact[0]-4,contact[1]-4,contact[0]+4,contact[1]+4),outline='#fa5949',width=1)
        ora(SRC/(key+'.ora'),(320,724),[('contact_root_guides',guides,False),('authored_character_flat',out,True)])
    strip=Image.new('RGBA',(1280,724))
    for i,im in enumerate(pose_images): strip.alpha_composite(im,(320*i,0))
    write(strip,'kaze/key_pose_atlas.png')
    # Environment dimensions map to explicit visual-only pilot envelopes.
    env=[]
    def fitted(source,size,name):
        im=clean(Image.open(SRC/(source+'_master.png')))
        box=im.getchannel('A').point(lambda a:255 if a>32 else 0).getbbox()
        out=Image.new('RGBA',size)
        out.alpha_composite(im.crop(box).resize((size[0]-16,size[1]-16),Image.Resampling.LANCZOS),(8,8))
        write(out,'environment/'+name+'.png');return clean(out)
    door=fitted('door',(208,224),'door_combined')
    a=np.array(door);front=np.zeros_like(a);front[88:,149:]=a[88:,149:];front[207:]=a[207:]
    back=a.copy();back[88:,149:]=0;back[207:]=0
    front=Image.fromarray(front);back=Image.fromarray(back)
    write(front,'environment/r14_door_front.png');write(back,'environment/r14_door_back.png')
    # Recover an unobstructed interior detail from the approved painting, with no character.
    reference=Image.open(ROOT/'docs/art/tr03/art03_recovery/01_doorway.png').convert('RGBA')
    interior=Image.new('RGBA',(208,224));detail=reference.crop((1184,212,1298,559)).resize((75,126),Image.Resampling.LANCZOS);interior.alpha_composite(detail,(82,84));write(interior,'environment/r14_door_interior.png')
    ora(SRC/'r14_door_layers.ora',(208,224),[('front_jamb_threshold',front,True),('rear_frame',back,True),('interior_from_approved_painting',interior,True)])
    for source,size,name in [('stairs',(384,112),'stair_flight_right'),('roof',(488,186),'r14_roof_support'),('arch_plain',(456,338),'r15_masonry_support')]:
        im=fitted(source,size,name)
        ora(SRC/(name+'.ora'),size,[('authored_architecture_flat',im,True)])
    # Front stair lip is separated from backing; it can occlude toes by 1–2px.
    stairs=Image.open(ASSET/'environment/stair_flight_right.png').convert('RGBA')
    arr=np.array(stairs);lip=np.zeros_like(arr)
    for x in range(stairs.width):
        ys=np.flatnonzero(arr[:,x,3]>200)
        if len(ys):
            y=int(ys[0]);lip[y:y+2,x]=arr[y:y+2,x]
    write(Image.fromarray(lip),'environment/stair_front_lip.png')
    env=[
      dict(id='r14_roof_support',room=14,path='assets/art04/environment/r14_roof_support.png',top_left=[706,922],opaque_envelope=[714,930,472,170],draw='rear dressing, before platform lips and live actors'),
      dict(id='r15_masonry_support',room=15,path='assets/art04/environment/r15_masonry_support.png',top_left=[1292,970],opaque_envelope=[1300,978,440,322],draw='rear dressing, before platform lips and live actors'),
      dict(id='r14_depth_door',room=14,endpoint=[120,1100],root_px=[120,208],layers=['r14_door_interior','r14_door_back','r14_door_front'],draw='interior → rear frame → actor → front jamb/threshold; prompts above all'),
      dict(id='r14_stair_flight',room=14,endpoint=[1450,480],path='assets/art04/environment/stair_flight_right.png',size=[384,112],review_top_left=[1330,431.8],review_draw_size=[384,89.6],review_actor_root=[1450,478],draw='short render-proxy staging only; no new physical stairs or collision',front='assets/art04/environment/stair_front_lip.png'),
    ]
    contract=dict(assignment='ART-04',level_reference='c2c002267c58e991966c0eebf7e098c6e7fff769',character_keys=metadata,environment=env,loader_unchanged_seconds=.65,frames_supplied=4,full_animation_pack=False,existing_run='reuse approved clip without changing its scale/pivot',mirror_policy='stair up right and stair down left are authored. Other facings/reverse door require review; do not assume symmetric ribbons.')
    (ASSET/'ART04_ASSETS.json').write_text(json.dumps(contract,indent=2)+'\n')
    # A real importer resource: four one-key clips, intentionally named _key.
    text='[gd_resource type="SpriteFrames" load_steps="5" format="3"]\n\n'
    for i,key in enumerate(POSES): text+=f'[ext_resource type="Texture2D" path="res://assets/art04/kaze/{key}.png" id="{i+1}"]\n'
    text+='\n[resource]\nanimations = [\n'
    text+=',\n'.join('{"frames": [{"duration": 1.0, "texture": ExtResource("%d")}], "loop": false, "name": &"%s", "speed": 20.0}'%(i+1,key) for i,key in enumerate(POSES))
    text+='\n]\n';(ASSET/'kaze/ART04_key_poses.tres').write_text(text)
    # Atlas source retains registration guides separately from the paint.
    sheet=Image.new('RGB',(1280,880),'#202338');d=ImageDraw.Draw(sheet)
    d.text((20,12),'KAZE / ART-04 — four authored keys, not complete cycles',font=FONT,fill='#eee0c7')
    for i,(key,im) in enumerate(zip(POSES,pose_images)):
        d.text((i*320+12,52),key,font=FONT,fill='#eee0c7');sheet.paste(im,(i*320,90),im)
        d.line((i*320,690,i*320+319,690),fill='#e4b75b');d.line((i*320+160,665,i*320+160,712),fill='#e4b75b')
        reduced=im.resize((97,219),Image.Resampling.LANCZOS);sheet.paste(reduced,(i*320+110,664),reduced)
    sheet.save(DOC/'KEY_POSE_REVIEW.png')
    # Four background alpha check sheet at 1:1 source size for each key.
    edge=Image.new('RGB',(1280,2896));d=ImageDraw.Draw(edge)
    for row,color in enumerate(['#000000','#ffffff','#777777','#25294b']):
        d.rectangle((0,row*724,1279,(row+1)*724),fill=color)
        for col,im in enumerate(pose_images):edge.paste(im,(col*320,row*724),im)
    edge.save(DOC/'ALPHA_EDGE_REVIEW.png')
    manifest=[]
    for p in sorted(ASSET.rglob('*.png')):
        with Image.open(p) as im:
            im.load();a=np.array(im);alpha=a[:,:,3];box=im.getchannel('A').getbbox()
            assert im.mode=='RGBA' and alpha.min()==0
            assert not np.any(a[alpha==0,:3])
            if p.parent.name=='kaze':
                cell_count=4 if 'atlas' in p.name else 1
                assert im.size==(320*cell_count,724)
                for i in range(cell_count):
                    b=im.crop((320*i,0,320*(i+1),724)).getchannel('A').getbbox()
                    assert b and min(b[0],b[1],320-b[2],724-b[3])>=12,(p,b)
            manifest.append(dict(path=str(p.relative_to(ROOT)),size=list(im.size),mode=im.mode,alpha_bbox=box,transparent_fraction=round(float(np.mean(alpha==0)),4),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size))
    (ASSET/'MANIFEST.json').write_text(json.dumps(dict(status='technical asset candidates; creator acceptance pending',images=manifest),indent=2)+'\n')
    print('Exported',len(manifest),'RGBA textures; hidden RGB, transparent edges, cell size and 12px key margins passed.')

if __name__=='__main__': main()

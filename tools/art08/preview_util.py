import numpy as np
from PIL import Image, ImageDraw
def sheet(frames, path, crop=(60,250,420,620), scale=1, bg=(120,140,150), cols=8, label=None, ground=None):
    ims=[]
    for i,f in enumerate(frames):
        im=Image.fromarray(f); b=Image.new('RGBA',im.size,bg+(255,)); b.alpha_composite(im)
        b=b.convert('RGB').crop(crop)
        if scale!=1: b=b.resize((int(b.width*scale),int(b.height*scale)),Image.LANCZOS)
        d=ImageDraw.Draw(b); d.text((3,3),str(i),fill=(255,255,0))
        ims.append(b)
    w,h=ims[0].size; rows=(len(ims)+cols-1)//cols
    S=Image.new('RGB',(w*min(cols,len(ims)),h*rows),(40,40,40))
    for i,b in enumerate(ims): S.paste(b,((i%cols)*w,(i//cols)*h))
    S.save(path)

"""Rebuild review layouts and audit PNGs without repainting or cropping final art."""
from pathlib import Path
import hashlib, io, json, struct, zlib
from PIL import Image, ImageDraw, ImageFont, ImageFile

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'docs/art/tr03/art03_recovery'
OLD = ROOT / 'docs/art/tr03/production_revision'
NAMES = ['01_doorway.png', '02_staircase.png', '03_supported_crossing.png']
TITLES = ['01  Doorway / Hidden Village', '02  Stair ascent / Silent District', '03  Supported crossing / Canal Remains']
FONT = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial.ttf', 25)
SMALL = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial.ttf', 19)

def audit(path):
    b = path.read_bytes()
    result = dict(path=str(path.relative_to(ROOT)), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())
    off, errors, iend = 8, [], False
    while off + 12 <= len(b):
        size = struct.unpack('>I', b[off:off+4])[0]
        tag, data = b[off+4:off+8], b[off+8:off+8+size]
        crc = b[off+8+size:off+12+size]
        if len(crc) != 4 or zlib.crc32(tag+data) != int.from_bytes(crc, 'big'):
            errors.append(tag.decode('ascii', errors='replace'))
        if tag == b'IEND': iend = True
        off += 12+size
    result.update(crc_errors=errors, iend_present=iend)
    ImageFile.LOAD_TRUNCATED_IMAGES = False
    try:
        with Image.open(io.BytesIO(b)) as im:
            result.update(width=im.width, height=im.height, mode=im.mode)
            im.load()
        result['strict_decode'] = 'passed'
    except Exception as e:
        result['strict_decode'] = str(e)
    return result

def fit(canvas, path, box, partial=False):
    ImageFile.LOAD_TRUNCATED_IMAGES = partial
    with Image.open(path) as im:
        im.load()
        im = im.convert('RGB')
        im.thumbnail((box[2]-box[0], box[3]-box[1]), Image.Resampling.LANCZOS)
        canvas.paste(im, (box[0]+(box[2]-box[0]-im.width)//2, box[1]+(box[3]-box[1]-im.height)//2))
    ImageFile.LOAD_TRUNCATED_IMAGES = False

def main():
    old = [audit(p) for p in sorted(OLD.glob('*.png'))]
    recorded = json.loads((OLD/'QA_RESULTS.json').read_text())
    claims = {Path(x['path']).name:x for x in recorded['images']}
    for row in old:
        claim = claims[Path(row['path']).name]
        row.update(recorded_bytes=claim['bytes'], recorded_sha256=claim['sha256'], recorded_hash_matches=row['sha256']==claim['sha256'])
    (OUT/'RECOVERY_AUDIT.json').write_text(json.dumps(dict(base='0b96d41fa7b6b424591fdd685f5c8fdf9290c02b', findings=old, conclusion='All four committed PNGs fail strict decoding and recorded integrity checks. Partial decoding exposes only upper scanlines. Complete compositions could not be recovered from this Git master. Cause of corruption is unproven. New paintings reconstruct missing content.'), indent=2)+'\n')
    gallery = Image.new('RGB',(1328,2440),'#111923')
    draw = ImageDraw.Draw(gallery)
    draw.text((24,18),'KAZE / ART-03 — complete painted concepts',font=FONT,fill='#efdfc1')
    draw.text((24,54),'Creator review pending • static concept paintings • no animation integrated',font=SMALL,fill='#b8c8cd')
    svg=['<svg xmlns="http://www.w3.org/2000/svg" width="1328" height="2440" viewBox="0 0 1328 2440">','<rect width="1328" height="2440" fill="#111923"/>','<text x="24" y="40" fill="#efdfc1" font-size="25" font-family="Arial">KAZE / ART-03 — complete painted concepts</text>']
    for i,(name,title) in enumerate(zip(NAMES,TITLES)):
        top = 102+i*776
        draw.text((24,top),title+' / 1672 × 941',font=FONT,fill='#efdfc1')
        fit(gallery,OUT/name,(24,top+42,1304,top+763))
        svg.extend([f'<text x="24" y="{top+25}" fill="#efdfc1" font-size="25" font-family="Arial">{title} / 1672 × 941</text>',f'<image href="{name}" x="24" y="{top+42}" width="1280" height="721" preserveAspectRatio="xMidYMid meet"/>'])
    gallery.save(OUT/'REVIEW_GALLERY.png')
    (OUT/'REVIEW_GALLERY.svg').write_text('\n'.join(svg+['</svg>'])+'\n')
    comparison=Image.new('RGB',(1800,1840),'#111923'); d=ImageDraw.Draw(comparison)
    d.text((24,16),'KAZE / ART-03 — before and after',font=FONT,fill='#efdfc1')
    d.text((24,58),'BEFORE: best-effort partial decode of corrupt PR #26 PNGs',font=SMALL,fill='#efb89e')
    d.text((918,58),'AFTER: complete reconstructed paintings, fitted without cropping',font=SMALL,fill='#b8c8cd')
    for i,(name,title) in enumerate(zip(NAMES,TITLES)):
        top=104+i*568
        d.text((24,top),title,font=FONT,fill='#efdfc1')
        d.rectangle((24,top+48,882,top+532),fill='#28323e')
        fit(comparison,OLD/name,(24,top+48,882,top+532),partial=True)
        fit(comparison,OUT/name,(918,top+48,1776,top+532))
        d.text((24,top+538),'Black pixels are decoder fill; missing scene data was not recovered.',font=SMALL,fill='#efb89e')
    comparison.save(OUT/'BEFORE_AFTER.png')
    # Real gameplay-size review, with no implied runtime integration.
    for name in NAMES:
        with Image.open(OUT/name) as im:
            im.load(); im.resize((1280,720),Image.Resampling.LANCZOS).save(OUT/('review_1280_'+name))
    manifest=[audit(p) for p in sorted(OUT.glob('*.png'))]
    assert all(r['strict_decode']=='passed' and not r['crc_errors'] and r['iend_present'] for r in manifest)
    (OUT/'ASSET_MANIFEST.json').write_text(json.dumps(dict(status='painted concepts; creator review pending',images=manifest),indent=2)+'\n')
    print('Passed strict PNG decode, all chunk CRCs and IEND checks:',len(manifest),'new images')

if __name__ == '__main__': main()

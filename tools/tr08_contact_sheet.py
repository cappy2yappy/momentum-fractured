"""TR-08: contact sheets (and JPEG derivatives) from build/tr08/captures PNG frames.
Usage: python3 tools/tr08_contact_sheet.py <captures_dir> <out_dir> [--cols 4] [--width 400]
Frames are grouped by sequence prefix (text before _NN_t). Python stdlib + Pillow."""
import argparse, json, re
from pathlib import Path
from PIL import Image, ImageDraw

p = argparse.ArgumentParser()
p.add_argument('src'); p.add_argument('out')
p.add_argument('--cols', type=int, default=4); p.add_argument('--width', type=int, default=400)
p.add_argument('--jpeg', action='store_true', help='also write per-frame JPEG derivatives')
a = p.parse_args()
src, out = Path(a.src), Path(a.out)
out.mkdir(parents=True, exist_ok=True)
groups = {}
for f in sorted(src.glob('*.png')):
    m = re.match(r'(.+?)_(-?\d+)_t([\d.]+)$', f.stem)
    if not m: continue
    groups.setdefault(m.group(1), []).append((int(m.group(2)), float(m.group(3)), f))
for name, frames in groups.items():
    frames.sort()
    w = a.width; h = int(w * 720 / 1280); pad = 18
    rows = (len(frames) + a.cols - 1) // a.cols
    sheet = Image.new('RGB', (a.cols * w, rows * (h + pad)), (8, 8, 12))
    d = ImageDraw.Draw(sheet)
    for i, (n, t, f) in enumerate(frames):
        im = Image.open(f).convert('RGB')
        if a.jpeg: im.save(out / (f.stem + '.jpg'), quality=86)
        x, y = (i % a.cols) * w, (i // a.cols) * (h + pad)
        sheet.paste(im.resize((w, h), Image.LANCZOS), (x, y + pad))
        d.text((x + 4, y + 3), '%s #%d t=%.2fs' % (name, n, t), fill=(235, 225, 200))
    sheet.save(out / ('SHEET_%s.jpg' % name), quality=86)
    print(name, len(frames), out / ('SHEET_%s.jpg' % name))

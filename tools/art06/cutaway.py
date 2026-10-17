#!/usr/bin/env python3
"""ART-06 cutaway screen: original, parametric 'RIBBON RUSH' passage graphic for the lateral transition.

Everything is a pure function of the 20 fps tick (0..12 of the 0.65 s loader clock) so Transition
Masta can either play the exported PNG sequence or redraw the same shapes. Right-going is authored;
left-going is the whole layer mirrored (scale.x = -1 about screen centre). No text, no third-party
artwork. Luminance is deliberately low and never strobes (see QA in preview.py).

  tick  0-1  in-room run commit / anticipation (no overlay)
  tick  2    bands begin to sweep in from the exit side (partial cover)
  tick  3-8  full cover: hero Kaze sprint cycle + parallax passage (room swap lands at ~0.33 s = tick 6)
  tick  9    bands clear from the ARRIVAL side first (left for right-going), exposing the entry edge
  tick 10+   clear; destination room visible
"""
import argparse, math, os
from PIL import Image, ImageDraw

W, H = 1280, 720
FLOOR_Y = 520
INK, INK2 = (19, 13, 36), (29, 18, 56)
VIO, VIO_L = (75, 35, 144), (122, 69, 201)
GREEN, CREAM, DEEP = (34, 224, 107), (243, 236, 220), (11, 7, 22)
BAND_W, BAND_STEP, SLANT, N_BANDS, X0 = 300, 270, 170, 7, -300
COVER_TICKS = range(3, 9)


def ease_out(t): return 1 - (1 - t) ** 3
def ease_in(t): return t ** 3
def clamp(x, a=0.0, b=1.0): return max(a, min(b, x))


def band_x(k, tick):
    """Left x of band k at a (float) tick. Enter from the right, leave to the left."""
    p_in = clamp((tick - 1.4 - (N_BANDS - 1 - k) * 0.08) / 1.0)
    p_out = clamp((tick - 7.7 - k * 0.12) / 1.0)
    x = X0 + k * BAND_STEP
    x += (1 - ease_out(p_in)) * W * 1.35
    x -= ease_in(p_out) * W * 1.7
    if p_in >= 1 and p_out <= 0:
        x -= (tick - 3.0) * 5  # slow drift while held
    return x, p_in, p_out


def covered(tick):
    return any(band_x(k, tick)[1] > 0 and band_x(k, tick)[2] < 1 for k in range(N_BANDS))


def render(tick, ss=2):
    """Returns (bg, fg) RGBA at W x H. bg sits behind hero Kaze, fg (near streaks) in front."""
    w, h = W * ss, H * ss
    mask = Image.new("L", (w, h), 0)
    md = ImageDraw.Draw(mask)
    panels = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    pd = ImageDraw.Draw(panels)
    cols = [INK, VIO, INK2, VIO_L]
    for k in range(N_BANDS):
        x, p_in, p_out = band_x(k, tick)
        if p_in <= 0 or p_out >= 1:
            continue
        poly = [((x + SLANT) * ss, 0), ((x + SLANT + BAND_W) * ss, 0), ((x + BAND_W) * ss, h), (x * ss, h)]
        md.polygon(poly, fill=255)
        pd.polygon(poly, fill=cols[k % 4] + (255,))
        # cream edge line on the leading (right) slanted edge
        e = [((x + SLANT + BAND_W - 9) * ss, 0), ((x + SLANT + BAND_W) * ss, 0), ((x + BAND_W) * ss, h), ((x + BAND_W - 9) * ss, h)]
        pd.polygon(e, fill=CREAM + (255,))
        if k in (3, 5):  # green accent ribbon along the trailing edge
            g = [((x + SLANT) * ss, 0), ((x + SLANT + 14) * ss, 0), ((x + 14) * ss, h), (x * ss, h)]
            pd.polygon(g, fill=GREEN + (255,))
    inner_bg = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    inner_fg = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    bd, fd = ImageDraw.Draw(inner_bg), ImageDraw.Draw(inner_fg)
    t = tick - 3.0
    # floor of the passage
    bd.rectangle([0, FLOOR_Y * ss, w, h], fill=DEEP + (255,))
    bd.line([(0, FLOOR_Y * ss), (w, FLOOR_Y * ss)], fill=CREAM + (255,), width=3 * ss)
    for i in range(14):  # floor speed lines (deterministic)
        y = FLOOR_Y + 14 + (i * 53) % 190
        L = 140 + (i * 97) % 220
        x = (-t * (260 + (i % 3) * 90) + i * 211) % (W + 400) - 200
        bd.line([(x * ss, y * ss), ((x + L) * ss, y * ss)], fill=(VIO_L if i % 2 else VIO) + (255,), width=(2 + i % 3) * ss)
    # parallax gate pillars: far, mid (behind Kaze)
    for spacing, speed, pw, shade in ((360, 70, 34, INK2), (300, 150, 24, DEEP)):
        n = W // spacing + 3
        for i in range(n):
            x = (i * spacing - t * speed) % (spacing * n) - spacing
            bd.rectangle([x * ss, 130 * ss, (x + pw) * ss, FLOOR_Y * ss], fill=shade + (255,))
            bd.rectangle([(x - 26) * ss, 126 * ss, (x + pw + 26) * ss, 144 * ss], fill=shade + (255,))
            bd.line([((x - 26) * ss, 126 * ss), ((x + pw + 26) * ss, 126 * ss)], fill=VIO_L + (255,), width=2 * ss)
    # ribbon streaks: two behind Kaze, one in front
    for j, (y, L, sp, front) in enumerate(((210, 640, 430, False), (360, 520, 520, False), (455, 760, 610, True))):
        x = (W + 200) - ((t + j * 0.7) * sp) % (W + 1000) + 0
        d = fd if front else bd
        poly = [(x * ss, (y - 11) * ss), ((x + L) * ss, y * ss), (x * ss, (y + 11) * ss)]
        d.polygon(poly, fill=GREEN + (255,))
    # near streak lines in front
    for i in range(6):
        y = 150 + i * 62
        x = (-t * 700 + i * 331) % (W + 600) - 300
        fd.line([(x * ss, y * ss), ((x + 180) * ss, y * ss)], fill=CREAM + (150,), width=2 * ss)
    bg = panels.copy()
    inner_bg.putalpha(Image.eval(inner_bg.getchannel("A"), lambda v: v))
    bg = Image.alpha_composite(bg, Image.composite(inner_bg, Image.new("RGBA", (w, h), (0, 0, 0, 0)), mask))
    fg = Image.composite(inner_fg, Image.new("RGBA", (w, h), (0, 0, 0, 0)), mask)
    return bg.resize((W, H), Image.LANCZOS), fg.resize((W, H), Image.LANCZOS)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="assets/art06/cutaway")
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    for tick in range(2, 11):
        bg, fg = render(float(tick))
        bg.save(os.path.join(a.out, f"cutaway_bg_{tick:02d}.png"), optimize=True)
        fg.save(os.path.join(a.out, f"cutaway_fg_{tick:02d}.png"), optimize=True)
        print("tick", tick, "covered", covered(float(tick)))


if __name__ == "__main__":
    main()

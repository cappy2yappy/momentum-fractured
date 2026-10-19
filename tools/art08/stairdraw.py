import numpy as np
from PIL import Image, ImageDraw
def stair_polys(plan, jmin=-3, jmax=9):
    """profile polygons (world px) for the treads the plan's feet stand on: each tread is a flat top between riser x midpoints."""
    X, Y = plan.X, plan.Y
    js = sorted(j for j in X if jmin <= j <= jmax)
    polys = []
    for a, b in zip(js, js[1:]):
        pass
    return js
def draw_background(plan, root, size=(480, 724), pivot=(240, 600), col=(60, 62, 80), top=(150, 150, 170)):
    im = Image.new("RGBA", size, (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    js = sorted(plan.X)
    # surface: flat at each foot's Y between riser midpoints
    pts = []
    for i, j in enumerate(js):
        x0 = -1e4 if i == 0 else (plan.X[js[i - 1]] + plan.X[j]) / 2
        x1 = 1e4 if i == len(js) - 1 else (plan.X[j] + plan.X[js[i + 1]]) / 2
        pts.append((x0, x1, plan.Y[j]))
    def c(x, y): return (pivot[0] + x - root[0], pivot[1] + y - root[1])
    for x0, x1, y in pts:
        X0 = max(x0, root[0] - 400); X1 = min(x1, root[0] + 400)
        if X1 <= X0: continue
        a = c(X0, y); b = c(X1, y + 400)
        d.rectangle([a[0], a[1], b[0], b[1]], fill=col + (255,))
        d.line([a, (b[0], a[1])], fill=top + (255,), width=2)
    return im

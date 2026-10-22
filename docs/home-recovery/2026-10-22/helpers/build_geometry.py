import json, ast, re
from PIL import Image
from pathlib import Path
from reportlab.pdfgen import canvas
from reportlab.lib.colors import HexColor,white
from reportlab.platypus import Paragraph
from reportlab.lib.styles import ParagraphStyle
from pypdf import PdfReader,PdfWriter
B=Path.cwd(); src=B/'work/ld07-recovery/docs/ld07'; data=json.loads((src/'evidence/room_inventory.json').read_text())
rooms=[r for r in data if r['comparison']=='open-top']; roofs={r['index']:r for r in data if r['comparison']=='roof-on'}
notes={}
for n in ast.parse((B/'tmp/pdfs/build_master.py').read_text()).body:
 if isinstance(n,ast.Assign) and isinstance(n.targets[0],ast.Name) and n.targets[0].id in ['mainnotes','extra']:notes[n.targets[0].id]=ast.literal_eval(n.value)
notes=notes['mainnotes']+notes['extra']
c=canvas.Canvas(str(B/'tmp/pdfs/geometry_pages.pdf'),pagesize=(792,612));ink=HexColor('#172d38')
style=ParagraphStyle('p',fontName='Helvetica',fontSize=8,leading=10,textColor=ink)
def text(s,x,y,w=185):
 q=Paragraph(s,style);_,h=q.wrap(w,1000);q.drawOn(c,x,y-h);return y-h

def head(title,sub,page):
 c.setFillColor(ink);c.rect(0,548,792,64,fill=1,stroke=0);c.setFillColor(white);c.setFont('Helvetica-Bold',21);c.drawString(26,580,title);c.setFont('Helvetica',9);c.drawString(26,560,sub)
 c.setFillColor(ink);c.setFont('Helvetica',8);c.drawString(26,18,'KAZE / GEOMETRY EDITION / LD-07 RUNTIME EXPORT / 22 OCT 2026');c.drawRightString(766,18,f'GEOMETRY {page} / 22')
head('ACTUAL ROOM GEOMETRY + COLLISION','Companion to the traversal master | 21 rooms | landscape Letter at Actual Size',1)
y=523
for s in [
'<b>What changed</b><br/>The blank room grids are replaced with vector drawings of exported runtime collision rectangles and polygons. Each room has its actual exported size, local coordinate grid, exit markers, major object locations, gates, anchors, and an in-game collision-overlay reference image.',
'<b>How to read the diagrams</b><br/>Blue-gray fill: solid collision. Amber fill and dashed outline: one-way collision. Purple dashed outline: additional roof-on collision, shown only as a comparison. Red circles E1, E2...: exit endpoints, with destinations in the side register. Green squares O1, O2...: major objects, whose coordinates are listed at right. Hollow blue circles: grapple anchors. Orange vertical lines: gate locations and exported heights. Gray X: enemy position present in the export. Red bands at the floor: exported pit intervals.',
'<b>Scale and coordinates</b><br/>Each room preserves its own aspect ratio; scale varies between pages. Grid spacing is 200 game pixels. X increases right; Y increases down. Exit dots indicate departure points, not trigger rectangles or arrival points. Room bounds come from the export, so R17 is 1800 x 2160 rather than the old planning height of 2200.',
'<b>Baseline and limits</b><br/>Source: docs/ld07/evidence/room_inventory.json and docs/ld07/captures/rooms/R00-R20_overview.png in the local ld07-recovery checkout, matching the original print pack. The export contains 42 builds: 21 open-top and 21 roof-on. The main diagrams use open-top collision; purple comparison outlines do not imply roof approval. Screenshots are reference captures, not a statement that every optional mode is active.',
'<b>Object and state coverage</b><br/>Major objects are transcribed from the matching audit and traversal register. The collision drawing uses the exported runtime state; gates and enemies can change with progression. A gate marker is not a claim that its collider was active in that capture. This is not a fresh export from the newest candidate, nor a full inventory of animated art, enemy hitboxes, interaction triggers, or all hazard volumes.',
'<b>Use with the first three pages</b><br/>The traversal master appears first in this combined PDF. Its page numbers remain local to that three-page section. The following geometry section has its own numbering. Mark terrain changes directly on a room diagram and use its notes area for revised objects or exits.'
]:y=text(s,30,y,730)-18
c.showPage()
counts=[]
for r in rooms:
 i=r['index'];w,h=r['size'];head(f'R{i:02d} / {r["name"]}',f'Exported bounds: {int(w)} x {int(h)} px | 200 px grid | open-top + roof comparison',i+2)
 # map box with margin beyond room for walls
 top=min(0,min(sh['rect'][1] for sh in roofs[i]['runtime_shapes'])); span=h-top; scale=min(526/(w+120),410/(span+120));ox=28+(526-(w+120)*scale)/2+60*scale;oy=105+(410-(span+120)*scale)/2+60*scale
 def pt(x,y):return ox+x*scale,oy+(h-y)*scale
 c.setStrokeColor(HexColor('#e4e8ea'));c.setLineWidth(.3)
 for x in range(0,int(w)+1,200):a,b=pt(x,0);d,e=pt(x,h);c.line(a,b,d,e)
 for y0 in range(0,int(h)+1,200):a,b=pt(0,y0);d,e=pt(w,y0);c.line(a,b,d,e)
 c.setFillColor(ink);c.setFont('Helvetica',6)
 for x in range(0,int(w)+1,400):a,b=pt(x,0);c.drawCentredString(a,b+5,str(x))
 for y0 in range(0,int(h)+1,400):a,b=pt(0,y0);c.drawRightString(a-40*scale-4,b-2,str(y0))
 def rect(sh,roof=False):
  x,y,rw,rh=sh['rect'];a,b=pt(x,y+rh)
  c.setLineWidth(.65);c.setDash(3,2) if roof or sh['one_way'] else c.setDash()
  c.setStrokeColor(HexColor('#a04491' if roof else '#a26b10' if sh['one_way'] else '#42616f'))
  c.setFillColor(HexColor('#f8e2a9' if sh['one_way'] else '#c8d5da'));c.rect(a,b,rw*scale,rh*scale,fill=0 if roof else 1,stroke=1);c.setDash()
 for sh in r['runtime_shapes']:rect(sh)
 for poly in r['runtime_polygons']:
  path=c.beginPath();path.moveTo(*pt(*poly[0]))
  for v in poly[1:]:path.lineTo(*pt(*v))
  path.close();c.setFillColor(HexColor('#a8bec8'));c.drawPath(path,fill=1,stroke=1)
 added=[s for s in roofs[i]['runtime_shapes'] if s not in r['runtime_shapes']]
 for sh in added:rect(sh,True)
 for lo,hi in r['floor_gaps']:
  a,b=pt(lo,1372);d,e=pt(hi,1372);c.setStrokeColor(HexColor('#b83f42'));c.setLineWidth(2);c.line(a,b,d,e)
 for at in r['anchors']:
  a,b=pt(*at);c.setStrokeColor(HexColor('#216aaa'));c.setLineWidth(1);c.circle(a,b,3,fill=0)
 for at in r['enemies']:
  a,b=pt(*at);c.setStrokeColor(HexColor('#777777'));c.line(a-3,b-3,a+3,b+3);c.line(a-3,b+3,a+3,b-3)
 for g in r['gates']:
  x,y=g['at'];c.setStrokeColor(HexColor('#d57918'));c.setLineWidth(2);c.line(*pt(x,y),*pt(x,y-g['height']))
 objs=[]
 for part in notes[i].split(';'):
  for m in re.finditer(r'([^();]*?)\((\d+),(\d+)\)',part):objs.append((m.group(1).strip(' .'),int(m.group(2)),int(m.group(3))))
 for k,(label,x,y) in enumerate(objs,1):
  a,b=pt(x,y);c.setFillColor(HexColor('#23754c'));c.rect(a-3,b-3,6,6,fill=1,stroke=0);c.setFont('Helvetica-Bold',7);c.drawString(a-14,b+10+(k%2)*10,f'O{k}')
 for k,e in enumerate(r['endpoints'],1):
  a,b=pt(*e['at']);c.setStrokeColor(HexColor('#b83f42'));c.setFillColor(white);c.circle(a,b,3.2,fill=1);c.setFillColor(HexColor('#a52b2f'));c.setFont('Helvetica-Bold',7);c.drawString(a+5,b+6,f'E{k}')
 y=526;y=text('<b>EXITS / DEPARTURE POINTS</b>',570,y)-5
 for k,e in enumerate(r['endpoints'],1):y=text(f'E{k} > R{e["target"]:02d} / {e["mode"].replace("_"," ")}<br/>({int(e["at"][0])}, {int(e["at"][1])})',570,y)-5
 y-=6;y=text('<b>MAJOR OBJECTS</b>',570,y)-5
 for k,(label,x,y0) in enumerate(objs,1):y=text(f'O{k} {label} ({x},{y0})',570,y)-4
 if not objs:y=text(notes[i],570,y)-5
 if r['gates']:y=text('<b>Gate markers:</b> '+', '.join(g['id'].replace('_',' ') for g in r['gates']),570,y)-8
 y=text(f'<b>Collision inventory:</b> {len(r["runtime_shapes"])} rectangles; {len(r["runtime_polygons"])} polygons; {sum(s["one_way"] for s in r["runtime_shapes"])} one-way. Roof comparison: +{len(added)} rectangle(s).',570,y)-10
 shot=src/f'captures/rooms/R{i:02d}_overview.png';assert shot.exists()
 sy=min(y-108,160);assert sy>45,(i,sy)
 im=Image.open(shot).convert('RGB');im.thumbnail((700,400));thumb=B/f'tmp/pdfs/ref-{i:02d}.jpg';im.save(thumb,quality=85)
 c.drawImage(str(thumb),570,sy,width=196,height=110.25,preserveAspectRatio=True,anchor='c');text('In-game collision-overlay reference',570,sy-3)
 text('<b>MARKUP:</b> terrain / collision / objects / exits',30,83,520)
 c.setStrokeColor(HexColor('#aebdc3'));c.setLineWidth(.4)
 for yy in [57,39]:c.line(30,yy,552,yy)
 counts.append([i,len(r['runtime_shapes']),len(r['runtime_polygons']),len(r['endpoints'])]);c.showPage()
c.save()
writer=PdfWriter()
for file in ['output/pdf/Kaze_Traversal_Master_Sheet.pdf','tmp/pdfs/geometry_pages.pdf']:
 writer.append(str(B/file))
output=B/'output/pdf/Kaze_World_Design_Geometry_Edition.pdf'
with output.open('wb') as f:writer.write(f)
assert len(PdfReader(output).pages)==25
print(output);print('21 rooms, 25 combined pages; counts:',counts)

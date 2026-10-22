import json,zipfile,re
from reportlab.pdfgen import canvas
from reportlab.lib import colors
from reportlab.platypus import Paragraph,Table,TableStyle
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.enums import TA_LEFT
from pathlib import Path
base=Path.cwd()
with zipfile.ZipFile('/Users/tonysantiago/Downloads/Kaze_World_Design_Pack (1).zip') as z: rooms=json.loads(z.read('kaze_map_pack/ROOM_REFERENCE.json'))
out=base/'output/pdf/Kaze_Traversal_Master_Sheet.pdf'
c=canvas.Canvas(str(out),pagesize=(792,612));c.setTitle('Kaze | Traversal Master Sheet')
ink=colors.HexColor('#172d38');teal=colors.HexColor('#176b70')
style=ParagraphStyle('cell',fontName='Helvetica',fontSize=8,leading=10,textColor=ink)
def p(s): return Paragraph(s,style)
def header(title,sub,num):
 c.setFillColor(ink);c.rect(0,540,792,72,fill=1,stroke=0);c.setFillColor(colors.white);c.setFont('Helvetica-Bold',23);c.drawString(30,577,title);c.setFont('Helvetica',10);c.drawString(30,554,sub)
 c.setFillColor(ink);c.setFont('Helvetica',8);c.drawString(30,20,'KAZE / PRINT PACK COMPANION / LD-07 BASELINE / 22 OCT 2026');c.drawRightString(762,20,f'{num} / 3')
def text(s,x,y,w=732):
 q=p(s);_,h=q.wrap(w,500);q.drawOn(c,x,y-h);return h

def table(rows,widths,y):
 t=Table([[p(str(a)) for a in row] for row in rows],colWidths=widths)
 t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),colors.HexColor('#d9e9e9')),('VALIGN',(0,0),(-1,-1),'TOP'),('GRID',(0,0),(-1,-1),.35,colors.HexColor('#aebfc3')),('ROWBACKGROUNDS',(0,1),(-1,-1),[colors.white,colors.HexColor('#f3f6f6')]),('LEFTPADDING',(0,0),(-1,-1),7),('RIGHTPADDING',(0,0),(-1,-1),7),('TOPPADDING',(0,0),(-1,-1),3),('BOTTOMPADDING',(0,0),(-1,-1),3)]))
 _,h=t.wrap(732,500);assert y-h>39,(y,h);t.drawOn(c,30,y-h);return y-h
header('TRAVERSAL MASTER','Main progression, optional branches, return loops and unlock milestones',1)
text('<b>Read order:</b> Follow steps 01-13 for the main progression. Branch letters are optional exploration routes, not additional mandatory steps. This is a planning guide derived from the matching LD-07 baseline; it is not a fresh playthrough certification.',30,524)
for i,r in enumerate(rooms[:13]):
 row=i//7; col=i%7;x=30+col*105;y=440-row*76
 c.setFillColor(colors.HexColor('#eaf2f2'));c.roundRect(x,y,98,55,5,fill=1,stroke=0)
 text(f'<b>{i+1:02d} / R{i:02d}</b><br/>{r["name"]}',x+6,y+46,86)
 if col<6 and i<12: text('&gt;',x+99,y+34,8)
text('Main route continues from R06 to R07 on the second row. After R12: unlock the return to R08.',30,354)
rows=[['BRANCH','CONNECTED ROUTE','WHEN TO USE / REQUIREMENTS'],['A / Rooftops','R00 > R13 > R14 > R09','Windstep opens R00-R13-R14. R14-R09 requires Archive restoration. Stride I is in R13.'],['B / Lower route','R02 > R15 > R16 > R08','R02-R15 needs Wind kunai + cistern cache gate open. R15-R16-R08 requires Archive restoration.'],['C / Spire','R05 > R17 > R14','Wind Tether + Gale Dash. R17-R20 additionally needs Archive restored + spire Wind shutter open.'],['D / Service route','R08 > R16 > R18 > R19 > R11','Archive opens R16/R18 access. R18-R19 needs regional unlock + Electric isolator; R19-R11 needs regional unlock.'],['E / Junction loop','R19 > R20 > R13','Regional unlock + coil Fire gate for R19-R20. Activate the return at R20 (600,520) to open the Wind-fold to R13.']]
bottom=table(rows,[83,166,483],331)
text('<b>Regional unlock:</b> Archive restored + all three named sigils + Skyworks Wind intake open. <b>Sigils:</b> R08 undercroft; R09 west terrace and fire cache. <b>Return seals:</b> R03-R09 and R08-R12 are story-gated; do not use them to skip first-pass progression.',30,bottom-12)
text('<b>Source scope:</b> Existing 23-page World Design Print Pack / ROOM_REFERENCE.json, plus matching local LD-07 ROOM_AUDIT.md and world.gd / world_expansion.gd. Exit types are copied per departing room, including asymmetric pairs. Newer candidate builds were not substituted.',30,79)
c.showPage()
mainnotes=[
'Spawn / shrine (220,1300).',
'Windstep + Wind kunai (1580,1300).',
'Pits; Wind cache gate (2150,850); cache (2300,830).',
'Wind Tether (1320,1300).',
'Fire kunai (1080,980); Fire cache gate (1990,1080); pits.',
'Gale Dash (1320,1300); Electric kunai (1510,930); pits.',
'Tide Warden boss. Defeat to open R07.',
'Electric seal (2000,1300); Archive control (2200,1190).',
'Shrine (2060,1300); undercroft sigil (1470,690).',
'West sigil (1490,600); Fire gate (2110,810); cache sigil (2240,770).',
'Wind intake gate (2110,810).',
'Rest station (1720,1300); Electric relay gate (2370,760).',
'Storm Keeper (1320,1300); relay (2220,1300).']
needs=['Start; main exit to R01.','Windstep to R02.','Continue east to R03.','Tether to R04.','Continue to R05.','Dash to R06.','Boss defeated to R07.','Restore Archive to R08.','Collect sigil, then R09.','All 3 sigils to R10.','Open Wind intake to R11.','Open Electric relay to R12.','After Keeper: return to R08.']
def exits(r):return '<br/>'.join(f'R{e["destination"]:02d} { {"walk":"W","depth":"D","stair":"S","wind-fold":"F"}[e["type"]]} ({e["x"]},{e["y"]})' for e in r['exits'])
header('MAIN ROUTE / ROOM REGISTER','01-13 traversal sequence | all outgoing exits | major objects and progression checks',2)
rows=[['STEP / ROOM','EXITS: DESTINATION / TYPE / (X,Y)','OBJECTS / LANDMARKS','NEXT-STEP CHECK']]
for i,r in enumerate(rooms[:13]):rows.append([f'<b>{i+1:02d} / R{i:02d}</b> {r["name"]}',exits(r),mainnotes[i],needs[i]])
table(rows,[140,182,245,165],527)
text('<b>Key:</b> W walk-through / D depth-interact / S stair / F Wind-fold. Coordinates are room-local pixels, Y increases downward. Exit positions identify departure endpoints, not arrival coordinates. Original print-pack page = room ID + 3.',30,68)
c.showPage()
header('BRANCH ROOMS / OBJECT REGISTER','R13-R20 are exploration loops | revisit when requirements are met',3)
extra=[
'Stride I (450,440); Wind-fold (900,400).',
'Optional log (1300,1220); stair (1450,480); lower service walk.',
'Optional Wind gate (500,500); log (390,500); dry descent.',
'Save shrine (420,1120); log (1500,760).',
'Wind shutter (1430,420); log (1370,420); vertical climb.',
'Electric isolator (2370,760); log (1690,620).',
'Fire gate (1730,480); log (1960,520).',
'Return activation / Wind-fold (600,520); log (1800,1120).']
bn=['A / Windstep; return from R20 needs activated junction.','A,C / Windstep to R13; Archive to R09; Tether + Dash to R17.','B / Wind + cistern cache to R02; Archive to R16.','B,D / Archive for every listed connection.','C / Tether + Dash to R05/R14; Archive + climb + shutter to R20.','D / Archive to R08/R16; regional + isolator to R19.','D,E / Regional to R11; regional + isolator to R18; regional + Fire gate to R20.','E / Spire conditions to R17; regional + Fire gate to R19; regional + return activation to R13.']
rows=[['ROOM / BRANCH','ALL OUTGOING EXITS','OBJECTS / LANDMARKS','ACCESS CHECK']]
for j,r in enumerate(rooms[13:]):rows.append([f'<b>R{r["id"]:02d} {r["name"]}</b>',exits(r),extra[j],bn[j]])
b=table(rows,[140,182,215,195],527)
text('<b>How to mark up:</b> Circle the exit used, number any added objects, and note revised unlocks below. Object lists cover major progression and reference objects, not every enemy, grapple anchor, platform or collider. Unlisted coordinates have not been invented.',30,b-12)
text('<b>Design notes / changes:</b>',30,103)
for y in [77,57]:c.setStrokeColor(colors.HexColor('#bbc6c9'));c.line(30,y,762,y)
c.save()
print(out)

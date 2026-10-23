"""Reproduce CIN-04 review scenes. Edit saved native scenes; regeneration overwrites edits."""
from pathlib import Path
import json, random
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'presets/cutins/story'
OUT.mkdir(parents=True,exist_ok=True)
def v(x,y):return f'Vector2({x}, {y})'
def c(h,a=1):
 h=h.lstrip('#');return 'Color('+', '.join(str(round(int(h[i:i+2],16)/255,4)) for i in (0,2,4))+f', {a})'
def q(s):return json.dumps(s)
def build(key,title,duration,line,kind):
 nodes=[]; count=0
 def node(name,typ,parent='.',props=''):
  nodes.append(f'[node name="{name}" type="{typ}"'+(f' parent="{parent}"' if parent is not None else '')+']\n'+props)
 def poly(name,points,color,parent='Framing/Shake/Set',alpha=1):
  node(name,'Polygon2D',parent,'polygon = PackedVector2Array('+', '.join(str(n) for p in points for n in p)+')\ncolor = '+c(color,alpha))
 def rect(name,x,y,w,h,color,parent='Framing/Shake/Set',alpha=1):
  poly(name,[(x,y),(x+w,y),(x+w,y+h),(x,y+h)],color,parent,alpha)
 def ln(name,pts,color,width=2,parent='Framing/Shake/Set'):
  node(name,'Line2D',parent,'points = PackedVector2Array('+', '.join(str(n) for p in pts for n in p)+f')\nwidth = {width}\ndefault_color = '+c(color))
 node('StoryCutIn','Node2D',None,'script = ExtResource("stage")\nartwork_status = "CIN-04 review staging; approved Kaze sheets unchanged. Props and reactions are proposals."')
 node('Framing','Node2D');node('Shake','Node2D','Framing');node('Set','Node2D','Framing/Shake')
 rect('Night',-600,-500,2400,1500,'101b25')
 # Architectural depth: distant ruined refuge passage, no campaign identity.
 for i,x in enumerate(range(-200,1500,180)):
  rect(f'FarPier{i}',x,70,55,520,'1b3039')
  poly(f'Arch{i}',[(x+45,170),(x+90,100),(x+150,100),(x+190,170),(x+190,210),(x+150,151),(x+95,151),(x+45,222)],'25404a')
  ln(f'FarEdge{i}',[(x+55,210),(x+55,530)],'35515a',2)
 for i in range(8):
  rect(f'Steps{i}',-100,480+i*14,1550,12,'233741' if i%2 else '293d45')
 poly('ColdLight',[(840,-100),(1000,-100),(730,590),(340,590)],'82aba3',alpha=.08)
 poly('ColdLightNarrow',[(990,-100),(1030,-100),(800,590),(690,590)],'cad9bc',alpha=.07)
 rect('Floor',-600,565,2400,460,'172a32')
 ln('FloorLip',[(-400,565),(1500,565)],'637a77',3)
 for i in range(12):
  ln(f'FloorJoint{i}',[(-400+i*165,565),(-650+i*205,900)],'2b4249',2)
 for i,y in enumerate([615,690,805]):ln(f'FloorRow{i}',[(-600,y),(1800,y)],'2b4249',2)
 # Broken near columns frame the view, rather than flattening the scene.
 for i,x in enumerate([-40,1175]):
  rect(f'PierBase{i}',x-25,490,140,88,'293b43')
  poly(f'Pier{i}',[(x,500),(x,80),(x+35,58),(x+50,90),(x+76,42),(x+91,105),(x+91,500)],'344a50')
  rect(f'PierFace{i}',x+10,130,15,360,'4b6263')
  ln(f'PierCrack{i}',[(x+65,120),(x+41,210),(x+69,267),(x+50,350)],'142730',4)
  rect(f'PierFoot{i}',x-12,487,119,13,'637575')
 # Fallen beam and splinters.
 poly('BrokenLintel',[(120,440),(410,365),(428,381),(390,393),(409,410),(130,465)],'56605b')
 ln('LintelRidge',[(130,443),(404,376)],'959783',3)
 rng=random.Random(41+kind)
 for i in range(35):
  x=rng.randint(60,1210);y=rng.randint(551,638);s=rng.randint(4,15)
  poly(f'Rubble{i}',[(x,y),(x+s,y-s*.4),(x+s*2,y+4),(x+5,y+8)],'3f5154' if i%3 else '65736b')
 # All meaningful props are independent editable nodes.
 node('Evidence','Node2D','Framing/Shake')
 p='Framing/Shake/Evidence'
 if kind==0:
  poly('UnfastenedSatchel',[(762,537),(774,504),(827,500),(847,536),(834,559),(778,560)],'6e5b50',p)
  poly('OpenFlap',[(774,506),(787,477),(835,482),(827,510)],'9b8265',p)
  ln('SatchelStrap',[(771,524),(745,483),(750,468),(790,498)],'b19c7a',5,p)
  poly('MendedWrap',[(828,532),(867,525),(902,545),(925,549),(913,566),(881,564),(856,549),(834,550)],'b6b4a0',p)
  ln('Mending',[(856,540),(884,553),(908,558)],'6d8984',2,p)
  for i in range(7):ln(f'Stitch{i}',[(854+i*8,537+i*2.5),(852+i*8,545+i*2.5)],'dce1c7',2,p)
  poly('Cup',[(714,555),(724,535),(743,542),(736,563)],'8eaaa5',p)
  ln('CupCrack',[(729,541),(725,552),(731,557)],'344c55',2,p)
 elif kind==1:
  # Shield faces the damaged approach; carrying frame lies protected behind it.
  poly('BracedShield',[(720,436),(779,415),(824,441),(809,529),(765,558),(728,526)],'5c7578',p)
  poly('ShieldInset',[(733,445),(778,430),(811,448),(798,522),(766,542),(741,518)],'263f49',p)
  ln('ShieldRim',[(720,436),(779,415),(824,441),(809,529),(765,558),(728,526),(720,436)],'b2b7a3',4,p)
  for i in range(3):ln(f'Impact{i}',[(741+i*14,456),(762+i*14,478)],'adb2a0',3,p)
  ln('Brace',[(796,471),(868,560)],'8f7760',12,p)
  ln('BrokenSpear',[(684,562),(811,458)],'a69c7c',5,p)
  poly('SpearBreak',[(803,460),(821,442),(813,462),(827,451),(818,468)],'c5c5aa',p)
  ln('CarryingFrame',[(907,553),(916,481),(989,487),(1005,558)],'9b896a',7,p)
  ln('FrameCrossbar',[(914,514),(994,520)],'8e8066',6,p)
  poly('ShelteredBlanket',[(927,498),(970,501),(986,531),(975,549),(922,542)],'a5aca0',p)
  # Empty gap on right is the escape direction, without assigning a destination.
 else:
  # Anonymous, fully covered defender silhouettes. No anatomy, crest, name or loot.
  for i,(x,y,s) in enumerate([(790,548,1),(1000,509,.73)]):
   pts=[(0,0),(8,-12),(12,-24),(23,-30),(34,-29),(42,-19),(51,-22),(64,-35),(88,-35),(122,-18),(164,-12),(183,0)]
   poly(f'CoveredDefender{i}',[(x+px*s,y+py*s) for px,py in pts],'778985' if i==0 else '4a6567',p)
   ln(f'ClothFold{i}',[(x+24*s,y-9*s),(x+66*s,y-22*s),(x+116*s,y-9*s),(x+169*s,y-5*s)],'b2b9a5' if i==0 else '748c85',2,p)
   ln(f'ClothHem{i}',[(x+4*s,y),(x+174*s,y)],'c6c7ae' if i==0 else '78928b',2,p)
  poly('DefenderGuard',[(746,551),(755,525),(780,529),(792,551),(773,565)],'5c7276',p)
  ln('GuardEdge',[(746,551),(755,525),(780,529)],'a3afa1',3,p)
 # approved actor sprite; art data stays byte-identical
 node('Character','Sprite2D','Framing/Shake','position = Vector2(485, 566)\nscale = Vector2(0.67, 0.67)\ntexture = ExtResource("idle")\nhframes = 8\noffset = Vector2(0, -229)')
 node('Foreground','Node2D','Framing/Shake')
 poly('NearShadow',[(-350,680),(145,612),(280,673),(560,703),(930,651),(1380,649),(1550,1000),(-350,1000)],'0b171f','Framing/Shake/Foreground')
 # cinematic bars and editable title/subtitle
 for name,y,h in [('Top',0,70),('Bottom',636,84)]:
  node(name,'ColorRect','.',f'offset_top = {y}.0\noffset_right = 1280.0\noffset_bottom = {y+h}.0\nmouse_filter = 2\ncolor = '+c('090f16'))
 node('Title','Label','.','offset_left = 44.0\noffset_top = 23.0\ntext = '+q(title)+'\ntheme_override_colors/font_color = '+c('d9d7bf')+'\ntheme_override_font_sizes/font_size = 19')
 node('Status','Label','.','offset_left = 825.0\noffset_top = 25.0\ntext = '+q('PROVISIONAL / LOCATION & IDENTITIES UNASSIGNED' if kind==2 else 'CIN-04 / CREATOR REVIEW')+'\ntheme_override_font_sizes/font_size = 12\ntheme_override_colors/font_color = '+c('889e9b'))
 node('Destination','Label','.','offset_left = 100.0\noffset_top = 658.0\noffset_right = 1180.0\noffset_bottom = 704.0\nhorizontal_alignment = 1\ntext = ""\ntheme_override_font_sizes/font_size = 23\ntheme_override_colors/font_color = '+c('e3e0cf'))
 node('Fade','ColorRect','.','offset_right = 1280.0\noffset_bottom = 720.0\nmouse_filter = 2\ncolor = '+c('090f16',0))
 node('Music','AudioStreamPlayer');node('SFX','AudioStreamPlayer')
 node('AnimationPlayer','AnimationPlayer','.','libraries = {&"": SubResource("library")}')
 def anim(name,reduced=False,reset=False):
  tracks=[]
  def tr(path,times,values,discrete=False):
   i=next((j for j,t in enumerate(tracks) if 'NodePath(\"'+path+'\")' in t),len(tracks))
   entry=(f'tracks/{i}/type = "value"\ntracks/{i}/path = NodePath("{path}")\ntracks/{i}/interp = {0 if discrete else 1}\ntracks/{i}/enabled = true\ntracks/{i}/keys = {{\n"times": PackedFloat32Array('+', '.join(map(str,[0] if reset else times))+'),\n"transitions": PackedFloat32Array('+', '.join(['1']*(1 if reset else len(times)))+'),\n"update": '+str(1 if discrete else 0)+',\n"values": ['+', '.join(values[:1] if reset else values)+']\n}')
   if i<len(tracks): tracks[i]=entry
   else: tracks.append(entry)
  tr('.:handoff',[0,duration],['false','true'],True)
  tr('.:shake_strength',[0],['0.0'])
  tr('.:sample_time',[0,duration],['0.0',str(duration)])
  # Wide -> evidence -> shared reaction. Reduced version remains static and readable.
  tr('Framing:position',[0,2.8,5.3,8.4,duration-1],[v(0,0),v(0,0),v(-200,-87),v(-95,-40),v(-95,-40)] if not reduced else [v(0,0)]*5)
  tr('Framing:scale',[0,2.8,5.3,8.4,duration-1],[v(1,1),v(1,1),v(1.23,1.23),v(1.12,1.12),v(1.12,1.12)] if not reduced else [v(1,1)]*5)
  tr('Framing/Shake/Foreground:position',[0,5.3,8.4],[v(0,0),v(-20,6),v(-8,2)] if not reduced else [v(0,0)]*3)
  tr('Framing/Shake/Character:position',[0,1.1,2.3,7,8,duration],[v(375,566),v(375,566),v(485,566),v(485,566),v(485,571 if kind==2 else 568),v(485,571 if kind==2 else 568)] if not reduced else [v(485,566)]*6)
  tr('Framing/Shake/Character:texture',[0,1.1,2.3],['ExtResource("idle")','ExtResource("run")','ExtResource("idle")'] if not reduced else ['ExtResource("idle")']*3,True)
  tr('Framing/Shake/Character:hframes',[0],['8'],True)
  tr('Framing/Shake/Character:scale',[0],[v(.67,.67)])
  tr('Framing/Shake/Character:offset',[0,1.1,2.3],[v(0,-229),v(0,-229) if reduced else v(0,-198),v(0,-229)])
  times=[0];frames=['0']
  for i in range(1,int(duration*8)):
   t=round(i/8,3);times.append(t)
   frames.append(str((i%8) if t<7 else (4 if kind==2 else 0)))
  tr('Framing/Shake/Character:frame',times,frames,True)
  tr('Framing/Shake/Character:rotation',[0],['0.0'])
  if kind==2:
   # Approved crouch pose repurposed as a quiet lowering-to-ground reaction.
   tr('Framing/Shake/Character:texture',[0,1.1,2.3,7.8],['ExtResource(\"idle\")','ExtResource(\"idle\")' if reduced else 'ExtResource(\"run\")','ExtResource(\"idle\")','ExtResource(\"crouch\")'],True)
   tr('Framing/Shake/Character:offset',[0,1.1,2.3,7.8],[v(0,-229),v(0,-229) if reduced else v(0,-198),v(0,-229),v(0,-148)],True)
   tr('Framing/Shake/Character:position',[0,1.1,2.3,duration],[v(605,566) if reduced else v(375,566),v(605,566) if reduced else v(375,566),v(605,566),v(605,566)])
   tr('Framing/Shake/Character:frame',[0,1,2.3,7.8],['0','1','0','0'],True)
  tr('Destination:text',[0,7.8,duration-.7],['""',q(line),'""'],True)
  tr('Fade:color',[0,.8,duration-.8,duration],[c('090f16',1),c('090f16',0),c('090f16',0),c('090f16',1)])
  return f'[sub_resource type="Animation" id="{name}"]\nresource_name = "{name}"\nlength = {.001 if reset else duration}\n'+'\n'.join(tracks)
 ext='\n'.join(['[ext_resource type="Script" path="res://tools/cin_tools_01/presentation.gd" id="stage"]','[ext_resource type="Texture2D" path="res://assets/kaze/cleaned/kaze_idle_strip.png" id="idle"]','[ext_resource type="Texture2D" path="res://assets/kaze/cleaned/kaze_run_strip.png" id="run"]','[ext_resource type="Texture2D" path="res://assets/kaze/cleaned/kaze_traversal_strip.png" id="crouch"]'])
 text='[gd_scene load_steps=9 format=3]\n'+ext+'\n'+anim('standard')+'\n'+anim('reduced',True)+'\n'+anim('RESET',True,True)+'\n[sub_resource type="AnimationLibrary" id="library"]\n_data = {&"standard": SubResource("standard"), &"reduced": SubResource("reduced"), &"RESET": SubResource("RESET")}\n'+'\n\n'.join(nodes)+'\n'
 (OUT/(key+'.tscn')).write_text(text,encoding='utf-8',newline='\n')
build('aftermath','01 / AFTERMATH',12,'The refuge was attacked. I have to find the others.',0)
build('resistance','02 / EVIDENCE OF RESISTANCE',14,'They held this passage... so others could get through.',1)
build('fallen_defenders','03 / FALLEN DEFENDERS',16,"I'm sorry.",2)

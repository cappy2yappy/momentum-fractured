import argparse,os,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--godot',required=True);args=p.parse_args()
root=Path(__file__).resolve().parents[2];engine=Path(args.godot).resolve()
profile=root/'build/ld08/profiles/captures';profile.mkdir(parents=True,exist_ok=True)
env=os.environ.copy();env['APPDATA']=str(profile)
for mode,flag in [('before','--ld08-before'),('after',''),('roof','--ld08-roof-reference')]:
 cmd=[str(engine),'--path',str(root),'--rendering-method','gl_compatibility','--script','res://tools/ld08/capture.gd','--','res://tools/ld08/capture_spec.json',f'res://docs/ld08/captures/{mode}','--test']
 if flag:cmd.append(flag)
 with (root/f'docs/ld08/evidence/capture_{mode}.log').open('w') as f:r=subprocess.run(cmd,env=env,stdout=f,stderr=subprocess.STDOUT,timeout=90)
 print(mode,r.returncode,flush=True)
 if r.returncode:raise SystemExit(r.returncode)

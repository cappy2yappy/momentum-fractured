"""Wait for actual exported Windows launchers from a path containing spaces."""
from pathlib import Path
import subprocess,zipfile,os,json,time
r=Path(__file__).resolve().parents[1];out=r/'build/tr05/spaced candidate';out.mkdir(parents=True,exist_ok=True)
with zipfile.ZipFile(r/'build/tr05/Kaze-TR05-Windows-Demos.zip') as z:z.extractall(out)
rows=[]
profile=r/'build/tr05/launcher-profile';profile.mkdir(exist_ok=True);env=os.environ.copy();env['APPDATA']=str(profile)
for f in sorted(out.glob('Play-*.cmd')):
 log=out/(f.stem+'.log');start=time.monotonic()
 result=subprocess.run(['cmd.exe','/d','/c',f.name,'--headless','--quit-after','8','--log-file',str(log)],cwd=out,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=45)
 text=log.read_text(errors='replace') if log.exists() else ''
 row=dict(launcher=f.name,exit=result.returncode,seconds=round(time.monotonic()-start,2),log_present=log.exists(),engine_banner='Godot Engine v4.6.1' in text,errors=[x for x in text.splitlines() if any(s in x for s in ['SCRIPT ERROR','Parse Error','Failed to load','Could not open'])])
 row['passed']=row['exit']==0 and row['engine_banner'] and not row['errors'];rows.append(row);print(json.dumps(row),flush=True)
(r/'build/tr05/launcher-smoke.json').write_text(json.dumps(rows,indent=2)+'\n')
raise SystemExit(not all(x['passed'] for x in rows))

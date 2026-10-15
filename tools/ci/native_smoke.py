"""Launch the downloaded release package headlessly under a disposable native profile."""
import argparse, hashlib, json, os, pathlib, platform, subprocess, sys, zipfile
from qa import hard_errors
p=argparse.ArgumentParser();p.add_argument('artifact',type=pathlib.Path);p.add_argument('--output',type=pathlib.Path,required=True);args=p.parse_args()
args.output.mkdir(parents=True,exist_ok=True)
manifest=json.loads((args.artifact/'BUILD_MANIFEST.json').read_text())
assert not os.environ.get('EXPECTED_SOURCE_SHA') or manifest['source_sha']==os.environ['EXPECTED_SOURCE_SHA']
archive=args.artifact/manifest['zip']['name']
assert hashlib.sha256(archive.read_bytes()).hexdigest()==manifest['zip']['sha256']
extract=args.output/'game';extract.mkdir(parents=True,exist_ok=True)
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    z.extractall(extract)
if platform.system()=='Windows':
    executable=next(extract.glob('*.exe'))
else:
    executable=next(extract.glob('*.app/Contents/MacOS/*'));executable.chmod(0o755)
profile=(args.output/'profile').resolve();profile.mkdir(parents=True,exist_ok=True)
env=os.environ.copy()
for key in ('HOME','USERPROFILE','APPDATA','LOCALAPPDATA'):env[key]=str(profile)
env['XDG_DATA_HOME']=str(profile/'.local/share')
log=(args.output/'engine.log').resolve()
command=[str(executable.resolve()),'--headless','--fixed-fps','60','--quit-after','120','--log-file',str(log)]
try:
    proc=subprocess.run(command,cwd=extract,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=90)
    output,rc=proc.stdout,proc.returncode
except subprocess.TimeoutExpired as e:
    output,rc=(e.stdout or b'').decode(),124
except OSError as e:
    output,rc=str(e),126
(args.output/'stdout.log').write_text(output)
engine=log.read_text() if log.exists() else ''
errors=hard_errors(output+'\n'+engine)
passed=rc==0 and not errors and 'Godot Engine v4.6.1.stable.official.14d19694e' in output+engine
comparisons=[]
if platform.system()=='Windows' and (extract/'launch.ps1').exists():
    for pilot in ['fresh','walk','stair','special']:
        for treatment in (['graphic'] if pilot=='fresh' else ['plain','graphic','reduced']):
            result=subprocess.run(['powershell.exe','-NoProfile','-ExecutionPolicy','Bypass','-File',str((extract/'launch.ps1').resolve()),'-Pilot',pilot,'-Treatment',treatment,'-Headless','-QuitAfter','120'],cwd=extract,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=90)
            (args.output/f'{pilot}-{treatment}.log').write_text(result.stdout)
            errors_found=hard_errors(result.stdout)
            comparisons.append(dict(pilot=pilot,treatment=treatment,returncode=result.returncode,hard_errors=errors_found))
            passed=passed and result.returncode==0 and not errors_found
report=dict(comparison_launcher_boots=comparisons,status='passed' if passed else 'failed',source_sha=manifest['source_sha'],target=manifest['target'],os=platform.system(),architecture=platform.machine(),returncode=rc,hard_errors=errors,scope='Release executable main-scene headless startup only; graphics, input, interactive gameplay and sustained 60 FPS untested',archive_sha256=manifest['zip']['sha256'])
(args.output/'NATIVE_SMOKE.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report,indent=2))
sys.exit(0 if passed else 1)


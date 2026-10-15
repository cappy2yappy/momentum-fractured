"""Execute all 45 real package launchers with spaced package/save/script/log paths."""
import argparse,json,os,pathlib,platform,subprocess,zipfile
from qa import hard_errors
p=argparse.ArgumentParser();p.add_argument('artifact',type=pathlib.Path);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args()
a.output.mkdir(parents=True,exist_ok=True);m=json.loads((a.artifact/'BUILD_MANIFEST.json').read_text());assert m['source_sha']==os.environ['EXPECTED_SOURCE_SHA']
extract=(a.output/'Comparison Package With Spaces').resolve();extract.mkdir(parents=True,exist_ok=True)
with zipfile.ZipFile(a.artifact/m['zip']['name']) as z:z.extractall(extract)
for f in extract.glob('*.app/Contents/MacOS/*'):f.chmod(0o755)
rows=[]
for mode in m['comparison_modes']:
    for pilot in ['fresh','passage','stair-up','stair-down','depth','reverse-depth','special','structure14','structure15']:
        name=f'Play-{pilot}-{mode}';log=(a.output/(name+' engine.log')).resolve()
        if platform.system()=='Windows':
            command=['cmd.exe','/d','/c','call',str(extract/(name+'.cmd')),'-Headless','-QuitAfter','120','-LogFile',str(log)]
        else:
            launcher=extract/(name+'.command');launcher.chmod(0o755)
            command=[str(launcher),'--headless','--quit-after','120','--log-file',str(log)]
        try:
            r=subprocess.run(command,cwd=extract,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=90)
            output,rc=r.stdout,r.returncode
        except subprocess.TimeoutExpired as e:output,rc=(e.stdout or b'').decode(),124
        except OSError as e:output,rc=str(e),126
        (a.output/(name+' stdout.log')).write_text(output)
        engine=log.read_text() if log.exists() else '';errors=hard_errors(output+'\n'+engine)
        profile=extract/'profiles'/(pilot+'-'+mode)
        passed=rc==0 and not errors and 'Godot Engine v4.6.1.stable.official.14d19694e' in output+engine and profile.is_dir()
        rows.append(dict(launcher=name,returncode=rc,status='passed' if passed else 'failed',hard_errors=errors,package_path_contains_spaces=True,save_path=str(extract/'profiles'/(pilot+'-'+mode)/'comparison.json')))
        print(name,rows[-1]['status'],flush=True)
report=dict(status='passed' if all(r['status']=='passed' for r in rows) and len(rows)==45 else 'failed',source_sha=m['source_sha'],os=platform.system(),architecture=platform.machine(),launcher_count=len(rows),scope='45 actual release launchers, bounded startup/log/profile creation with spaced paths. Mode/save identity asserted separately by source CLI tests; no release memory inspection, interactive/performance certification.',results=rows)
(a.output/'LAUNCHER_VERIFICATION.json').write_text(json.dumps(report,indent=2));raise SystemExit(report['status']!='passed')

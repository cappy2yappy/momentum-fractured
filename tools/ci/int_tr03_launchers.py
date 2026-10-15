"""Execute all 45 real package launchers with spaced package/save/script/log paths."""
import argparse,json,os,pathlib,platform,subprocess,zipfile
from qa import hard_errors
p=argparse.ArgumentParser();p.add_argument('artifact',type=pathlib.Path);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args()
a.output.mkdir(parents=True,exist_ok=True);m=json.loads((a.artifact/'BUILD_MANIFEST.json').read_text());assert m['source_sha']==os.environ['EXPECTED_SOURCE_SHA']
extract=(a.output/'Comparison Package With Spaces').resolve();extract.mkdir(parents=True,exist_ok=True)
with zipfile.ZipFile(a.artifact/m['zip']['name']) as z:z.extractall(extract)
for f in extract.glob('*.app/Contents/MacOS/*'):f.chmod(0o755)
observer=(a.output/'Native Package Observer With Spaces.gd').resolve()
observer.write_text('''extends SceneTree
func _init(): call_deferred("run")
func run():
 await process_frame
 var w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w
 w.set_physics_process(false);w.player.set_physics_process(false)
 var save=""
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--tr03-save="):save=arg.trim_prefix("--tr03-save=")
 var name=save.get_base_dir().get_file()
 var mode=""
 for candidate in ["art-preview","original","refined","reduced","plain"]:
  if name.ends_with("-"+candidate):mode=candidate;break
 var pilot=name.trim_suffix("-"+mode)
 var rooms={"fresh":0,"passage":15,"stair-up":14,"stair-down":17,"depth":14,"reverse-depth":13,"special":20,"structure14":14,"structure15":15}
 var ok=rooms.has(pilot) and w.room==rooms.get(pilot,-1) and w.save_path==save and save.is_absolute_path() and save.contains(" ") and w.embodied_transitions.comparison==mode
 print("PACKAGED_LAUNCHER_PASS" if ok else "FAIL: packaged launcher mismatch", " room=",w.room," mode=",w.embodied_transitions.comparison," save=",w.save_path)
 w.queue_free();current_scene=null
 for tick in 3:await process_frame
 quit(0 if ok else 1)
''')
rows=[]
for mode in m['comparison_modes']:
    for pilot in ['fresh','passage','stair-up','stair-down','depth','reverse-depth','special','structure14','structure15']:
        name=f'Play-{pilot}-{mode}';log=(a.output/(name+' engine.log')).resolve()
        if platform.system()=='Windows':
            command=['cmd.exe','/d','/c','call',str(extract/(name+'.cmd')),'-Headless','-QuitAfter','120','-LogFile',str(log),'-ValidationScript',str(observer)]
        else:
            launcher=extract/(name+'.command');launcher.chmod(0o755)
            command=[str(launcher),'--headless','--quit-after','120','--log-file',str(log),'--script',str(observer)]
        try:
            r=subprocess.run(command,cwd=extract,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=90)
            output,rc=r.stdout,r.returncode
        except subprocess.TimeoutExpired as e:output,rc=(e.stdout or b'').decode(),124
        except OSError as e:output,rc=str(e),126
        (a.output/(name+' stdout.log')).write_text(output)
        engine=log.read_text() if log.exists() else '';errors=hard_errors(output+'\n'+engine)
        passed=rc==0 and not errors and 'PACKAGED_LAUNCHER_PASS' in output+engine
        rows.append(dict(launcher=name,returncode=rc,status='passed' if passed else 'failed',hard_errors=errors,package_path_contains_spaces=True,save_path=str(extract/'profiles'/(pilot+'-'+mode)/'comparison.json')))
        print(name,rows[-1]['status'],flush=True)
report=dict(status='passed' if all(r['status']=='passed' for r in rows) and len(rows)==45 else 'failed',source_sha=m['source_sha'],os=platform.system(),architecture=platform.machine(),launcher_count=len(rows),scope='Actual launchers and exported native code; observer checks room/mode/absolute isolated save. Separate normal main-scene startup; no interactive/performance certification.',results=rows)
(a.output/'LAUNCHER_VERIFICATION.json').write_text(json.dumps(report,indent=2));raise SystemExit(report['status']!='passed')

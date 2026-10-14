"""TR-02 repro: isolated OS profiles, raw logs and exact counts."""
import argparse,json,os,pathlib,re,subprocess,sys,time
p=argparse.ArgumentParser();p.add_argument('--godot',required=True);args=p.parse_args()
r=pathlib.Path(__file__).resolve().parents[1];out=r/'build/tr02/qa';out.mkdir(parents=True,exist_ok=True)
suites=['approved_baseline','approved_combat_swing','annex_expansion','annex_traversal','save_compatibility','skyworks_progression','storm_keeper','movement_momentum','sprite_integration','world_expansion','expansion_gates_save','expansion_traversal','gameplay_stabilization','traversal_transitions','world_cohesion_traversal','integration_candidate','integration_descent','room_transition_prototype','mixed_transitions']
results=[]
def run(name,cmd,profile):
 env=os.environ.copy();folder=out/('profile-'+profile);folder.mkdir(exist_ok=True)
 env['APPDATA']=str(folder);env['XDG_DATA_HOME']=str(folder/'xdg')
 # Do not repurpose HOME. Windows APPDATA and Linux XDG are explicitly isolated.
 start=time.time()
 try:
  result=subprocess.run(cmd,cwd=r,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=300)
  text=result.stdout.decode('utf-8',errors='replace');rc=result.returncode
 except subprocess.TimeoutExpired as e:
  text=(e.stdout or b'').decode('utf-8',errors='replace');rc=124
 (out/(name+'.log')).write_text(text,encoding='utf-8')
 row={'suite':name,'command':cmd,'returncode':rc,'seconds':round(time.time()-start,2),'passes':len(re.findall(r'^PASS:',text,re.M)),'failures':len(re.findall(r'^FAIL:',text,re.M)),'script_errors':len(re.findall(r'SCRIPT ERROR|Parse Error|Failed to load',text)),'diagnostics':[x for x in text.splitlines() if x.startswith(('WARNING:','ERROR:'))]}
 results.append(row);(out/'results.json').write_text(json.dumps(results,indent=2)+'\n',encoding='utf-8');print(name,row['passes'],row['failures'],rc,flush=True)
base=[args.godot,'--headless','--path',str(r)]
run('import',base+['--editor','--import','--quit'],'import')
run('verify_baseline',[sys.executable,'tools/verify_baseline.py'],'verify')
for name in suites:
 run(name,base+(['--fixed-fps','60'] if name=='integration_descent' else [])+['--script','res://tests/'+name+'.gd','--','--test'],name)
for stage in ['prepare','reload']:
 run('profile_'+stage,base+['--script','res://tests/integration_profile.gd','--','--'+stage],'restart-'+str(os.getpid()))
sys.exit(1 if any(x['returncode'] or x['failures'] or x['script_errors'] for x in results) else 0)

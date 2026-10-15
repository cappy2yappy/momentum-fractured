"""Fresh Windows/source verification; profiles and engine settings stay in build/.
Does not overwrite AUD01 historical evidence. No benchmark or listening claims.
"""
import argparse, hashlib, json, os, pathlib, re, subprocess, sys, time
ROOT=pathlib.Path(__file__).resolve().parents[1]
BASE='da121f19f85b49c3bb5e1c7910472c448c673935'

def main():
    p=argparse.ArgumentParser();p.add_argument('--godot',required=True);p.add_argument('--finalize-existing',action='store_true',help='Finalize a completed run from its retained logs; never rerun or invent suite results');a=p.parse_args()
    evidence=ROOT/'docs/agent_handoffs/aud02_evidence';evidence.mkdir(parents=True,exist_ok=True)
    profiles=ROOT/'build/aud02/profiles';profiles.mkdir(parents=True,exist_ok=True)
    rows=[]
    def run(name,args,profile=None):
        if a.finalize_existing:
            output=(evidence/(name+'.txt')).read_text(encoding='utf-8')
            # Every listed suite must have completed with observed exit 0 in the
            # prior run. Explicit completed-exit ledger is created at recovery.
            ledger=json.loads((evidence/'COMPLETED_EXITS.json').read_text())
            assert ledger[name]==0,name
            rows.append(dict(suite=name,returncode=ledger[name],passes=len(re.findall(r'^PASS:',output,re.M)),failures=len(re.findall(r'^FAIL:',output,re.M)),script_errors=len(re.findall('SCRIPT ERROR|Parse Error|Failed to load',output)),seconds=None))
            return output
        env=os.environ.copy();folder=profiles/(profile or name);folder.mkdir(parents=True,exist_ok=True)
        env['APPDATA']=str(folder);env['LOCALAPPDATA']=str(folder)
        command=[a.godot,'--headless','--path',str(ROOT),'--log-file',str(folder/'engine.log')]+args
        start=time.time()
        result=subprocess.run(command,cwd=ROOT,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=180)
        output=result.stdout+result.stderr
        (evidence/(name+'.txt')).write_text(output,encoding='utf-8')
        row=dict(suite=name,returncode=result.returncode,passes=len(re.findall(r'^PASS:',output,re.M)),failures=len(re.findall(r'^FAIL:',output,re.M)),script_errors=len(re.findall('SCRIPT ERROR|Parse Error|Failed to load',output)),seconds=round(time.time()-start,2))
        rows.append(row);print(json.dumps(row),flush=True);return output
    run('import',['--import','--quit'])
    probe=run('profile_isolation',['--script','res://tests/audio_user_path.gd','--','--test'])
    normalized=probe.replace('\\','/')
    assert profiles.as_posix() in normalized, 'Profile isolation not established; do not run save fixtures'
    verification=subprocess.run([sys.executable,'tools/verify_baseline.py'],cwd=ROOT,capture_output=True,text=True,encoding='utf-8',errors='replace')
    (evidence/'verify_baseline.txt').write_text(verification.stdout+verification.stderr,encoding='utf-8')
    assert verification.returncode==0,verification.stdout+verification.stderr
    suites=['approved_baseline','approved_combat_swing','annex_expansion','annex_traversal','save_compatibility','skyworks_progression','storm_keeper','movement_momentum','sprite_integration','world_expansion','expansion_gates_save','expansion_traversal','gameplay_stabilization','traversal_transitions','world_cohesion_traversal','integration_candidate','integration_descent']
    for suite in suites:
        extra=['--fixed-fps','60'] if suite=='integration_descent' else []
        run(suite,extra+['--script','res://tests/'+suite+'.gd','--','--test','--audio-bank=aud02'])
    profile='restart-'+str(time.time_ns())
    for stage in ['prepare','reload']:run('profile_'+stage,['--script','res://tests/integration_profile.gd','--','--'+stage,'--audio-bank=aud02'],profile)
    for bank in ['aud01','aud02']:
        args=['--test']+(['--audio-bank=aud02'] if bank=='aud02' else [])
        for suite in ['audio_foundation','audio_curation']:
            run(suite+'_'+bank,['--script','res://tests/'+suite+'.gd','--']+args)
    # Files that must remain byte-identical; compare Git blobs, avoiding newline ambiguity.
    names=subprocess.check_output(['git','ls-tree','-r','--name-only',BASE],cwd=ROOT,text=True).splitlines()
    checked=[];changed=[]
    for name in names:
        if name.startswith(('scripts/','scenes/','world/','assets/audio/','assets/kaze/','assets/web/')) or name in ['project.godot','default_bus_layout.tres','export_presets.cfg']:
            if name=='scripts/audio/audio_director.gd' or name.endswith('.import'):continue
            expected=subprocess.check_output(['git','show',BASE+':'+name],cwd=ROOT)
            actual=(ROOT/name).read_bytes();checked.append(name)
            if expected!=actual:changed.append(name)
    preservation=dict(base=BASE,checked_count=len(checked),changed=changed,excluded='Only audio_director.gd and import metadata; new AUD02 files are additions.')
    (evidence/'PRESERVATION.json').write_text(json.dumps(preservation,indent=2)+'\n')
    assert not changed,changed
    success=not any(r['returncode'] or r['failures'] or r['script_errors'] for r in rows)
    result=dict(status='PASS' if success else 'FAIL',platform='Windows x86_64',engine=subprocess.check_output([a.godot,'--version'],text=True).strip(),finalized_from_retained_logs=a.finalize_existing,rows=rows,assertions=sum(r['passes'] for r in rows),failures=sum(r['failures'] for r in rows),preservation=preservation,baseline_verifier='PASS',profile_isolation='Confirmed OS.get_user_data_dir points inside build/aud02/profiles before persistence fixtures',audible_listening='NOT PERFORMED',macos_execution='NOT AVAILABLE',latency='NOT MEASURED',sustained_60fps='NOT CERTIFIED')
    (evidence/'RESULTS.json').write_text(json.dumps(result,indent=2)+'\n')
    print('TOTAL',result['assertions'],'assertions',result['status'],flush=True)
    raise SystemExit(0 if success else 1)

if __name__=='__main__':main()

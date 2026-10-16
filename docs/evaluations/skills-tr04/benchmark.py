import argparse, hashlib, io, json, os, pathlib, re, subprocess, sys, tarfile, time
parser=argparse.ArgumentParser();parser.add_argument('--workspace',type=pathlib.Path,default=pathlib.Path(__file__).resolve().parent);args=parser.parse_args()
ROOT=args.workspace.resolve()
REPO=ROOT/'kaze-skill-eval'
RUN=ROOT/'skill-audit-run-v2'
OUT=REPO/'docs/evaluations/skills-tr04'
OUT.mkdir(parents=True,exist_ok=True)
PIN='1835fcca272fd6a925b3d8ad4834fb225a6caef6'
ENGINE=ROOT/'sprite-engine/Godot_v4.6.1-stable_win64_console.exe'
UP=ROOT/'skill-audit-upstream'
repos={'divergent':('thedivergentai/Game-Dev-Agentic-Skills','002d004c50b865406e58b3ec86508adab926d7f4'),'awesome':('gamedev-skills/awesome-gamedev-agent-skills','0a70cfc64672d512c5b5b6006b5dcb5cf90dbdbd'),'haxqer':('haxqer/godot-skill','037c03e9858ae748bf66c010aeb9942dbe9b93d6'),'vl4dt':('vl4dt/godot-skills','1ae280d35f2cc3931d4d8eb63f4bac82d6acf4a0')}
manifest={}
for key,(remote,pin) in repos.items():
    actual=subprocess.check_output(['git','-C',str(UP/key),'rev-parse','HEAD'],text=True).strip()
    assert actual==pin,(key,actual,pin)
    files={}
    packed=subprocess.check_output(['git','-C',str(UP/key),'-c','core.autocrlf=false','archive',pin])
    with tarfile.open(fileobj=io.BytesIO(packed)) as upstream:
        for entry in upstream.getmembers():
            if not entry.isfile(): continue
            b=upstream.extractfile(entry).read()
            files[entry.name]={'sha256':hashlib.sha256(b).hexdigest(),'bytes':len(b)}
    manifest[key]={'repository':remote,'commit':pin,'files':files}
(OUT/'upstream-lock.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
RUN.mkdir(exist_ok=True)
archive=subprocess.check_output(['git','-C',str(REPO),'-c','core.autocrlf=false','archive',PIN])
with tarfile.open(fileobj=io.BytesIO(archive)) as t:
    for m in t.getmembers():
        dest=(RUN/m.name).resolve()
        assert dest.is_relative_to(RUN.resolve()) and (m.isfile() or m.isdir())
    t.extractall(RUN)
tracked=subprocess.check_output(['git','-C',str(REPO),'ls-tree','-r','--name-only',PIN],text=True).splitlines()
def hashes():
    return {n:hashlib.sha256((RUN/n).read_bytes()).hexdigest() for n in tracked}
before=hashes()
rows=[]
def run(name,cmd,expect=0,cwd=RUN):
    profile=ROOT/'skill-audit-profiles-v2'/name
    profile.mkdir(parents=True,exist_ok=True)
    env=os.environ.copy()
    for k in ['APPDATA','LOCALAPPDATA','HOME','XDG_DATA_HOME','XDG_CONFIG_HOME','TMP','TEMP']:
        env[k]=str(profile)
    env['PYTHONDONTWRITEBYTECODE']='1';env['PYTHONIOENCODING']='utf-8'
    env['GIT_DIR']=str(REPO/'.git');env['GIT_WORK_TREE']=str(RUN)
    start=time.monotonic()
    try:
        p=subprocess.run([str(x) for x in cmd],cwd=cwd,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=300)
        text=p.stdout.decode('utf-8',errors='replace');rc=p.returncode
    except subprocess.TimeoutExpired as e:
        text=(e.stdout or b'').decode('utf-8',errors='replace');rc=124
    (OUT/(name+'.txt')).write_bytes(text.encode('utf-8'))
    row={'name':name,'command':[str(x) for x in cmd],'exit':rc,'expected_exit':expect,'seconds':round(time.monotonic()-start,3),'passes':len(re.findall(r'^PASS:',text,re.M)),'failures':len(re.findall(r'^FAIL:',text,re.M)),'script_errors':len(re.findall(r'SCRIPT ERROR|Parse Error|Failed to load',text)),'profile':str(profile),'sha256':hashlib.sha256(text.encode()).hexdigest()}
    rows.append(row)
    (OUT/'benchmark-results.json').write_text(json.dumps(rows,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(row),flush=True)
    return text
run('engine-version',[ENGINE,'--version'])
base=[ENGINE,'--headless','--path',RUN]
run('import-warmup',base+['--editor','--import','--quit'])
run('import-settled',base+['--editor','--import','--quit'])
for stage in ['baseline','pilot']:
    if stage=='pilot':
        hax=UP/'haxqer/skill/godot/scripts'
        run('haxqer-lint',[sys.executable,hax/'debug/lint_project.py',RUN,'--pretty'])
        run('api-positive',[sys.executable,hax/'docs/api_lookup.py','--godot',ENGINE,'--cache-dir',ROOT/'skill-audit-api-cache','--json','CharacterBody2D.move_and_slide','CollisionShape2D.one_way_collision','PhysicsRayQueryParameters2D.create','AnimationPlayer.play','CollisionObject2D.collision_layer'])
        run('api-negative',[sys.executable,hax/'docs/api_lookup.py','--godot',ENGINE,'--cache-dir',ROOT/'skill-audit-api-cache','--json','CharacterBody2D.move_and_snap','CharacterBody2D.move_teleport','CollisionShape2D.one_way_collision_direction'],expect=1)
    for tool in ['verify_baseline','verify_tr03_preservation','verify_tr04_preservation']:
        run(stage+'-'+tool,[sys.executable,'tools/'+tool+'.py'])
    for suite in ['level_geometry','movement_momentum','sprite_integration','art04_transitions','save_compatibility']:
        run(stage+'-'+suite,base+['--script','res://tests/'+suite+'.gd','--','--test'])
after=hashes()
changes=[n for n in before if before[n]!=after[n]]
(OUT/'preservation.json').write_text(json.dumps({'source_commit':PIN,'tracked_files':len(before),'before':before,'after':after,'changed':changes},indent=2)+'\n',encoding='utf-8')
print('TRACKED CHANGES:',changes,flush=True)

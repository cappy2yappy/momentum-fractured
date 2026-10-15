"""Validate the pinned integration's own runner and explicit comparison options."""
import ast,json,os,pathlib,re,subprocess,sys
from qa import ROOT,LOGS,KNOWN,hard_errors

def main(godot):
    runner=ROOT/'tools/run_int_tr03_art04_qa.py'
    tree=ast.parse(runner.read_text())
    suites=set(next(ast.literal_eval(n.value) for n in tree.body if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='suites' for t in n.targets)))
    assert len(suites)==21 and KNOWN<=suites
    completed=subprocess.run([sys.executable,str(runner),'--godot',godot],cwd=ROOT)
    origin=ROOT/'build/int-tr03/qa';raw=json.loads((origin/'results.json').read_text());LOGS.mkdir(parents=True,exist_ok=True)
    expected=suites|{'import_warmup','import','verify_baseline','verify_tr03_preservation','verify_art04_assets','profile_prepare','profile_reload','endpoint_audit'}
    assert {r['name'] for r in raw}==expected and len(raw)==29
    rows=[];failures=[]
    for r in raw:
        output=(origin/(r['name']+'.log')).read_text();(LOGS/(r['name']+'.log')).write_text(output)
        errors=hard_errors(output)
        diagnostic=r['diagnostic_only']
        row=dict(suite=r['name'],returncode=r['exit'],passes=r['passes'],failures=r['failures'],script_errors=r['script_errors'],hard_errors=errors,diagnostic_only=diagnostic,seconds=r['seconds'])
        rows.append(row)
        if r['exit'] or (not diagnostic and (r['failures'] or r['script_errors'] or errors)):failures.append(r['name'])
        if r['name'] in suites and r['passes']==0:failures.append(r['name']+': no assertions')
    flags={'original':['--tr03-original'],'refined':[],'art-preview':['--tr03-art-preview'],'reduced':['--tr03-art-preview','--tr03-reduced-motion'],'plain':['--tr03-art-preview','--tr03-plain']}
    for mode,extra in flags.items():
        profile=ROOT/'build/ci/CLI Profile With Spaces'/mode;profile.mkdir(parents=True,exist_ok=True)
        save=profile/'comparison save.json';env=os.environ.copy();env.update(HOME=str(profile),XDG_DATA_HOME=str(profile/'xdg'),APPDATA=str(profile))
        r=subprocess.run([godot,'--headless','--path',str(ROOT),'--script','res://tests/art04_profile_options.gd','--',f'--tr03-save={save}',f'--expect={mode}']+extra,env=env,cwd=ROOT,capture_output=True,text=True,timeout=90)
        output=r.stdout+r.stderr;name='cli_'+mode;(LOGS/(name+'.log')).write_text(output)
        passes=len(re.findall(r'^PASS:',output,re.M));errors=hard_errors(output)
        rows.append(dict(suite=name,returncode=r.returncode,passes=passes,hard_errors=errors))
        if r.returncode or errors or passes!=(5 if mode=='reduced' else 4):failures.append(name)
    report=dict(status='failed' if failures or completed.returncode else 'passed',qa_mode='candidate-full-regression',source_sha=os.environ['SOURCE_SHA'],suite_count=len(suites),source_action_count=len(raw),source_assertion_count=sum(r['passes'] for r in raw),assertion_count=sum(r['passes'] for r in rows),failures=failures,results=rows)
    (LOGS/'CI_QA_REPORT.json').write_text(json.dumps(report,indent=2));print(json.dumps({k:v for k,v in report.items() if k!='results'},indent=2))
    return int(report['status']!='passed')

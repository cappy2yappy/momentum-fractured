"""Download Actions archives and independently verify exact game-source payloads."""
from pathlib import Path
import argparse,hashlib,importlib.util,io,json,subprocess,zipfile

def main():
 p=argparse.ArgumentParser();p.add_argument('--run',required=True);p.add_argument('--controls',required=True);p.add_argument('--source-root',type=Path,required=True);p.add_argument('--downloads',type=Path,required=True);a=p.parse_args()
 repo=Path(__file__).resolve().parents[2];out=repo/'docs/build06/evidence';out.mkdir(parents=True,exist_ok=True)
 a.downloads.mkdir(parents=True,exist_ok=True)
 def api(path):return json.loads(subprocess.check_output(['gh','api','repos/cappy2yappy/momentum-fractured/'+path]))
 run=api('actions/runs/'+a.run);assert run['head_sha']==a.controls and run['conclusion']=='success'
 jobs=api('actions/runs/'+a.run+'/jobs');artifacts=api('actions/runs/'+a.run+'/artifacts')
 (out/'HOSTED_RUN.json').write_text(json.dumps(run,indent=2)+'\n')
 (out/'HOSTED_JOBS.json').write_text(json.dumps(jobs,indent=2)+'\n')
 (out/'ARTIFACTS.json').write_text(json.dumps(artifacts,indent=2)+'\n')
 loader=importlib.util.spec_from_file_location('build06',repo/'tools/build06/candidate.py');module=importlib.util.module_from_spec(loader);loader.loader.exec_module(module)
 results=[]
 for artifact in artifacts['artifacts']:
  target=a.downloads/(str(artifact['id'])+'.zip')
  with target.open('wb') as stream:subprocess.run(['gh','api','repos/cappy2yappy/momentum-fractured/actions/artifacts/'+str(artifact['id'])+'/zip'],stdout=stream,check=True)
  sha=hashlib.sha256(target.read_bytes()).hexdigest();assert 'sha256:'+sha==artifact['digest']
  with zipfile.ZipFile(target) as outer:
   assert outer.testzip() is None
   if not artifact['name'].startswith('Kaze-BUILD06-'):
    qa=[n for n in outer.namelist() if n.endswith('QA_RESULTS.json')]
    if qa:assert all(c['passed'] for c in json.loads(outer.read(qa[0]))['checks'])
    results.append({'artifact':artifact['name'],'id':artifact['id'],'outer_sha256':sha,'crc':'pass','type':'QA evidence'});continue
   manifest=json.loads(outer.read(next(n for n in outer.namelist() if n.endswith('MANIFEST.json'))))
   assert manifest['source_commit']=='5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c'
   assert manifest['controls_commit']==a.controls
   assert not any(manifest['content'][k] for k in ['approved_transition_art','r18_authored_art','art07_idle_candidates','doorway_issue_42_fix'])
   assert manifest['reproducibility']['resource_payloads_identical']
   inner=outer.read(next(n for n in outer.namelist() if n.endswith(manifest['archive'])))
   assert hashlib.sha256(inner).hexdigest()==manifest['archive_sha256']
   distribution=a.downloads/manifest['archive'];distribution.write_bytes(inner)
   with zipfile.ZipFile(io.BytesIO(inner)) as z:
    assert z.testzip() is None
    assert set(z.namelist())==set(manifest['members'])
    for name,digest in manifest['members'].items():assert hashlib.sha256(z.read(name)).hexdigest()==digest
    pack=next(n for n in z.namelist() if n.endswith('.pck') or n=='Kaze-BUILD06.exe')
    records,scripts=module.pack_records(z.read(pack),a.source_root.resolve())
    assert len(records)==manifest['pck_entries']
    assert module.digest(json.dumps(records,sort_keys=True).encode())==manifest['reproducibility']['canonical_resource_sha256']
    assert len(scripts)==manifest['reproducibility']['source_text_scripts_verified']
    assert not any(n.startswith(('assets/art05/','assets/art06/','assets/art07/')) for n in records)
   label='windows' if 'windows' in artifact['name'] else 'macos'
   (out/(label+'-MANIFEST.json')).write_text(json.dumps(manifest,indent=2)+'\n')
   qa=json.loads(outer.read(next(n for n in outer.namelist() if n.endswith('QA_RESULTS.json'))))
   assert all(c['passed'] for c in qa['checks'])
   (out/(label+'-QA_RESULTS.json')).write_text(json.dumps(qa,indent=2)+'\n')
   results.append({'artifact':artifact['name'],'id':artifact['id'],'outer_sha256':sha,'inner_sha256':manifest['archive_sha256'],'crc':'pass','members_verified':len(manifest['members']),'resource_payloads_verified':len(records),'exact_source_scripts_verified':len(scripts),'expires_at':artifact['expires_at'],'url':'https://github.com/cappy2yappy/momentum-fractured/actions/runs/'+a.run+'/artifacts/'+str(artifact['id'])})
 (out/'DOWNLOADED_VERIFICATION.json').write_text(json.dumps(results,indent=2)+'\n')
 print(json.dumps(results,indent=2))

if __name__=='__main__':main()

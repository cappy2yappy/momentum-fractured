from pathlib import Path
import subprocess,json
root=Path(__file__).resolve().parent.parent
specs=[('A','animation','codex/alpha07-animation','af184380fb690f2c19bac69960b7aacce50f9ff2',85),('B','narrative','codex/alpha07-story-cinematics','af184380fb690f2c19bac69960b7aacce50f9ff2',86),('C','int01-remote-followup','codex/alpha07-int01-remote-followup','2fa6cd6a03de599b7f9098e8bf61f8d770784091',89),('D','compliance','codex/alpha07-compliance','5265e6c6182d883432215f4e9beab50255e48b5e',87),('E','integration-qa-authoritative','codex/alpha07-integration-qa-authoritative','af184380fb690f2c19bac69960b7aacce50f9ff2',90)]
rows=[]
def git(path,*args):return subprocess.check_output(['git','-C',str(path),*args],text=True).strip()
for owner,folder,branch,base,pr in specs:
 path=root/'work'/folder
 if not path.exists():continue
 rows.append(dict(owner='Agent '+owner,branch=branch,worktree=str(path),base_sha=base,tested_local_sha=git(path,'rev-parse','HEAD'),tree_sha=git(path,'rev-parse','HEAD^{tree}'),draft_pr=pr,changed_files=[dict(status=line.split('\t')[0],path=line.split('\t')[-1]) for line in git(path,'diff','--name-status',base,'HEAD').splitlines()]))
snaps={r['pr']:r for r in json.loads((root/'work/final-pr-snapshots.json').read_text())}
for row in rows:
 if row['draft_pr'] in snaps:
  row['published_sha']=snaps[row['draft_pr']]['sha'];row['published_draft_url']=snaps[row['draft_pr']]['url']
 if row['owner']=='Agent E': row['publication_scope']='Separate report/test-only draft; combined fixture source remains local'; row['published_artifact_branch']='codex/alpha07-integration-readiness';row['runtime_source_sha']='892b1ea29ab459d6e6ece1edba0cb88d3ec24972';row['runtime_tree_sha']='bbd3c06f77c8672d1823f1a6b157923706eda457';row['published_artifact_tree_sha']='e7b739b5f9c93f6230fd8eb103030e1170b5b1fe';row['authoritative_report']='outputs/integration-qa-authoritative/REPORT.md'
p=root/'outputs'/'component-inventory.json';p.write_text(json.dumps(rows,indent=2)+'\n')

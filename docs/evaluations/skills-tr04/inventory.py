import io,json,pathlib,re,subprocess,tarfile
root=pathlib.Path(__file__).resolve().parent
out=root/'kaze-skill-eval/docs/evaluations/skills-tr04'
lock=json.loads((out/'upstream-lock.json').read_text())
patterns={
 'process_execution':r'\bsubprocess\.|\bOS\.execute\(|\bOS\.create_process\(|\bos\.system\(|\bexec_module\(',
 'destructive_or_overwrite':r'\brmtree\(|\bunlink\(|\btaskkill\b|\bos\.kill\(|\bwrite_text\(|\bwrite_bytes\(|FileAccess\.WRITE',
 'network_or_install':r'\brequests\.|\burllib\.|\bsocket\.|\blisten\(|WebSocket|\bpip install\b|\bnpm install\b|\bnpx\b|https?://',
 'instruction_boundary':r'ignore.{0,35}(previous|prior|system).{0,20}instruction|disable.{0,30}(permission|sandbox)|bypass.{0,30}(permission|sandbox)',
}
report={}
for key,data in lock.items():
 packed=subprocess.check_output(['git','-C',str(root/'skill-audit-upstream'/key),'-c','core.autocrlf=false','archive',data['commit']])
 rows=[];skills=[];executables=[]
 with tarfile.open(fileobj=io.BytesIO(packed)) as archive:
  for m in archive.getmembers():
   if not m.isfile():continue
   if m.name.endswith('SKILL.md'):skills.append(m.name)
   if pathlib.Path(m.name).suffix in ['.py','.sh','.gd','.ts','.js','.ps1','.cmd']:executables.append(m.name)
   if pathlib.Path(m.name).suffix not in ['.py','.sh','.gd','.ts','.js','.ps1','.cmd','.md','.json']:continue
   text=archive.extractfile(m).read().decode('utf-8',errors='replace')
   for lineno,line in enumerate(text.splitlines(),1):
    for category,pat in patterns.items():
     if re.search(pat,line,re.I):rows.append({'path':m.name,'line':lineno,'indicator':category,'excerpt':line.strip()[:220]})
 report[key]={'commit':data['commit'],'skill_count':len(skills),'skills':skills,'executable_source_count':len(executables),'indicator_counts':{k:sum(x['indicator']==k for x in rows) for k in patterns},'indicators':[x for x in rows if x['indicator']!='network_or_install']}
(out/'static-indicators.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:{n:v for n,v in d.items() if n in ['skill_count','executable_source_count','indicator_counts']} for k,d in report.items()},indent=2))

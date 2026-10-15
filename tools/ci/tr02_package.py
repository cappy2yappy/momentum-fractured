"""Preserve the committed TR-02 launcher recipe without image-generation dependencies."""
import ast, hashlib, json, os, pathlib, zipfile
root=pathlib.Path(os.environ['CI_SOURCE_ROOT'])
assert (root/'scripts/mixed_transitions.gd').is_file()
sha=os.environ['SOURCE_SHA']
recipe=ast.parse((root/'tools/package_tr02.py').read_text())
launcher=next(ast.literal_eval(n.value) for n in recipe.body if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='launcher' for t in n.targets))
readme=next(n.value.args[0].func.value.value for n in recipe.body if isinstance(n,ast.Expr) and isinstance(n.value,ast.Call) and isinstance(n.value.func,ast.Attribute) and n.value.func.attr=='write_text' and n.value.args and isinstance(n.value.args[0],ast.Call) and isinstance(n.value.args[0].func,ast.Attribute) and n.value.args[0].func.attr=='replace')
folder=root/'build/ci/Windows-x86_64'
manifest_path=folder/'BUILD_MANIFEST.json'
m=json.loads(manifest_path.read_text());original=folder/m['zip']['name']
with zipfile.ZipFile(original) as z:
    exe=next(n for n in z.namelist() if n.endswith('.exe'));data=z.read(exe)
archive=folder/f'Kaze-TR02-Mixed-Transitions-Windows-{sha[:8]}.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
    z.writestr('Kaze-TR02.exe',data)
    z.writestr('launch.ps1',launcher)
    z.writestr('README.txt',readme.replace('RUNTIME_SHA',sha))
    for pilot in ['fresh','walk','stair','special']:
        for treatment in (['graphic'] if pilot=='fresh' else ['plain','graphic','reduced']):
            z.writestr(f'Play-{pilot}-{treatment}.cmd',f'@echo off\r\npowershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0launch.ps1" -Pilot {pilot} -Treatment {treatment}\r\n')
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None and len(z.namelist())==13
    members=[dict(path=i.filename,size=i.file_size,sha256=hashlib.sha256(z.read(i)).hexdigest()) for i in z.infolist()]
m.update(feature_set='TR-02 mixed transitions; no AUD-01 audio branch integration',comparison_modes=['walk','stair','special','plain','graphic','reduced','fresh'],members=members)
m['zip']=dict(name=archive.name,size=archive.stat().st_size,sha256=hashlib.sha256(archive.read_bytes()).hexdigest())
manifest_path.write_text(json.dumps(m,indent=2))
original.unlink()
print(json.dumps(m['zip']))


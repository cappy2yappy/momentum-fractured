"""Checksum-pinned official Universal editor and export templates for native macOS CI."""
from pathlib import Path
import hashlib,os,subprocess,urllib.request,zipfile
assets={
'Godot_v4.6.1-stable_macos.universal.zip':'59c7fc792c9a7a9b3c877b43fc6bdedfa3618e90f0d7d5fa77edb8d3bd64568af19bdfa6ecc8ec3eeaa17ad9cb65f7c93760de83b485ae4a33a679e730f7ffd9',
'Godot_v4.6.1-stable_export_templates.tpz':'d80001711c07973b1fd3e88077ba99644e19db7c9e52627e16f38a2937879f809f94dbd8493936fb8204908bbc57a521d41173dce5208061fe4c99772490c541'}
dest=Path(os.environ['RUNNER_TEMP'])/'godot461';dest.mkdir()
for name,digest in assets.items():
 p=dest/name;urllib.request.urlretrieve('https://github.com/godotengine/godot-builds/releases/download/4.6.1-stable/'+name,p)
 assert hashlib.sha512(p.read_bytes()).hexdigest()==digest,name
subprocess.run(['ditto','-x','-k',str(dest/next(iter(assets))),str(dest)],check=True)
godot=dest/'Godot.app/Contents/MacOS/Godot'
assert subprocess.check_output([str(godot),'--version'],text=True).strip()=='4.6.1.stable.official.14d19694e'
templates=Path.home()/'Library/Application Support/Godot/export_templates/4.6.1.stable';templates.mkdir(parents=True,exist_ok=True)
with zipfile.ZipFile(dest/'Godot_v4.6.1-stable_export_templates.tpz') as z:
 for name in ['macos.zip','version.txt']:(templates/name).write_bytes(z.read('templates/'+name))
with open(os.environ['GITHUB_ENV'],'a') as f:f.write('GODOT='+str(godot)+'\nCI_TEMPLATES_DIR='+str(templates)+'\n')

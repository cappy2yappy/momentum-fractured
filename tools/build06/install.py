"""Install checksum-pinned official Godot 4.6.1; never install game dependencies."""
from pathlib import Path
import hashlib,json,os,platform,subprocess,urllib.request,zipfile

ASSETS={
 'windows':('Godot_v4.6.1-stable_win64.exe.zip','088da0457e2d1f7f8a45e6d4605a42b756ea33b9ccd75059bdbc01bb31c2b40d'),
 'macos':('Godot_v4.6.1-stable_macos.universal.zip','f43613ad72ab1cc9ef14383545f4de344844451a5c9c5f4ea4a923f1f34f91e4'),
 'templates':('Godot_v4.6.1-stable_export_templates.tpz','e6d372afd4fdfaae9571eb5e3568afcd96ce6db9a569244034154faf0ac69875')}

def main():
 host={'Windows':'windows','Darwin':'macos'}[platform.system()]
 dest=Path(os.environ['RUNNER_TEMP'])/'build06-engine';dest.mkdir(parents=True,exist_ok=True)
 evidence={}
 for key in [host,'templates']:
  name,digest=ASSETS[key];p=dest/name
  urllib.request.urlretrieve('https://github.com/godotengine/godot-builds/releases/download/4.6.1-stable/'+name,p)
  assert hashlib.sha256(p.read_bytes()).hexdigest()==digest,name
  evidence[name]=digest
 if host=='macos':
  subprocess.run(['ditto','-x','-k',str(dest/ASSETS[host][0]),str(dest)],check=True)
  binary=dest/'Godot.app/Contents/MacOS/Godot'
 else:
  with zipfile.ZipFile(dest/ASSETS[host][0]) as z:z.extractall(dest)
  binary=dest/'Godot_v4.6.1-stable_win64_console.exe'
 assert subprocess.check_output([str(binary),'--version'],text=True).strip()=='4.6.1.stable.official.14d19694e'
 templates=dest/'templates';templates.mkdir(exist_ok=True)
 with zipfile.ZipFile(dest/ASSETS['templates'][0]) as z:
  for name in (['macos.zip'] if host=='macos' else ['windows_release_x86_64.exe'])+['version.txt']:
   (templates/name).write_bytes(z.read('templates/'+name))
 (dest/'INSTALL.json').write_text(json.dumps(evidence,indent=2)+'\n')
 with open(os.environ['GITHUB_ENV'],'a',encoding='utf-8') as f:
  f.write('GODOT='+str(binary)+'\nBUILD06_TEMPLATES='+str(templates)+'\nBUILD06_INSTALL='+str(dest/'INSTALL.json')+'\n')

if __name__=='__main__':main()

"""Guard LD-08 against expanding into another pending redesign or changing movement/save code."""
import hashlib,json,subprocess
from pathlib import Path
root=Path(__file__).resolve().parents[2]
BASE='c2170032d08ea55268313e0020676c743251deab'
def git(*args):return subprocess.check_output(['git','-C',str(root),*args])
changes=git('diff','--name-only',BASE).decode().splitlines()
existing=set(git('ls-tree','-r','--name-only',BASE).decode().splitlines())
unexpected=[p for p in changes if not p.endswith('.import') and ((p in existing and p not in ['scripts/world.gd','scripts/room_boundary.gd']) or (p not in existing and p!='scripts/open_top_boundary.gd' and not p.startswith(('docs/ld08/','tests/ld08/','tools/ld08/'))))]
world=(root/'scripts/world.gd').read_bytes()
baseworld=git('show',f'{BASE}:scripts/world.gd')
checks={
 'only_two_existing_source_files_changed':not unexpected,
 'world_only_adds_scoped_background_draw':world.replace(b'\tRoomBoundary.OpenTop.draw_background(self)\n',b'')==baseworld,
 'controller_identical':(root/'scripts/player.gd').read_bytes()==git('show',f'{BASE}:scripts/player.gd'),
 'room_graph_and_shelves_identical':(root/'scripts/world_expansion.gd').read_bytes()==git('show',f'{BASE}:scripts/world_expansion.gd'),
 'Canal_gatehouse_identical':(root/'scripts/canal_gatehouse.gd').read_bytes()==git('show',f'{BASE}:scripts/canal_gatehouse.gd'),
}
report=dict(base=BASE,checks=checks,unexpected=unexpected,runtime_sha256={p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in ['scripts/world.gd','scripts/room_boundary.gd','scripts/open_top_boundary.gd','scripts/player.gd']})
(root/'docs/ld08/evidence/source_preservation.json').write_text(json.dumps(report,indent=2)+'\n',newline='\n')
print(json.dumps(report,indent=2));raise SystemExit(not all(checks.values()))

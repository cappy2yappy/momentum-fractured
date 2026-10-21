"""Mutation checks for the narrowly scoped PR58 preservation allowance."""
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
HOOK = '\tif index == 13: CanalGatehouse.build(w)\n'

class PreservationGuard(unittest.TestCase):
    def run_guard(self, expansion=None, gatehouse=None):
        with tempfile.TemporaryDirectory(prefix='ld07-guard-') as temp:
            shadow = Path(temp)
            for name in ['.git', 'assets', 'project.godot', 'export_presets.cfg', 'world']:
                (shadow / name).symlink_to(ROOT / name, target_is_directory=(ROOT / name).is_dir())
            (shadow / 'scripts').mkdir();(shadow / 'tools').mkdir()
            for entry in (ROOT / 'scripts').iterdir():
                if entry.name in {'world_expansion.gd', 'canal_gatehouse.gd'}:
                    shutil.copyfile(entry, shadow / 'scripts' / entry.name)
                else:
                    (shadow / 'scripts' / entry.name).symlink_to(entry)
            shutil.copyfile(ROOT / 'tools/verify_tr05_preservation.py', shadow / 'tools/verify_tr05_preservation.py')
            if expansion is not None:
                (shadow / 'scripts/world_expansion.gd').write_text(expansion)
            if gatehouse is not None:
                (shadow / 'scripts/canal_gatehouse.gd').write_text(gatehouse)
            return subprocess.run(['python3', str(shadow / 'tools/verify_tr05_preservation.py')],
                                  stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

    def test_current_passes(self):
        result = self.run_guard()
        self.assertEqual(result.returncode, 0, result.stdout.decode())

    def test_duplicate_or_missing_hook_fails(self):
        text = (ROOT / 'scripts/world_expansion.gd').read_text()
        for replacement in ['', HOOK + HOOK]:
            with self.subTest(replacement=replacement):
                self.assertNotEqual(self.run_guard(expansion=text.replace(HOOK,replacement)).returncode,0)

    def test_unrelated_route_change_fails(self):
        text = (ROOT / 'scripts/world_expansion.gd').read_text()
        self.assertIn('float(step)/count',text)
        self.assertNotEqual(self.run_guard(expansion=text.replace('float(step)/count','float(step)/(count+1)')).returncode,0)

    def test_changed_gatehouse_fails(self):
        text = (ROOT / 'scripts/canal_gatehouse.gd').read_text()
        self.assertNotEqual(self.run_guard(gatehouse=text.replace('const DOOR_X = 120.0','const DOOR_X = 121.0')).returncode,0)

if __name__ == '__main__':
    unittest.main()

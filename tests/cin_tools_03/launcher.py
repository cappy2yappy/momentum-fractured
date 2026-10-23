"""Guard the actual Mac launcher against selecting Godot's headless OS loop."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


class LauncherTest(unittest.TestCase):
    def test_native_arguments_and_disposable_profile(self):
        root = Path(__file__).resolve().parents[2]
        with tempfile.TemporaryDirectory(prefix='cin03-launch-') as folder:
            temporary = Path(folder)
            engine = temporary / 'Godot stub'
            engine.write_text(
                '#!/usr/bin/env python3\n'
                'import json, os, sys\n'
                'if sys.argv[1:] == ["--version"]:\n'
                '    print("4.6.1.stable.official.14d19694e")\n'
                'else:\n'
                '    print(json.dumps({"cwd": os.getcwd(), "args": sys.argv[1:]}))\n'
            )
            engine.chmod(0o755)
            profile = temporary / 'creator review profile'
            profile.mkdir()
            sentinel = profile / 'studio_session.tres'
            sentinel.write_bytes(b'Preserve the existing creator snapshot.\n')
            environment = dict(os.environ, GODOT_BIN=str(engine), CIN_STUDIO_SAVE_DIR=str(profile))
            result = subprocess.run(
                ['zsh', str(root / 'tools/cin_tools_03/launch.command'), '--resolution', '1024x640'],
                cwd=temporary, env=environment, capture_output=True, text=True, timeout=10,
                check=True,
            )
            launched = json.loads(result.stdout.splitlines()[-1])
            args = launched['args']
            self.assertNotIn('--test', args, 'macOS scans even arguments after -- for headless flags')
            self.assertNotIn('--headless', args)
            self.assertEqual(launched['cwd'], str(root))
            self.assertEqual(args[args.index('--path') + 1], str(root))
            self.assertIn('res://tools/cin_tools_03/studio.tscn', args)
            self.assertEqual(args[args.index('--resolution') + 1], '1024x640')
            self.assertEqual(args[args.index('--') + 1:], ['--studio-save-dir=' + str(profile)])
            self.assertEqual(sentinel.read_bytes(), b'Preserve the existing creator snapshot.\n')


if __name__ == '__main__':
    unittest.main()

"""Full existing candidate QA plus audio assertions, with counted raw evidence.

The existing runner manages disposable profiles for persistence suites. The
audio fixture requires --test and never loads or writes gameplay profiles.
"""
import argparse, json, pathlib, re, shutil, subprocess, sys
ROOT = pathlib.Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / 'docs/agent_handoffs/aud01_evidence'

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--godot', default='/Applications/Godot.app/Contents/MacOS/Godot')
    p.add_argument('--reuse-regression', action='store_true', help='Explicitly reuse prior full-run evidence; run audio suite now')
    args = p.parse_args()
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    if not args.reuse_regression:
        subprocess.run([sys.executable, 'tools/run_int01_qa.py', '--godot', args.godot], cwd=ROOT, check=True)
    rows = json.loads((ROOT/'build/int01/logs/int01_reproduction_results.json').read_text())
    for row in rows:
        source = ROOT/'build/int01/logs'/ (row['suite']+'.log')
        text = source.read_text()
        assert not row['returncode'] and not row['failures'] and not row['script_errors'], row['suite']
        if row['suite'] not in ['import','verify_baseline']:
            assert row['passes'] and ('0 failure(s)' in text or row['suite']=='sprite_integration'), row['suite']
        shutil.copy2(source, EVIDENCE/(row['suite']+'.txt'))
    result = subprocess.run([args.godot,'--headless','--path',str(ROOT),'--log-file',str(ROOT/'build/aud01/audio-engine.log'),'--script','res://tests/audio_foundation.gd','--','--test'],cwd=ROOT,capture_output=True,text=True,timeout=120)
    output = result.stdout + result.stderr
    (EVIDENCE/'audio_foundation.txt').write_text(output)
    audio = dict(suite='audio_foundation', returncode=result.returncode, passes=len(re.findall(r'^PASS:',output,re.M)), failures=len(re.findall(r'^FAIL:',output,re.M)), script_errors=len(re.findall(r'SCRIPT ERROR|Parse Error|Failed to load',output)), completion='AUDIO FOUNDATION: 0 failure(s)' in output)
    assert not audio['returncode'] and not audio['failures'] and not audio['script_errors'] and audio['passes'] and audio['completion'], audio
    rows.append(audio)
    report = dict(assignment='AUD-01-0061',engine=subprocess.check_output([args.godot,'--version'],text=True).strip(),base_sha='afecef1922231081807a332c511de85c7941fec8',status='PASS',regression_reused=args.reuse_regression,assertions=sum(r['passes'] for r in rows),failures=0,results=rows,manual_listening='PENDING CREATOR',windows_execution='NOT TESTED',intel_execution='NOT TESTED',sustained_60fps='NOT CERTIFIED')
    (ROOT/'docs/agent_handoffs/AUD01_ALPHA061_TEST_RESULTS.json').write_text(json.dumps(report,indent=2)+'\n')
    print(report['assertions'],'PASS / 0 FAIL')

if __name__=='__main__': main()

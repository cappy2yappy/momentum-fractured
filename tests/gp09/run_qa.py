"""Run GP09 integration and preserved component contracts with private profiles."""
import argparse, os, pathlib, subprocess, json
p=argparse.ArgumentParser()
p.add_argument("--godot",required=True)
args=p.parse_args()
root=pathlib.Path(__file__).resolve().parents[2]
out=root/"docs/gp09/evidence"
out.mkdir(parents=True,exist_ok=True)
suites=["approved_baseline","approved_combat_swing","movement_momentum","sprite_integration","en01/framework","en01/consumer_contract","haz01_toolkit","haz01_contract"]
results=[]
for suite in suites:
    profile=root/"build/gp09/profiles"/suite.replace("/","_")
    profile.mkdir(parents=True,exist_ok=True)
    env=os.environ.copy();env.update(APPDATA=str(profile),LOCALAPPDATA=str(profile))
    cmd=[args.godot,"--headless","--path",str(root),"--script",f"res://tests/{suite}.gd","--","--test"]
    r=subprocess.run(cmd,env=env,capture_output=True,text=True,timeout=60)
    text=r.stdout+r.stderr
    (out/(suite.replace("/","_")+".log")).write_text(text,encoding="utf-8")
    result={"suite":suite,"exit":r.returncode,"passes":text.count("PASS:"),"failures":text.count("FAIL:"),"script_error":"SCRIPT ERROR" in text}
    results.append(result);print(json.dumps(result),flush=True)
(out/"regressions.json").write_text(json.dumps(results,indent=2)+"\n")
raise SystemExit(any(r["exit"] or r["failures"] or r["script_error"] for r in results))

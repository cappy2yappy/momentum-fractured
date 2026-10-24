"""Bounded Windows native run with process CPU totals and frame timings."""
import argparse, ctypes, json, pathlib, subprocess, time
from ctypes import wintypes
p=argparse.ArgumentParser()
p.add_argument('--godot',required=True)
p.add_argument('--project',required=True)
p.add_argument('--output',required=True)
a=p.parse_args()
if pathlib.Path(a.godot).stem.endswith('_console'):
    p.error('Use the actual Godot win64 executable, not its console launcher, for process CPU measurement')
out=pathlib.Path(a.output).resolve(); out.mkdir(parents=True,exist_ok=True)
start=time.perf_counter()
proc=subprocess.Popen([a.godot,'--path',a.project,'--rendering-method','gl_compatibility','--audio-driver','Dummy','--script','res://tests/en02/capture.gd','--quit-after','2400','--','--output='+str(out),'--mode=skirmisher','--no-frames'],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,creationflags=subprocess.CREATE_NO_WINDOW)
try: stdout,_=proc.communicate(timeout=45)
except subprocess.TimeoutExpired:
    proc.kill(); raise
wall=time.perf_counter()-start
times=[wintypes.FILETIME() for _ in range(4)]
ok=ctypes.windll.kernel32.GetProcessTimes(wintypes.HANDLE(int(proc._handle)),*[ctypes.byref(t) for t in times])
cpu=sum((t.dwHighDateTime<<32)+t.dwLowDateTime for t in times[2:])/1e7 if ok else None
report={'returncode':proc.returncode,'process_wall_seconds':wall,'process_cpu_seconds':cpu,'average_logical_core_percent':100*cpu/wall if cpu is not None else None,'note':'Includes process startup. Wall/frame and CPU measurements are separate; not a GPU or full-world performance certification.'}
(out/'process.json').write_text(json.dumps(report,indent=2))
(out/'process.log').write_text(stdout)
print(json.dumps(report))
raise SystemExit(proc.returncode)

"""Encode wall-clock frame timestamps without speeding up playback."""
import json, subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
dest=ROOT/'docs/cin04/captures'
dest.mkdir(parents=True,exist_ok=True)
for key in ['aftermath','resistance','fallen_defenders']:
 folder=ROOT/'build/cin04/video'/key
 data=json.loads((folder/'timing.json').read_text())
 frames=data['frames']
 lines=[]
 for i,row in enumerate(frames):
  file=Path(row['path']).as_posix()
  lines.append("file '"+file+"'")
  delta=frames[i+1]['time']-row['time'] if i+1<len(frames) else 1/24
  lines.append('duration '+str(delta))
 lines.append("file '"+Path(frames[-1]['path']).as_posix()+"'")
 concat=folder/'frames.txt'
 concat.write_text('\n'.join(lines))
 subprocess.run(['ffmpeg','-y','-hide_banner','-loglevel','error','-f','concat','-safe','0','-i',str(concat),'-fps_mode','vfr','-c:v','libx264','-crf','25','-pix_fmt','yuv420p','-movflags','+faststart',str(dest/(key+'.mp4'))],check=True)
 (dest/(key+'_timing.json')).write_text(json.dumps({'clock':data['clock'],'completion_seconds':data['completion_seconds'],'outcome':data['outcome'],'frame_times':[r['time'] for r in frames]},indent=2))

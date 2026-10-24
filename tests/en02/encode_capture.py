"""Encode wall-clock native frames at their measured durations, without retiming."""
import argparse, hashlib, json, pathlib, subprocess

p = argparse.ArgumentParser()
p.add_argument('folder', type=pathlib.Path)
p.add_argument('--ffmpeg', required=True)
p.add_argument('--output', type=pathlib.Path, required=True)
a = p.parse_args()
d = json.loads((a.folder / 'timing.json').read_text())
frames = d['frames']
assert frames and all(frames[i+1]['wall_seconds'] > f['wall_seconds'] for i, f in enumerate(frames[:-1]))
lines = ['ffconcat version 1.0']
for i, f in enumerate(frames):
    end = frames[i+1]['wall_seconds'] if i+1 < len(frames) else d['wall_seconds']
    assert pathlib.PurePath(f['file']).name == f['file']
    lines += [f"file '{f['file']}'", f"duration {max(.001, end-f['wall_seconds']):.6f}"]
lines.append(f"file '{frames[-1]['file']}'")
listing = a.folder / 'frames.ffconcat'
listing.write_text('\n'.join(lines)+'\n')
a.output.parent.mkdir(parents=True, exist_ok=True)
subprocess.run([a.ffmpeg, '-hide_banner', '-loglevel', 'error', '-y', '-safe', '0', '-i', str(listing), '-fps_mode', 'vfr', '-c:v', 'libx264', '-crf', '19', '-pix_fmt', 'yuv420p', '-movflags', '+faststart', str(a.output)], check=True)
print(json.dumps({'output':str(a.output), 'sha256':hashlib.sha256(a.output.read_bytes()).hexdigest(), 'capture_wall_seconds':d['wall_seconds'], 'frames':len(frames), 'retiming':'none; measured wall-clock durations'}))

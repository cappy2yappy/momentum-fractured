"""New opt-in dry/organic action study; seed 2061; NO source recordings read.

Requires numpy and scipy. Does not regenerate or overwrite AUD01.
"""
import hashlib, json, pathlib, wave
import numpy as np
from scipy.signal import butter, sosfilt
ROOT=pathlib.Path(__file__).resolve().parents[1]
RATE=22050
SPECS={
 'dash':(.24,-17,'pressure'), 'swing':(.18,-18,'blade'),
 'contact':(.19,-17,'body'), 'parry':(.33,-17,'metal'),
 'kunai_throw':(.12,-21,'flick'), 'tether_fire':(.15,-20,'line'),
 'tether_attach':(.19,-20,'catch'), 'tether_release':(.13,-23,'release'),
 'impact_wind':(.32,-20,'gust'), 'impact_fire':(.35,-18,'crackle'),
 'impact_electric':(.24,-20,'arc'), 'room_passage':(.42,-22,'fold')}

def render(cue,duration,peak,kind,seed):
    rng=np.random.default_rng(seed);n=round(duration*RATE);t=np.arange(n)/RATE;u=t/duration
    noise=rng.normal(0,1,n)
    def band(low,high):return sosfilt(butter(2,[low,high],fs=RATE,btype='bandpass',output='sos'),noise)
    air=band(650,6500); body=band(65,500); grit=band(1800,7500)
    attack=np.minimum(t/.002,1); tail=np.minimum((duration-t)/.012,1)
    if kind in ['pressure','blade','gust','fold']:
        center={'pressure':.19,'blade':.24,'gust':.15,'fold':.36}[kind]
        envelope=np.exp(-((u-center)/(.26 if kind!='fold' else .32))**2)
        x=air*envelope*(1+.13*np.sin(2*np.pi*37*t))+body*np.exp(-u*10)*.22
    elif kind in ['metal','catch']:
        freqs=[1720,2681,4217,6139] if kind=='metal' else [690,1547,3121]
        x=grit*np.exp(-u*36)*.7
        for k,f in enumerate(freqs):x+=np.sin(2*np.pi*f*t+rng.uniform(0,6.28))*np.exp(-u*(5+3*k))*(.24/(k+1))
        x+=body*np.exp(-u*25)*.3
    elif kind=='body':
        x=body*np.exp(-u*13)*1.2+grit*np.exp(-u*29)*.18
        x+=np.sin(2*np.pi*(98*t-47*t*t))*np.exp(-u*17)*.3
    elif kind=='crackle':
        impulses=(rng.random(n)<.0018)*rng.uniform(-1,1,n)
        crack=sosfilt(butter(1,2600,fs=RATE,output='sos'),impulses)*12
        x=(body*.6+air*.28+crack)*np.exp(-u*7)
    elif kind=='arc':
        gate=(np.sin(2*np.pi*(74*t+330*t*t))>.15).astype(float)
        x=grit*gate*np.exp(-u*8)*.55+air*np.exp(-u*23)*.3
    else:
        x=air*np.exp(-u*12)*.55+grit*np.exp(-u*35)*.28
        if kind in ['flick','line']:x+=np.sin(2*np.pi*2317*t)*np.exp(-u*30)*.12
    x*=attack*tail;x[0]=x[-1]=0
    x*=10**(peak/20)/max(np.max(np.abs(x)),1e-12)
    return np.round(x*32767).astype('<i2')

def main():
    out=ROOT/'assets/audio/aud02';out.mkdir(parents=True,exist_ok=True);manifest=[]
    for i,(cue,(duration,peak,kind)) in enumerate(SPECS.items()):
        pcm=render(cue,duration,peak,kind,2061+i);p=out/(cue+'.wav')
        with wave.open(str(p),'wb') as w:w.setparams((1,2,RATE,0,'NONE','not compressed'));w.writeframes(pcm.tobytes())
        # Explicit uncompressed imports, matching AUD01's format/latency policy.
        res='res://'+p.relative_to(ROOT).as_posix();dest='res://.godot/imported/'+p.name+'-'+hashlib.md5(res.encode()).hexdigest()+'.sample'
        p.with_suffix('.wav.import').write_text('[remap]\nimporter="wav"\ntype="AudioStreamWAV"\npath="'+dest+'"\n\n[deps]\nsource_file="'+res+'"\ndest_files=["'+dest+'"]\n\n[params]\nforce/8_bit=false\nforce/mono=false\nforce/max_rate=false\nforce/max_rate_hz=44100\nedit/trim=false\nedit/normalize=false\nedit/loop_mode=0\nedit/loop_begin=0\nedit/loop_end=-1\ncompress/mode=0\n')
        x=pcm.astype(float)/32768
        manifest.append(dict(cue=cue,path=p.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),seconds=len(pcm)/RATE,rate=RATE,channels=1,peak_dbfs=round(20*np.log10(max(np.abs(x))),2),rms_dbfs=round(20*np.log10(np.sqrt(np.mean(x*x))),2),full_scale_samples=int(np.count_nonzero(np.abs(pcm.astype(int))>=32767)),seed=2061+i,design=kind,rights='Original procedural synthesis; CC0-1.0',source_audio_inputs=[],approval='PENDING CREATOR',activation='Opt-in --audio-bank=aud02 only'))
    (out/'MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(len(manifest),'new original cues;',sum((ROOT/r['path']).stat().st_size for r in manifest),'WAV bytes')

if __name__=='__main__': main()

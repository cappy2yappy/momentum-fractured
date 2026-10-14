"""Original AUD-01 candidate sounds; deterministic stdlib synthesis, no samples.

Run from any directory. 22.05 kHz PCM16 mono; seed 61. No music is generated.
All layers are noise, damped sine resonances and envelopes authored for Kaze.
"""
import array, hashlib, json, math, pathlib, random, wave

ROOT = pathlib.Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets/audio'
RATE = 22050
CUES = {
    'step_stone': (.10, 160, .16, .18),
    'step_wood': (.12, 105, .12, .20),
    'jump': (.16, 280, .35, .16),
    'land': (.18, 90, .22, .23),
    'dash': (.24, 140, .90, .23),
    'tether_fire': (.12, 630, .60, .18),
    'tether_attach': (.18, 1250, .16, .20),
    'tether_release': (.15, 370, .55, .15),
    'swing': (.18, 310, .95, .22),
    'contact': (.14, 190, .48, .24),
    'kunai_throw': (.13, 710, .70, .17),
    'impact_wind': (.22, 380, .82, .18),
    'impact_fire': (.25, 110, .85, .21),
    'impact_electric': (.22, 1800, .20, .18),
    'parry': (.38, 1468, .12, .24),
    'damage': (.23, 83, .55, .25),
    'death': (.55, 180, .30, .23),
    'checkpoint': (.65, 880, .04, .18),
    'room_passage': (.30, 230, .88, .18),
    'reject': (.12, 240, .10, .10),
}

def write_sound(name, values, loop=False):
    values = [max(-.95, min(.95, v)) for v in values]
    pcm = array.array('h', (round(v * 32767) for v in values))
    import sys
    if sys.byteorder != 'little': pcm.byteswap()
    file = OUT / (name + '.wav')
    with wave.open(str(file), 'wb') as w:
        w.setparams((1, 2, RATE, 0, 'NONE', 'not compressed'))
        w.writeframes(pcm.tobytes())
    return dict(id=name, path=f'assets/audio/{name}.wav', seconds=len(values)/RATE,
                bytes=file.stat().st_size, sha256=hashlib.sha256(file.read_bytes()).hexdigest(),
                peak_dbfs=round(20*math.log10(max(abs(v) for v in values)), 3),
                rms_dbfs=round(20*math.log10(math.sqrt(sum(v*v for v in values)/len(values))), 3),
                start=values[0], end=values[-1], loop=loop)

def main():
    OUT.mkdir(parents=True, exist_ok=True)
    rng = random.Random(61)
    inventory = []
    for name, (duration, freq, air, gain) in CUES.items():
        values = []; low = 0.0; phase = 0.0
        for i in range(round(duration*RATE)):
            t = i/RATE; u=t/duration
            raw=rng.uniform(-1,1); low=.82*low+.18*raw
            noise = low if name in ['damage','death','land','step_wood'] else raw*.35+low*.65
            sweep = (1-.7*u) if name in ['death','jump','tether_release'] else 1
            phase += math.tau*freq*sweep/RATE
            ring = math.sin(phase)*.65 + math.sin(phase*2.71)*.18
            envelope = min(1, t/.004)*math.exp(-u*6)*min(1, (1-u)/.05)
            if name in ['dash','swing','room_passage']: envelope=math.sin(math.pi*u)**1.4
            if name in ['parry','checkpoint']: envelope=min(1,t/.008)*math.exp(-u*4)*min(1,(1-u)/.08)
            values.append(gain * envelope * (air*noise + (1-air)*ring))
        values[0]=values[-1]=0.0
        inventory.append(write_sound(name,values))
    # Exactly periodic Fourier noise beds: all components complete integral cycles.
    # Canal uses brighter rippling resonances; rooftop is darker filtered wind.
    for name in ['amb_city','amb_canal']:
        duration=8; n=duration*RATE
        bands = range(15, 190, 3) if name=='amb_city' else range(45, 650, 7)
        components=[(k, rng.uniform(0,math.tau), rng.uniform(.4,1)/math.sqrt(k)) for k in bands]
        values=[]
        for i in range(n):
            u=i/n
            bed=sum(a*math.sin(math.tau*k*u+p) for k,p,a in components)
            ripple = .22*math.sin(math.tau*1080*u)*( .6+.4*math.sin(math.tau*3*u)) if name=='amb_canal' else 0
            values.append((bed+ripple)*(.022 if name=='amb_city' else .018))
        inventory.append(write_sound(name,values,True))
    (OUT/'AUD01_MANIFEST.json').write_text(json.dumps(inventory,indent=2)+'\n')
    print(f'{len(inventory)} original sounds; {sum(r["bytes"] for r in inventory)} WAV bytes')

if __name__=='__main__': main()

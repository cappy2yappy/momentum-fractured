"""Decode supplied WAVs; metadata is public, recordings remain outside the repo.

Requires numpy/scipy/soundfile. Signal-derived descriptors are NOT listening notes.
Usage: --zip PATH --extra DIR --private DIR --output DIR
"""
import argparse, csv, hashlib, json, math, pathlib, re, stat, zipfile
import numpy as np
import soundfile as sf
from scipy.signal import resample_poly

def digest(data): return hashlib.sha256(data).hexdigest()
def db(value): return round(20*math.log10(max(float(value),1e-12)),2)

def extract(archive, destination):
    destination=destination.resolve(); destination.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(archive) as z:
        assert len(z.infolist()) < 2000, 'Too many archive entries'
        assert sum(i.file_size for i in z.infolist()) < 1_000_000_000, 'Expansion limit'
        names=set()
        for i in z.infolist():
            name=i.filename.replace('\\','/'); target=(destination/name).resolve()
            assert target.is_relative_to(destination), 'Unsafe archive path'
            assert not stat.S_ISLNK(i.external_attr>>16), 'Symlink rejected'
            assert name.casefold() not in names, 'Colliding archive name'
            names.add(name.casefold())
            if i.is_dir(): continue
            assert target.suffix.lower()=='.wav', 'Unexpected non-WAV entry'
            assert not i.flag_bits & 1, 'Encrypted entry'
            target.parent.mkdir(parents=True,exist_ok=True)
            target.write_bytes(z.read(i))
        assert z.testzip() is None, 'CRC failure'

def analyze(path, group, root):
    raw=path.read_bytes(); x,rate=sf.read(path,always_2d=True,dtype='float64')
    assert len(x)>0 and np.isfinite(x).all(), str(path)
    info=sf.info(path); mono=x.mean(axis=1); peak=np.max(np.abs(x)); rms=np.sqrt(np.mean(x*x))
    hop=max(1,rate//1000)
    padded=np.pad(mono,(0,(-len(mono))%hop)); env=np.sqrt(np.mean(padded.reshape(-1,hop)**2,axis=1))
    threshold=max(10**(-60/20),env.max()*.03)
    active=np.flatnonzero(env>threshold)
    onset=int(active[0])*hop/rate if len(active) else len(x)/rate
    end=(int(active[-1])+1)*hop/rate if len(active) else 0
    # Average FFT of actual decoded signal; filename does not influence features.
    nfft=2048; padded=np.pad(mono,(0,max(0,nfft-len(mono))))
    frames=np.lib.stride_tricks.sliding_window_view(padded,nfft)[::1024]
    spectrum=np.mean(np.abs(np.fft.rfft(frames*np.hanning(nfft),axis=1))**2,axis=0)
    frequencies=np.fft.rfftfreq(nfft,1/rate); total=max(spectrum.sum(),1e-18)
    centroid=float(np.sum(spectrum*frequencies)/total)
    low=float(spectrum[frequencies<250].sum()/total); high=float(spectrum[frequencies>4000].sum()/total)
    flatness=float(np.exp(np.mean(np.log(spectrum[1:]+1e-18)))/max(np.mean(spectrum[1:]),1e-18))
    bits=24 if info.subtype=='PCM_24' else 16
    clipped=int(np.count_nonzero(np.abs(x)>=1-1/(2**(bits-1))))
    flags=[]
    if clipped: flags.append('full_scale_samples_possible_clipping')
    if abs(x.mean())>.01: flags.append('dc_offset_above_0.01')
    if onset>.05: flags.append('delayed_onset_trim_for_responsiveness')
    if max(np.max(np.abs(x[0])),np.max(np.abs(x[-1])))>.015: flags.append('nonzero_boundary_check_clicks')
    if len(x)/rate>2: flags.append('long_for_repeated_action')
    if peak<.01: flags.append('very_quiet')
    descriptors=[('low-heavy' if low>.5 else 'bright' if high>.2 else 'midrange'),('noise-rich' if flatness>.08 else 'resonant/tonal'),('short' if end-onset<.4 else 'extended'),('fast-onset' if onset<.02 else 'delayed-onset')]
    if len(x)/rate>4: category='ambience/long-tail review'
    elif flatness>.08 and centroid>1800: category='air/friction/elemental review'
    elif low>.45: category='body/impact review'
    else: category='resonance/interface/metal review'
    # Compact amplitude-normalized fingerprint: possible duplicates, not proof.
    f=resample_poly(mono,1000,rate); f=f/(np.max(np.abs(f))+1e-12)
    fingerprint=digest(np.round(f*127).astype('int8').tobytes())
    return dict(filename=path.name,relative_path=path.relative_to(root).as_posix(),group=group,sha256=digest(raw),pcm_sha256=digest(x.astype('<f4').tobytes()),normalized_fingerprint=fingerprint,bytes=len(raw),rate=rate,channels=x.shape[1],subtype=info.subtype,duration=round(len(x)/rate,5),peak_dbfs=db(peak),rms_dbfs=db(rms),crest_db=round(db(peak)-db(rms),2),onset_seconds=round(onset,4),active_seconds=round(end-onset,4),centroid_hz=round(centroid),low_energy=round(low,4),high_energy=round(high,4),flatness=round(flatness,5),dc=round(float(x.mean()),6),full_scale_samples=clipped,flags=flags,descriptors=', '.join(descriptors),provisional_category=category,listening_status='NOT AUDITIONED; signal inspection only',rights='UNVERIFIED; private reference only',creator_approval='PENDING')

EVENTS=[
('step_stone',.13,1000,'Dry, restrained sole contact; preserve current until heard.'),
('step_wood',.15,600,'Muted hollow contact, no exaggerated bass.'),
('jump',.18,2200,'Small cloth/air lift, avoid rising arcade tone.'),
('land',.24,450,'Compact body weight with dry grit.'),
('dash',.25,3200,'Fast broad air, no shrill tonal tail.'),
('slide',.38,2300,'Short friction scrape; no dedicated existing trigger.'),
('wall_jump',.2,1400,'Dry contact then air; existing jump hook shared.'),
('tether_fire',.18,3000,'Narrow line launch with fast onset.'),
('tether_attach',.22,2500,'Small firm metallic catch.'),
('tether_release',.17,2800,'Light line flick, short tail.'),
('tether_swing',.45,1400,'Subtle tension/air; no continuous emitter added.'),
('swing',.21,3000,'Dry blade/cloth air cut.'),
('contact',.23,700,'Body impact with brief edge, no excessive boom.'),
('parry',.42,3400,'Distinct bright metal transient, controlled ring.'),
('damage',.27,550,'Dull hit, separate from successful contact.'),
('enemy_defeat',.55,800,'Falling mass/air; dedicated hook deferred.'),
('kunai_throw',.16,3600,'Tiny metal flick followed by air.'),
('impact_wind',.35,2500,'Dispersing filtered air.'),
('impact_fire',.4,900,'Dry crackle and compact low puff.'),
('impact_electric',.3,4000,'Brief irregular crack without sustained whine.'),
('elemental_gate',.65,1300,'Break/resolve cue; existing elemental contact retained.'),
('checkpoint',.75,1900,'Gentle resonance, no melody or music selection.'),
('room_passage',.38,2000,'Brief folded-air transition; no timing change.'),
('wind_fold',.5,2700,'Soft pressure fold; shares existing passage concept.'),
('collectible',.3,2900,'Small affirmative detail; dedicated hook deferred.'),
('ui_confirm',.13,1800,'Quiet tactile confirmation; hook deferred.'),
('reject',.14,500,'Muted denial tick, unobtrusive.'),
('ambience',8,700,'Sparse nonmusical atmosphere; retain established loops.')]

def main():
    p=argparse.ArgumentParser(); p.add_argument('--zip',required=True);p.add_argument('--extra',required=True);p.add_argument('--private',required=True);p.add_argument('--output',required=True);a=p.parse_args()
    private=pathlib.Path(a.private).resolve(); out=pathlib.Path(a.output);out.mkdir(parents=True,exist_ok=True)
    extracted=private/'pack'; extract(a.zip,extracted)
    rows=[]
    for group,folder in [('pack',extracted),('extra',pathlib.Path(a.extra).resolve())]:
        for path in sorted(folder.rglob('*.wav')):
            rows.append(analyze(path,group,folder))
    byhash={}; fingerprint={}
    for r in rows:
        r['duplicate_of']=byhash.get(r['pcm_sha256']);byhash.setdefault(r['pcm_sha256'],r['filename'])
        r['possible_normalized_duplicate_of']=fingerprint.get(r['normalized_fingerprint']);fingerprint.setdefault(r['normalized_fingerprint'],r['filename'])
    slate=[];used=set()
    for event,duration,brightness,brief in EVENTS:
        def score(r):
            return abs(math.log(max(r['active_seconds'],.01)/duration))+abs(math.log(max(r['centroid_hz'],40)/brightness))*.5+r['onset_seconds']*4+(3 if r['full_scale_samples'] else 0)+(2 if r['duplicate_of'] else 0)
        ranked=sorted([r for r in rows if r['filename'] not in used],key=score)
        source=ranked[0]; used.add(source['filename'])
        slate.append(dict(cue=event,source_filename=source['filename'],source_group=source['group'],source_relative_path=source['relative_path'],source_sha256=source['sha256'],duration=source['duration'],descriptors=source['descriptors'],flags=source['flags'],alternates=[dict(filename=r['filename'],group=r['group'],sha256=r['sha256']) for r in ranked[1:3]],proposed_use=brief,recommendation='Listening candidate only; retain AUD01 or audition original alternative. Do not distribute source.',basis='Automated waveform/spectral fit; NOT an artistic ranking',creator_approval='PENDING'))
    summary=dict(zip_sha256=digest(pathlib.Path(a.zip).read_bytes()),expected_zip_sha256='46c15f62b9b6a8a4aded5a61ae0902570e7a43ff575313c63ef99f4622ce2e95',pack_count=sum(r['group']=='pack' for r in rows),extra_count=sum(r['group']=='extra' for r in rows),decoded_count=len(rows),auditioned_count=0,confirmed_suitable_count=0,provisional_candidates=len(slate),total_seconds=round(sum(r['duration'] for r in rows),2),exact_pcm_duplicates=sum(bool(r['duplicate_of']) for r in rows),possible_normalized_duplicates=sum(bool(r['possible_normalized_duplicate_of']) for r in rows),files_with_full_scale_samples=sum(bool(r['full_scale_samples']) for r in rows),formats=sorted(set((r['rate'],r['channels'],r['subtype']) for r in rows)),listening_limitation='No perceptual audio input available to this agent; do not represent measurements as listening.',zip_safety='All entries validated before extracting: path containment, collisions, symlinks, extension, size limits, encryption, CRC.')
    for name,data in [('AUD02_INVENTORY.json',rows),('AUD02_SHORTLIST.json',slate),('AUD02_AUDIT_SUMMARY.json',summary)]:
        (out/name).write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')
    with (out/'AUD02_INVENTORY.csv').open('w',newline='',encoding='utf-8') as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
    print(json.dumps(summary,indent=2))

if __name__=='__main__': main()

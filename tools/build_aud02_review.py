"""Labeled listening board. Public mode NEVER reads reference recordings.

Optional --private-source PATH enables a private board with supplied references.
No private output may be placed inside the repository. Requires numpy/scipy/soundfile.
"""
import argparse, base64, hashlib, html, io, json, os, pathlib, wave
import numpy as np
import soundfile as sf
from scipy.signal import resample_poly
ROOT=pathlib.Path(__file__).resolve().parents[1]

def preview(path,limit=None):
    # Review derivatives: mono22k PCM16, attenuate only to -18dBFS peak.
    x,rate=sf.read(path,always_2d=True);x=x.mean(axis=1)
    if limit:x=x[:round(rate*limit)]
    x=resample_poly(x,22050,rate); peak=max(float(np.max(np.abs(x))),1e-12)
    gain=min(1,10**(-18/20)/peak);x*=gain
    data=io.BytesIO()
    with wave.open(data,'wb') as w:w.setparams((1,2,22050,0,'NONE','not compressed'));w.writeframes(np.round(x*32767).astype('<i2').tobytes())
    return dict(src='data:audio/wav;base64,'+base64.b64encode(data.getvalue()).decode(),gain_db=round(20*np.log10(gain),2),seconds=round(len(x)/22050,3))

PAGE='''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Kaze · Sound Shogun AUD02</title>
<style>body{background:#151a21;color:#e9ecef;font:16px/1.5 system-ui;margin:0}header,main{max-width:1160px;margin:auto;padding:28px}header{border-bottom:1px solid #495364}h1{font-size:30px;margin:0}h2{font-size:21px}p{max-width:900px}label{display:block}input,select,button,textarea{font:inherit;background:#27323f;color:inherit;border:1px solid #667080;border-radius:5px;padding:8px}input{width:70%}button{cursor:pointer}article{border:1px solid #495364;border-radius:10px;margin:20px 0;padding:20px;background:#1c2430}.players{display:flex;flex-wrap:wrap;gap:20px}.player{flex:1;min-width:250px;overflow-wrap:anywhere}audio{width:100%}.badge{color:#e7c184;font-size:13px}.meta{font-size:13px;color:#bac6d2}.choices{display:flex;gap:12px;flex-wrap:wrap;margin-top:18px}textarea{min-width:50%;flex:1}.hidden{display:none}.subtle{color:#b4c0cf}summary{cursor:pointer}table{border-collapse:collapse;font-size:13px;width:100%}td,th{padding:8px;border-bottom:1px solid #495364;text-align:left}code{overflow-wrap:anywhere}</style>
<header><p class="badge">KAZE ALPHA 0.6.1 · AUD-02 · LISTENING REVIEW</p><h1>The Sound Shogun</h1><p id="status"></p><p>28 provisional event comparisons. These candidates were selected by measured duration, onset and spectrum. <strong>The agent has not heard them.</strong> No sound is artistically approved. Choose each cue individually; no random montage.</p><p class="meta">Previews are mono22k PCM16, attenuated only to a maximum peak of −18 dBFS, with no onset trimming. This is a peak-limited comparison, not perceived-loudness matching. Start quietly. Supplementary recordings are excerpts up to eight seconds. No music is selected.</p><label>Filter by cue or exact source filename <input id="search" placeholder="dash, parry, commse0…"></label><p><button id="export">Download review decisions</button> <button id="stop">Stop all audio</button></p><p class="meta">Selections are saved in this browser when available. Download decisions to preserve them and send them back. Nothing is sent automatically.</p></header>
<main><div id="cards"></div><h2>Additional creator references</h2><p class="subtle">Supplementary files are separate from the 496-file ZIP. Filename descriptions are supplied metadata, not independently confirmed listening notes.</p><div id="extras"></div><details><summary>Full 512-file technical inventory</summary><p>Use the original attachment to audition files outside these comparisons. This table records measurements, not artistic suitability.</p><div id="inventory"></div></details></main>
<script>const DATA=__DATA__;const $=id=>document.getElementById(id);let decisions={};try{decisions=JSON.parse(localStorage.getItem('kaze-aud02-decisions')||'{}')}catch(e){}function el(tag,text,cls){let x=document.createElement(tag);if(text!==undefined)x.textContent=text;if(cls)x.className=cls;return x}function playbox(title,data,note){let d=el('div',undefined,'player');d.append(el('h3',title),el('p',note||'','meta'));if(data){let a=document.createElement('audio');a.controls=true;a.preload='none';a.src=data.src;a.addEventListener('play',()=>document.querySelectorAll('audio').forEach(b=>{if(b!==a)b.pause()}));d.append(a,el('p',`${data.seconds}s preview · attenuation ${data.gain_db} dB`,'meta'))}else d.append(el('p','Not included. Retain existing cue / listen privately.','subtle'));return d}function save(){try{localStorage.setItem('kaze-aud02-decisions',JSON.stringify(decisions))}catch(e){}}$('status').textContent=DATA.private?'PRIVATE REVIEW — source redistribution rights unverified. Do not post this file publicly.':'PUBLIC-SAFE REVIEW — only new originals and AUD01 fallbacks contain playable audio. Source recordings are excluded.';for(let [i,r] of DATA.cards.entries()){let card=el('article');card.dataset.search=(r.cue+' '+r.source_filename+' '+r.alternates.map(a=>a.filename).join(' ')).toLowerCase();card.append(el('span',`CUE ${String(i+1).padStart(2,'0')} · APPROVAL PENDING`,'badge'),el('h2',r.cue.replaceAll('_',' ')),el('p',r.proposed_use),el('p',r.descriptors+' · signal descriptors only','meta'),el('p','Source SHA256: '+r.source_sha256,'meta'));let players=el('div',undefined,'players');players.append(playbox('A · Reference: '+r.source_filename,r.reference,'Unverified rights. Listening candidate only.'),playbox('B · New original: '+r.cue,r.original,'Original CC0 procedural candidate; opt-in only.'),playbox('C · AUD01 fallback',r.fallback,'Existing original retained. No approval inferred.'));card.append(players);let detail=el('details');detail.append(el('summary','Two alternate references'));for(let a of r.alternates)detail.append(playbox(a.filename,a.preview,'Provisional measured match; private source only.'));card.append(detail);let choices=el('div',undefined,'choices');let select=el('select');for(let s of ['Pending','Prefer reference — rights clearance needed','Prefer new original','Keep AUD01','Revise','Reject all']){let o=el('option',s);select.append(o)}let notes=el('textarea');notes.placeholder='What should change? Texture, weight, tail, loudness, timing…';select.value=decisions[r.cue]?.choice||'Pending';notes.value=decisions[r.cue]?.notes||'';let update=()=>{decisions[r.cue]={cue:r.cue,source:r.source_filename,source_sha256:r.source_sha256,choice:select.value,notes:notes.value};save()};select.onchange=update;notes.oninput=update;choices.append(select,notes);card.append(choices);$('cards').append(card)}for(let r of DATA.extras){let card=el('article');card.append(el('h2',r.filename),el('p',r.descriptors,'meta'),playbox('Private supplementary reference',r.preview,'Original duration '+r.duration+'s; preview first up to 8s. Approval pending.'));$('extras').append(card)}let table=el('table');let head=el('tr');for(let h of ['Filename','Duration','Signal descriptor','Flags','Approval'])head.append(el('th',h));table.append(head);for(let r of DATA.inventory){let row=el('tr');for(let v of [r.filename,r.duration+'s',r.descriptors,r.flags.join(', '),'Pending'])row.append(el('td',v));table.append(row)}$('inventory').append(table);$('search').oninput=()=>{let s=$('search').value.toLowerCase();document.querySelectorAll('#cards article').forEach(c=>c.classList.toggle('hidden',!c.dataset.search.includes(s)))};$('stop').onclick=()=>document.querySelectorAll('audio').forEach(a=>a.pause());$('export').onclick=()=>{let blob=new Blob([JSON.stringify({assignment:'AUD02',date:new Date().toISOString(),decisions},null,2)],{type:'application/json'});let url=URL.createObjectURL(blob);let a=el('a');a.href=url;a.download='Kaze-AUD02-Creator-Decisions.json';a.click();setTimeout(()=>URL.revokeObjectURL(url),1000)};</script></html>'''

def main():
    p=argparse.ArgumentParser();p.add_argument('--private-source');p.add_argument('--output',required=True);a=p.parse_args()
    output=pathlib.Path(a.output).resolve()
    if a.private_source:assert not output.is_relative_to(ROOT), 'Private source previews must stay outside Git repository'
    directory=ROOT/'docs/audio/aud02';cards=json.loads((directory/'AUD02_SHORTLIST.json').read_text());inventory=json.loads((directory/'AUD02_INVENTORY.json').read_text())
    private=pathlib.Path(a.private_source).resolve() if a.private_source else None
    byname={(r['group'],r['filename']):r for r in inventory}
    cache={}
    def reference(group,name):
        if private is None:return None
        if (group,name) not in cache:
            row=byname[(group,name)];path=private/('pack' if group=='pack' else 'extra')/row['relative_path']
            assert hashlib.sha256(path.read_bytes()).hexdigest()==row['sha256']
            cache[(group,name)]=preview(path,8)
        return cache[(group,name)]
    for r in cards:
        r['reference']=reference(r['source_group'],r['source_filename'])
        candidate=ROOT/'assets/audio/aud02'/(r['cue']+'.wav');fallback=ROOT/'assets/audio'/(r['cue']+'.wav')
        r['original']=preview(candidate) if candidate.exists() else None;r['fallback']=preview(fallback) if fallback.exists() else None
        for alt in r['alternates']:alt['preview']=reference(alt['group'],alt['filename'])
    extras=[]
    for r in inventory:
        if r['group']=='extra':extras.append(dict(filename=r['filename'],duration=r['duration'],descriptors=r['descriptors'],preview=reference('extra',r['filename'])))
    if private is None:
        for r in cards:
            for key,folder in [('original','assets/audio/aud02'),('fallback','assets/audio')]:
                if r[key]:r[key]['src']=os.path.relpath(ROOT/folder/(r['cue']+'.wav'),output.parent).replace('\\','/')
        extras=[]
    data=dict(private=bool(private),cards=cards,extras=extras,inventory=inventory if private else [])
    output.parent.mkdir(parents=True,exist_ok=True)
    output.write_text(PAGE.replace('__DATA__',json.dumps(data).replace('</','<\\/')),encoding='utf-8')
    print(str(output),output.stat().st_size,'bytes;',len(cache),'private reference previews')

if __name__=='__main__':main()

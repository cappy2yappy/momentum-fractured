"""Independent final-file QA, with explicit artistic limitations."""
from pathlib import Path
import hashlib,json,subprocess,zipfile
import numpy as np
from PIL import Image
from export import crc_check
ROOT=Path(__file__).resolve().parents[2]
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    m=json.loads((ROOT/'assets/art05/MANIFEST.json').read_text());rows=[];checks=0
    assert m['cell_size']==[320,724] and m['pivot_px']==[160,600] and m['engine_scale']==.303125;checks+=1
    for clip in m['clips']:
        path=ROOT/clip['path'];crc_check(path);im=Image.open(path);im.load()
        assert im.mode=='RGBA' and im.size==(320*len(clip['frames']),724);checks+=1
        assert sha(path)==clip['sha256'];checks+=1
        assert sha(ROOT/'source_art/art05'/({'turn_depth':'turn','enter_depth':'entry','stair_up':'stair_up'}[clip['id']]+'_master.png'))==clip['master_sha256'];checks+=1
        for i,rec in enumerate(clip['frames']):
            frame=im.crop((320*i,0,320*(i+1),724));a=np.array(frame);b=frame.getchannel('A').getbbox()
            assert min(b[0],b[1],320-b[2],724-b[3])>=12;checks+=1
            assert hashlib.sha256(frame.tobytes()).hexdigest()==rec['sha256_rgba'];checks+=1
            assert not np.any(a[a[:,:,3]==0,:3]);checks+=1
            if clip['status']=='candidate':assert not rec['source_cell_clipped'];checks+=1
            if clip['id']=='turn_depth':
                # Independently inspect the actual exported heel silhouette, not guide metadata.
                ys,xs=np.where(a[580:610,150:175,3]>128)
                assert len(ys)>0
                error=(580+int(ys.max())-600)*.303125
                assert abs(error)<=1.0
                contact_y,contact_x=np.where(a[597:603,150:170,3]>128)
                assert len(contact_x)>0
                heel_x=float((contact_x+150).mean())
                rows.append({'frame':i,'heel_roi_px':[150,580,25,30],'ground_error_world_px':error,'heel_contact_centroid_x_px':heel_x});checks+=1
        ora=ROOT/'source_art/art05'/f"{clip['id']}.ora"
        with zipfile.ZipFile(ora) as z:assert z.testzip() is None;Image.open(z.open('mergedimage.png')).load()
        checks+=1
    e=m['environment'];im=Image.open(ROOT/e['path']);assert im.size==(180,80) and e['world_rect']==[520,1220,180,80]
    assert np.all(np.array(im)[:,:,3]==255) and sha(ROOT/e['path'])==e['sha256'];checks+=1
    # Every preexisting tracked file is protected; all task work must be additive.
    changed=subprocess.check_output(['git','diff','5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c','--name-only','--diff-filter=DMRT'],cwd=ROOT,text=True)
    assert not changed,changed;checks+=1
    drift=(max(r['heel_contact_centroid_x_px'] for r in rows)-min(r['heel_contact_centroid_x_px'] for r in rows))*.303125
    assert drift<=1;checks+=1
    output={'checks':checks,'failures':0,'turn_heel_contour':rows,'max_ground_error_world_px':max(abs(r['ground_error_world_px']) for r in rows),'horizontal_contact_drift_world_px':drift,'source_clipping_rejected':['stair_up'],'limits':'Contour ROI tests contact height/drift; rotation, silhouette, anatomy, identity and motion continuity require sequence review. Entry/stair WIP are not production accepted.'}
    (ROOT/'docs/art/art05/evidence/TECHNICAL_QA.json').write_text(json.dumps(output,indent=2)+'\n')
    print(json.dumps(output))
if __name__=='__main__':main()

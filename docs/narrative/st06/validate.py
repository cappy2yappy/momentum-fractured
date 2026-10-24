"""ST06 structural validation. Not a browser, Godot or playtest."""
from pathlib import Path
from html.parser import HTMLParser
import json, re, hashlib, subprocess
ROOT = Path(__file__).resolve().parent
checks=[]
def check(name, condition):
    checks.append({"check":name,"pass":bool(condition)})
    if not condition: raise AssertionError(name)
data=json.loads((ROOT/"BOARD.json").read_text(encoding="utf-8"))
html=(ROOT/"REVIEW.html").read_text(encoding="utf-8")
class ReviewParser(HTMLParser):
    def __init__(self):
        super().__init__(); self.scripts=[]; self.active=None; self.ids=[]; self.external=[]
    def handle_starttag(self,tag,attrs):
        attrs=dict(attrs)
        if "id" in attrs:self.ids.append(attrs["id"])
        if tag=="script":self.active={"attrs":attrs,"text":""}
        if tag in ("script","img","iframe","link") and any(k in attrs for k in ("src","href")):self.external.append(attrs)
    def handle_data(self,text):
        if self.active is not None:self.active["text"]+=text
    def handle_endtag(self,tag):
        if tag=="script" and self.active is not None:self.scripts.append(self.active);self.active=None
parser=ReviewParser();parser.feed(html)
embedded=json.loads(next(s["text"] for s in parser.scripts if s["attrs"].get("id")=="initial"))
check("embedded HTML model equals editable BOARD.json",embedded==data)
check("eight unique fixed card IDs", [p["id"] for p in data["panels"]]==["P%02d"%i for i in range(1,9)])
check("continuous relative 0-90 candidate-study windows (not boot)", data["panels"][0]["start"]==0 and data["panels"][-1]["end"]==90 and all(a["end"]==b["start"] for a,b in zip(data["panels"],data["panels"][1:])))
check("schema v2 rejects superseded opening-board imports", data["schema"]=="st06-review-2")
check("confirmed A-B-C-D experience order", [p["id"] for p in data["experience"]]==["A","B","C","D"] and data["presentation_contract"]["order"]==["A","B","C","D"])
check("flashback trigger rooms and conditions remain unassigned", data["presentation_contract"]["trigger"]["room_ids"] is None and data["presentation_contract"]["trigger"]["conditions"] is None)
check("chronology distinct from experience order", [p["id"] for p in data["chronology"]]==["CH1","CH2","CH3","CH4"])
check("all eight panels remain unscheduled candidates", all(p["timeline_scope"]=="candidate-study-only" and p["placement"]=="Unscheduled candidate flashback or memory material" for p in data["panels"]))
for p in data["panels"]:
    check(p["id"]+" complete review fields",all(isinstance(p.get(k),str) and p[k] for k in ("purpose","pose","camera","control","geography","audio","entry","exit","skip","reduced","status")))
    check(p["id"]+" four layers",set(p["layers"])=={"far","mid","play","front"} and all(p["layers"].values()))
rooms=data["rooms"]
check("21 exact room IDs", [r["id"] for r in rooms]==list(range(21)))
edges=set()
for room in rooms:
    for n in room["neighbors"]:
        check("reciprocal R%d-R%d"%(room["id"],n),room["id"] in rooms[n]["neighbors"])
        edges.add(tuple(sorted((room["id"],n))))
check("29 links / 58 directed endpoints",len(edges)==29 and sum(len(r["neighbors"]) for r in rooms)==58)
for r in rooms:check("R%d visual overlay complete"%r["id"],all(r.get(k) for k in ("first","learn","misread","uncertain","motif","readability","clue","revisit")))
check("exact approved opening",data["exact"]["opening"]=="The refuge was attacked. I have to find the others.")
check("exact approved objective",data["exact"]["objective"]=="Search for survivors. Defeat the Market sentinel for Windstep.")
check("exact Rest Station label",data["exact"]["checkpoint"]=="Foundry Rest Station")
register=json.loads(r'''"| Decision | Concrete choice | Current status |\n|---|---|---|\n| C1 | Immediate post-attack survival/search; Mizuki naming; preserve delayed reveals | Confirmed by PR38; preserved |\n| C2 | Exact opening/first objective/Foundry Rest Station label | Approved by PR68 comments; present in inspected candidate |\n| D1 | Twelve-beat framework, optional delivery and no lore gates | Pending |\n| D2 | R1 wrap, shared mending recognition and exact B02 copy | Pending; no owner identified |\n| D3 | R2 undated physical letter treatment and optional “which dawn” reaction | Pending; original reward/text retained |\n| D4 | R4 parapet as damaged defensive structure, without cause/date | Pending |\n| D5 | R7 access-for-search panel/reaction | Earlier proposal; still pending |\n| D6a | F1 anonymous clan-associated death, F2 affiliation withheld death, F3 possible injury evidence, or omit | Pending; choose only one; no named victims |\n| D6b | If F1/F2: death existence, affiliation and unidentifiable victim policy separately | Pending |\n| D6c | R8 placement, covered visual, recognition motif, exact reaction | Pending; Level bounds also required |\n| D6d | Optional cloth memorial and any reduced-intensity variant | Pending; no ritual/reward implied |\n| D7 | R14 carrying frame/bundle as uncertain interrupted travel | Pending; not recent clan evacuation proof |\n| D8 | R16 optional hope reaction and lamp treatment | Pending; existing note preserved |\n| D9 | R18 guard observation variants, no allegiance/patrol changes | Pending |\n| D10 | R11 optional rest reaction and bay framing | Pending; approved label unchanged |\n| D11 | R12 unresolved-search reaction after real attunement | Pending |\n| D12 | R20 state-aware return reaction and landmark | Pending |\n| D13 | New examine UI and additive persistence contract | Pending Gameplay/INT-01 + creator scope approval |\n| D14 | Any optional cinematic adaptation | Not needed for default plan; pending separate approval |"''')
source=(ROOT/"SOURCES_AND_DECISIONS.md").read_text(encoding="utf-8")
check("verbatim inherited decision register",register in source)
for id in ["D1","D2","D3","D4","D5","D6a","D6b","D6c","D6d","D7","D8","D9","D10","D11","D12","D13","D14"]:
    check("retained "+id,("| "+id+" |") in source)
check("no external page dependencies",not parser.external)
check("no duplicate static HTML IDs",len(parser.ids)==len(set(parser.ids)))
check("no page network or persistence calls",not re.search(r"\b(fetch|XMLHttpRequest|WebSocket|localStorage|sessionStorage)\b",html))
check("no page injected HTML", "innerHTML" not in html)
check("native keyboard controls and live status",'<button' in html and 'aria-live="polite"' in html and '<label' in html)
check("no autoplay animation", "<video" not in html and "requestAnimationFrame" not in html)
check("reduced motion media support","prefers-reduced-motion" in html)
missing=[]
for file in ROOT.glob("*.md"):
    for target in re.findall(r"\]\(([^)]+)\)",file.read_text(encoding="utf-8")):
        if not re.match(r"https?://",target) and not (ROOT/target.split("#")[0]).exists():missing.append((file.name,target))
# VALIDATION.json is created below; allow its forward link during first run.
missing=[m for m in missing if m[1]!="VALIDATION.json"]
check("local Markdown links resolve",not missing)
js=next(s["text"] for s in parser.scripts if s["attrs"].get("id")!="initial")
syntax=subprocess.run(["node","--check"],input=js,text=True,capture_output=True)
check("Node JavaScript syntax",syntax.returncode==0)
# Execute actual card renderer and import validation using a tiny DOM model.
# This checks handlers/model logic only, not browser visuals or accessibility.
harness=r"""
const vm=require('vm'), assert=require('assert');
class E {
 constructor(tag){this.tag=tag;this.children=[];this.textContent='';this.listeners={};this.files=[];this.value='';}
 append(...x){this.children.push(...x)}
 replaceChildren(...x){this.children=x}
 get lastChild(){return this.children[this.children.length-1]}
 addEventListener(k,f){this.listeners[k]=f}
 click(){if(this.listeners.click)this.listeners.click()}
}
const payload=JSON.parse(require('fs').readFileSync(0,'utf8'));
const initial=payload.model;
const ids={};for(const id of ['initial','cards','experience','chronology','approved','status','export','import','print','reset'])ids[id]=new E(id);
ids.initial.textContent=JSON.stringify(initial);
const sandbox={document:{getElementById:id=>ids[id],createElement:t=>new E(t),querySelectorAll:()=>[]},
structuredClone,Blob,URL:{createObjectURL:()=> 'blob:review',revokeObjectURL:()=>{}},
setTimeout:f=>f(),window:{confirm:()=>true,print:()=>{}},console};
vm.createContext(sandbox);vm.runInContext(payload.js,sandbox);
assert.equal(ids.cards.children.length,8);
assert.equal(ids.experience.children.length,4);
assert.equal(ids.chronology.children.length,4);
assert.equal(ids.approved.children.length,3);
function exec(s){return vm.runInContext(s,sandbox)}
assert.equal(exec('validateImport(structuredClone(initial)).panels.length'),8);
exec('let good=structuredClone(initial);good.panels[0].notes="review note";validateImport(good)');
for(const change of [
'v.exact.opening="changed"',
'v.panels.pop()',
'v.panels[0].id="P99"',
'v.rooms[0].neighbors=[]',
'v.panels[0].review="approved"',
'v.panels[0].pose=17',
'v.schema="st06-review-1"',
'v.presentation_contract.trigger.room_ids=[1]',
'v.experience.reverse()',
'v.experience[0].purpose=17',
'v.chronology.reverse()',
'v.panels[0].placement="New-game opening"',
'v.panels[0].window="0-90 seconds at boot"']){
 exec('var v=structuredClone(initial);'+change);
 assert.throws(()=>exec('validateImport(v)'));
}
exec('var unsafe=structuredClone(initial);unsafe.panels[0].notes="<img src=x onerror=alert(1)>";board=validateImport(unsafe);render()');
assert.equal(ids.cards.children.length,8);
ids.export.click();assert(ids.status.textContent.includes('exported'));
ids.reset.click();assert(ids.status.textContent.includes('restored'));
console.log('PASS: render 8 cards; locks reject thirteen invalid imports; text-only content; export/reset handlers');
"""
model=subprocess.run(["node","-e",harness],input=json.dumps({"model":data,"js":js}),text=True,capture_output=True)
check("DOM-model render/import/export/reset",model.returncode==0)
result={"status":"PASS","executed":[*checks],"count":len(checks),"scope":"Structural/content and JavaScript model only", "runner":"Python validator with Node syntax/DOM model",
"not_executed":["native browser rendering/visual QA","screen-reader/accessibility audit","Godot/runtime","Windows/macOS playtest","FPS","controller/save/transition QA","actual artwork/animation review"],
"inherited_claims":"ST05/WD/source evidence was read; their runtime/test claims were not rerun.",
"model_output":model.stdout.strip(),
"sha256":{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in ROOT.iterdir() if p.is_file() and p.name!="VALIDATION.json"}}
(ROOT/"VALIDATION.json").write_text(json.dumps(result,indent=2)+"\n",encoding="utf-8")
print(json.dumps({"status":"PASS","checks":len(checks),"model":model.stdout.strip(),"not_executed":result["not_executed"]}))

/* ST06 documentation checks. V8 fallback for an unavailable local Python/Node launcher.
 * Executes review JavaScript against a DOM model, not a real browser or game.
 * Optional local use: node validate_fallback.js (writes VALIDATION.json).
 */
async function runReviewChecks(files) {
 const checks=[];
 function check(name,ok){checks.push({check:name,pass:!!ok});if(!ok)throw Error(name);}
 const equal=(a,b)=>JSON.stringify(a)===JSON.stringify(b);
 const data=JSON.parse(files["BOARD.json"]),html=files["REVIEW.html"];
 const scripts=[...html.matchAll(/<script([^>]*)>([\s\S]*?)<\/script>/g)];
 const embedded=JSON.parse(scripts.find(s=>/id="initial"/.test(s[1]))[2]);
 const js=scripts.find(s=>!/id="initial"/.test(s[1]))[2];
 const register="| Decision | Concrete choice | Current status |\n|---|---|---|\n| C1 | Immediate post-attack survival/search; Mizuki naming; preserve delayed reveals | Confirmed by PR38; preserved |\n| C2 | Exact opening/first objective/Foundry Rest Station label | Approved by PR68 comments; present in inspected candidate |\n| D1 | Twelve-beat framework, optional delivery and no lore gates | Pending |\n| D2 | R1 wrap, shared mending recognition and exact B02 copy | Pending; no owner identified |\n| D3 | R2 undated physical letter treatment and optional “which dawn” reaction | Pending; original reward/text retained |\n| D4 | R4 parapet as damaged defensive structure, without cause/date | Pending |\n| D5 | R7 access-for-search panel/reaction | Earlier proposal; still pending |\n| D6a | F1 anonymous clan-associated death, F2 affiliation withheld death, F3 possible injury evidence, or omit | Pending; choose only one; no named victims |\n| D6b | If F1/F2: death existence, affiliation and unidentifiable victim policy separately | Pending |\n| D6c | R8 placement, covered visual, recognition motif, exact reaction | Pending; Level bounds also required |\n| D6d | Optional cloth memorial and any reduced-intensity variant | Pending; no ritual/reward implied |\n| D7 | R14 carrying frame/bundle as uncertain interrupted travel | Pending; not recent clan evacuation proof |\n| D8 | R16 optional hope reaction and lamp treatment | Pending; existing note preserved |\n| D9 | R18 guard observation variants, no allegiance/patrol changes | Pending |\n| D10 | R11 optional rest reaction and bay framing | Pending; approved label unchanged |\n| D11 | R12 unresolved-search reaction after real attunement | Pending |\n| D12 | R20 state-aware return reaction and landmark | Pending |\n| D13 | New examine UI and additive persistence contract | Pending Gameplay/INT-01 + creator scope approval |\n| D14 | Any optional cinematic adaptation | Not needed for default plan; pending separate approval |";
 check("embedded HTML model equals editable BOARD.json",equal(embedded,data));
 check("eight unique fixed card IDs",equal(data.panels.map(p=>p.id),Array.from({length:8},(_,i)=>"P"+String(i+1).padStart(2,"0"))));
 check("continuous relative 0-90 candidate-study windows (not boot)",data.panels[0].start===0&&data.panels[7].end===90&&data.panels.slice(1).every((p,i)=>p.start===data.panels[i].end));
 check("schema v2 rejects superseded opening-board imports",data.schema==="st06-review-2");
 check("confirmed A-B-C-D experience order",equal(data.experience.map(p=>p.id),["A","B","C","D"])&&equal(data.presentation_contract.order,["A","B","C","D"]));
 check("flashback trigger rooms and conditions remain unassigned",data.presentation_contract.trigger.room_ids===null&&data.presentation_contract.trigger.conditions===null);
 check("chronology distinct from experience order",equal(data.chronology.map(p=>p.id),["CH1","CH2","CH3","CH4"]));
 check("all eight panels remain unscheduled candidates",data.panels.every(p=>p.timeline_scope==="candidate-study-only"&&p.placement==="Unscheduled candidate flashback or memory material"));
 for(const p of data.panels){
  check(p.id+" complete review fields",["purpose","pose","camera","control","geography","audio","entry","exit","skip","reduced","status"].every(k=>typeof p[k]==="string"&&p[k]));
  check(p.id+" four layers",equal(Object.keys(p.layers).sort(),["far","front","mid","play"])&&Object.values(p.layers).every(Boolean));
 }
 const rooms=data.rooms,edges=new Set();
 check("21 exact room IDs",equal(rooms.map(r=>r.id),Array.from({length:21},(_,i)=>i)));
 for(const r of rooms)for(const n of r.neighbors){check("reciprocal R"+r.id+"-R"+n,rooms[n].neighbors.includes(r.id));edges.add([r.id,n].sort((a,b)=>a-b).join("-"));}
 check("29 links / 58 directed endpoints",edges.size===29&&rooms.reduce((v,r)=>v+r.neighbors.length,0)===58);
 for(const r of rooms)check("R"+r.id+" visual overlay complete",["first","learn","misread","uncertain","motif","readability","clue","revisit"].every(k=>r[k]));
 check("exact approved opening",data.exact.opening==="The refuge was attacked. I have to find the others.");
 check("exact approved objective",data.exact.objective==="Search for survivors. Defeat the Market sentinel for Windstep.");
 check("exact Rest Station label",data.exact.checkpoint==="Foundry Rest Station");
 check("verbatim inherited decision register",files["SOURCES_AND_DECISIONS.md"].includes(register));
 for(const id of ["D1","D2","D3","D4","D5","D6a","D6b","D6c","D6d","D7","D8","D9","D10","D11","D12","D13","D14"])check("retained "+id,files["SOURCES_AND_DECISIONS.md"].includes("| "+id+" |"));
 const staticHTML=html.replace(/(<script[^>]*>)[\s\S]*?(<\/script>)/g,"$1$2");
 const ids=[...staticHTML.matchAll(/\bid="([^"]+)"/g)].map(m=>m[1]);
 check("no external page dependencies",!/<(?:script|img|iframe|link)\b[^>]*\b(?:src|href)=/i.test(staticHTML));
 check("no duplicate static HTML IDs",ids.length===new Set(ids).size);
 check("no page network or persistence calls",! /\b(fetch|XMLHttpRequest|WebSocket|localStorage|sessionStorage)\b/.test(html));
 check("no page injected HTML",!html.includes("innerHTML"));
 check("native keyboard controls and live status",html.includes("<button")&&html.includes('aria-live="polite"')&&html.includes("<label"));
 check("no autoplay animation",!html.includes("<video")&&!html.includes("requestAnimationFrame"));
 check("reduced motion media support",html.includes("prefers-reduced-motion"));
 let missing=[];
 for(const [name,body]of Object.entries(files))if(name.endsWith(".md"))for(const m of body.matchAll(/\]\(([^)]+)\)/g)){
  const target=m[1].split("#")[0];if(!/^https?:\/\//.test(target)&&!(target in files)&&target!=="VALIDATION.json")missing.push([name,target]);
 }
 check("local Markdown links resolve",missing.length===0);
 const factory=new Function("document","structuredClone","Blob","URL","setTimeout","window",js+"\nreturn {validateImport,render,getBoard:()=>board,setBoard:v=>{board=v;}};");
 check("V8 JavaScript syntax (Node launcher unavailable)",typeof factory==="function");
 class E{
  constructor(tag){this.tag=tag;this.children=[];this.textContent="";this.listeners={};this.files=[];this.value="";}
  append(...x){this.children.push(...x);}
  replaceChildren(...x){this.children=x;}
  get lastChild(){return this.children[this.children.length-1];}
  addEventListener(k,f){this.listeners[k]=f;}
  click(){if(this.listeners.click)return this.listeners.click();}
 }
 const elements={};for(const id of ["initial","cards","experience","chronology","approved","status","export","import","print","reset"])elements[id]=new E(id);
 elements.initial.textContent=JSON.stringify(data);
 const clone=v=>JSON.parse(JSON.stringify(v));
 let exported="",printed=false;
 const api=factory({getElementById:id=>elements[id],createElement:t=>new E(t),querySelectorAll:()=>[]},clone,class{constructor(parts){exported=parts.join("");}}, {createObjectURL:()=> "blob:review",revokeObjectURL:()=>{}},f=>f(),{confirm:()=>true,print:()=>{printed=true;}});
 check("DOM-model render/import/export/reset",elements.cards.children.length===8&&elements.experience.children.length===4&&elements.chronology.children.length===4&&elements.approved.children.length===3&&api.validateImport(clone(data)).panels.length===8);
 const good=clone(data);good.panels[0].notes="review note";good.experience[0].notes="phase review";api.validateImport(good);
 const invalid=[
 ["changed approved copy",v=>v.exact.opening="changed"],
 ["missing candidate",v=>v.panels.pop()],
 ["changed candidate ID",v=>v.panels[0].id="P99"],
 ["changed graph",v=>v.rooms[0].neighbors=[]],
 ["approval mark",v=>v.panels[0].review="approved"],
 ["non-text pose",v=>v.panels[0].pose=17],
 ["old v1 opening board",v=>v.schema="st06-review-1"],
 ["invented trigger room",v=>v.presentation_contract.trigger.room_ids=[1]],
 ["reordered experience",v=>v.experience.reverse()],
 ["non-text experience",v=>v.experience[0].purpose=17],
 ["chronology reorder",v=>v.chronology.reverse()],
 ["new-game candidate placement",v=>v.panels[0].placement="New-game opening"],
 ["boot timeline",v=>v.panels[0].window="0-90 seconds at boot"]
 ];
 for(const [name,change]of invalid){const v=clone(data);change(v);let rejected=false;try{api.validateImport(v);}catch{rejected=true;}check("model rejects "+name,rejected);}
 const unsafe=clone(data);unsafe.panels[0].notes="<img src=x onerror=alert(1)>";api.setBoard(api.validateImport(unsafe));api.render();
 check("model untrusted notes stay text",elements.cards.children[0].children.at(-1).value===unsafe.panels[0].notes);
 const pose=elements.cards.children[0].children.find(x=>x.id==="P01-pose");pose.value="Edited candidate pose";pose.listeners.input();
 const purpose=elements.experience.children[0].children.find(x=>x.id==="A-purpose");purpose.value="Edited phase proposal";purpose.listeners.input();
 elements.export.click();
 check("model exports candidate and experience edits",JSON.parse(exported).panels[0].pose==="Edited candidate pose"&&JSON.parse(exported).experience[0].purpose==="Edited phase proposal"&&elements.status.textContent.includes("exported"));
 const file={size:JSON.stringify(good).length,text:async()=>JSON.stringify(good)};
 await elements.import.listeners.change({target:{files:[file],value:"review.json"}});
 check("model imports review file",api.getBoard().panels[0].notes==="review note"&&api.getBoard().experience[0].notes==="phase review");
 const old=clone(data);old.schema="st06-review-1";
 await elements.import.listeners.change({target:{files:[{size:100,text:async()=>JSON.stringify(old)}],value:"old.json"}});
 check("model import handler rejects v1 without replacing edits",elements.status.textContent.includes("Import rejected")&&api.getBoard().panels[0].notes==="review note");
 elements.reset.click();check("model reset restores revised initial data",equal(api.getBoard(),data)&&elements.status.textContent.includes("restored"));
 elements.print.click();check("model print handler requests print",printed);
 check("candidate Markdown fields match JSON",data.panels.every(p=>["purpose","pose","camera","control","geography","audio","entry","exit","skip","reduced"].every(k=>files["STORYBOARD_CARDS.md"].includes(p[k]))));
 check("experience Markdown fields match JSON",data.experience.every(p=>["purpose","control","entry","exit"].every(k=>files["STORYBOARD_CARDS.md"].includes(p[k]))));
 check("HTML explicitly separates experience, chronology and candidates",["experience-heading","chronology-heading","candidates-heading"].every(id=>ids.includes(id)));
 return {status:"PASS",executed:checks,count:checks.length,
 scope:"Structural/document/HTML/JSON and actual review JavaScript against a DOM model only",
 runner:"V8 fallback; equivalent existing assertions plus revision/import checks. Python/Node command and Python HTMLParser not executed.",
 not_executed:["Python/Node validate.py invocation","native browser rendering/visual QA","screen-reader/accessibility audit","real browser download/print","Godot/runtime","Windows/macOS playtest","FPS","controller/save/transition QA","actual artwork/animation review"],
 inherited_claims:"Prior ST06 131-check result and ST05/WD runtime claims were not copied as current results.",
 model_output:"PASS: four experience phases, four chronology entries, eight candidates; 13 invalid imports rejected; edit/export/import/reset/print handlers checked in model.",
 environment_limit:"Local exec rejected before launch: configured file:///workspace permission path is invalid on Windows.",
 source_parent:"9426c7d8086bc20745fd7301fa1f318c84d0b6d3"};
}
if(typeof module!=="undefined"&&module.exports){
 module.exports={runReviewChecks};
 if(require.main===module){
  const fs=require("fs"),path=require("path");
  const files=Object.fromEntries(fs.readdirSync(__dirname).filter(n=>/\.(md|json|html|py|js)$/.test(n)).map(n=>[n,fs.readFileSync(path.join(__dirname,n),"utf8")]));
  runReviewChecks(files).then(result=>{
   result.runner="Node validate_fallback.js; equivalent assertions and DOM model";
   result.not_executed=result.not_executed.map(s=>s==="Python/Node validate.py invocation"?"Python validate.py invocation":s);
   delete result.environment_limit;
   fs.writeFileSync(path.join(__dirname,"VALIDATION.json"),JSON.stringify(result,null,2)+"\n");
   console.log(JSON.stringify({status:result.status,checks:result.count,scope:result.scope}));
  }).catch(e=>{console.error(e);process.exitCode=1;});
 }
}

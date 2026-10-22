"""Wave 3 package inventory (BUILD-07): what exactly is inside a comparison package, and what was NOT validated.

Per package it records the exact source SHA, every ART-08 clip with its SHA256 and provenance label
(candidate, stand-in, unfinished), the LD-05 switches, the TR-08 / pilot flags in the source, the launcher
arguments, and an explicit split between "successful export" and "native graphical validation".

Rules enforced here (problems are returned and the builder asserts there are none):
  * ART-08: every clip in assets/art08/MANIFEST.json carries exactly one label from {candidate, stand_in, unfinished};
    no clip claims approval; every strip on disk is in the manifest with a matching SHA256; an unfinished clip has no
    PNG; an alias must point at a real clip with the same file and SHA256.
  * ART-07 never appears in the source or the pack.
  * The package says, in words, that no ART-08 clip is creator-approved.

Stdlib only. Can be run standalone for a local dry run:
    python tools/pmpilot/w3_inventory.py --source-root <checkout> --variant w3-art --out <dir>
"""
from pathlib import Path
import argparse, hashlib, json, re, subprocess

LABELS = {'candidate': 'candidate', 'stand_in': 'stand-in', 'stand-in': 'stand-in', 'unfinished': 'unfinished'}
ART07 = ('assets/art07/', 'tools/art07/', 'source_art/art07/')
NOT_APPROVED_SENTENCE = 'NO ART-08 ANIMATION CLIP IN THIS PACKAGE IS CREATOR-APPROVED.'
VALIDATION_STATEMENT = (
    'Hosted runs are headless. "Successful export" means the pinned source exported, the exported pack was proved equal to the '
    'source scripts, and headless scripted suites passed. It does NOT mean native graphical validation: no window was rendered '
    'by these runs and nobody looked at the result. Native graphical validation is the creator playtest on a desktop host.')


def sha256_file(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def _git_ls(root):
    r = subprocess.run(['git', '-c', 'safe.directory=*', '-C', str(root), 'ls-files'], capture_output=True)
    return r.stdout.decode(errors='replace').splitlines() if r.returncode == 0 else []


def art08_inventory(root, pack_records=None):
    """Return (rows, problems, meta) for assets/art08/MANIFEST.json, or (None, [], None) when the source has no ART-08."""
    root = Path(root)
    mpath = root / 'assets/art08/MANIFEST.json'
    if not mpath.is_file():
        stray = [n for n in _git_ls(root) if n.startswith(('assets/art08/', 'source_art/art08/', 'tools/art08/'))]
        return None, (['assets/art08 absent but ART-08 paths exist: %s' % stray[:3]] if stray else []), None
    doc = json.loads(mpath.read_text(encoding='utf-8'))
    problems = []
    legend = set(doc.get('status_legend', {}))
    clips = doc.get('clips', [])
    names = [c['name'] for c in clips]
    if len(set(names)) != len(names):
        problems.append('duplicate clip names in ART-08 manifest')
    for k in doc:
        if re.search(r'approv|accepted|final', k, re.I) and doc[k] not in (False, None, 'pending', 'reserved'):
            problems.append('manifest key %s claims acceptance: %r' % (k, doc[k]))
    on_disk = sorted(p.name for p in (root / 'assets/art08').glob('*.png'))
    listed = set()
    by_name = {}
    rows = []
    for c in clips:
        raw = c.get('status')
        label = LABELS.get(raw)
        if label is None:
            problems.append('clip %s has unknown provenance label %r' % (c.get('name'), raw))
            label = 'UNLABELLED'
        if legend and raw not in legend:
            problems.append('clip %s label %r is not in the manifest status_legend' % (c.get('name'), raw))
        for k, v in c.items():
            if re.search(r'approv|accepted', k, re.I) and v not in (False, None):
                problems.append('clip %s key %s claims acceptance: %r' % (c['name'], k, v))
        strip = c.get('strip')
        fname = Path(strip).name if strip else None
        path = root / strip if strip else None
        exists = bool(path and path.is_file())
        actual = sha256_file(path) if exists else None
        if label == 'unfinished':
            if exists:
                problems.append('clip %s is unfinished but a PNG exists' % c['name'])
        else:
            if not exists:
                problems.append('clip %s (%s) has no PNG at %s' % (c['name'], label, strip))
            elif c.get('sha256') and c['sha256'] != actual:
                problems.append('clip %s manifest sha256 %s != file %s' % (c['name'], c['sha256'][:12], actual[:12]))
            elif not c.get('sha256'):
                problems.append('clip %s has no manifest sha256' % c['name'])
        if exists:
            listed.add(fname)
        in_pack = None
        if pack_records is not None and exists:
            in_pack = any(r in pack_records for r in (strip, strip + '.import', strip + '.remap'))
            if not in_pack:
                problems.append('clip %s strip is not in the exported pack' % c['name'])
            elif strip + '.import' not in pack_records:
                problems.append('clip %s strip has no .import entry in the exported pack' % c['name'])
        if pack_records is not None and label == 'unfinished' and strip and any(r.startswith(strip) for r in pack_records):
            problems.append('unfinished clip %s has pack entries' % c['name'])
        row = dict(name=c['name'], provenance_label=label, manifest_status=raw, creator_approved=False, strip=strip,
                   file_present=exists, sha256=actual, manifest_sha256=c.get('sha256'), bytes=path.stat().st_size if exists else None,
                   hframes=c.get('hframes'), fps=c.get('fps'), loop=c.get('loop'), alias_of=c.get('alias_of'),
                   in_exported_pack=in_pack, provenance=c.get('provenance'), note=c.get('note'))
        # Several manifests describe a stand-in as "approved-lineage"; that is source lineage, never approval of this clip.
        if re.search(r'approv', ' '.join(str(c.get(k) or '') for k in ('provenance', 'note')), re.I):
            row['provenance_text_mentions_approved_lineage'] = True
        rows.append(row)
        by_name[c['name']] = row
    for r in rows:
        if r['alias_of']:
            tgt = by_name.get(r['alias_of'])
            if not tgt or tgt['sha256'] != r['sha256'] or tgt['strip'] != r['strip']:
                problems.append('alias %s -> %s is not the same file and SHA256' % (r['name'], r['alias_of']))
    unlisted = [f for f in on_disk if f not in listed]
    if unlisted:
        problems.append('PNG strips on disk but not in the manifest: %s' % unlisted)
    counts = {}
    for r in rows:
        counts[r['provenance_label']] = counts.get(r['provenance_label'], 0) + 1
    meta = dict(manifest_sha256=sha256_file(mpath), schema=doc.get('schema'), interface_version=doc.get('interface_version'),
                clip_count=len(rows), label_counts=counts, distinct_png_files=len(listed),
                creator_approved_count=0, statement=NOT_APPROVED_SENTENCE)
    return rows, problems, meta


def ld05_inventory(root):
    root = Path(root)
    rb = root / 'scripts/room_boundary.gd'
    if not rb.is_file():
        return None
    text = rb.read_text(encoding='utf-8')

    def static(name):
        m = re.search(r'static\s+var\s+%s\s*=\s*(true|false)' % name, text)
        return m.group(1) == 'true' if m else None
    flags = sorted(set(re.findall(r'"(--ld05-[a-z0-9-]+)"', text)))
    out = dict(
        switches=dict(ROOF_ENABLED=static('ROOF_ENABLED'), ORIGINAL_ROOMS_ENABLED=static('ORIGINAL_ROOMS_ENABLED'), command_line_flags=flags),
        files={n: sha256_file(root / n) for n in ('scripts/room_boundary.gd', 'tests/ld05_boundaries.gd') if (root / n).is_file()},
        room_audit=None)
    audit = root / 'docs/ld05/room_audit.json'
    if audit.is_file():
        d = json.loads(audit.read_text(encoding='utf-8'))
        rooms = d.get('rooms', [])
        fixed = []
        for i, r in enumerate(rooms):
            n = [f['id'] for f in r.get('findings', []) if 'fixed' in str(f.get('status', ''))]
            if n:
                fixed.append(dict(room=i, name=r.get('name'), fixed_findings=n))
        out['room_audit'] = dict(sha256=sha256_file(audit), rooms=len(rooms), totals=d.get('totals'), rooms_with_fixes=fixed)
    return out


def tr08_inventory(root):
    root = Path(root)
    scripts = root / 'scripts'
    out = dict(tr08_present=(scripts / 'tr08_embodied_cinematics.gd').is_file(), flags={}, binds_art08_clips=False,
               binding_doc=None)
    seen = {}
    for p in sorted(scripts.glob('*.gd')):
        for f in re.findall(r'"(--(?:pm|tr0[5-9]|ld0[5-9])-[a-z0-9=-]+)', p.read_text(encoding='utf-8', errors='replace')):
            seen.setdefault(f, set()).add(p.name)
    out['flags'] = {k: sorted(v) for k, v in sorted(seen.items())}
    lib = scripts / 'tr08_clip_library.gd'
    if lib.is_file():
        t = lib.read_text(encoding='utf-8', errors='replace')
        out['binds_art08_clips'] = 'art08' in t
        out['clip_library_stand_in_markers'] = len(re.findall(r'stand[-_ ]?in', t, re.I))
    for rel in ('docs/tr08/ART08_BINDING.json', 'docs/tr08/DEMO_ARGS.md'):
        if (root / rel).is_file():
            out.setdefault('docs', {})[rel] = sha256_file(root / rel)
    return out


def referenced_by_scripts(root):
    """Which ART-08 strips does the game code actually reference (art-only builds show nothing)."""
    root = Path(root)
    blob = ''.join(p.read_text(encoding='utf-8', errors='replace') for p in sorted((root / 'scripts').glob('*.gd')))
    return {'art08_path_mentioned_in_scripts': 'assets/art08' in blob or 'art08/' in blob}


def build(root, variant, head, tree, spec=None, launchers=None, pack_records=None, purpose=None, export_ok=None):
    root = Path(root)
    spec = spec or {}
    rows, problems, meta = art08_inventory(root, pack_records)
    tracked = _git_ls(root)
    art07 = [n for n in tracked if n.startswith(ART07)]
    if art07:
        problems.append('ART-07 files in source: %s' % art07[:3])
    if pack_records is not None:
        in_pack = [n for n in pack_records if n.startswith(ART07)]
        if in_pack:
            problems.append('ART-07 entries in the exported pack: %s' % in_pack[:3])
        has_art08 = rows is not None
        pack_art08 = [n for n in pack_records if n.startswith('assets/art08/')]
        if has_art08 and 'assets/art08/MANIFEST.json' not in pack_records:
            problems.append('assets/art08/MANIFEST.json is not in the exported pack')
        if any(n.startswith('source_art/') for n in pack_records):
            problems.append('source_art entries in the exported pack')
        if not has_art08 and pack_art08:
            problems.append('pack contains assets/art08 but source has no ART-08 manifest')
        if spec.get('expect_art08') is True and not has_art08:
            problems.append('variant expects ART-08 clips but the source has none')
        if spec.get('expect_art08') is False and (has_art08 or pack_art08):
            problems.append('variant must not contain ART-08 clips')
    inv = dict(
        schema='build07/1', variant=variant, label=spec.get('label'), purpose=purpose,
        source_head=head, source_tree=tree, pinned_commit=spec.get('commit'),
        art07=dict(excluded=not art07 and not (pack_records and any(n.startswith(ART07) for n in pack_records)), source_hits=art07),
        art08=dict(present=rows is not None, manifest=meta, clips=rows, code_references=referenced_by_scripts(root),
                   statement=NOT_APPROVED_SENTENCE),
        ld05=ld05_inventory(root), tr08=tr08_inventory(root), launchers=launchers or [],
        validation=dict(
            export_success=export_ok,
            native_graphical_validation='NOT PERFORMED',
            hosted_run_headless=True,
            statement=VALIDATION_STATEMENT),
        problems=problems)
    return inv


def to_markdown(inv):
    L = ['# Package inventory: %s' % inv['variant'], '',
         '- Source commit: `%s`' % inv['source_head'], '- Source tree: `%s`' % inv['source_tree'], '',
         '## Validation level', '', VALIDATION_STATEMENT, '',
         '- Export success: %s' % inv['validation']['export_success'],
         '- Native graphical validation: %s' % inv['validation']['native_graphical_validation'], '',
         '## ART-08 clips', '', inv['art08']['statement'], '']
    if inv['art08']['present']:
        m = inv['art08']['manifest']
        L += ['Manifest SHA256 `%s`; labels: %s; %d clips, %d distinct PNG files.' % (m['manifest_sha256'], m['label_counts'], m['clip_count'], m['distinct_png_files']), '',
              '| clip | label | creator approved | frames | fps | PNG SHA256 | in pack | note |', '|---|---|---|---|---|---|---|---|']
        for r in inv['art08']['clips']:
            alias = ' (alias of %s, same file)' % r['alias_of'] if r['alias_of'] else ''
            L.append('| %s%s | %s | no | %s | %s | %s | %s | %s |' % (
                r['name'], alias, r['provenance_label'].upper(), r['hframes'], r['fps'], r['sha256'] or 'no PNG shipped',
                {True: 'yes', False: 'NO', None: 'n/a'}[r['in_exported_pack']], (r.get('note') or '').replace('|', '/')[:90]))
        L += ['', 'References from game code: %s.' % ('yes' if inv['art08']['code_references']['art08_path_mentioned_in_scripts'] else
              'none (the strips are packaged but nothing plays them in this variant)')]
    else:
        L.append('This source contains no ART-08 clips.')
    L += ['', '## ART-07', '', 'Excluded: %s.' % ('yes' if inv['art07']['excluded'] else 'NO'), '', '## LD-05', '']
    if inv['ld05']:
        sw = inv['ld05']['switches']
        L.append('Switches: ROOF_ENABLED=%s, ORIGINAL_ROOMS_ENABLED=%s, command line %s.' % (sw['ROOF_ENABLED'], sw['ORIGINAL_ROOMS_ENABLED'], ', '.join(sw['command_line_flags']) or 'none'))
        ra = inv['ld05']['room_audit']
        if ra:
            L.append('Room audit: %d rooms; rooms with non-roof fixes: %s.' % (ra['rooms'], ', '.join('R%d' % x['room'] for x in ra['rooms_with_fixes'])))
    else:
        L.append('This source has no LD-05 boundary code.')
    L += ['', '## TR-08 and pilot flags found in scripts', '']
    L.append('TR-08 present: %s.' % inv['tr08']['tr08_present'])
    for k, v in inv['tr08']['flags'].items():
        L.append('- `%s` in %s' % (k, ', '.join(v)))
    L += ['', '## Launchers', '']
    for l in inv['launchers']:
        L.append('- %s: %s' % (l['name'], l.get('describe', '')) + ('  args: `%s`' % ' '.join(l.get('flags', [])) if l.get('flags') else ''))
    if inv['problems']:
        L += ['', '## PROBLEMS', ''] + ['- ' + p for p in inv['problems']]
    return '\n'.join(L) + '\n'


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--source-root', type=Path, required=True)
    p.add_argument('--variant', required=True)
    p.add_argument('--out', type=Path)
    a = p.parse_args()
    git = lambda *x: subprocess.check_output(['git', '-c', 'safe.directory=*', '-C', str(a.source_root), *x]).decode().strip()
    inv = build(a.source_root, a.variant, git('rev-parse', 'HEAD'), git('rev-parse', 'HEAD^{tree}'))
    if a.out:
        a.out.mkdir(parents=True, exist_ok=True)
        (a.out / 'INVENTORY.json').write_text(json.dumps(inv, indent=2) + '\n', encoding='utf-8')
        (a.out / 'INVENTORY.md').write_text(to_markdown(inv), encoding='utf-8')
    print(json.dumps({k: inv[k] for k in ('variant', 'source_head', 'problems')}, indent=2))
    raise SystemExit(1 if inv['problems'] else 0)


if __name__ == '__main__':
    main()

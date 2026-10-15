# Sound Shogun — no-regeneration recovery

1. Read CONTEXT, SESSION_LOG, docs/agent_handoffs/AUD02_ALPHA061_PM_REPORT.md,
   docs/audio/aud02/README.md and PROVENANCE.md. Verify live branch/PR SHA.
2. Reuse all AUD01 architecture,22 existing WAVs and the12 AUD02 originals.
   Do not regenerate them. Normal launch uses AUD01; --audio-bank=aud02 opts in.
3. Verify inventory512 and original ZIP hash from audit summary. Source recordings
   are intentionally absent from public Git and exports. Retrieve original creator
   attachments privately if needed, never infer redistribution rights.
4. Use separately delivered private listening HTML for sources; public board works
   from a downloaded checkout for original/fallback WAVs. Agent never heard these
   recordings. Complete listening before classifying actual artistic suitability.
5. Apply exported creator choice JSON as targeted revisions; preserve gameplay/save
   identity and no duplicate transition emitters. Soundtrack remains creator-owned.
6. Fresh QA: tools/run_aud02_qa.py --godot <4.6.1>. Windows profiles are verified
   disposable. Audit source bytes after Windows newline/import rewrites, and run
   package audits/relevant exported checks if assets change. Retain raw results.
7. Commit/publish on audio-curation branch and update these records. No shared
   branch merges, history rewrite, source-pack uploads or default bank promotion.

# KAZE PM-02 — Agent Continuity and Recovery Protocol

**Owner:** PM-01 (Project Management)  
**Adopted for review:** 2026-10-14  
**Status:** Documentation-only proposal, awaiting merge approval.

## Purpose
GitHub is the durable technical source of truth for Kaze / Momentum Fractured. ChatGPT chats and temporary Work environments are **not automatically backed up by Git**. These continuity files make it possible for a replacement specialist to resume from verified source without reproducing finished work or guessing at lost instructions.

## Required session discipline
1. Start: read the assigned `CONTEXT.md`, `SESSION_LOG.md` and `RECOVERY.md`, then retrieve actual current remote branch/PR SHA.
2. During work: commit meaningful completed increments to **your own specialist branch**; record creator decisions, their dates, affected components and relevant links in `SESSION_LOG.md`.
3. Before pause, quota limit, stall or final return: push recoverable source, update `CONTEXT.md` with exact branch/commit/test status and record a short actionable `RECOVERY.md` checkpoint. If push fails, report it and avoid saying the work is backed up.
4. On re-entry: compare GitHub state to the record, inspect existing work, **do not restart or regenerate** unless assets are verifiably absent.
5. Report tests precisely: reported vs independently verified, headless vs interactive, source vs export, macOS vs Windows, sampled vs sustained frame rate.
6. Never merge into main or integration unless PM/creator explicitly approves.
7. Only archive conversation transcripts if the creator supplies/authorizes an export. Do **not** imply GitHub automatically stores verbatim chats. No credentials, personal information, private account data or inaccessible local machine paths as a substitute for remote artifacts.
8. Keep continuity updates scoped to a docs-only commit when possible; link to previous authoritative assignments and PM reports instead of duplicating entire documents.

## Required records
- `CONTEXT.md`: mission, current remote pointers, assets/code and explicit known/unknown state.
- `SESSION_LOG.md`: dated, sourced summaries and creator decisions, never invented transcript quotes.
- `RECOVERY.md`: ordered no-regeneration recovery procedure and next action.

## Existing work
Reconstructed bootstrap records reflect known GitHub evidence as of 2026-10-14. They **are not an archive of missing chats**. Future agents must verify live branch state before trusting any historical SHA. Existing `docs/agent_assignments/`, `docs/agent_handoffs/` and `docs/project_management/` remain in place. No game paths change.

## Index
- [Sound Shogun](sound_shogun/CONTEXT.md)
- [Level Masta Masta](level_masta_masta/CONTEXT.md)
- [Gameplay Masta](gameplay_masta/CONTEXT.md)
- [Art Mane](art_mane/CONTEXT.md)
- [Build Shogun](build_shogun/CONTEXT.md)
- [Story Agent](story_agent/CONTEXT.md)

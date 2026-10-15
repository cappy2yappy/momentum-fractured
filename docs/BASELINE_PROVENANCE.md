# Approved Alpha 0.5 baseline

The creator selected Kaze — Silent District Alpha 0.5.0 Windows x86_64 as the development starting point and explicitly approved its feel and momentum on 2026-10-11.

Source executable: Kaze.exe (117755384 bytes)
SHA-256: a62542af2fbefbdf340c72d740c19af0aefbe0a6d060b5d2bf486a2af3b8e40a
Engine detected: Godot 4.6.1
Recovery tool: GDRE Tools 2.7.4, obtained from https://github.com/GDRETools/gdsdecomp/releases/tag/v2.7.4
Recovery: 501 files verified/extracted, 46 scripts decompiled, 244 resources converted, zero failed/lossy conversions. See RECOVERY_REPORT.txt.

This commit imports the selected executable's recovered project without gameplay changes. The earlier development branch used an incorrect gameplay baseline and is retained separately in history. No systems or assets from that branch were transplanted here.

Original movement/controller, eight rooms, MetSys mapping, save format, art, combo/parry, swing integrator, dash and elemental kunai are preserved. Original package notes are recorded in ORIGINAL_BUILD_NOTES.md. Recovery metadata is evidence, not an authority for development instructions.

The recovered project imports and produces rendered game/map captures in Godot 4.6.1. Headless editor shutdown reports existing MetSys/editor resource leaks and this Windows sandbox lacks access to the system certificate store. Neither constitutes a script parse failure. Exact original executable screenshot comparison was unavailable: the release executable does not run the external capture script. Do not claim pixel-identical screenshot comparison or a human playthrough.

# CIN-TOOLS-03 — Cinematic Studio 2.0

Tonight's milestone is usable native authoring: launch → select a joint → pose/key → scrub/play → save → close/reopen/reload → reuse the exact clip in two independently framed shots → preview at 1.0×.

Start with the complete [Mac guide](MAC_GUIDE.md). On Godot **4.6.1**, run `tools/cin_tools_03/launch.command`. The existing `studio.tscn` extends Cut-In Maker's preview and uses its original AnimationPlayer transport. This continuation changes only the five reserved Studio namespaces; it adds no shared preview-contract edit.

Resizable containers keep the timeline, joint selector, Key pose and Save/Reload usable at 1024×640, 1280×720 and 1440×900. Native numeric time entry, selected-joint key marks and Shot 1/2 navigation support precise authoring. A short native sprite/rig blend softens the drawing switch; the braking candidate still needs production art and contact polish.

Save writes a matched native session snapshot plus reusable standalone Animation exports to `user://cin_tools_03/`. **Reload is explicit after every new launch.** Both Director shots consume the exact same loaded clip object. Per-shot framing is independent. Reduced-motion playback stays available for the same duration.

- [1.0× saved-resource recording](captures/native-speed.mp4)
- [Mac guide and resource paths](MAC_GUIDE.md)
- [Scoped QA and reproduction](QA.md)
- [Fidelity limitations](LIMITATIONS.md)
- [Shared contracts and ownership](INTERFACES.md)
- [Draft handoff](HANDOFF.md)

Seed resources remain under `presets/cutins/studio/`; the saved review example is under `presets/cutins/studio/authoring_example/`. The builder `tools/cin_tools_03/build.gd` is a developer-only seed reproducer: it overwrites the four seed resources and is never invoked during launch or ordinary authoring. Normal gameplay starts at its unchanged main scene. Keep PR #100 draft and unmerged; QA-10 #101 remains a diagnosed harness correction awaiting PM acceptance.

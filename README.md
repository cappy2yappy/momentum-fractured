# Kaze — Silent District Alpha 0.5.2 Development

This continues the creator-approved Alpha 0.5.0 executable. Its player controller, original eight-room geometry, art, momentum and controls are preserved. See PROJECT_STATUS.md for provenance, tests, limitations and the next task.

The first expansion adds Relay Undercroft and Signal Terrace beyond the restored Relay Archive, three collectible relay sigils, a Fire cache, an Electric return to Echo Shrine, a shrine and a travel kit.

## Play

Open project.godot in Godot 4.6.1, then run scenes/main.tscn. The Windows package runs without Godot installed. Existing Alpha 0.5 saves remain compatible.

A/D or arrows move. Double-tap a direction to run. Space jumps; Windstep enables double jump. Hold Q to tether and pump with movement; release to retain momentum. Shift dashes. J/left click attacks; F/K/right click parries. R throws kunai; T cycles elements. E interacts with doors, shrines and the relay. M opens the atlas; I opens the travel kit; Esc pauses. The pause screen has Save Journey. Touch controls retain the existing layout and add kunai/cycle buttons.

## New route

Restore the Relay Archive as before, then use its east door. Explore the two annexes and recover three relay sigils. Fire opens the terrace cache. Electric opens the return to Echo Shrine; after opening, both ends are usable. The Undercroft shrine saves an exact safe arrival position. The map and kit track progress.

## SkyWorks

After collecting all three relay sigils, use Signal Terrace’s east door with E. Open the Approach seal with Wind kunai, then the Foundry seal with Electric kunai (T selects, R throws). Attune the Foundry Refuge shrine before entering Keeper Relay. Parry the Keeper’s facing sweep or evade it; jump or tether over its ground pulse. Its second phase warns faster. After victory, press E at the relay to restore SkyWorks and open the two-way return to Relay Undercroft. Existing saves continue directly into this route.

## Verification

Seven suites cover controller/geometry preservation, combat/swing behavior, expansion, live-input traversal and save compatibility. Run them with `godot --headless --path . --script res://tests/<suite>.gd -- --test` using disposable user data. Windows exports with the committed export_presets.cfg and official 4.6.1 templates. CI is included.

This is a tested development increment. The creator completed the previous ten-room expansion. Human acceptance of the new SkyWorks route and authenticated web-benchmark comparison remain pending. See PROJECT_STATUS.md for known editor cleanup and sandbox certificate diagnostics.

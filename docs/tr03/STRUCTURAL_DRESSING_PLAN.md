# Structural dressing audit and pilot plan

Priority ranks are visual review recommendations, not collision work. Each reference identifies the actual world-map cell and a live collision-shelf candidate from ENDPOINT_MATRIX.json. Existing backdrop may already imply support; later artists must resolve that in composition rather than stamp a support everywhere. No global remodelling.

|Priority / room|Map reference|Representative shelf candidate (world px)|Structural direction / status|
|---|---|---|---|
|P2 R0 CANAL HAVEN|atlas cell [0, 2, 0]|[480.0, 1110.0, 300.0, 40.0]|quay retaining mass and timber corbels — audit only; not implemented|
|P2 R1 LANTERN MARKET|atlas cell [1, 2, 0]|[370.0, 1120.0, 280.0, 40.0]|market awning posts and stall roof beams — audit only; not implemented|
|P2 R2 FLOODED CISTERN|atlas cell [2, 2, 0]|[330.0, 1120.0, 260.0, 40.0]|canal retaining piers outside water lanes — audit only; not implemented|
|P2 R3 ECHO SHRINE|atlas cell [2, 1, 0]|[0.0, 850.0, 300.0, 40.0]|shrine stone brackets and wall-backed ruins — audit only; not implemented|
|P1 R4 BROKEN SPAN|atlas cell [3, 1, 0]|[300.0, 1110.0, 310.0, 40.0]|bridge girders/cables terminating in existing abutments — audit only; not implemented|
|P1 R5 ASCENT TOWER|atlas cell [4, 1, 0]|[0.0, 1080.0, 280.0, 40.0]|tower beam pockets and lift-shaft crossmembers — audit only; not implemented|
|P2 R6 TIDE WARDEN|atlas cell [4, 0, 0]|[300.0, 1110.0, 280.0, 40.0]|arena stone ledges joined to perimeter mass — audit only; not implemented|
|P2 R7 RELAY ARCHIVE|atlas cell [5, 0, 0]|[0.0, 1090.0, 300.0, 40.0]|archive shelf consoles and wall ribs — audit only; not implemented|
|P2 R8 RELAY UNDERCROFT|atlas cell [5, 1, 0]|[0.0, 1090.0, 310.0, 40.0]|undercroft masonry corbels — audit only; not implemented|
|P2 R9 SIGNAL TERRACE|atlas cell [6, 1, 0]|[0.0, 830.0, 650.0, 40.0]|terrace roof parapets and wall brackets — audit only; not implemented|
|P2 R10 SKYWORKS APPROACH|atlas cell [6, 0, 0]|[0.0, 830.0, 300.0, 40.0]|intake brackets and fixed conduit frames — audit only; not implemented|
|P2 R11 STORM FOUNDRY|atlas cell [7, 0, 0]|[0.0, 760.0, 310.0, 40.0]|foundry service gantries and fixed crossbeams — audit only; not implemented|
|P2 R12 KEEPER RELAY|atlas cell [7, 1, 0]|[80.0, 830.0, 480.0, 40.0]|keeper arena buttresses behind play plane — audit only; not implemented|
|P1 R13 MOORING LOFT|atlas cell [-1, 2, 0]|[200.0, 1160.0, 400.0, 40.0]|mooring crane/timber load paths — audit only; not implemented|
|P0 R14 BELLROOF WALK|atlas cell [-1, 1, 0]|[750, 900, 400, 40]|roof knee braces into continuous roof mass — visual-only pilot implemented; see structure_R14_original/refined.jpg|
|P0 R15 LOWER SLUICE|atlas cell [2, 3, 0]|[1320, 940, 400, 40]|masonry corbels and retaining piers to dry recovery floor — visual-only pilot implemented; see structure_R15_original/refined.jpg|
|P2 R16 ROOT SHRINE|atlas cell [3, 3, 0]|[80.0, 1120.0, 500.0, 40.0]|soil-backed stone with terminating roots — audit only; not implemented|
|P1 R17 COUNTERWEIGHT SPIRE|atlas cell [4, 2, 0]|[80.0, 1900.0, 520.0, 40.0]|counterweight-shaft landing brackets and crossbeams — audit only; not implemented|
|P1 R18 PUMP GALLERY|atlas cell [4, 3, 0]|[1040.0, 1180.0, 320.0, 40.0]|pump housings and fixed frame brackets — audit only; not implemented|
|P1 R19 COIL SERVICE HALL|atlas cell [5, 3, 0]|[1950.0, 1140.0, 300.0, 40.0]|insulated service ribs — audit only; not implemented|
|P2 R20 RELAY JUNCTION|atlas cell [5, 2, 0]|[1400.0, 1120.0, 750.0, 40.0]|garden retaining stone and rooted arches — audit only; not implemented|

## Implemented evidence

[R14 before](../agent_handoffs/tr03_evidence/structure_R14_original.jpg) / [after](../agent_handoffs/tr03_evidence/structure_R14_refined.jpg); [R15 before](../agent_handoffs/tr03_evidence/structure_R15_original.jpg) / [after](../agent_handoffs/tr03_evidence/structure_R15_refined.jpg). Captured1280×720, zoom1.0, scripted grounded fixture on the recovery floor. R14 roof backing/braces terminate in existing roof mass; R15 piers reach floor1300. Low-contrast art draws before collision lips/live actors. Collider counts remain23 forR14 and15 forR15. No shader, particle, physics, navigation or grapple position changes.

Source art coordination: PR24 ARCHITECTURE.md and PR25 ARCHITECTURE_KIT.md. Their screenshot coordinates were not used as collision coordinates. No unapproved rendered Lane B art is included.

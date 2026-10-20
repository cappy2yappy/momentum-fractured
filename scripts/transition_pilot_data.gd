extends RefCounted
## PM pilot (TRANSITION): the ONE data block for Canal-left aperture numbers and the
## staged stair pilot timings. Presentation and tests read these values; the
## crossing/armed/corridor/recovery logic in cinematic_transitions.gd is untouched
## and tests assert that these mirrored numbers still match that runtime logic.
## Source: /home/claude/pilot_shared/CANAL_CONTRACT.md v1 (LEVEL, base PR51 baedd678).

const CANAL_CONTRACT_VERSION = "v1"
const CANAL_LEFT = {
	"room": 13, "target": 0,
	"door_x": 120.0, "floor_y": 1200.0,
	# Section 3: clear aperture Kaze walks into, and the jamb/head frame around it.
	"aperture": Rect2(72,1068,96,132),
	"frame": Rect2(40,1032,160,168),
	# Section 4: trigger line, feet corridor and inward arming line (mirrors update()).
	"trigger_x": 120.0, "corridor_top": 1110.0, "corridor_bottom": 1208.0, "arm_x": 136.0,
	"arrival": Vector2(184,1198),
	# Section 5: LEVEL-owned solids. Used ONLY by tests as a stub when the LEVEL
	# branch (scripts/canal_gatehouse.gd) is not combined into this checkout.
	"pier": Rect2(0,1020,72,180), "mass": Rect2(0,0,296,1020), "ceiling_y": 1020.0,
	"leftmost_feet_x": 86.0,
}
## Art Mane layers per /home/claude/pilot_shared/ART_INTEGRATION.md (absolute room
## positions, 1 px = 1 room px). Drawn only when the files exist in the checkout (the
## coordinator's combination commit); otherwise the procedural stand-in is drawn.
## Order is back to front; L4 is drawn by the cinematic node above Kaze.
const CANAL_ART = [
	["L0_hall_back_wall","res://assets/pm_pilot/canal/canal_L0_hall_back_wall.png",Vector2(72,1020)],
	["L1_door_interior","res://assets/pm_pilot/canal/canal_L1_door_interior.png",Vector2(72,1068)],
	["L1_door_frame","res://assets/pm_pilot/canal/canal_L1_door_frame.png",Vector2(40,1032)],
	["L1_door_leaf","res://assets/pm_pilot/canal/canal_L1_door_leaf.png",Vector2(72,1068)],
	["L2_gatehouse_face","res://assets/pm_pilot/canal/canal_L2_gatehouse_face.png",Vector2(0,0)],
	["L2_lintel_course","res://assets/pm_pilot/canal/canal_L2_lintel_course.png",Vector2(72,960)],
	["L3_back_pier","res://assets/pm_pilot/canal/canal_L3_back_pier.png",Vector2(0,1020)],
]
const CANAL_FRONT = ["L4_mouth_corbel","res://assets/pm_pilot/canal/canal_L4_mouth_corbel.png",Vector2(284,1004)]
const LOCKED_TINT = Color("c48e78")
## Wipe kit (screen space). Panels 1822x488, tilted 6 degrees, authored travelling -x.
const WIPE_ART = {
	"a":"res://assets/pm_pilot/wipe/wipe_panel_a.png",
	"b":"res://assets/pm_pilot/wipe/wipe_panel_b.png",
	"c":"res://assets/pm_pilot/wipe/wipe_panel_c.png",
	"badge":"res://assets/pm_pilot/wipe/wipe_badge_plate.png",
}
const WIPE_ROWS = [[-230.0,"a",0.0],[-60.0,"b",-90.0],[110.0,"c",50.0],[280.0,"a",-60.0],[450.0,"b",30.0]]

## Staged stair pilot: R14 Bellroof Walk <-> R17 Counterweight Spire (PILOTS 14:17/17:14),
## chosen per STORY_GUIDANCE.md. Enter -> inherited 0.65 s loader -> arrive -> control.
const STAGED_STAIR = {
	"pairs": ["14:17"],                     # ONE staged entrance; 17:14 keeps TR05
	"enter": 0.85, "arrive": 0.85,          # + 0.65 loader = 2.35 s total
	"reduced_enter": 0.15, "reduced_arrive": 0.15, # + 0.65 loader = 0.95 s total
	"watchdog": 4.0,                         # hard ceiling: control always returns
	# Render-only tread contacts, feet offsets from the R14 stair contact (1450,478),
	# measured from the approved ART-04 stair_flight_right.png tread tops as drawn.
	"treads": [Vector2(50,-14),Vector2(107,-26),Vector2(170,-39)],
	"zoom": 1.35,
	"flag": "--pm-staged-stair",
}

## TR-08 (default): embodied stair and Canal doorway presentations. Timings are seconds.
## The inherited loader clock (0.65 s, swap at 0.33 s) is NOT changed; sequences run
## around it (see scripts/tr08_*.gd and docs/tr08/README.md).
const TR08 = {
	"stair_pairs": ["14:17","17:14"],
	"canal_pairs": ["13:0","0:13"],
	"off_flags": ["--tr08-off","--pm-staged-stair"],
	"stair": {
		"layer": 6,                 # above the HUD (1) and the loader fade
		"cover": 0.30,              # opening wipe covers the world; request released here
		"open_out": 0.30,           # opening wipe clears off the stage
		"close_in": 0.30, "close_out": 0.25,
		"loops": 2, "reduced_loops": 1,
		"reduced_rate": 1.25, "reduced_fade": 0.15,
		"figure_px": 430.0,         # Kaze height on the 1280x720 stage (60 percent)
		"zoom": 1.08,               # gentle push-in over the climb (none when reduced)
		"watchdog": 6.0,
	},
	"canal": {
		"layer": 2,                 # world-space layer above the HUD loader fade
		"loader_cover": 0.33,       # inherited loader time from request to hidden swap
		"r0_door": Vector2(590,780),          # R0 end of the passage (legacy door art, unchanged)
		"r0_opening": Rect2(560,684,60,89),   # its drawn inner opening (room_presentation.gd)
		"depth_px": 8.0, "depth_scale": 0.86, "shade": 0.32,
		"reduced_rate": 1.4,
		"watchdog": 5.0,
	},
}

static func canal_key() -> String:
	return "%d:%d"%[CANAL_LEFT.room,CANAL_LEFT.target]

## Loads every optional texture that exists; the returned dictionary keeps them alive.
static func load_art() -> Dictionary:
	var result={}
	for row in CANAL_ART+[CANAL_FRONT]:
		if ResourceLoader.exists(row[1]): result[row[0]]=load(row[1])
	for k in WIPE_ART:
		if ResourceLoader.exists(WIPE_ART[k]): result["wipe_"+k]=load(WIPE_ART[k])
	return result

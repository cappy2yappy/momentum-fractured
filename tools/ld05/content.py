"""Hand-curated gameplay content positions (feet/centre px) per room, read from scripts/*.gd (cited in the audit).
Used only by build_audit.py to tag which platforms carry purpose. Keys are room indices."""
SHRINES = {0:(220,1300),8:(2060,1300),11:(1720,1300),12:(2220,1300),16:(420,1120)}
PICKUPS = {  # item or objective the player is sent to
 1:[("Windstep",1580,1300)],3:[("Wind Tether",1320,1300)],4:[("Fire Kunai",1080,1030)],
 5:[("Gale Dash",1320,1300),("Electric Kunai",1510,930)],
 13:[("Stride I",450,440)],
 8:[("Relay sigil undercroft",1470,740)],9:[("Relay sigil terrace west",1490,640),("Relay sigil fire cache",2240,810)],
}
LORE = {14:(1300,1220),15:(390,500),16:(1500,760),17:(1370,420),18:(1690,620),19:(1960,520),20:(1800,1120)}
KEEPER = {12:(1320,1300)}

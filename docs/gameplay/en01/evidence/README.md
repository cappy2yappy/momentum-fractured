# EN-01 evidence

Godot 4.6.1, macOS Apple M4, native OpenGL Compatibility renderer. Captured from live scene ticks with the actual controller using `tests/en01/capture.gd`. Screenshots are unedited. Automated inputs are not a human feel/balance sign-off.

- [Combined arena overview](combined_overview.png): all three prototypes and cover.
- [Guard telegraph](guard_telegraph.png) and [dash](guard_dash.png).
- [Ambush telegraph](ambush_telegraph.png) and [dash](ambush_dash.png).
- [Ranged telegraph](ranged_telegraph.png) and [jump over projectile](ranged_jump_dodge.png).
- [Combined close-up](combined_telegraph.png).
- [Assertion counts](results.json), [native controller run](native_framework.txt), [real disk persistence](persistence.txt), [preserved source hashes](preserved_sha256.json).

The existing suites total 191 assertions; the framework suite passes 43 assertions in both headless and native runs; five additional assertions verify the real serializer and load path. Negative-path save tests intentionally target nonexistent directories. Headless runs report a sandbox macOS system-certificate lookup warning; no script errors or failing assertions occurred. Native controller verification has no such warning.

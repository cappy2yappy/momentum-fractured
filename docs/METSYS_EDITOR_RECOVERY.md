Restored missing editor-only files from official MetSys source: https://github.com/KoBeWi/Metroidvania-System
Pinned source revision: 0065ae8974291d1c4dfe72f55cfca0f37e3d6ef3

Only missing files were added; recovered runtime scripts, themes, and game assets were preserved. The editor scene UID crxgu2q73va5y matches the recovered MetSysPlugin reference. The official plugin manifest and MIT license are included. Added files:

Translations\MetSys.pot
Translations\nl.po

Recovery manifest selected the wrong editor script. The official manifest restores MetSysPlugin. Its editor Main scene now loads by its explicit resource path rather than an unresolved UID during editor initialization. No runtime behavior was changed by this editor-only repair; clean import is verified.

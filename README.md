# Katakana — Dank Material Shell plugin

Rotates through the katakana table (104 kana including voiced and combination
kana; hiragana can be switched on too) with romaji, rendered by Dank Material
Shell itself. One plugin, two surfaces (DMS ≥ 1.5.0 composite plugin):

* **Bar pill** — the current kana (plus romaji) in the DankBar. Left click
  opens a popout card with the kana, its romaji and *Play* / *Next* buttons.
  Right click skips to the next kana. With *open popouts on hover* enabled
  in the bar settings the card opens on hover.
* **Desktop widget** — text on the wallpaper layer, fixed where you put it.
  Right-click drag moves it, the corner handle resizes it, left click skips
  to the next kana, middle click speaks it.

Both surfaces share the settings. By default every instance (all monitors,
bar and desktop) shows the same kana; turn off *Same kana everywhere* for
independent rotations.

Sibling plugins: [Hiragana](https://nemiru.tail2e41a3.ts.net/lykos/dms-hiragana-widget),
[JLPT Kanji](https://nemiru.tail2e41a3.ts.net/lykos/dms-kanji-widget) and [JLPT vocab + Jlab listening](https://nemiru.tail2e41a3.ts.net/lykos/jlpt-kanji-widget)
(the `dms-plugin` branch).

## Install

```sh
git clone https://nemiru.tail2e41a3.ts.net/lykos/dms-katakana-widget.git ~/dms-katakana-widget
~/dms-katakana-widget/install.sh          # symlink into ~/.config/DankMaterialShell/plugins
~/dms-katakana-widget/install.sh copy     # ...or copy, if you want to delete the clone
```

Then in DMS: **Settings → Plugins → Scan for Plugins**, toggle *Katakana* on.
Add `katakanaWidget` to a bar section under **Settings → DankBar → layout**,
and/or add the desktop widget under **Settings → Desktop Widgets**. Settings
(sets, timing, sizes, audio) are in the plugin's accordion in the Plugins tab.

Japanese text needs a CJK font: `sudo pacman -S noto-fonts-cjk`.

Reload after editing the QML: `dms ipc call plugins reload katakanaWidget`.

## Settings

| section | keys |
|---|---|
| Content | katakana, hiragana too, voiced kana, combination kana, **seconds per kana** (3–600), random / gojūon order, same kana everywhere, Japanese font |
| Audio | speak automatically, audio player command, text-to-speech command (optional, replaces the clips) |
| Bar pill & popout | romaji in the pill, popout width, popout kana size |
| Desktop widget | kana size, show romaji, show set tag, text outline, background opacity |

## Audio

*Play* in the popout (or middle click on the desktop widget) plays a bundled
clip of the kana from `KatakanaWidget/data/audio/<romaji>.wav`. Every clip is
trimmed and levelled to the same loudness, so all 104 kana sound alike in
length and volume. The player is picked at run time: the first of `pw-play`,
`paplay`, `mpv`, `ffplay` on PATH (all of them drain the buffer before exiting,
so short clips are not cut). *Audio player command* overrides that, e.g.
`pw-play {file}`.

The clips are native-speaker recordings from
[Learn Japanese Adventure](https://www.learn-japanese-adventure.com/learn-how-to-speak-japanese.html)
(the kana sound files on that page). The recordings remain that site's
property and are bundled here with credit only. `gen-audio` downloads them, trims
the silence, levels them and writes the WAVs. To re-fetch, or to synthesise
with Microsoft's neural voice instead:

```sh
python3 -m venv .venv && .venv/bin/pip install numpy       # plus ffmpeg and curl on PATH
.venv/bin/python gen-audio                                  # recordings from the site
.venv/bin/pip install edge-tts && .venv/bin/python gen-audio --source edge   # synthesised
```

Why clips and not live text-to-speech: no offline engine says a lone mora
well. Piper's Japanese voice is trained on sentences; on a single kana it
returns a different length every call, chops the vowel, renders ン as a click
and peaks every clip at full scale, so kana sound inconsistent and often wrong
(a speech recogniser identified 5 of 104). espeak-ng and Open JTalk are
steadier but their consonants are weak (21 and 30 of 104).

Live speech is still available: set *Text-to-speech command* and the clips
are bypassed, `{text}` replaced by the kana. `espeak-ng -v ja -s 110 {text}`
works out of the box; `say-ja {text}` uses Piper (`pipx install
"piper-tts[http,ja]"`, then `say-ja setup`; `say-ja server` for instant
playback; `PIPER_SPEAKER`, `PIPER_LENGTH_SCALE`, `PIPER_VOICE` knobs; errors in
`~/.cache/say-ja.log`). Expect the single-kana problems described above.

No sound from the widget? (1) `pw-play ~/dms-katakana-widget/KatakanaWidget/data/audio/ka.wav`
in a terminal must work; (2) click *Play* in the popout (or middle-click the
desktop widget), *Speak automatically* is off by default; (3) DMS is started by
the compositor, so a player that only lives in `~/.local/bin` is not on its
PATH: set *Audio player command* to the full path. Commands are split on
whitespace and run without a shell, so `{file}` / `{text}` must be a whole
argument.

*Speak automatically* says every new kana as it appears. Only the instance
that picked the kana speaks, so with *Same kana everywhere* on you hear it
once even with several pills and widgets.

## Files

| file | role |
|---|---|
| `gen-audio` | builds `data/audio/*.wav` from the Learn Japanese Adventure recordings (or edge-tts), see Audio |
| `say-ja` | optional Piper text-to-speech wrapper, see Audio |
| `KatakanaWidget/plugin.json` | composite manifest, `widget` + `desktop` surfaces |
| `KatakanaWidget/KatakanaDeck.qml` | loads `data/kana.json`, filters, rotates on a timer, speaks |
| `KatakanaWidget/KatakanaBarWidget.qml` | `PluginComponent`: pill + popout |
| `KatakanaWidget/KatakanaDesktopWidget.qml` | `DesktopPluginComponent` |
| `KatakanaWidget/KatakanaSettings.qml` | settings UI (`PluginSettings`) |
| `KatakanaWidget/data/kana.json` | hiragana + katakana with romaji, in gojūon order |
| `KatakanaWidget/data/audio/` | one clip per romaji reading (hiragana and katakana share them), recordings © Learn Japanese Adventure |

Status: written against the DMS `master` plugin API and syntax-checked with
`qmllint`, not yet run in a live DMS session. If DMS logs an error on load,
`dms ipc call plugins reload katakanaWidget` prints it.

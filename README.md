# Spice Flow Mod for Tabletop Simulator

A Tabletop Simulator mod for Dune Imperium and its extensions.

![Capture](captures/capture-1.jpg)

Features:

- Base game 3-4P
- Rise of Ix extension
- Immortality extension
- Hagal House
- Arrakeen Scouts

Supported langages:

- French
- English

## Links

- Steam: https://steamcommunity.com/sharedfiles/filedetails/?id=3043517751

## Build Process

cf. [tts_build/README.md](tts_build/README.md)

## Disclaimer

This repository contains the JSON skeletons and Lua scripts of various mods for Dune Imperium/Uprising (referenced resources are not included). With the exception of the "immorality" branch, all other branches contain code exclusively written by [me](https://steamcommunity.com/profiles/76561197978597744/myworkshopfiles/?appid=286160) under the "Unlicense" license. That means you can do whatever you want with it, you have my blessing. Things are obviously not so simple regarding the referenced resources which are no more than a collection of illegal images and 3D models. If my contributions are freely usable (e.g. 3D boards), I cannot speak on behalf of any other contributors.

## TODO

- Parameter name conflict in generic typing with a compound call!
- Normalize spaces/tabs.

- Scan Arrakeen Scouts deck (en).
- Main board in French. -> No.
- Plastic or wood? Color adjust too.
- Multiple battlegrounds.
- Arrakeen Scouts history (as cards).
- Arrakeen Scouts memory cards (using decals).
- Blitz! mode
- Detect unused I18N strings.
- Dreadnought block agents.

## Tests

- [ ] base
- [ ] base + ix
- [ ] base + immortality
- [ ] base + ix + immortality
- [ ] base + bloodlines
- [ ] base + ix + bloodlines
- [ ] base + immortality + bloodlines
- [ ] base + ix + immortality + bloodlines

× { 1P, 2P, 3P, 4P }
× { FR, EN }

×~ difficulty, special rules, formal, first player, etc.

/ boards / spaces / leaders / cards (imperium, intrigue, hagal) / conflict / VP tokens

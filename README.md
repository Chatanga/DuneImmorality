# Rakis Rising Mod for Tabletop Simulator

An evolution of Dune Uprising (a simplified and undisclosed port of Spice Flow) to bring back some advanced features of Spice Flow.

![Capture](captures/capture-1.jpg)

Features:

- Base game 3-4P
- Base game 6P
- Rise of Ix extension
- Immortality extension
- Legacy Dune as an extension
- Hagal House

Supported langages:

- English
- French

## Links :

- Steam: https://steamcommunity.com/sharedfiles/filedetails/?id=3127748613

## Build Process

cf. [tts_build/README.md](tts_build/README.md)

## Disclaimer

This repository contains the JSON skeletons and Lua scripts of various mods for Dune Imperium/Uprising (referenced resources are not included). With the exception of the "immorality" branch, all other branches contain code exclusively written by [me](https://steamcommunity.com/profiles/76561197978597744/myworkshopfiles/?appid=286160) under the "Unlicense" license. That means you can do whatever you want with it, you have my blessing. Things are obviously not so simple regarding the referenced resources which are no more than a collection of illegal images and 3D models. If my contributions are freely usable (e.g. 3D boards), I cannot speak on behalf of any other contributors.

## TODO

__All__

- Free selection of leaders.

__6P__

- Team PV counter.
- Exchange of resources.

__2P / Solo__

- Rework the selection of rivals (and isolate "streamlined rivals").
- Hagal cards in French.

__Aesthetic__

- Review the tech/contract decals.
- Rectify the height of the 6J Emperor/Fremen faction tokens.
- Widen the colored border of the boards (and remove the trigger effects in the process).

## Lua sources

### scripts

- __Global.-1.lua__ - Create, register, load, set up and save all the modules + manage the set up UI.
- __Global.-1.xml__ - All global UI roots are there (only the set up menu for Uprising).

### scripts/modules

Modules relies on the Luabundler tool, but also on utils.Modules.

- __Action.lua__ - All atomic actions (or effets): spending spice, deploying a troop, drawing a card...
- __CardEffect.lua__ - Small framework to describe most card effects. Heavily used by the fully automated Hagal house, but also by the assisted revelation, among others.
- __ChoamContractMarket.lua__ - Everything related to the CHOAM contract module.
- __Combat.lua__ - Manage the mainboard content related to combat, conflict cards included.
- __Commander.lua__ - Some functions related to the 6P mode and a proxy for a commander's leader (similarto the rival proxies) dispactching effects between a commander's leader and its active ally's leader.
- __Deck.lua__ - All cards and decks are generated here, both in a static and dynamic way.
- __Example.lua__ - A documented example of a fake module.
- __HagalCard.lua__ - Functions to resolve each Hagal card, in agent or reveal turn.
- __Hagal.lua__ - Solo/2P mode providing fully automated rivals, mainly by introducing a proxy for each rival altering each action and taking automated decisions.
- __ImperiumCard.lua__ - Describes all the Imperium cards with their (reveal) effects.
- __ImperiumRow.lua__ - Everything related to the Imperium Row (which excludes the Reserve).
- __InfluenceTrack.lua__ - Manages the 4/6 influences tracks.
- __Intrigue.lua__ - Manages the intrigue deck (intrigues are not automated at all).
- __Leader.lua__ - Provides a proxy for each leader, used as an indirection to Leader then Action. Each leader ability is implemented as an alteration of an existing action or as an event handler.
- __LeaderSelection.lua__ - Only used in the start up phase to offer various ways for each player to select its leader.
- __Locale.lua__ - Configure the I18N module with the relevant content.
- __MainBoard.lua__ - Creates the various actionable spaces on the 4P/6P boards based on their snappoints and provides the functions to resolve their effects on the active player's leader (which is a proxy on Action).
- __Music.lua__ - Handles the sound part, nothing elaborated here.
- __Pdf.lua__ - Same as Deck, but for PDF. Quite basic.
- __PlayBoard.lua__ - The heaviest module around, but contrary to ArrakeenScouts, offers little game related functions. It's mostly here to manage the layout and the mod niceties related to each player's board with all their content.
- __Reserve.lua__ - Handles the card reserve next to the ImperiumRow.
- __Resource.lua__ - A class handling the resources tokens (spice, solaris, etc.) on the various boards.
- __Rival.lua__ - Provides a proxy for each rival leader, used as an indirection to Rival then Action. Each leader ability is implemented as an alteration of an existing action or as an event handler. Contrary to the Leader class, mostly empty, the Rival class provides part of the "AI" for Solo/Hagal mode.
- __ScoreBoard.lua__ - A facade to retrieve the VP tokens from their various locations on the maiboard and player boards. Badly named actually, since it doesn't handle the shared VP track.
- __ShipmentTrack.lua__ - Handle the shipping track and its freighters from the Ix extension.
- __TechCard.lua__ - Describes all the Tech tiles, mainly their costs and acquisition bonuses.
- __TechMarket.lua__ - Handles the tech market (and its "tiles" which are cards actually) from the Ix extension.
- __ThroneRow.lua__ - Manages the Throne row for the 6P mode.
- __TleilaxuResearch.lua__ - Manages the whole Tleilax board from the Immortality extension : 2D research track, Tleilax track and specimen space.
- __TleilaxuRow.lua__ - Handles the tleilaxu row from the Immorality extension.
- __TurnControl.lua__ - A pivotal module in charge of sequencing the whole game once started. It works by interacting with the player boards and by emitting events for turn and phase changes.
- __Types.lua__ - A bunch of common test for typed values and tagged objects.

### scripts/modules/en

- __Deck.lua__ - English content for Deck.
- __Locale.lua__ - English translations.
- __Pdf.lua__ - English manuals.

### scripts/modules/fr

- __Deck.lua__ - French content for Deck.
- __Locale.lua__ - French translations.
- __Pdf.lua__ - French manuals.

### scripts/modules/utils

Reusable modules without dependencies on the other modules.

- __AcquireCard.lua__ - An auto adjustable dynami button to draw from a stack of deck.
- __Dialog.lua__ - Alternative dialogs to be notified when a user choose to cancel.
- __Helper.lua__ - Various helping functions.
- __I18N.lua__ - Internationalisation support.
- __Module.lua__ - LazyModule would be a better name.
- __Park.lua__ - An ubiquitous mechanism to manage a kind of open field bag.
- __Set.lua__ - A set container.
- __XmlUI.lua__ - To help control a XML UI.

# Dune Immorality TTS Mod

![Capture](resources/capture-1.jpg)

Features:
- Base game
- Rise of Ix extension
- Immortality extension
- Hagal House
- (Blitz!)
- Arrakeen Scouts
- (Fanmade leaders)
- (Reload support)

Supported langages:
- French
- (English)

## Links :

- Steam: https://steamcommunity.com/sharedfiles/filedetails/?id=3043517751
- Mod: 3043517751

## Build Process

![Capture](workflow.png)

The whole process could be executed with a single call:

    ./build

It amounts to call the sequence of commands `import + unpack + unbundle + patch + bundle + pack + export`.
However, when only modifying scripts, the beginning of this sequence is not needed and,
after an initial call to `import + unpack + unbundle`, we simply need to call `bundle + pack + export`.

The two Python scripts `upload.py` and `listen.py` are a new addition to take advantage of the TTS Editor API.
The second is especially useful to translate the error message locations into ctrl-clickable links.
When using this path, the `bundle + pack + export` sequence above becomes `bundle + upload`:

    ./bundle.sh && ./upload.py

Having launched `./listen.py` in another terminal will provide you with an immediate feedback from TTS.
Unfortunately, it seems to induce some kind of latency, leading to board corruptions on the remote guests.

## Principles

- Game -> Action (+log)
- Player (-> Leader/Hagal -> Action (+log))

## Sequencing (partial)

    Global.setUp
        LeaderSelection.setUp
            [LeaderSelection.setUpTest
                Playboard.setLeader(color, leader)]
            [LeaderSelection.setUpPicking]

    TurnControl.start
        TurnControl.startPhase(leaderSelection)
            [Hagal.pickAnyCompatibleLeader(color)
                LeaderSelection.claimLeader(color, leaderOrPseudoLeader)
                    Playboard.setLeader(color, leader)]
            [<click>
                LeaderSelection.claimLeader(color, leader)
                    Playboard.setLeader(color, leader)]
            Playboard.setLeader(color, leader)
                playboard.leader =
                    Hagal.newRival(Leader.getLeader(leaderCard) | nil) |
                    Leader.getLeader(leaderCard)

    TurnControl.endOfTurn
        TurnControl.next
            TurnControl.findActivePlayer
                TurnControl >-(playerTurns, color)->
                    Playboard.setActivePlayer(phase, color)
                        [Hagal.activate(phase, color, playboard)
                                Hagal.lateActivate(phase, color, playboard) -- with leader as Rival.]

    TurnControl.endOfTurn
        TurnControl.next
            TurnControl.findActivePlayer
                TurnControl.startPhase(nextPhase)

## FIXME

- Investigate missing trigger effects on guests after a reload.
- Fix the whole save/reload behavior in a minimal way.

## TODO (by priority)

- Fully restore translations (tokens and books included).
- Rival combat optimization.
- Blitz!
- [Fanmade leaders](https://drive.google.com/drive/folders/1-V3xcHk6078YR1fyhtJL3tdqv2zg5q3Q).
- Replace freighters by tokens.
- Change the [dreadnought model](https://www.thingiverse.com/thing:5326146).
- Rise of Ix board without Immortality.
- Card acquisition bonus (unify card effect framework).
- Tech acquisition cost (multiple options).
- Fix the 6 tech park saturation.
- Handle all space access options and notify agent action failures.
- Reservation slot cleaned on recall.
- Custom hidden pick.

## Later (maybe)

- Introduce the graphic log?
- Keep Module special, but unify everything else?
- Move the Tleilaxu track in its own module?
- Workaround the font_size ratio / support for the boards.
- Gather all VP sources in ScoreBoard?
- Some kind of hungarian notation with Array (ipairs) and Dict (pairs), a Array being a Dict?
- Alt mouse hover defeated by area buttons...
- Redundancy GMNotes VS resolve using them?
- Better support for chained transferts in Parks.

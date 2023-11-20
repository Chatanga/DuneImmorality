# Dune Uprising TTS Mod

Features:

- Base game 4P
- Base game 6P
- Hagal House
- Rise of Ix extension
- Immortality extension

Supported langages:

- French
- English

## Build Process

### Requirements

- [LuaBundler](https://github.com/Benjamin-Dobell/luabundler)
- Python 3

### Build & Deploy

First time:

```bash
python3 build.py --full
```

You should have 2 new saves 200 and 201, named xxx and yyy in TTS.

You only change the scripts, but don't have a running TTS instance with a loaded save:

```bash
python3 build.py
```

Save xxx is imported, updated with your scripts, then exported to yyy.

You only change the scripts and have a running TTS instance with a loaded save:

```bash
python3 build.py --upload
```

It directly updates the scripts of your live save.

You changed the save content in TSS: overwrite save xxx with it, then `python3 build.py --full` and reload the save.

In addition to the step above, you could have `python3 listen.py` running in another terminal to print the output of TSS (especially usefull for translating error message source locations).

### Internals

![Capture](workflow.png)

The whole process could be executed with a single call:

```bash
python3 build.py --full
```

It amounts to call the sequence of commands `import + unpack + unbundle + patch + bundle + pack + export`.
However, when only modifying scripts, the beginning of this sequence is not needed and,
after an initial call to `import + unpack + unbundle`, we simply need to call `bundle + pack + export`.

```bash
python3 build.py
```

If you have a TTS instance running your target save, you can also use the `upload` path instead of `pack + export`
The two Python scripts `upload.py` and `listen.py` are a new addition to take advantage of the TTS Editor API.
The second is especially useful to translate the error message locations into ctrl-clickable links.
When using this path, the `bundle + pack + export` sequence above becomes `bundle + upload`:

```bash
python3 listen.py
```

Having launched `listen.py` in another terminal will provide you with an immediate feedback from TTS.

## Nota

    Object  Snap    Zone    Decal?
    x       x       x       x       Have a position
    x       x               x       which could be "grounded"
    x               x               and a size.
    x               x               Could be (precisely) modified.
    x       x               x       Could stick to its parent (and disappear with it)
            x       x               Is invisible (and unobstrusive)
    x               x               Is easily identified (GUID or GMNotes) -> not at all for decals
    x                               Can have button attached (uniscaled objects are the best this purpose)

This mod approach: use snapoints for multistates objects, otherwise stick to zones. Decals and anchors are procedurally generated (one for all or at each load).

## TODO Immorality

- Corriger les décalcos (déclarations comprises) et déterminer, comme pour les snaps, la parenté.
- Solo : affiner détection intrigues combat.
- Terminer I18N pour les éclaireurs d'Arrakeen.
- Corriger tags.

Debug Moonsharp:

- error(msg, level)
- print(debug.traceback())

## TODO All

- Corriger custom token -> tile pour MainBoard.
- Switch player: gray -> teal.
- Log envoi agent.
- Se pencher sur la sérialisation (save / load), identifier les continuations longues.
- Popup custom verbeuse, plutôt que décarrer onceStabilized.
- Utiliser l'appelation CouncilorToken.
- Garantie du passage de tour.
- Toujours décorréler l'acquisition (carte, tech, contrat) de son effet.

## TODO Uprising

- Espaces dynamiques MainBoard.
- Logo d’activation.
- Reactivation ImperiumCard.
- I18N.
- Revoir Settings.

- Se méfier de "input.mod.json" vis à vis des opérations de rebase et commit. Mieux vaut qu'une seule personne le modifie et que les autres ignorent leurs modifications locales (les sauvegardes contiennent un timestamp nécessaire).

- Animation couleur pour les plateaux de 4 à 6 (x2 pour l'activation alliée) (+1 pour le noir).

- Ajouter *.move(position) pour :
    MainBoard (the game board, not the table)
    PlayBoard
    TleilaxuResearch
    TleilaxuRow
    ImperiumRow
    Reserve
    Intrigue
    TechMarket (inclut une partie de Mainboard)
    ContractMarket (inclut une partie de Mainboard)
    ScoreBoard (les jetons de PV)

- Deck : conserver l'existant pour construire des caches de cartes globaux.
- Plateaux noirs cachés (avec drapeau), dont un générique, pour le contenu localisé :
    Cartes Imperium
    Cartes d'intrigue
    Cartes Hagal
    Cartes Rival
    Cartes de conflits
    Cartes d'objectifs
    Cartes / tuiles tech
    Cartes / tuiles contrat
    Cartes Imperium Tleilaxu
    Cartes des dirigeants
    Manuels

- Coche pour activer les contrats.
- Sélection pas 4 joueurs :
    Retirer l'option 4-3-1-2.
- Sélection 6 joueurs :
    Désactiver la randomisation des joueurs.
    Retirer l'option des contrats (car obligatoire).

- Migration des images (attention aux conflits de noms).
- Bouton de fin de combat participatif, c'est tout (dans un écran de scores) -> fin de phase suspensive.
- Le mécanisme d'attibution du premier joueur est à coupler avec l'attribution d'objectif.
- Un joueur peut utiliser les ressources d'un autre joueurs (uniquement avec un clic gauche), mais le résultat est un transfert à partir des siennes.
- Ajouter un sélecteur (nécessaire de toute manière pour le maître d'armes) sur le plateau colorisant les agents du commandant.
- Remise en cause du clic pour envoyer ? Non, sélection allié, puis sens déduit ou double puis swordmaster. De fait, c'est aussi le moyen de rappeler la nécessité de sélectionner un allié.
- Ajouter un emplacement ThroneRow de taille illimitée...
- Désactiver les options d'achat des techs (et le dialogues qui vont avec).
- Park "memory" pour Jessica.

Maybe:

- Prendre en considération crans de zoom, préconfigurer les caméras ?
- Une deuxième main pour les joueurs ?
- Mains des joueurs à l'horizontal en 4J ?

## Serialisation

    scripts
        modules
            utils
                AcquireCard
                Helper -> transient listeners and callbacks
                I18N -> current locale in Global
                Module
                Park -> transient object in transit list in Global
                Set
                XmlUI
            Action -> TODO Action.context, (transient display)
            Combat -> TODO ranking, dreadnought strength by color
            CommercialTrack (-> TODO dynamic bonuses (Arrakeen Scouts))
            Deck
            Hagal
            HagalCard
            ImperiumRow
            InfluenceTrack -> (transient lock)
            Intrigue
            Leader
            LeaderSelection -> not at all
            Locale
            Mainboard (-> TODO dynamic bonuses (Arrakeen Scouts))
            Music
            Pdf
            Playboard
            Reserve
            Resource -> (transient display)
            ScoreBoard
            TechMarket
            TleilaxuResearch
            TleilaxuRow
            TurnControl -> already done
            Types
        Global

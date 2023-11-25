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

cf. [tts_build/README.md](tts_build/README.md)

Note : se méfier de "input.mod.json" vis à vis des opérations de rebase et commit.
Mieux vaut qu'une seule personne le modifie et que les autres ignorent leurs modifications locales (les sauvegardes contiennent un timestamp nécessaire).

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

## TODO Uprising

[75%] 4J
- Revoir les décalcos tech. et élargir les tags des snaps (Tech + Contract).
- 3 + 1 "Battle Trophy".
- Nouveaux PV (notamment victoires directes et indirectes) et sacs à PV.
- FeydRauthaHarkonnen.prepare -> clonage cube blanc (ou le mettre avec le matos en plus) + snaps + tag dédié.
- Verrouiller carte révérende mère Jessica.
- Park "memory" pour Jessica.
- Régler tressautement paquets.

[50%] Extensions
- Achat de tech débrayé par défaut.
- Rétablir tous les effets de cartes sauf conflits et Hagal.
- Patch Ix (avec postes d'observation) pour le plateau principal (emmerdant pour les snaps -> 2 x 2 ?).
- Patch Immortality pour le plateau principal.
- Considérer 'base' (legacy ?) comme une extension.

[10%] 6J
- Ajouter un emplacement ThroneRow.
- Rendre mobiles les éléments de jeu pour avoir 2 configurations 4J et 6J.
- Automatiser les espaces 6J.
- Reprendre les images des marqueurs de score.
- Créer 6 SwordmasterBonusToken (de couleurs différentes).
- Sélecteur d'allié.
- Activation et surcharge des commandants (une vraie surcharge !).
    - Ajouter un sélecteur (nécessaire de toute manière pour le maître d'armes) sur le plateau colorisant les agents du commandant.
    - Remise en cause du clic pour envoyer ? Non, sélection allié, puis sens déduit ou double puis swordmaster. De fait, c'est aussi le moyen de rappeler la nécessité de sélectionner un allié.
- Système influences partagées.
- Enlever le bouton Sandworm à 6J pour l'Imperium.
- Paquet de départ de commandant.
- Activation (et espaces) plateaux commandants.
- Commander.lua ?
- Transfert de ressources.
    - Un joueur peut utiliser les ressources d'un autre joueurs (uniquement avec un clic gauche), mais le résultat est un transfert à partir des siennes.
- Fin de tour d'un joueur -> raz des épées si aucune unité en combat.
- Maître d'armes -> assignation jeton +2 épées, mais rappel destructif.

[10%] Solo
- Mise en place.
- Tirage de cartes et prise en compte des épées, mais aucune automatisation sinon.

## Stabilisation

- Changer MainBoard from "custom token" en "custom tile".
- Se pencher sur la sérialisation (save / load), identifier les continuations longues.
- Dialogue fait maison pour notifier l'annulation par l'utilisateur.
- Utiliser l'appelation CouncilorToken et ScoreMarker.
- Fin de tour / phase robuste.
- Toujours décorréler l'acquisition (carte, tech, contrat) de son effet.
- Log envoi agent.
- Cache spatial de Deck.lua.
- Surcouche d'accès à Deck.
- Revoir la gestion des tuiles.
- Patcher le bouton de tour pour les idiots ?
- Corriger colorimétrie.
- Corriger altitudes objets et actions (findHeight du projet de test ?).

## Details

Ajouter *.move(position) pour :
    MainBoard (the game board with 6P extensions, not the table)
    PlayBoard
    TleilaxuResearch
    TleilaxuRow
    ImperiumRow
    Reserve
    Intrigue
    TechMarket (inclut une partie de Mainboard)
    ContractMarket (inclut une partie de Mainboard)
    ScoreBoard (les jetons de PV)
    ThroneRow

Deck : plateaux noirs cachés (avec drapeau), dont un générique, pour le contenu localisé :
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

## Maybe

- Prendre en considération crans de zoom, préconfigurer les caméras ?
- Une deuxième main pour les joueurs ?
- Mains des joueurs à l'horizontal en 4J ?

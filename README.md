# Dune Uprising TTS Mod

Features:

- Base game 4P
- (Base game 6P)
- (Hagal House)
- (Rise of Ix extension)
- (Immortality extension)
- (Legacy as an extension)

Supported langages:

- French
- English

## Build Process

cf. [tts_build/README.md](tts_build/README.md)

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

## TODO

- Refaire les PV et leurs sacs.
- Retirer les options avec ver si pas d’hameçon.
- Respecter le découpage des zones de combat.

[75%] 4J
- Revoir le contexte d’action pour les logs.
- Créer pions PV pour nouveaux conflits.
- Capacités spéciales des dirigeants.
- Revoir les décalcos tech. et élargir les tags des snaps (Tech + Contract).
- 1/2 PV pour les 3 + 1 objectifs.

[10%] 6J
- Ajouter un emplacement ThroneRow.
- Rendre mobiles les éléments de jeu pour avoir 2 configurations 4J et 6J.
- Automatiser les espaces 6J.
- Reprendre les images des marqueurs de score.
- Sélecteur d'allié.
- Activation et surcharge des commandants (une vraie surcharge !).
    - Ajouter un sélecteur (nécessaire de toute manière pour le maître d'armes) sur le plateau colorisant les agents du commandant.
    - Remise en cause du clic pour envoyer ? Non, sélection allié, puis sens déduit ou double puis swordmaster. De fait, c'est aussi le moyen de rappeler la nécessité de sélectionner un allié.
- Système influences partagées.
- Transfert de ressources.
    - Un joueur peut utiliser les ressources d'un autre joueurs (uniquement avec un clic gauche), mais le résultat est un transfert à partir des siennes.
- Fin de tour d'un joueur -> raz des épées si aucune unité en combat.
- Maître d'armes -> assignation jeton +2 épées, mais rappel destructif.

[50%] Extensions
- Achat de tech débrayé par défaut.
- Rétablir TechCard et ImperiumCard (uniquement les cartes Tleilaxu avec leur coût).
- Patch Ix (avec postes d'observation) pour le plateau principal (emmerdant pour les snaps -> 2 x 2 ?).
- Patch Immortality pour le plateau principal.
- Considérer base/core/legacy comme une extension.

[10%] 2P / Solo
- Mise en place.
- Tirage de cartes et prise en compte des épées, mais aucune automatisation sinon.

### Later

- Régler tressautement paquets après apple à "moveAt".
- Custom token -> tile (MainBoard).
- Cache pour le module Deck.
- Dialogue fait maison pour notifier l'annulation par l'utilisateur.
- Utiliser l'appelation CouncilorToken et ScoreMarker.
- Fin de tour / phase robuste.
- Toujours décorréler l'acquisition (carte, tech, contrat) de son effet.
- Prendre en considération crans de zoom, préconfigurer les caméras ?
- Une deuxième main pour les joueurs ?
- Mains des joueurs à l'horizontal en 4J ?

## Notes

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

# Dune Uprising TTS Mod

Features:

- Base game 3-4P
- (Base game 6P)
- (Rise of Ix extension)
- (Immortality extension)
- (Legacy as an extension)
- (Hagal House)

Supported langages:

- English
- French
- (Portugese)

## Build Process

cf. [tts_build/README.md](tts_build/README.md)

## TODO

__All__
- Donner un VP auto pour l'achat de l'"Epice doit couler" 
- Retirer les options avec ver si pas d’hameçon.
- Automatiser l’acquisition / détection d’hameçon pour les actions liées.
- Respecter le découpage des zones de combat.
- Revoir le contexte d’action pour les logs.
- Capacités spéciales des dirigeants.
- Revoir les décalcos tech. et élargir les tags des snaps (Tech + Contract).
- Sacs de jetons 1/2 PV pour les 3 + ? objectifs (+ Decal + Snap). ( les sacs sont présents sur le workshop, je les ai ajouté)
- Donner une troupe auto en cas de contrôle d'un lieu avec flag de contrôle si un conflit est sur ce lieu


__6P__

- Ajouter un emplacement ThroneRow.
- Rendre mobiles les éléments de jeu pour avoir 2 configurations 4J et 6J (A).
- Automatiser les espaces 6J.
- Reprendre les images des marqueurs de score des commandants.
- Activation et surcharge des commandants (une vraie surcharge !).
- Ajouter un sélecteur (nécessaire de toute manière pour le maître d'armes) sur le plateau colorisant les agents du commandant.
- Système influences partagées.
- Transfert de ressources inter-alliés.
- Fin de tour d'un joueur -> raz des épées si aucune unité en combat.
- Maître d'armes -> assignation jeton +2 épées, mais rappel destructif.

__Extensions__

- Achat de tech débrayé par défaut.
- Rétablir TechCard et ImperiumCard (uniquement les cartes Tleilaxu avec leur coût).
- Patch Ix (avec postes d'observation) pour le plateau principal (emmerdant pour les snaps -> 2 x 2 ?).
- Patch Immortality pour le plateau principal.
- Considérer base/core/legacy comme une extension.

__2P / Solo__

- Mise en place.
- Tirage de cartes et prise en compte des épées, mais aucune automatisation sinon.

__Later__

- Régler tressautement paquets après un appel à "moveAt".
- Custom token -> tile (MainBoard).
- Dialogue fait maison pour notifier l'annulation par l'utilisateur.
- Utiliser l'appelation CouncilorToken et ScoreMarker.
- Fin de tour / phase robuste.
- Toujours décorréler l'acquisition (carte, tech, contrat) de son effet.
- Prendre en considération crans de zoom, préconfigurer les caméras ?
- Une deuxième main pour les joueurs ?
- Mains des joueurs à l'horizontal en 4J ?

## Notes

A. Ajouter *.move(position) pour :
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

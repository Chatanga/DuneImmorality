# Dune Uprising TTS Mod

Features:

- Base game 3-4P
- Base game 6P
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

__Bugs__

- Repositionner *tout* le contenu du mod en Y >= 1 pour que les snaps relatifs fonctionnent.
- Remplacer les états et les mutations de plateaux (et PDF ?) par des instances multiples.
- Le compteur de AcquireCard ne voit que les arrivées / départs de Card, pas de Deck.
- Dialogue fait maison pour notifier explicitement l'annulation par l'utilisateur.

__All__

- Snapifier le secteur des combats (casernes troupes et cuirassés, champs de bataille, zone PV, conflits, jetons de force).
- Doubler tous les jetons de PV de combat, ajouter faux PV pour C et A, refaire TSMF.
- Automatiser les contrats.
- Élargir la persistance à l’avant sélection des dirigeants.
- Déverrouiller la révélation assistée.
- Réactiver la détection de cartes jouées (Undercover Asset & Co.) -> utilisée par Ix.
- Marquer par décalcos les positions de départ des maîtres d'armes -> mieux : modifier le test.

- Améliorer le clic-droit sur un espace.
- Revoir le contexte d’action pour les logs.
- Découpler les actions des tests de possibilité.

- Créer le jeton d’objectif manquant (?).
- Ajouter un bouton "Réclamer les PV" pour convertir les paires en PV.
- Sortir automatiquement un jeton d'objectif (nommé) pour les conflits.
- Automatiser le bannières en se basant sur les jetons d’objectif (oublier la compatibilité anciens conflits).

__6P__

- Ajouter sous-espaces manquants en 6J (ou bien tous les retirer).
- Compteur global PV équipe.

__Extensions__

- Achat de tech débrayé par défaut.
- Rétablir TechCard.
- Patch Ix (avec postes d'observation) pour le plateau principal (emmerdant pour les snaps -> 2 x 2 ?).
- Patch Immortality pour le plateau principal.
- Considérer base/core/legacy comme une extension.

__2P / Solo__

- Mise en place.
- Récupérer un paquet Hagal à jour.
- Tirage de cartes et prise en compte des épées, mais aucune automatisation sinon.

__Aesthetic__

- Réorganiser les éléments de jeu en 4J et 6J.
- Revoir les décalcos tech / contrat.
- Ranger les goodies (fouineurs, baron, feyd, voix à donner en bonus, bonus maîtres d'armes) dans une zone invisible ?
- Prendre en considération les crans de zoom, préconfigurer les caméras ?
- Snaps jetons factions 6J empereur/fremen trop hauts.

__Internal__

- Utiliser les appelations (Councilor)Token et (Score)Marker.
- Fin de tour/phase robuste par asynchronisme.
- Toujours décorréler l'acquisition (carte, tech, contrat) de son effet.
- Retirer complétement les trigger effects des plateaux des joueurs.
- AcquireCard pour la pioche et la défausse des joueurs ?

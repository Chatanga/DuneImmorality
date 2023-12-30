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
- Déverrouiller la révélation assistée.
- Réactiver la détection de cartes jouées (Undercover Asset & Co.) -> utilisée par Ix.
- Marquer par décalcos les positions de départ des maîtres d'armes -> mieux : modifier le test.
- Automatiser le gain de 2 solaris pour un contrat si le module n'est pas actif (ou s'il n'y a plus de contrats).

- Améliorer le clic-droit sur un espace.
- Revoir le contexte d’action pour les logs.
- Découpler les actions des tests de possibilité.

- Créer le jeton d’objectif manquant (?).
- Ajouter un bouton "Réclamer les PV" pour convertir les paires en PV.
- Sortir automatiquement un jeton d'objectif (nommé) pour les conflits.
- Automatiser le bannières en se basant sur les jetons d’objectif (oublier la compatibilité anciens conflits).

- Mode libre pour la sélection des dirigeants.

__6P__

- Ajouter sous-espaces manquants en 6J (ou bien tous les retirer).
- Compteur global PV équipe.

__Extensions__

- Achat de tech débrayé par défaut.
- Rétablir TechCard.
- Patch Ix (avec postes d'observation) pour le plateau principal (emmerdant pour les snaps -> 2 x 2 ?).
- Patch Immortality pour le plateau principal.
- Considérer base/core/legacy comme une extension.
- Incorporer la variante de Paul Dennen.

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

## Build Process

cf. [tts_build/README.md](tts_build/README.md)

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
- __Leader.lua__ - Provides a proxy for each Leader, used as an indirection to Action. Each leader ability is implemented as an alteration of an existing action or as an event handler.
- __LeaderSelection.lua__ - Only used in the start up phase to offer various ways for each player to select its leader.
- __Locale.lua__ - Configure the I18N module with the relevant content.
- __MainBoard.lua__ - Creates the various actionable spaces on the 4P/6P boards based on their snappoints and provides the functions to resolve their effects on the active player's leader (which is a proxy on Action).
- __Music.lua__ - Handles the sound part, nothing elaborated here.
- __Pdf.lua__ - Same as Deck, but for PDF. Quite basic.
- __PlayBoard.lua__ - The heaviest module around, but contrary to ArrakeenScouts, offers little game related functions. It's mostly here to manage the layout and the mod niceties related to each player's board with all their content.
- __Reserve.lua__ - Handles the card reserve next to the ImperiumRow.
- __Resource.lua__ - A class handling the resources tokens (spice, solaris, etc.) on the various boards.
- __ScoreBoard.lua__ - A facade to retrieve the VP tokens from their various locations on the maiboard and player boards. Badly named actually, since it doesn't handle the shared VP track.
- __ShipmentTrack.lua__ - Handle the shipping track and its freighters from the Ix extension.
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
- __Helper.lua__ - Various helping functions.
- __I18N.lua__ - Internationalisation support.
- __Module.lua__ - LazyModule would be a better name.
- __Park.lua__ - An ubiquitous mechanism to manage a kind of open field bag.
- __Set.lua__ - A set container.
- __XmlUI.lua__ - To help control a XML UI.

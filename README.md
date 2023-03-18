# Important :
- activation de "Physic Full" côté joueur pour que la dépose de cartes soit OK.

# Conception :
- prise en compte du rechargement potentiel des chefs.
- sauvegarde des données.
- nombre de joueurs actifs et mode de jeu (multi / hot seat).
- application dynamique de la langue.
- distinguer le helper bas niveau et haut niveau.
- introduire un ResourceModule (épice, eau et solari) ?
- quel notion d'état du jeu, entretenu ou déduit ?

# Tests à faire (et cartographier / tracer vers le code et les objets du monde = dépendances) :
- suppression / paralysie des joueurs surnuméraires.
- protection des boutons.
- achat de cartes Imperium ou d'intrigue.
- atomiques de famille.
- achat de carte Tleilaxu (avec paiement en spécimens).
- tirage de 1 ou 5 cartes à partir d'une pioche vide, partiellement suffisante ou complètement suffisante.
- révélation d'une main vide ou contenant des cartes, de manière prématurée ou non.
- attribution des jetons d'amitié et d'alliance.
- vol de jeton d'alliance.
- montée et descente sur les pistes d'influence (avec bornes).
- montée et descente sur la piste commerciale (avec bornes).
- mise à jour des marqueurs de force.
- prérequis d'accès à une zone.
- attribution de cartes Imperium ou d'intrigue.
- attribution de troupes ou de spécimens (avec bornes).
- attribution d'épice, eau ou solari.
- attribution de scarabés.
- attribution de jetons de PV.
- attribution du mentat (pourvu qu'il soit disponible).
- attribution automatique de dreadnoughts ?
- attribution du contrôle d'un espace (peut être remis en cause trop facilement).
- déploiement automatique d'une troupe en fonction du contrôle.
- attribution ressources supplémentaire grâce au contrôle d'espace.
- mise à jour des compteurs de scores.
- mise à jour du marqueur du faiseur.
- incrémentation de l'épice lors du rappel.
- récupération des troupes et dreadnoughts lors du rappel.
- mise à jour du conflit lors du rappel.
- passage du marqueur de premier joueur lors du rappel.
- mécanisme pour passer le tour et détection de la fin de manche (bataille).
- attribution des récompenses sur le plateau du Bene Tleilax.
- l'activation / désactivation des 2 extensions et du mode épique.
- le marché noir.
- les comportements de tous les chefs...
- la prise en compte de toutes les tuiles technologiques...
- la mobilité complète des blocs de jeu (à réaliser par un second patch Python).
- le support de la maison Hagal.

# A faire :
- ajouter les point d'aimantation manquants et vérifier leurs tags.
- intégrer les derniers changements (faire un diff en T).

# A faire plus tard :
- Pas de passage de "round start" à "player turns" au 1er tour.
- Remplacer la tétrachié de ["literal"] en (.)literal.
- gérer plus finement les hauteurs des boutons.
- ajouter des colliders.
- améliorer la qualité des décalcos (et pointillés pour la zone du marqueur premier joueur).
- mettre à jour les crédits (y compris pour les textures).
- Mode solo.
- Enhanced Recall for Endgame -> detected end of game: reveal intrigue and grant VP tokens automatically.
- Unifier le code des 4 * 3 compteurs de ressources.

# Important :
- Activation de "Physic Full" côté joueur pour que la dépose de cartes soit correcte.

# Tests à faire (et cartographier / tracer vers le code et les objets du monde :
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
- Corriger hidden pick à 3 joueurs.
- Corriger fin de paquet cartes recherche du Bene Tleilax.
- Retirer le suffixe module des modules ?
- Pas de passage de "round start" à "player turns" au 1er tour.
- gérer plus finement les hauteurs des boutons.
- ajouter des colliders.
- améliorer la qualité des décalcos (et pointillés pour la zone du marqueur premier joueur).
- mettre à jour les crédits (y compris pour les textures).
- Mode solo.
- Enhanced Recall for Endgame -> detected end of game: reveal intrigue and grant VP tokens automatically.
- Marker -> token pour éviter la confusion avec Maker.
- Nombre de joueurs actifs et mode de jeu (multi / hot seat).
- Mettre à jour / à niveau les textures.
- Mettre à jour boutons acquisition tech avec coût réel.
- Déploiement de spécimens : le faire directement.
- Abstraire la création de boutons façon Ark Nova (et ajouter une icône "activate" pour le pay & get).
- Mettre à jour les URL des cartes françaises.
- Gérer les tuiles technologiques comme des cartes (et ne plus les dupliquer -> problématique d'identification) ?
- Explorer la notion de tour, multi(, solo) et hotseat.
- Automatiser la maison Hagal.
- Traduire les cartes de la maison Hagal.
- Grande conception avant refactoring.
- Identifier les actions de haut niveau, introduire un module services pour les regrouper en déléguant au mieux.
- Uniformiser nommage et usage "local" (déclarer que des "local" (au chunk donc) ?).
- Expliciter la gestion des tours.
- Retirer vieilles ressources.

- Limiter autant que possible les appels de fonction au chargement, car peu pratique à débugger.
- Au chargement, ne pas dépendre d'autres objets (sont-ils même résolvables ?), ni d'autres scripts.
- Dans la fonction onLoad, dépendre éventuellement des autres objets, mais pas de l'état interne de leurs scripts (call).
- Différence sauvegarde implicite / explicite ?
- Toujours sauver / restaurer l'état d'un script s'il existe.

# Liens :
- Mods -> $HOME/.local/share/Tabletop Simulator/Mods/
- Saves -> $HOME/.local/share/Tabletop Simulator/Saves/
- Tabletop Simulator Lua -> /tmp/TabletopSimulator/Tabletop Simulator Lua/
- Mod : 2956104551.



http://cloud-3.steamusercontent.com/ugc/2042985641582150737/6DE3AA409E94D2CE99D4E34B6B8A2FC913DE8C56/
http://cloud-3.steamusercontent.com/ugc/2042987291567703596/214F7AE0C188D5DFEBBAF9CE67CCB56777663B4A/

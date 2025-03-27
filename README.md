# Voting Smart Contract

## Description

Ce contrat permet à une organisation de gérer un système de vote sécurisé. Les utilisateurs peuvent être enregistrés, proposer des idées, voter et enfin obtenir les résultats du vote.

## Prérequis

- **Solidity 0.8.29**
- **OpenZeppelin Contracts** pour la gestion des permissions (Ownable).

## Workflow

Le contrat suit un processus en plusieurs étapes :

1. **Whitelisting** des électeurs par le propriétaire.
2. **Enregistrement des électeurs** par le propriétaire.
3. **Ouverture d'une session de proposition** par le propriétaire.
4. **Enregistrement des propositions** par les électeurs enregistrés.
5. **Fermeture de la session de proposition** par le propriétaire.
6. **Ouverture d'une session de vote** par le propriétaire.
7. **Enregistrement des votes** par les électeurs enregistrés.
8. **Fermeture de la session de vote** par le propriétaire.
9. **Comptabilisation des votes** par le propriétaire.
10. **Affichage du résultat** par le propriétaire.

## Fonctions du Contrat

### `whitelist(address _account)`
Administrateur uniquement.
Ajoute une adresse à la whitelist.

### `isWhitelisted(address _account) public view returns (bool)`
Vérifie si une adresse est dans la whitelist.

### `registerVoter(address _voter)`
Administrateur uniquement.
Permet au propriétaire d'enregistrer un électeur.

### `startProposalRegistration()`
Administrateur uniquement.
Démarre la session d'enregistrement des propositions.

### `registerProposal(string memory _description)`
Permet à un électeur enregistré d'ajouter une proposition.

### `endProposalRegistration()`
Administrateur uniquement.
Clôture l'enregistrement des propositions.

### `startVotingSession()`
Administrateur uniquement.
Démarre la session de vote.

### `getProposals() external view returns (string[] memory descriptions, uint256[] memory indexes)`
Récupère toutes les propositions et leurs index.

### `vote(uint256 _proposalId)`
Permet à un électeur de voter pour une proposition.

### `endVotingSession()`
Administrateur uniquement.
Clôture la session de vote.

### `getTalliedVotes()`
Administrateur uniquement.
Comptabilise les votes et détermine la proposition gagnante.

### `getWinner() external view returns (string memory)`
Administrateur uniquement.
Récupère la proposition gagnante après comptabilisation des votes.


## Sécurité

- Seul le propriétaire du contrat peut ajouter des électeurs, démarrer et terminer les sessions.
- Les électeurs ne peuvent voter qu'une seule fois.
- Une fois les votes comptabilisés, le propriétaire peut récupérer la proposition gagnante.



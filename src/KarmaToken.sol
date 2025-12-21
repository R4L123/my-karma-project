// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title KarmaToken
 * @dev Les utilisateurs peuvent donner du Karma à d'autres adresses, augmentant leur score de réputation(karma).
 */
contract KarmaToken is ERC20, Ownable {
    // Score de Karma pour chaque adresse.
    mapping(address => uint256) public karmaScores;

    event KarmaGiven(address indexed giver, address indexed receiver, uint256 amount);

    constructor(string memory name, string memory symbol, uint256 initialSupply)
        ERC20(name, symbol)
        Ownable(msg.sender)
    {
        // Mint la supply initiale au déployeur du contrat.
        _mint(msg.sender, initialSupply * (10 ** decimals()));
    }

    /**
     * @dev Permet à un détenteur de tokens de donner du Karma à une autre adresse.
     * Cette fonction ne transfère PAS de tokens, elle augmente seulement le karma du recepient.
     * @param _receiver L'adresse qui reçoit le Karma.
     * @param _amount Le montant de Karma
     */

    function giveKarma(address _receiver, uint256 _amount) external {
        require(_receiver != address(0), "Le receveur ne peut pas etre l'adresse 0");
        require(_receiver != msg.sender, "Vous ne pouvez pas vous donner du Karma a vous meme");
        require(_amount > 0, "Le montant de Karma doit etre superieur a zero");

        // Augmente le score de Karma du receveur.
        karmaScores[_receiver] += _amount;

        // Emet un événement pour que les dApps (vesting)
        emit KarmaGiven(msg.sender, _receiver, _amount);
    }

    /**
     * @dev Fonction pour le propriétaire pour modifier manuellement le score de karma
     * Utiliser pour corriger des abus ou récompenser des actions exceptionnelles.
     * @param _target L'adresse dont le score de Karma doit être changé.
     * @param _newScore Le nouveau score de Karma pour cette adresse.
     */
    function setKarmaScore(address _target, uint256 _newScore) external onlyOwner {
        require(_target != address(0), "La cible ne peut pas etre l'adresse zero");
        karmaScores[_target] += _newScore;
    }

    /**
     * @dev Le propriétaire peut créer de nouveaux tokens.
     * augmente la supply totale et attribue les tokens au propriétaire.
     * utilisé pour des récompenses ou de l'expansion .
     * @param _amount Le nombre de nouveaux tokens à mint.
     */
    function mintNewTokens(uint256 _amount) external onlyOwner {
        _mint(msg.sender, _amount);
    }
}

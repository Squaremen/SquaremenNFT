# SquaremenNFT

This repo is aimed to share with the community the source code of the deployed contracts.

These are all contracts in use within the Squaremen ecosystem:

- SquaremenERC20
- SquaremenERC721
- SquaremenGame

First two contracts are the core of Squaremen ecosystem, they have functions to interact with each other approaching the concepts of NFT and fungible token.

The key point is the possibility given to Squaremen holders to make the claim of an ERC20 token (SQTOK) provided by the SquaremenERC20.sol contract.
However, this condition is possible only if the BurnToken function of ERC721 contract is called. This works as easily imaginable as it burns your NFT and increments the burnedTokens counter. This mapping is then called by the ERC20 contract if the user intends to claim his tokens.

For any doubts or reports do not hesitate to contact us via mail or Discord

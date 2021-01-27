# ERC918

ERC918 is A more specific implementation that implements mint(), and breaks the preceding operations into 4 different phases, hash, reward, epoch and difficulty adjustments, each realized as separate abstract internal functions to be implemented by the sub contract. It additionally stores state variables for challenge number, target, tokens minted, blocks per adjustment, epoch count and statistics for the last minted token block.

Decoupling from other standards - The original spec was proposed as an extension of ERC20. After some thought and discussion, it made sense to remove this prerequisite as ERC918 should only define 'mineability'. So to create a mineable ERC20, or a mineable ERC721, one only has to use multiple inheritance. (ie. contract AwesomeCoin is ERC20, ERC918 { } )

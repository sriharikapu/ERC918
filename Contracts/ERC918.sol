pragma solidity ^0.4.23;

//----------------------------------------------------//
//-Gas Limited / Controllable contract----------------//
//-Mineable ERC20 (ERC918) Token using Proof Of Work--//
//-author: sriharikapu--------------------------------//
//----------------------------------------------------//

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

library ExtendedMath {
    //return the smaller of the two inputs (a or b)
    function limitLessThan(uint a, uint b) internal pure returns (uint c) {
        if(a > b) return b;
        return a;
    }
}

interface EIP918Interface  {

    //function mint(uint256 nonce, bytes32 challenge_digest) external returns (bool success);
    function getChallengeNumber() external constant returns (bytes32);
    function getMiningDifficulty() external constant returns (uint);
    function getMiningTarget() external constant returns (uint);
    function getMiningReward() external constant returns (uint);

    event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);

}

/**
 * Pausable is Ownable
 * StandardToken is ERC20, BasicToken
 * ERC20 is ERC20Basic
 * BasicToken is ERC20Basic
 */
contract ERC918 is Pausable, StandardToken, EIP918Interface {

  using ExtendedMath for uint;

  // Events
  event GasPriceSet(uint8 _gasPrice);
  event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);
  event Debug(uint256 txGas, uint256 curGasPriceLimit); //TODO - remove this once contract finalised

  // Variables
  // ERC20 Standard
  string public name;               //Token name for display
  string public symbol;             //Token symbol for display
  uint8 public decimals;            //Number of decimal places
  uint public _totalSupply;

  // Owner Controls
  uint public gasPriceLimit;                     //Gas Price Limit

  // Mineable Related
  address public lastRewardTo;
  bytes32 public challengeNumber;
  uint public miningTarget;
  uint public latestDifficultyPeriodStarted;
  uint public epochCount;                       //number of 'blocks' mined
  uint public _blocks_per_adjustment;
  uint public _min_target;
  uint public _max_target;
  uint public rewardEra;
  uint public maxSupplyForEra;
  uint public lastRewardAmount;
  uint public lastRewardEthBlockNumber;
  uint public tokensMinted;
  uint startingMiningReward;                      //this is not public, as mining reward will change over time

  mapping(address => uint) balances;
  mapping(address => mapping(address => uint)) allowed;
  mapping(bytes32 => bytes32) solutionForChallenge;

  //Constructor
  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    _blocks_per_adjustment = 512;                // TODO: set in constructor
    startingMiningReward = 50;                    // TODO: set in constructor
    totalSupply_ = 21000000 * 10**uint(decimals);  // TODO: read from constructor

    //default values - don't change unless you know what you are doing
    _min_target = 2**16;
    _max_target = 2**234;
    rewardEra = 1;
    tokensMinted = 0;
    maxSupplyForEra = totalSupply_.div(2);
    latestDifficultyPeriodStarted = block.number;
    challengeNumber = block.blockhash(block.number - 1);

    //these are default values that will be overwritten by the contract automatically or
    //can be changed by the contract owner calling a function
    miningTarget = _max_target;
    gasPriceLimit = 999;

    //original contract called _startNewMiningEpoch();
    //this is not really needed - we have already set all the values

  }

  //modifier used for checking that the txn.gasPrice is lower than the limit set
  modifier checkGasPrice(uint txnGasPrice) {
    require(txnGasPrice <= gasPriceLimit * 1000000000);
    _;
  }

  // dont receive ether via fallback method (by not having 'payable' modifier on this function).
  function () public { }

  /**
   * @dev transfer out any accidently sent ERC20 tokens
   * @param tokenAddress The contract address of the token
   * @param tokens The amount of tokens to transfer
   */
  function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
    return StandardToken(tokenAddress).transfer(owner, tokens);
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender when not paused.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) whenNotPaused public returns (bool) {
    return super.approve(_spender, _value);
  }

  /**
   * @dev
   * @param _gasPrice The gas price in Gwei to set
   */
   function setGasPriceLimit(uint8 _gasPrice) onlyOwner
    //checkGasPrice(_gasPrice)
    public {
      require(_gasPrice > 0);
     gasPriceLimit = _gasPrice;

     emit GasPriceSet(_gasPrice); //emit event
   }

   /**
    * Mining related functions
    */

    function getChallengeNumber() public constant returns (bytes32) {
        return challengeNumber;
    }

    function getMiningTarget() public constant returns (uint) {
       return miningTarget;
    }

    //the number of zeroes the digest of the PoW solution requires.  Auto adjusts
    function getMiningDifficulty() public constant returns (uint) {
      return _max_target.div(miningTarget);
    }

    //reward is cut in half every reward era (as tokens are mined)
    function getMiningReward() public constant returns (uint) {
      if(rewardEra == 1) {
        return startingMiningReward * 10**uint(decimals);
      } else {
        return (startingMiningReward * 10**uint(decimals) ).div( 2**(rewardEra-1) );
      }
    }

    // TODO
    function mint(uint256 nonce, bytes32 challenge_digest) checkGasPrice(tx.gasprice) public returns (bool success) {

      //the PoW must contain work that includes a recent ethereum block hash (challenge number) and the msg.sender's address to prevent MITM attacks
      bytes32 digest =  keccak256(challengeNumber, msg.sender, nonce);

      //the challenge digest must match the expected
      if (digest != challenge_digest) revert();

      //the digest must be smaller than the target
      if(uint256(digest) > miningTarget) revert();

      //only allow one reward for each challenge
      bytes32 solution = solutionForChallenge[challengeNumber];
      solutionForChallenge[challengeNumber] = digest;
      if(solution != 0x0) revert();  //prevent the same answer from awarding twice

      uint reward_amount = getMiningReward();
      balances[msg.sender] = balances[msg.sender].add(reward_amount);
      tokensMinted = tokensMinted.add(reward_amount);

      //Cannot mint more tokens than there are
      assert(tokensMinted <= maxSupplyForEra);

      //set readonly diagnostics data
      lastRewardTo = msg.sender;
      lastRewardAmount = reward_amount;
      lastRewardEthBlockNumber = block.number;

      _startNewMiningEpoch();

      Mint(msg.sender, reward_amount, epochCount, challengeNumber );

      return true;

    }

    function _startNewMiningEpoch() internal {

      //if max supply for the era will be exceeded next reward round then enter the new era before that happens
      //40 is the final reward era, almost all tokens minted
      //once the final era is reached, more tokens will not be given out because the assert function
      if( tokensMinted.add(getMiningReward()) > maxSupplyForEra && rewardEra < 40)
      {
        rewardEra = rewardEra + 1;
      }

      //set the next minted supply at which the era will change
      maxSupplyForEra = totalSupply_ - totalSupply_.div( 2**(rewardEra));

      epochCount = epochCount.add(1);

      _adjustDifficulty();

      //make the latest ethereum block hash a part of the next challenge for PoW to prevent pre-mining future blocks
      //do this last since this is a protection mechanism in the mint() function
      challengeNumber = block.blockhash(block.number - 1);

    }

    // Calculates the difficulty target at the end of every epoch
    function _adjustDifficulty() internal {

      uint ethBlocksSinceLastDifficultyPeriod = block.number - latestDifficultyPeriodStarted;
      uint epochsMined = _blocks_per_adjustment;
      uint targetEthBlocksPerDiffPeriod = epochsMined * 12; //TODO - calculate this with a variable should be 12 times slower than ethereum

      // less eth blocks mined than expected
      if( ethBlocksSinceLastDifficultyPeriod < targetEthBlocksPerDiffPeriod ) {

        uint excess_block_pct = (targetEthBlocksPerDiffPeriod.mul(100)).div( ethBlocksSinceLastDifficultyPeriod );
        uint excess_block_pct_extra = excess_block_pct.sub(100).limitLessThan(1000); //always between 0 and 1000

        //make it harder
        miningTarget = miningTarget.sub(miningTarget.div(2000).mul(excess_block_pct_extra));   //by up to 50 %

      } else {

        uint shortage_block_pct = (ethBlocksSinceLastDifficultyPeriod.mul(100)).div( targetEthBlocksPerDiffPeriod );
        uint shortage_block_pct_extra = shortage_block_pct.sub(100).limitLessThan(1000); //always between 0 and 1000

        //make it easier
        miningTarget = miningTarget.add(miningTarget.div(2000).mul(shortage_block_pct_extra));   //by up to 50 %
      }

      latestDifficultyPeriodStarted = block.number;

      if(miningTarget < _min_target) //very difficult
      {
          miningTarget = _min_target;
      }

      if(miningTarget > _max_target) //very easy
      {
        miningTarget = _max_target;
      }
    }

    //Useful for debugging miners
    function getMintDigest(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number) public view returns (bytes32 digesttest) {
      bytes32 digest = keccak256(challenge_number,msg.sender,nonce);
      return digest;
    }

    //Useful for debugging miners
    function checkMintSolution(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number, uint testTarget) public view returns (bool success) {
      bytes32 digest = keccak256(challenge_number,msg.sender,nonce);
      if(uint256(digest) > testTarget) revert();

      return (digest == challenge_digest);
    }

}

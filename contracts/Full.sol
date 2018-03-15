pragma solidity ^0.4.19;



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
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
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

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
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
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
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
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
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
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
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}



/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    require(_value <= balances[msg.sender]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    Burn(burner, _value);
    Transfer(burner, address(0), _value);
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
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}



/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}



contract SimpleToken is Pausable, BurnableToken, StandardToken {

  using SafeMath for uint256;

  string constant public name = "SimpleToken";
  string constant public symbol = "ST";
  uint256 constant public decimals = 18;
  address public addressICO;
  uint256 constant public INITIAL_TOTAL_SUPPLY = 10e6 * (10 ** decimals);

  modifier onlyICO() {
    require(msg.sender == addressICO);
    _;
  }

  function SimpleToken(address _addressICO) public {
    require(_addressICO != address(0x0));
    addressICO = _addressICO;
    totalSupply_ = totalSupply_.add(INITIAL_TOTAL_SUPPLY);
    balances[_addressICO] = balances[_addressICO].add(INITIAL_TOTAL_SUPPLY);
    Transfer(address(0x0), _addressICO, INITIAL_TOTAL_SUPPLY);
    pause();
  }

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    require(_to != address(0x0));
    require(_value <= balances[msg.sender]);

    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    require(_from != address(0x0));
    require(_to != address(0x0));

    return super.transferFrom(_from, _to, _value);
  }

  function transferFromICO(address _to, uint256 _amount) public onlyICO {
    require(_to != address(0x0));

    super.transfer(_to, _amount);
  }

  function burnFromICO() onlyICO public {
    uint256 remindingTokens = balanceOf(addressICO);
    balances[addressICO] = balances[addressICO].sub(remindingTokens);
    totalSupply_ = totalSupply_.sub(remindingTokens);
    Burn(addressICO, remindingTokens);
  }

  function burnFrom(address _from, uint256 _value) public {
    require(_value <= balances[msg.sender]);
    require(msg.sender == addressICO || msg.sender == owner);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_from] = balances[_from].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    Burn(_from, _value);
    Transfer(_from, address(0), _value);
  }

}



contract WhiteList is Ownable {
/*
  using SafeMath for uint256; */

  mapping(address => bool) whiteList;
  uint256 public whiteListLength = 0;

  function addWallet(address _wallet) onlyOwner public {
    require(_wallet != address(0x0));
    require(!isWhiteListed(_wallet));

    whiteList[_wallet] = true;
    whiteListLength++;
  }

  function deleteWallet(address _wallet) onlyOwner public {
    require(_wallet != address(0x0));
    require(isWhiteListed(_wallet));

    whiteList[_wallet] = false;
    whiteListLength--;
  }

  function isWhiteListed(address _wallet) public returns(bool) {
    return whiteList[_wallet];
  }
}



contract WhiteListable {
    WhiteList public whiteList;

    modifier whenWhiteListed(address _wallet) {
        require(whiteList.isWhiteListed(_wallet));
        _;
    }

    function WhiteListable() public {
        whiteList = new WhiteList();
    }
}



contract CrowdSale is Pausable, WhiteListable {

  using SafeMath for uint256;

  uint256 constant public decimals = 18;
  uint256 constant public RESERVED_TOKENS_FOUNDERS = 33e5 * (10 ** decimals);
  uint256 constant public RESERVED_TOKENS_OPERATIONAL_EXPENSES = 2e5 * (10 ** decimals);
  uint256 constant public HARDCAP_TOKENS_PRE_ICO = 2e6 * (10 ** decimals);  //5e27
  uint256 constant public HARDCAP_TOKENS_ICO = 6e6 * (10 ** decimals); //1e8 * (10 ** DECIMALS)

  uint256 public minCap; //in tokens

  uint256 public startPreICO;
  uint256 public endPreICO;
  uint256 public startICO;
  uint256 public endICO;

  uint256 public PreICORate;
  uint256 public ICORate;
  uint256 public TokenSoldPreICO; //Token
  uint256 public TokenSoldICO; //Token

  uint256 public weiRaisedPreICO; //Ether
  uint256 public weiRaisedICO; //Ether

  uint256 public period1 = 12 * 60 * 60;
  uint256 public period2 = 1 * 24 * 60 * 60;
  uint256 public period3 = 3 * 24 * 60 * 60;
  uint256 public period4 = 4 * 24 * 60 * 60;

  uint256 public tokensRemindingICO = HARDCAP_TOKENS_PRE_ICO.add(HARDCAP_TOKENS_ICO);

  mapping(address => uint256) private investorsPreICO;
  address private withdrawWallet;
  /* address[] private investorsICO; */

  SimpleToken public token = new SimpleToken(this);

  function CrowdSale(uint256 _startPreICO,
                     uint256 _endPreICO,
                     uint256 _startICO,
                     uint256 _endICO,
                     uint256 _PreICORate,
                     uint256 _ICORate,
                     uint256 _minCap,
                     address _founders,
                     address _operational,
                     address _withdrawWallet
                     ) WhiteListable() public {
    require(_founders != address(0x0) && _operational != address(0x0) && _withdrawWallet != address(0x0));
    require(_endPreICO > _startPreICO && _startPreICO > now);
    require(_endICO > _startICO && _startICO > _endPreICO && _startICO > now );
    require(_PreICORate > 0 && _ICORate > 0);

    startPreICO = _startPreICO;
    endPreICO = _endPreICO;
    startICO = _startICO;
    endICO = _endICO;
    PreICORate = _PreICORate;
    ICORate = _ICORate;
    minCap = _minCap;
    withdrawWallet = _withdrawWallet;

    token.transferFromICO(_founders, RESERVED_TOKENS_FOUNDERS);
    token.transferFromICO(_operational, RESERVED_TOKENS_OPERATIONAL_EXPENSES);
    token.transferOwnership(msg.sender);
  }

  modifier whenICOSaleHasEnded() {
    require(now > endICO);
    _;
  }

  modifier whenPreICOSaleHasEnded() {
    require(now > endPreICO);
    _;
  }

  function isPreICO() public constant returns(bool) {
    return now >= startPreICO && now <= endPreICO;
  }

  function isICO() public constant returns(bool) {
    return now >= startICO && now <= endICO;
  }

  function minCapReached() public constant returns(bool) {
    return TokenSoldPreICO >= minCap;
  }

  function setWithdrawWallet(address _withdrawWallet) onlyOwner public {
    require(_withdrawWallet != address(0x0));
    withdrawWallet = _withdrawWallet;
  }

  function setStartPreICO(uint256 _startPreICO) onlyOwner public {
    require(_startPreICO > now);
    startPreICO = _startPreICO;
  }

  function setEndPreICO(uint256 _endPreICO) onlyOwner public {
    require(_endPreICO > now && _endPreICO > startPreICO);
    endPreICO = _endPreICO;
  }

  function setStartICO(uint256 _startICO) onlyOwner public {
    require(_startICO > now);
    startICO = _startICO;
  }

  function setEndICO(uint256 _endICO) onlyOwner public {
    require(_endICO > now && _endICO > startICO);
    endICO = _endICO;
  }

  function setPreICORate(uint256 _PreICORate) onlyOwner public {
    require(_PreICORate > 0);
    PreICORate = _PreICORate;
  }

  function setICORate(uint256 _ICORate) onlyOwner public {
    require(_ICORate > 0);
    ICORate = _ICORate;
  }

  function () public payable {
    if(isPreICO()) {
      saleTokenPreICO();
    } else if (isICO()) {
      saleTokenICO();
    } else {
      revert();
    }
  }

  function getBonusByTime() private returns(uint256) {
    if(now >= startICO && now <= startICO.add(period1)) {
      return 15;
    }
    if(now >= startICO && now <= startICO.add(period2)) {
      return 10;
    }
    if(now >= startICO && now <= startICO.add(period3)) {
      return 7;
    }
    if(now >= startICO && now <= startICO.add(period4)) {
      return 5;
    }
    return 0;
  }

  function getBonusByAmount(uint256 _amount) private returns(uint256) {
    if(_amount >= 200 * 1e18) {   //10e18
      return _amount.mul(ICORate).mul(110).div(100);
    }
    if(_amount >= 50 * 1e18) {   //5e18
      return _amount.mul(ICORate).mul(107).div(100);
    }
    if(_amount >= 20 * 1e18) {   //5e18
      return _amount.mul(ICORate).mul(105).div(100);
    }
    if(_amount >= 5 * 1e18) {   //5e18
      return _amount.mul(ICORate).mul(103).div(100);
    }
    return _amount.mul(ICORate);
  }

  function saleTokenPreICO() public payable whenNotPaused whenWhiteListed(msg.sender) {
    require(isPreICO());
    require(msg.value > 0);
    uint256 weiAmount = msg.value;
    weiRaisedPreICO = weiRaisedPreICO.add(weiAmount);
    addInvestmentPreICO(msg.sender, weiAmount);
    uint256 tokenAmountByTime = weiAmount.mul(PreICORate).mul(100 + getBonusByTime()).div(100);
    uint256 tokenAmountByAmount = getBonusByAmount(weiAmount);
    uint256 tokenAmount = tokenAmountByTime.add(tokenAmountByAmount);
    TokenSoldPreICO = TokenSoldPreICO.add(tokenAmount);
    if(TokenSoldPreICO > HARDCAP_TOKENS_PRE_ICO)
      revert();
    tokensRemindingICO = tokensRemindingICO.sub(tokenAmount);
    token.transferFromICO(msg.sender, tokenAmount);
  }

  function saleTokenICO() public payable whenNotPaused whenWhiteListed(msg.sender) {
    require(minCapReached());
    require(isICO());
    require(msg.value > 0);
    uint256 weiAmount = msg.value;
    weiRaisedICO = weiRaisedICO.add(weiAmount);
    /* addInvestmentICO(msg.sender, weiAmount); */
    uint256 tokenAmount = weiAmount.mul(ICORate);
    token.transferFromICO(msg.sender, tokenAmount);
    TokenSoldICO = TokenSoldICO.add(tokenAmount);
    tokensRemindingICO = tokensRemindingICO.sub(tokenAmount);
    withdrawWallet.transfer(weiAmount); //transfer money imideatelly
  }

  function addInvestmentPreICO(address _from, uint256 _value) internal {
    // if(investorsPreICO[_from] == 0){
    //   investorsPreICO.push(_from);
    // }
    investorsPreICO[_from] = investorsPreICO[_from].add(_value);
  }

  function burnUnsoldTokens() whenICOSaleHasEnded onlyOwner public {
    token.burnFromICO();
    tokensRemindingICO = 0;
  }

  function withdrawPreICO() onlyOwner whenPreICOSaleHasEnded external {
    require(minCapReached());
    withdrawWallet.transfer(weiRaisedPreICO);
  }

  function refund() whenPreICOSaleHasEnded external {
    require(!minCapReached());
    require(investorsPreICO[msg.sender] > 0);
    uint256 weiAmount = investorsPreICO[msg.sender];
    uint256 tokenAmount = token.balanceOf(msg.sender);
    investorsPreICO[msg.sender] = investorsPreICO[msg.sender].sub(weiAmount);
    token.burnFrom(msg.sender, tokenAmount);
    msg.sender.transfer(weiAmount);
  }

  //referal bonuses (123123123) 2% 3%
  function manualTransferToken(address _to, uint256 _amount) onlyOwner external {
    require(_to != address(0x0));
    tokensRemindingICO = tokensRemindingICO.sub(_amount);
    token.transferFromICO(_to, _amount);
  }


}

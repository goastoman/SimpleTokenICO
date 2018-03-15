pragma solidity ^0.4.18;



import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';
import "./SimpleToken.sol";
import "./WhiteListable.sol";
import "zeppelin-solidity/contracts/lifecycle/Pausable.sol";



contract CrowdSale is Pausable, WhiteListable {

  using SafeMath for uint256;

  uint256 constant public decimals = 18;
  uint256 constant public RESERVED_TOKENS_FOUNDERS = 23e6 * (10 ** decimals);
  uint256 constant public RESERVED_TOKENS_OPERATIONAL_EXPENSES = 2e6 * (10 ** decimals);
  uint256 constant public HARDCAP_TOKENS_PRE_ICO = 5e6 * (10 ** decimals);  //5e27
  uint256 constant public HARDCAP_TOKENS_ICO = 70e6 * (10 ** decimals); //1e8 * (10 ** DECIMALS)

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
    whiteList.transferOwnership(msg.sender);
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
    /* addInvestmentICO(msg.sender, weiAmount); */    //=========================================>  ругается
    uint256 tokenAmount = weiAmount.mul(ICORate);
    token.transferFromICO(msg.sender, tokenAmount);
    TokenSoldICO = TokenSoldICO.add(tokenAmount);
    tokensRemindingICO = tokensRemindingICO.sub(tokenAmount);
    withdrawWallet.transfer(weiAmount); //transfer money imideatelly
  }

  function addInvestmentPreICO(address _from, uint256 _value) internal {
    // if(investorsPreICO[_from] == 0){     //=========================================>  ругается
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








//

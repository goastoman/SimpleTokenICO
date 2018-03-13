pragma solidity ^0.4.18;


import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol";
import "zeppelin-solidity/contracts/lifecycle/Pausable.sol";



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

  function transfer(address _to, uint256 _value) public whenNotPaused returns(bool) {
    require(_to != address(0x0));
    require(_value <= balances[msg.sender]);
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns(bool) {
    require(_from != address(0x0));
    require(_to != address(0x0));
    return super.transferFrom(_from, _to, _value);
  }

  function transferFromICO(address _to, uint256 _value) public onlyICO returns(bool) {
    require(_to != address(0x0));
    return super.transfer(_to, _value);
  }

  function burnFromICO() public onlyICO {
    uint256 remindingTokens = balanceOf(addressICO);
    balances[addressICO] = balances[addressICO].sub(remindingTokens);
    totalSupply_ = totalSupply_.sub(remindingTokens);
    Burn(addressICO, remindingTokens);
  }

  function burnFrom(address _from, uint256 _value) public {
    require(_value <= balances[msg.sender]);
    require(_from != address(0x0));
    require(msg.sender == addressICO || msg.sender == owner);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_from] = balances[_from].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    Burn(_from, _value);
    Transfer(_from, address(0), _value); 
  }

}







//

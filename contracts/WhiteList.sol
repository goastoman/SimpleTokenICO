pragma solidity ^0.4.18;



import "zeppelin-solidity/contracts/ownership/Ownable.sol";



contract WhiteList is Ownable {
/*
  using SafeMath for uint256; */

  mapping(address => uint256) public list;
  uint256 public whiteListLength = 0;

  function addWallet(address _wallet, uint256 _type) onlyOwner public {
    require(_type > 0 && _type < 4);
    require(_wallet != address(0x0));
    require(!isWhiteListed(_wallet));

    list[_wallet] = _type;
    whiteListLength++;
  }

  // 0 - deleted
  // 1 - type 1 25%
  // 2 - type 2 20%
  // 3 - type 3 0%

  function deleteWallet(address _wallet) onlyOwner public {
    require(_wallet != address(0x0));
    require(isWhiteListed(_wallet));

    list[_wallet] = 0;
    whiteListLength--;
  }

  function isWhiteListed(address _wallet) view public returns(bool) {
    return list[_wallet] > 0;
  }
}















//

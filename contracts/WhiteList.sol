pragma solidity ^0.4.18;



import "zeppelin-solidity/contracts/ownership/Ownable.sol";



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















//

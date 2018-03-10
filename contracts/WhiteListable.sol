pragma solidity ^0.4.18;



import "./WhiteList.sol";



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

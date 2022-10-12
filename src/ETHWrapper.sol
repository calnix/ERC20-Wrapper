// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "yield-utils-v2/contracts/mocks/ERC20Mock.sol";

/**
@title An ETH to ERC20 Token wrapper (e.g. ETH -> WETH)
@author Calnix
@dev Users can send ETH and exchange them for wrapped ERC20 tokens.
@notice Wrapped tokens will be burned to withdraw the deposited tokens.
*/

contract ETHWrapper is ERC20Mock {

    ///@notice Emit event when ETH is wrapped
    event Wrap(address indexed from, uint amount);
    
    ///@notice Emit event when ETH is unwrapped
    event Unwrap(address indexed from, uint amount);


    ///@notice Creates a new wrapper token taking in ETH (e.g. ETH -> WETH)
    ///@dev Token will have 18 decimal places as ERC20Mock inherits from ERC20Permit
    ///@param tokenName Name of ERC20 wrapper token
    ///@param tokenSymbol Symbol of ERC20 wrapper token
    constructor(string memory tokenName, string memory tokenSymbol) ERC20Mock(tokenName, tokenSymbol) {}

    ///@dev User sends ETH for wrapped tokens
    receive() external payable {
        mint(msg.sender, msg.value);
        emit Wrap(msg.sender, msg.value);  
    }

    ///@dev User is returned ETH, wrapped tokens are burnt
    function unwrap(uint amount) public {
        burn(msg.sender, amount);

        (bool success, )= msg.sender.call{value: amount}("");
        require(success, "Unwrapping failed!");
        emit Unwrap(msg.sender, amount);
    }
}


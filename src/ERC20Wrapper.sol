// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "yield-utils-v2/contracts/mocks/ERC20Mock.sol";
import "yield-utils-v2/contracts/token/IERC20.sol";

/**
@title An ERC20 Token Wrapper
@author Calnix
@dev Contract allows users to exchange a pre-specified ERC20 token for some other wrapped ERC20 tokens.
@notice Wrapped tokens will be burned, when user withdraws their deposited tokens.
*/

contract ERC20Wrapper is ERC20Mock {

    ///@notice ERC20 interface specifying token contract functions
    ///@dev For constant variables, the value has to be fixed at compile-time, while for immutable, it can still be assigned at construction time.
    IERC20 public immutable token;    

    /// @notice Emit event when ERC20 tokens are deposited into wrapped contract
    event Wrap(address indexed from, uint amount);
    
    /// @notice Emit event when ERC20 tokens are withdrawn from wrapped contract
    event Unwrap(address indexed from, uint amount);

    ///@notice Creates a new wrapper token for a specified token 
    ///@dev Token will have 18 decimal places as ERC20Mock inherits from ERC20Permit
    ///@param token_ Address of specified ERC20 token contract referenced for wrapping (e.g. QTM)
    ///@param tokenName Name of ERC20 wrapper token 
    ///@param tokenSymbol Symbol of ERC20 wrapper token (e.g. wQTM)
    constructor(IERC20 token_, string memory tokenName, string memory tokenSymbol) ERC20Mock(tokenName, tokenSymbol) {
        token = token_;
    }

    /// @notice User to exchange base ERC20 tokens for wrapped tokens
    /// @dev Expect deposit to revert if transferFrom fails
    /// @param amount The amount of base tokens to exchange
    function wrap(uint amount) public {
        mint(msg.sender, amount);
        
        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "Wrapping failed!"); 

        emit Wrap(msg.sender, amount);   
    }

    /// @notice User burns wrapped ERC20 tokens, thereby receiving unwrapped ERC20 tokens.
    /// @dev Expect withdraw to revert if transfer fails
    /// @param amount The amount of ERC20 tokens to unwrap
    function unwrap(uint amount) public {
        burn(msg.sender, amount);
        
        bool success = token.transfer(msg.sender, amount);
        require(success, "Unwrapping failed!"); 

        emit Unwrap(msg.sender, amount);   
    }

}


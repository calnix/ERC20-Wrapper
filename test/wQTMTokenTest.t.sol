// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";

import 'src/QTMToken.sol';
import 'src/ERC20Wrapper.sol';

abstract contract StateQTMminted is Test {
        
    QTMToken qtm;
    ERC20Wrapper wqtm;
    address user;
    uint userTokens;

    event Wrap(address indexed from, uint amount);
    event Unwrap(address indexed from, uint amount);

    function setUp() public virtual {
        qtm = new QTMToken();
        wqtm = new ERC20Wrapper(qtm, "Wrapped QTM", "wQTM");

        user = address(1);
        vm.label(user, "user");

        userTokens = 100;
        qtm.mint(user, userTokens);
        vm.prank(user);
        qtm.approve(address(wqtm), userTokens);
    }
}

contract StateQTMmintedTest is StateQTMminted {
    
    function testWrapRevertsIfTransferFails() public {
        console2.log("Deposit should revert if transfer fails");
        qtm.setFailTransfers(true);

        vm.prank(user);
        vm.expectRevert("Wrapping failed!");
        wqtm.wrap(userTokens);
    }
   
    function testWrap() public {
        console2.log("User exchanges half of his QTM tokens for wQTM tokens");
        vm.prank(user);
        vm.expectEmit(true, false, false, true);
        emit Wrap(user, userTokens/2);
        wqtm.wrap(userTokens/2);
        assertTrue(qtm.balanceOf(user) == wqtm.balanceOf(user));
    }

}


abstract contract StateQTMWrapped is StateQTMminted {
    function setUp() public virtual override {
        super.setUp();

        vm.prank(user);
        wqtm.wrap(userTokens/2);
    }
}

contract StateQTMWrappedTest is StateQTMWrapped {
    
    function testUnwrapRevertsIfTransferFails() public {
        console2.log("Unwrap should revert if transfer fails");
        qtm.setFailTransfers(true);
        vm.prank(user);
        vm.expectRevert("Unwrapping failed!");
        wqtm.unwrap(userTokens/2);
    }

    function testCannotUnwrapExcessOfWrapped() public {
        console2.log("User should not be able to unwrap more than his quantity of wrapped tokens");
        vm.prank(user);
        vm.expectRevert("ERC20: Insufficient balance");
        wqtm.unwrap(userTokens * 2);
    }

    function testUnwrap(uint amount) public {
        console2.log("User should receive QTM tokens, and the corresponding amount of wQTM tokens should be burnt");
        vm.prank(user);
        vm.assume(amount < userTokens/2);
        vm.assume(amount > 0);

        vm.expectEmit(true, false, false, true);
        emit Unwrap(user, amount);
        wqtm.unwrap(amount);
        
        assertTrue(qtm.balanceOf(user) == (userTokens/2 + amount));
        assertTrue(wqtm.balanceOf(user) == (userTokens/2 - amount));
    }
}
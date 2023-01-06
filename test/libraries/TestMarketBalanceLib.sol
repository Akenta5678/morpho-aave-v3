// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

import {Types} from "../../src/libraries/Types.sol";
import {MarketBalanceLib} from "../../src/libraries/MarketBalanceLib.sol";
import {ThreeHeapOrdering} from "@morpho-data-structures/ThreeHeapOrdering.sol";

import {Test} from "@forge-std/Test.sol";

contract TestMarketLib is Test {
    using MarketBalanceLib for Types.MarketBalances;
    using ThreeHeapOrdering for ThreeHeapOrdering.HeapArray;

    Types.MarketBalances internal marketBalances;

    uint256 internal constant DEFAULT_MAX_SORTED_USERS = 20;

    function testScaledPoolSupplyBalance(address user, uint96 amount) public {
        vm.assume(user != address(0));
        assertEq(marketBalances.scaledPoolSupplyBalance(user), 0);

        marketBalances.poolSuppliers.update(user, 0, amount, DEFAULT_MAX_SORTED_USERS);

        assertEq(marketBalances.scaledPoolSupplyBalance(user), amount);
    }

    function testScaledPoolBorrowBalance(address user, uint96 amount) public {
        vm.assume(user != address(0));
        assertEq(marketBalances.scaledPoolBorrowBalance(user), 0);

        marketBalances.poolBorrowers.update(user, 0, amount, DEFAULT_MAX_SORTED_USERS);

        assertEq(marketBalances.scaledPoolBorrowBalance(user), amount);
    }

    function testScaledP2PSupplyBalance(address user, uint96 amount) public {
        vm.assume(user != address(0));
        assertEq(marketBalances.scaledP2PSupplyBalance(user), 0);

        marketBalances.p2pSuppliers.update(user, 0, amount, DEFAULT_MAX_SORTED_USERS);

        assertEq(marketBalances.scaledP2PSupplyBalance(user), amount);
    }

    function testScaledP2PBorrowBalance(address user, uint96 amount) public {
        vm.assume(user != address(0));
        assertEq(marketBalances.scaledP2PBorrowBalance(user), 0);

        marketBalances.p2pBorrowers.update(user, 0, amount, DEFAULT_MAX_SORTED_USERS);

        assertEq(marketBalances.scaledP2PBorrowBalance(user), amount);
    }

    function testScaledCollateralBalance(address user, uint256 amount) public {
        assertEq(marketBalances.scaledCollateralBalance(user), 0);

        marketBalances.collateral[user] = amount;

        assertEq(marketBalances.scaledCollateralBalance(user), amount);
    }
}
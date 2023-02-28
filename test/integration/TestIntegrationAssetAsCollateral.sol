// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {IMorpho} from "src/interfaces/IMorpho.sol";

import {Errors} from "src/libraries/Errors.sol";
import {UserConfiguration} from "@aave-v3-core/protocol/libraries/configuration/UserConfiguration.sol";

import {Morpho} from "src/Morpho.sol";

import "test/helpers/IntegrationTest.sol";

contract TestIntegrationAssetAsCollateral is IntegrationTest {
    using UserConfiguration for DataTypes.UserConfigurationMap;

    function setUp() public override {
        super.setUp();

        // Deposit LINK dust so that setting LINK as collateral does not revert on the pool.
        _deposit(link, 1e12, address(morpho));

        for (uint256 i; i < allUnderlyings.length; ++i) {
            morpho.setAssetIsCollateral(dai, false);
        }
    }

    function testSetAssetIsCollateralShouldRevertWhenMarketNotCreated(address underlying) public {
        vm.expectRevert(Errors.MarketNotCreated.selector);
        morpho.setAssetIsCollateral(underlying, true);
    }

    function testSetAssetIsCollateral() public {
        assertEq(morpho.market(dai).isCollateral, false);
        assertEq(_isUsingAsCollateral(dai), false);

        morpho.setAssetIsCollateral(dai, true);

        assertEq(morpho.market(dai).isCollateral, true);
        assertEq(_isUsingAsCollateral(dai), true);
    }

    function testSetAssetIsNotCollateral() public {
        vm.prank(address(morpho));
        pool.setUserUseReserveAsCollateral(dai, true);

        assertEq(morpho.market(dai).isCollateral, false);
        assertEq(_isUsingAsCollateral(dai), true);

        morpho.setAssetIsCollateral(dai, false);

        assertEq(morpho.market(dai).isCollateral, false);
        assertEq(_isUsingAsCollateral(dai), true);
    }

    function testSetAssetIsCollateralOnPoolShouldRevertWhenMarketIsNotCreated() public {
        assertEq(morpho.market(link).isCollateral, false);
        assertEq(pool.getUserConfiguration(address(morpho)).isUsingAsCollateral(pool.getReserveData(link).id), false);

        vm.expectRevert(Errors.MarketNotCreated.selector);
        morpho.setAssetIsCollateralOnPool(link, true);
    }

    function testSetAssetIsCollateralOnPoolWhenMarketIsCreatedAndIsCollateralOnMorphoAndOnPool() public {
        vm.prank(address(morpho));
        pool.setUserUseReserveAsCollateral(dai, true);
        morpho.setAssetIsCollateral(dai, true);

        assertEq(morpho.market(dai).isCollateral, true);
        assertEq(_isUsingAsCollateral(dai), true);

        morpho.setAssetIsCollateralOnPool(dai, true);

        assertEq(morpho.market(dai).isCollateral, true);
        assertEq(_isUsingAsCollateral(dai), true);
    }

    function testSetAssetIsCollateralOnPoolWhenMarketIsCreatedAndIsNotCollateralOnMorphoOnly() public {
        vm.prank(address(morpho));
        pool.setUserUseReserveAsCollateral(dai, true);

        assertEq(morpho.market(dai).isCollateral, false);
        assertEq(_isUsingAsCollateral(dai), true);

        morpho.setAssetIsCollateralOnPool(dai, true);

        assertEq(morpho.market(dai).isCollateral, false);
        assertEq(_isUsingAsCollateral(dai), true);
    }

    function testSetAssetIsCollateralOnPoolWhenMarketIsCreatedAndIsNotCollateral() public {
        assertEq(morpho.market(dai).isCollateral, false);
        assertEq(_isUsingAsCollateral(dai), false);

        morpho.setAssetIsCollateralOnPool(dai, true);

        assertEq(morpho.market(dai).isCollateral, false);
        assertEq(_isUsingAsCollateral(dai), true);
    }

    function testSetAssetIsNotCollateralOnPoolWhenMarketIsNotCreated() public {
        vm.prank(address(morpho));
        pool.setUserUseReserveAsCollateral(link, true);

        assertEq(morpho.market(link).isCollateral, false);
        assertEq(pool.getUserConfiguration(address(morpho)).isUsingAsCollateral(pool.getReserveData(link).id), true);

        morpho.setAssetIsCollateralOnPool(link, false);

        assertEq(morpho.market(link).isCollateral, false);
        assertEq(pool.getUserConfiguration(address(morpho)).isUsingAsCollateral(pool.getReserveData(link).id), false);
    }

    function testSetAssetIsNotCollateralOnPoolWhenMarketIsCreatedAndIsCollateralOnMorphoAndOnPool() public {
        vm.prank(address(morpho));
        pool.setUserUseReserveAsCollateral(dai, true);
        morpho.setAssetIsCollateral(dai, true);

        assertEq(morpho.market(dai).isCollateral, true);
        assertEq(_isUsingAsCollateral(dai), true);

        morpho.setAssetIsCollateralOnPool(dai, false);

        assertEq(morpho.market(dai).isCollateral, false);
        assertEq(_isUsingAsCollateral(dai), false);
    }

    function testSetAssetIsNotCollateralOnPoolWhenMarketIsCreatedAndIsNotCollateralOnMorphoOnly() public {
        vm.prank(address(morpho));
        pool.setUserUseReserveAsCollateral(dai, true);

        assertEq(morpho.market(dai).isCollateral, false);
        assertEq(_isUsingAsCollateral(dai), true);

        morpho.setAssetIsCollateralOnPool(dai, false);

        assertEq(morpho.market(dai).isCollateral, false);
        assertEq(_isUsingAsCollateral(dai), false);
    }

    function _isUsingAsCollateral(address underlying) internal view returns (bool) {
        return pool.getUserConfiguration(address(morpho)).isUsingAsCollateral(pool.getReserveData(underlying).id);
    }
}

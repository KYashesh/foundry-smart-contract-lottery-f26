// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig, CodeConstants} from "script/HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "script/Interactions.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract InteractionsTest is Test, CodeConstants {
    HelperConfig public helperConfig;
    HelperConfig.NetworkConfig public config;

    // Run tests only on local networks where mocks exist
    modifier skipFork() {
        if (block.chainid != LOCAL_CHAIN_ID) {
            return;
        }
        _;
    }

    function setUp() external {
        // Instantiate config to deploy local mocks and retrieve addresses
        helperConfig = new HelperConfig();
        config = helperConfig.getConfig();
    }

    /*//////////////////////////////////////////////////////////////
                       CREATE SUBSCRIPTION TESTS
    //////////////////////////////////////////////////////////////*/

    function testCreateSubscriptionUsingScript() public skipFork {
        // Arrange
        CreateSubscription createSubscription = new CreateSubscription();

        // Act: Programmatically trigger subscription creation via script
        (uint256 subId, address returnedCoordinator) = createSubscription
            .createSubscription(config.vrfCoordinator, config.account);

        // Assert: Verify coordinator matches and subscription ID was generated
        assertEq(returnedCoordinator, config.vrfCoordinator);
        assertGt(subId, 0);
    }

    /*//////////////////////////////////////////////////////////////
                        FUND SUBSCRIPTION TESTS
    //////////////////////////////////////////////////////////////*/

    function testFundSubscriptionUsingScript() public skipFork {
        // Arrange: Create a subscription first so we have a target ID
        CreateSubscription createSubscription = new CreateSubscription();
        (uint256 subId, ) = createSubscription.createSubscription(
            config.vrfCoordinator,
            config.account
        );

        // Act: Fund the created subscription using FundSubscription script
        FundSubscription fundSubscription = new FundSubscription();
        fundSubscription.fundSubscription(
            config.vrfCoordinator,
            subId,
            config.link,
            config.account
        );

        // Assert: Read subscription balance directly from Mock VRF Coordinator
        (uint96 balance, , , , ) = VRFCoordinatorV2_5Mock(config.vrfCoordinator)
            .getSubscription(subId);

        // 3 LINK is typically the default funding amount defined in Interactions.s.sol
        assertGt(balance, 0);
    }

    /*//////////////////////////////////////////////////////////////
                         ADD CONSUMER TESTS
    //////////////////////////////////////////////////////////////*/

    function testAddConsumerUsingScript() public skipFork {
        // Arrange: Create a subscription and deploy a mock consumer target
        CreateSubscription createSubscription = new CreateSubscription();
        (uint256 subId, ) = createSubscription.createSubscription(
            config.vrfCoordinator,
            config.account
        );

        // Target consumer address to register
        address consumerAddress = makeAddr("mockConsumer");

        // Act: Add target address as consumer via AddConsumer script
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            consumerAddress,
            config.vrfCoordinator,
            subId,
            config.account
        );

        // Assert: Verify mock coordinator recognizes target address as registered consumer
        bool isRegistered = VRFCoordinatorV2_5Mock(config.vrfCoordinator)
            .consumerIsAdded(subId, consumerAddress);

        assertTrue(isRegistered);
    }
}
